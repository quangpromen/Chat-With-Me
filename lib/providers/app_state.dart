import 'dart:async';
import 'dart:math';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/lan_chat_server.dart';
import '../services/lan_discovery_service.dart';
import '../core/database_service.dart';
import '../core/file_service.dart';
import '../chat_screen.dart';
import '../data/models/app_permission.dart';
import '../data/models/room.dart';
import '../data/models/user_profile.dart';
import '../data/models/app_settings.dart';
import '../data/models/peer.dart';
import '../data/models/file_transfer.dart';

final messagesByPeerProvider = Provider.family<List<ChatMessage>, String>(
  (ref, peerId) => ref.watch(
    appStateProvider.select((state) => state.messagesForPeer(peerId)),
  ),
);

// ================== APP STATE MODEL ==================
class AppState {
  final bool onboardingComplete;
  final Set<AppPermission> grantedPermissions;
  final UserProfile? profile;
  final bool isHosting;
  final List<Room> rooms;
  final Map<String, List<ChatMessage>> messagesByPeer;
  final List<Peer> peers;
  final AppSettings? settings;
  final List<FileTransfer> transfers;

  AppState({
    required this.onboardingComplete,
    required this.grantedPermissions,
    required this.profile,
    required this.isHosting,
    required this.rooms,
    required this.messagesByPeer,
    required this.peers,
    this.settings,
    this.transfers = const [],
  });

  AppState copyWith({
    bool? onboardingComplete,
    Set<AppPermission>? grantedPermissions,
    UserProfile? profile,
    bool? isHosting,
    List<Room>? rooms,
    Map<String, List<ChatMessage>>? messagesByPeer,
    List<Peer>? peers,
    AppSettings? settings,
    List<FileTransfer>? transfers,
  }) {
    return AppState(
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      grantedPermissions: grantedPermissions ?? this.grantedPermissions,
      profile: profile ?? this.profile,
      isHosting: isHosting ?? this.isHosting,
      rooms: rooms ?? this.rooms,
      messagesByPeer: messagesByPeer ?? this.messagesByPeer,
      peers: peers ?? this.peers,
      settings: settings ?? this.settings,
      transfers: transfers ?? this.transfers,
    );
  }

  static AppState initial() {
    return AppState(
      onboardingComplete: false,
      grantedPermissions: <AppPermission>{},
      profile: null,
      isHosting: false,
      rooms: <Room>[],
      messagesByPeer: <String, List<ChatMessage>>{},
      peers: <Peer>[],
      settings: const AppSettings(
        themeMode: 'system',
        language: 'en',
        networkPref: 'auto',
        lastHostIp: null,
      ),
      transfers: <FileTransfer>[],
    );
  }

  // Helper getters for providers
  UnmodifiableListView<Room> get roomList => UnmodifiableListView(rooms);
  UnmodifiableListView<Peer> get peerList => UnmodifiableListView(peers);
  UnmodifiableListView<FileTransfer> get transferList =>
      UnmodifiableListView(transfers);
  List<ChatMessage> messagesForPeer(String peerId) =>
      messagesByPeer[peerId] ?? <ChatMessage>[];

  bool get hasAllPermissions =>
      grantedPermissions.length == AppPermission.values.length;
}

// ================== APP STATE MODEL ==================

class AppNotifier extends Notifier<AppState> {
  ChatMessage? sendMessageToPeer(
    String peerId,
    String peerIp,
    String text, {
    bool fromCurrentUser = true,
    String? senderName,
  }) {
    final content = text.trim();
    if (content.isEmpty) return null;

    final currentMessages = List<ChatMessage>.from(
      state.messagesByPeer[peerId] ?? <ChatMessage>[],
    );

    final resolvedSender = fromCurrentUser
        ? state.profile?.displayName ?? 'You'
        : (senderName?.trim().isNotEmpty == true
              ? senderName!.trim()
              : 'Guest');

    final message = ChatMessage(
      sender: resolvedSender,
      text: content,
      time: DateTime.now(),
      isMe: fromCurrentUser,
    );

    currentMessages.add(message);
    final updatedMessages = Map<String, List<ChatMessage>>.from(
      state.messagesByPeer,
    );
    updatedMessages[peerId] = currentMessages;
    state = state.copyWith(messagesByPeer: updatedMessages);

    // TODO: gửi qua signalingService tới peerIp
    // ref.read(signalingServiceProvider).sendString(text);

    return message;
  }

