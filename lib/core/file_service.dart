import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/signaling_service.dart';
import '../data/models/file_transfer.dart';

const _kDefaultChunkSize = 32 * 1024; // 32 KB

class FileService {
  FileService(this._signaling) {
    _messageSubscription = _signaling.messages.listen(_handleInboundMessage);
  }

  final SignalingService _signaling;

  final Map<String, _OutgoingTransfer> _outgoing =
      <String, _OutgoingTransfer>{};
  final Map<String, _IncomingTransfer> _incoming =
      <String, _IncomingTransfer>{};

  final StreamController<FileTransferUpdate> _updatesController =
      StreamController<FileTransferUpdate>.broadcast();

  late final StreamSubscription<String> _messageSubscription;

  static final Random _random = Random();

  Stream<FileTransferUpdate> get updates => _updatesController.stream;

  Future<String> sendFile(
    String filePath, {
    int chunkSize = _kDefaultChunkSize,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('File not found', filePath);
    }

    final totalBytes = await file.length();
    final id = _generateTransferId();
    final outgoing = _OutgoingTransfer(
      id: id,
      file: file,
      filePath: filePath,
      fileName: _basename(filePath),
      totalBytes: totalBytes,
    );
    _outgoing[id] = outgoing;
    _emitUpdate(
      FileTransferUpdate(
        id: id,
        fileName: outgoing.fileName,
        filePath: outgoing.filePath,
        savedToPath: outgoing.filePath,
        bytesTransferred: 0,
        totalBytes: totalBytes,
        status: FileTransferStatus.offered,
        direction: FileTransferDirection.outgoing,
      ),
    );

    final offerPayload = <String, dynamic>{
      'type': 'file_offer',
      'id': id,
      'name': outgoing.fileName,
      'size': totalBytes,
      'relay': false,
    };

    await _signaling.sendString(jsonEncode(offerPayload));

    final raf = await file.open();
    try {
      while (_outgoing.containsKey(id)) {
        final chunk = await raf.read(chunkSize);
        if (chunk.isEmpty) {
          break;
        }

        final payload = <String, dynamic>{
          'type': 'file_chunk',
          'id': id,
          'data': base64Encode(chunk),
          'relay': false,
        };

        await _signaling.sendString(jsonEncode(payload));

        outgoing.bytesSent += chunk.length;
        _emitUpdate(
          FileTransferUpdate(
            id: id,
            fileName: outgoing.fileName,
            filePath: outgoing.filePath,
            savedToPath: outgoing.filePath,
            bytesTransferred: outgoing.bytesSent,
            totalBytes: outgoing.totalBytes,
            status: FileTransferStatus.inProgress,
            direction: FileTransferDirection.outgoing,
          ),
        );
      }
    } catch (err, stack) {
      if (kDebugMode) {
        debugPrint('Failed to send file chunk: $err');
        debugPrint('$stack');
      }
      _emitUpdate(
        FileTransferUpdate(
          id: id,
          fileName: outgoing.fileName,
          filePath: outgoing.filePath,
          savedToPath: outgoing.filePath,
          bytesTransferred: outgoing.bytesSent,
          totalBytes: outgoing.totalBytes,
          status: FileTransferStatus.failed,
          direction: FileTransferDirection.outgoing,
          errorDescription: '$err',
        ),
      );
      rethrow;
    } finally {
      await raf.close();
    }

    if (_outgoing.containsKey(id)) {
      await _signaling.sendString(
        jsonEncode(<String, dynamic>{
          'type': 'file_complete',
          'id': id,
          'relay': false,
        }),
      );
      _emitUpdate(
        FileTransferUpdate(
          id: id,
          fileName: outgoing.fileName,
          filePath: outgoing.filePath,
          savedToPath: outgoing.filePath,
          bytesTransferred: outgoing.totalBytes,
          totalBytes: outgoing.totalBytes,
          status: FileTransferStatus.completed,
          direction: FileTransferDirection.outgoing,
        ),
      );
    }

    _outgoing.remove(id);
    return id;
  }