  StreamSubscription<List<Peer>>? _peerSubscription;
  StreamSubscription<LanHostEvent>? _serverSubscription;
  StreamSubscription<FileTransferUpdate>? _fileTransferSubscription;
  bool _isStartingDiscovery = false;
  bool _isStartingServer = false;

  static final Random _random = Random();

  @override
  AppState build() {
    ref.onDispose(_dispose);
    _listenToFileTransfers();
    return AppState.initial();
  }

  void _dispose() {
    _peerSubscription?.cancel();
    _peerSubscription = null;
    _serverSubscription?.cancel();
    _serverSubscription = null;
    _fileTransferSubscription?.cancel();
    _fileTransferSubscription = null;
    _isStartingDiscovery = false;
    _isStartingServer = false;
    ref.read(lanDiscoveryServiceProvider).stop();
    unawaited(_tearDownServer());
  }

  void _listenToFileTransfers() {
    if (_fileTransferSubscription != null) {
      return;
    }
    final service = ref.read(fileServiceProvider);
    _fileTransferSubscription = service.updates.listen(
      _handleTransferUpdate,
      onError: (Object err, StackTrace stack) {
        debugPrint('File transfer stream error: $err');
        debugPrint('$stack');
      },
    );
  }

  void _handleTransferUpdate(FileTransferUpdate update) {
    final transfers = List<FileTransfer>.from(state.transfers);
    final index = transfers.indexWhere((t) => t.id == update.id);
    final mapped = FileTransfer(
      id: update.id,
      fileName: update.fileName,
      filePath: update.filePath,
      savedToPath: update.savedToPath,
      bytesTransferred: update.bytesTransferred,
      totalBytes: update.totalBytes,
      status: update.status,
      direction: update.direction,
      errorDescription: update.errorDescription,
    );
    if (index == -1) {
      transfers.add(mapped);
    } else {
      transfers[index] = mapped;
    }
    state = state.copyWith(transfers: transfers);
  }

  bool get _hasNetworkPermission =>
      state.grantedPermissions.contains(AppPermission.network);

  Future<void> ensureDiscoveryRunning() async {
    if (!_hasNetworkPermission) {
      return;
    }
    final profile = state.profile;
    if (profile == null) {
      return;
    }
    if (_peerSubscription != null || _isStartingDiscovery) {
      ref
          .read(lanDiscoveryServiceProvider)
          .updateIdentity(displayName: profile.displayName);
      return;
    }

    _isStartingDiscovery = true;
    final service = ref.read(lanDiscoveryServiceProvider);
    try {
      await service.start(
        deviceId: profile.deviceId,
        displayName: profile.displayName,
      );
      _peerSubscription = service.peersStream.listen(
        (peers) {
          state = state.copyWith(peers: peers);
          // Save peers to database
          final database = ref.read(databaseServiceProvider);
          if (database.isAvailable) {
            for (final peer in peers) {
              unawaited(database.savePeer(peer));
            }
          }
        },
        onError: (_, __) {
          _peerSubscription?.cancel();
          _peerSubscription = null;
        },
      );
    } finally {
      _isStartingDiscovery = false;
    }
  }

  void _tearDownDiscovery() {
    _peerSubscription?.cancel();
    _peerSubscription = null;
    _isStartingDiscovery = false;
    final service = ref.read(lanDiscoveryServiceProvider);
    service.stop();
    if (state.peers.isNotEmpty) {
      state = state.copyWith(peers: const <Peer>[]);
    }
  }

  Future<void> ensureHostingServer() async {
    if (!state.isHosting || !_hasNetworkPermission) {
      return;
    }
    final profile = state.profile;
    if (profile == null) {
      return;
    }

    final server = ref.read(lanChatServerProvider);
    if (_isStartingServer) {
      return;
    }

    if (!server.isRunning) {
      _isStartingServer = true;
      try {
        await server.start(deviceId: profile.deviceId);
      } finally {
        _isStartingServer = false;
      }
    }

    ref
        .read(lanDiscoveryServiceProvider)
        .setHostingStatus(isHosting: true, port: server.port);
  }