  Future<void> cancelTransfer(String id) async {
    final outgoing = _outgoing.remove(id);
    if (outgoing != null) {
      _emitUpdate(
        FileTransferUpdate(
          id: id,
          fileName: outgoing.fileName,
          filePath: outgoing.filePath,
          savedToPath: outgoing.filePath,
          bytesTransferred: outgoing.bytesSent,
          totalBytes: outgoing.totalBytes,
          status: FileTransferStatus.canceled,
          direction: FileTransferDirection.outgoing,
        ),
      );
    }
    final incoming = _incoming.remove(id);
    await incoming?.dispose();
    if (incoming != null) {
      _emitUpdate(
        FileTransferUpdate(
          id: id,
          fileName: incoming.fileName,
          filePath: incoming.fileName,
          savedToPath: incoming.filePath,
          bytesTransferred: incoming.bytesReceived,
          totalBytes: incoming.totalBytes,
          status: FileTransferStatus.canceled,
          direction: FileTransferDirection.incoming,
        ),
      );
    }
  }

  Future<bool> verifyChecksum(String filePath) async {
    final file = File(filePath);
    return file.existsSync();
  }

  Future<void> dispose() async {
    _outgoing.clear();
    for (final transfer in _incoming.values) {
      await transfer.dispose();
    }
    _incoming.clear();
    await _messageSubscription.cancel();
    await _updatesController.close();
  }

  void _handleInboundMessage(String raw) {
    if (raw.isEmpty) return;
    Map<String, dynamic>? packet;
    try {
      packet = jsonDecode(raw) as Map<String, dynamic>;
    } catch (err) {
      if (kDebugMode) {
        debugPrint('Invalid signaling packet: $err');
      }
      return;
    }

    final type = packet['type'];
    if (type is! String || !type.startsWith('file_')) {
      return;
    }

    final id = packet['id'] as String?;
    if (id == null) return;

    if (_outgoing.containsKey(id) && packet['relay'] == true) {
      // Ignore echoed packets for the sender; progress already tracked.
      return;
    }

    if (_signaling.isServer && packet['relay'] != true) {
      final relay = Map<String, dynamic>.from(packet)..['relay'] = true;
      unawaited(_signaling.sendString(jsonEncode(relay)));
    }

    switch (type) {
      case 'file_offer':
        _handleOffer(packet);
        break;
      case 'file_chunk':
        _handleChunk(packet);
        break;
      case 'file_complete':
        _handleComplete(packet);
        break;
      case 'file_error':
        _handleError(packet);
        break;
    }
  }

  void _handleOffer(Map<String, dynamic> packet) {
    final id = packet['id'] as String;
    final name = (packet['name'] as String?) ?? 'incoming_$id';
    final total = (packet['size'] as num?)?.toInt() ?? 0;

    final incoming = _IncomingTransfer(
      id: id,
      fileName: name,
      totalBytes: total,
    );
    _incoming[id] = incoming;

    _emitUpdate(
      FileTransferUpdate(
        id: id,
        fileName: name,
        filePath: incoming.filePath,
        savedToPath: incoming.filePath,
        bytesTransferred: 0,
        totalBytes: total,
        status: FileTransferStatus.offered,
        direction: FileTransferDirection.incoming,
      ),
    );
  }

  void _handleChunk(Map<String, dynamic> packet) {
    final id = packet['id'] as String?;
    final data = packet['data'] as String?;
    if (id == null || data == null) return;

    final transfer = _incoming[id];
    if (transfer == null) {
      return;
    }

    try {
      final bytes = base64Decode(data);
      transfer.sink.add(bytes);
      transfer.bytesReceived += bytes.length;
      _emitUpdate(
        FileTransferUpdate(
          id: id,
          fileName: transfer.fileName,
          filePath: transfer.filePath,
          savedToPath: transfer.filePath,
          bytesTransferred: transfer.bytesReceived,
          totalBytes: transfer.totalBytes,
          status: FileTransferStatus.inProgress,
          direction: FileTransferDirection.incoming,
        ),
      );
    } catch (err) {
      if (kDebugMode) {
        debugPrint('Failed to process file chunk: $err');
      }
      _handleError(<String, dynamic>{'id': id, 'message': 'decode_error'});
    }
  }