  Future<void> _tearDownServer() async {
    _serverSubscription?.cancel();
    _serverSubscription = null;
    _isStartingServer = false;
    final server = ref.read(lanChatServerProvider);
    if (server.isRunning) {
      await server.stop();
    }
    ref
        .read(lanDiscoveryServiceProvider)
        .setHostingStatus(isHosting: false, port: null);
  }

  static String _generateDeviceId() {
    final timestamp = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
    final randomSegment = _random
        .nextInt(0xFFFFFFFF)
        .toRadixString(16)
        .padLeft(8, '0');
    return 'dev-$timestamp$randomSegment';
  }

  void completeOnboarding() {
    if (!state.onboardingComplete) {
      state = state.copyWith(onboardingComplete: true);
    }
  }

  void setPermission(AppPermission permission, bool granted) {
    final updated = Set<AppPermission>.from(state.grantedPermissions);
    if (granted) {
      updated.add(permission);
    } else {
      updated.remove(permission);
    }
    state = state.copyWith(grantedPermissions: updated);
    // Save permissions to Hive
    final database = ref.read(databaseServiceProvider);
    if (database.isAvailable) {
      unawaited(database.savePermissions(updated));
    }

    if (permission == AppPermission.network) {
      if (granted) {
        unawaited(ensureDiscoveryRunning());
        if (state.isHosting) {
          unawaited(ensureHostingServer());
        }
      } else {
        _tearDownDiscovery();
        unawaited(_tearDownServer());
        if (state.isHosting) {
          state = state.copyWith(isHosting: false);
        }
      }
    }
  }

  void saveProfile(String displayName, {String? avatarPath}) {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) {
      return;
    }
    final existing = state.profile;
    final profile = UserProfile(
      id: existing?.id ?? 'self',
      displayName: trimmed,
      avatarPath: avatarPath ?? existing?.avatarPath,
      deviceId: existing?.deviceId ?? _generateDeviceId(),
      pubKey: existing?.pubKey,
      privKey: existing?.privKey,
    );
    state = state.copyWith(profile: profile);

    ref
        .read(lanDiscoveryServiceProvider)
        .updateIdentity(displayName: profile.displayName);
    unawaited(ensureDiscoveryRunning());
    if (state.isHosting) {
      unawaited(ensureHostingServer());
    }
  }

  void startHosting() {
    if (state.profile == null || !_hasNetworkPermission) {
      return;
    }
    if (!state.isHosting) {
      state = state.copyWith(isHosting: true);
    }
    unawaited(ensureHostingServer());
  }

  void stopHosting() {
    if (state.isHosting) {
      state = state.copyWith(isHosting: false);
    }
    unawaited(_tearDownServer());
  }
}

final appStateProvider = NotifierProvider<AppNotifier, AppState>(
  AppNotifier.new,
);

final roomsProvider = Provider<UnmodifiableListView<Room>>(
  (ref) => ref.watch(appStateProvider.select((state) => state.roomList)),
);

final peersProvider = Provider<UnmodifiableListView<Peer>>(
  (ref) => ref.watch(appStateProvider.select((state) => state.peerList)),
);

final transfersProvider = Provider<UnmodifiableListView<FileTransfer>>(
  (ref) => ref.watch(appStateProvider.select((state) => state.transferList)),
);

final permissionsProvider = Provider<Set<AppPermission>>(
  (ref) =>
      ref.watch(appStateProvider.select((state) => state.grantedPermissions)),
);

final lanChatServerProvider = Provider<LanChatServer>((ref) {
  final server = LanChatServer();
  ref.onDispose(server.dispose);
  return server;
});

final lanDiscoveryServiceProvider = Provider<LanDiscoveryService>((ref) {
  final service = LanDiscoveryService();
  ref.onDispose(service.dispose);
  return service;
});

final roomByIdProvider = Provider.family<Room?, String>((ref, roomId) {
  final rooms = ref.watch(roomsProvider);
  for (final room in rooms) {
    if (room.id == roomId) {
      return room;
    }
  }
  return null;
});