  Future<void> _handleComplete(Map<String, dynamic> packet) async {
    final id = packet['id'] as String?;
    if (id == null) return;
    final transfer = _incoming.remove(id);
    if (transfer == null) {
      return;
    }
    await transfer.dispose();

    _emitUpdate(
      FileTransferUpdate(
        id: id,
        fileName: transfer.fileName,
        filePath: transfer.filePath,
        savedToPath: transfer.filePath,
        bytesTransferred: transfer.bytesReceived,
        totalBytes: transfer.totalBytes,
        status: FileTransferStatus.completed,
        direction: FileTransferDirection.incoming,
      ),
    );
  }

  void _handleError(Map<String, dynamic> packet) {
    final id = packet['id'] as String?;
    if (id == null) return;
    final message = packet['message'] as String? ?? 'transfer_error';
    _emitUpdate(
      FileTransferUpdate(
        id: id,
        fileName: 'transfer',
        filePath: '',
        savedToPath: null,
        bytesTransferred: 0,
        totalBytes: 0,
        status: FileTransferStatus.failed,
        direction: FileTransferDirection.incoming,
        errorDescription: message,
      ),
    );
  }

  void _emitUpdate(FileTransferUpdate update) {
    if (_updatesController.isClosed) return;
    try {
      _updatesController.add(update);
    } catch (err) {
      if (kDebugMode) {
        debugPrint('Failed to emit transfer update: $err');
      }
    }
  }

  static String _basename(String path) {
    final normalized = path.replaceAll('\\', '/');
    final index = normalized.lastIndexOf('/');
    return index == -1 ? normalized : normalized.substring(index + 1);
  }

  static String _generateTransferId() {
    final timestamp = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
    final randomPart = _random
        .nextInt(0xFFFFFFFF)
        .toRadixString(16)
        .padLeft(8, '0');
    return 'tx-$timestamp$randomPart';
  }
}

class FileTransferUpdate {
  FileTransferUpdate({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.savedToPath,
    required this.bytesTransferred,
    required this.totalBytes,
    required this.status,
    required this.direction,
    this.errorDescription,
  });

  final String id;
  final String fileName;
  final String filePath;
  final String? savedToPath;
  final int bytesTransferred;
  final int totalBytes;
  final FileTransferStatus status;
  final FileTransferDirection direction;
  final String? errorDescription;

  double get progress => totalBytes == 0 ? 0 : bytesTransferred / totalBytes;
}

class _OutgoingTransfer {
  _OutgoingTransfer({
    required this.id,
    required this.file,
    required this.filePath,
    required this.fileName,
    required this.totalBytes,
  });

  final String id;
  final File file;
  final String filePath;
  final String fileName;
  final int totalBytes;
  int bytesSent = 0;
}

class _IncomingTransfer {
  _IncomingTransfer._({
    required this.id,
    required this.fileName,
    required this.totalBytes,
    required this.filePath,
    required this.sink,
  });

  factory _IncomingTransfer({
    required String id,
    required String fileName,
    required int totalBytes,
  }) {
    final path = _buildIncomingPath(fileName);
    final sink = File(path).openWrite(mode: FileMode.write);
    return _IncomingTransfer._(
      id: id,
      fileName: fileName,
      totalBytes: totalBytes,
      filePath: path,
      sink: sink,
    );
  }

  final String id;
  final String fileName;
  final int totalBytes;
  final String filePath;
  final IOSink sink;
  int bytesReceived = 0;

  Future<void> dispose() async {
    await sink.flush();
    await sink.close();
  }

  static String _buildIncomingPath(String fileName) {
    final safeName = fileName.replaceAll(RegExp(r'[\\/:]'), '_');
    final dir = Directory.systemTemp.createTempSync('chat_offline_');
    return '${dir.path}/$safeName';
  }
}

final fileServiceProvider = Provider<FileService>((ref) {
  final service = FileService(ref.read(signalingServiceProvider));
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});
