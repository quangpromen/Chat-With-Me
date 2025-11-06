import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/app_settings.dart';
import '../data/models/file_transfer.dart';
import '../data/models/peer.dart';
import '../data/models/room.dart';
import '../data/models/user_profile.dart';
import '../services/lan_discovery_service.dart';
import '../services/lan_chat_server.dart';
import 'package:chat_offline/core/file_service.dart';
import 'package:chat_offline/core/database_service.dart';

/// Logical permissions that the onboarding flow requests from the user.
enum AppPermission { network, storage, microphone }

/// Represents a single chat message within a room.
@immutable
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    required this.fromCurrentUser,
  });

  final String id;
  final String roomId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final bool fromCurrentUser;
}

/// Aggregate application state that powers the LAN chat experience.
@immutable
class AppState {
  const AppState({
    required this.onboardingComplete,
    required this.grantedPermissions,
    required this.profile,
    required this.isHosting,
    required this.rooms,
    required this.messagesByRoom,
    required this.peers,
    required this.settings,
    required this.transfers,
  });

  final bool onboardingComplete;
  final Set<AppPermission> grantedPermissions;
  final UserProfile? profile;
  final bool isHosting;
  final List<Room> rooms;
  final Map<String, List<ChatMessage>> messagesByRoom;
  final List<Peer> peers;
  final AppSettings settings;
  final List<FileTransfer> transfers;

  bool isPermissionGranted(AppPermission permission) =>
      grantedPermissions.contains(permission);

  bool get hasAllPermissions =>
      grantedPermissions.containsAll(AppPermission.values);

  List<ChatMessage> messagesForRoom(String roomId) =>
      messagesByRoom[roomId] ?? const [];

  UnmodifiableListView<Room> get roomList => UnmodifiableListView(rooms);
  UnmodifiableListView<Peer> get peerList => UnmodifiableListView(peers);
  UnmodifiableListView<FileTransfer> get transferList =>
      UnmodifiableListView(transfers);

  AppState copyWith({
    bool? onboardingComplete,
    Set<AppPermission>? grantedPermissions,
    UserProfile? profile,
    bool? isHosting,
    List<Room>? rooms,
    Map<String, List<ChatMessage>>? messagesByRoom,
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
      messagesByRoom: messagesByRoom ?? this.messagesByRoom,
      peers: peers ?? this.peers,
      settings: settings ?? this.settings,
      transfers: transfers ?? this.transfers,
    );
  }

  factory AppState.initial() {
    return const AppState(
      onboardingComplete: false,
      grantedPermissions: <AppPermission>{},
      profile: null,
      isHosting: false,
      rooms: <Room>[],
      messagesByRoom: <String, List<ChatMessage>>{},
      peers: <Peer>[],
      settings: AppSettings(
        themeMode: 'system',
        language: 'en',
        networkPref: 'auto',
        lastHostIp: null,
      ),
      transfers: <FileTransfer>[],
    );
  }
}

class AppNotifier extends Notifier<AppState> {
  Future<void> removeMemberFromRoom(String roomId, String member) async {
    final roomIndex = state.rooms.indexWhere((r) => r.id == roomId);
    if (roomIndex == -1) return;
    final oldRoom = state.rooms[roomIndex];
    final newMembers = List<String>.from(oldRoom.members)..remove(member);
    final updatedRoom = Room(
      id: oldRoom.id,
      name: oldRoom.name,
      createdAt: oldRoom.createdAt,
      hostId: oldRoom.hostId,
      members: newMembers,
    );
    final updatedRooms = List<Room>.from(state.rooms)
      ..[roomIndex] = updatedRoom;
    state = state.copyWith(rooms: updatedRooms);
    final database = ref.read(databaseServiceProvider);
    if (database.isAvailable) {
      await database.saveRoom(updatedRoom);
    }
    _syncServerState();
  }

  Future<void> deleteRoom(String roomId) async {
    final updatedRooms = List<Room>.from(state.rooms)
      ..removeWhere((r) => r.id == roomId);
    final updatedMessages = Map<String, List<ChatMessage>>.from(
      state.messagesByRoom,
    )..remove(roomId);
    state = state.copyWith(
      rooms: updatedRooms,
      messagesByRoom: updatedMessages,
    );
    final database = ref.read(databaseServiceProvider);
    if (database.isAvailable) {
      await database.deleteRoom(roomId);
    }
    _syncServerState();
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
    _loadFromDatabase();
    return AppState.initial();
  }

  Future<void> _loadFromDatabase() async {
    final database = ref.read(databaseServiceProvider);
    await database.initialize();
    if (!database.isAvailable) {
      return;
    }
    try {
      // Load permissions
      final loadedPerms = database.loadPermissions();
      if (loadedPerms.isNotEmpty) {
        state = state.copyWith(grantedPermissions: loadedPerms);
      }
      // Load rooms
      final rooms = await database.loadAllRooms();
      if (rooms.isNotEmpty) {
        state = state.copyWith(rooms: rooms);
      }
      // Load peers
      final peers = await database.loadAllPeers();
      if (peers.isNotEmpty) {
        state = state.copyWith(peers: peers);
      }
      // Load messages for each room
      final messagesByRoom = <String, List<ChatMessage>>{};
      for (final room in rooms) {
        final dbMessages = await database.loadMessagesForRoom(room.id);
        final chatMessages = dbMessages.map((m) {
          return ChatMessage(
            id: m.id.toString(),
            roomId: m.roomId,
            senderName: m.senderName,
            text: m.content,
            timestamp: m.timestamp,
            fromCurrentUser: m.fromSelf,
          );
        }).toList();
        if (chatMessages.isNotEmpty) {
          messagesByRoom[room.id] = chatMessages;
        }
      }
      if (messagesByRoom.isNotEmpty) {
        state = state.copyWith(messagesByRoom: messagesByRoom);
      }
    } catch (e) {
      debugPrint('Failed to load data from database: $e');
    }
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
      _serverSubscription = server.events.listen(_handleHostEvent);
    }

    _syncServerState();
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

  void _handleHostEvent(LanHostEvent event) {
    if (event is ClientCreateRoomEvent) {
      createRoom(event.roomName, createdByDisplayName: event.displayName);
    } else if (event is ClientSendMessageEvent) {
      sendMessage(
        event.roomId,
        event.text,
        fromCurrentUser: false,
        senderName: event.displayName,
      );
    }
  }

  void _syncServerState() {
    if (!state.isHosting) {
      return;
    }
    final server = ref.read(lanChatServerProvider);
    if (!server.isRunning) {
      return;
    }
    server.replaceState(
      rooms: state.rooms.map(_roomToJson).toList(growable: false),
      messages: _messagesSnapshot(),
    );
  }

  Map<String, List<Map<String, dynamic>>> _messagesSnapshot() {
    final result = <String, List<Map<String, dynamic>>>{};
    for (final entry in state.messagesByRoom.entries) {
      result[entry.key] = entry.value
          .map(_messageToJson)
          .toList(growable: false);
    }
    return result;
  }

  static Map<String, dynamic> _roomToJson(Room room) => <String, dynamic>{
    'id': room.id,
    'name': room.name,
    'createdAt': room.createdAt.toIso8601String(),
    'hostId': room.hostId,
    'members': List<String>.from(room.members),
  };

  static Map<String, dynamic> _messageToJson(ChatMessage message) =>
      <String, dynamic>{
        'id': message.id,
        'roomId': message.roomId,
        'senderName': message.senderName,
        'text': message.text,
        'timestamp': message.timestamp.toIso8601String(),
        'fromCurrentUser': message.fromCurrentUser,
      };

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

  Room? createRoom(
    String name, {
    String? createdByDisplayName,
    String? password,
    RoomAccessMethod accessMethod = RoomAccessMethod.open,
  }) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final hostDisplayName = state.profile?.displayName ?? 'You';
    final members = <String>{hostDisplayName};
    if (createdByDisplayName != null && createdByDisplayName.isNotEmpty) {
      members.add(createdByDisplayName);
    }

    final newRoom = Room(
      id: 'room-${DateTime.now().microsecondsSinceEpoch}',
      name: trimmed,
      createdAt: DateTime.now(),
      hostId: state.profile?.id,
      members: members.toList(growable: false),
      password: password,
      accessMethod: accessMethod,
    );

    final updatedRooms = List<Room>.from(state.rooms)..add(newRoom);
    final updatedMessages = Map<String, List<ChatMessage>>.from(
      state.messagesByRoom,
    )..putIfAbsent(newRoom.id, () => <ChatMessage>[]);

    state = state.copyWith(
      rooms: updatedRooms,
      messagesByRoom: updatedMessages,
    );

    // Save to database
    final database = ref.read(databaseServiceProvider);
    if (database.isAvailable) {
      unawaited(database.saveRoom(newRoom));
    }

    _syncServerState();
    if (state.isHosting) {
      final server = ref.read(lanChatServerProvider);
      if (server.isRunning) {
        server.broadcastRoom(_roomToJson(newRoom));
      }
    }
    return newRoom;
  }

  ChatMessage? sendMessage(
    String roomId,
    String text, {
    bool fromCurrentUser = true,
    String? senderName,
  }) {
    final content = text.trim();
    if (content.isEmpty) return null;

    if (!state.messagesByRoom.containsKey(roomId)) {
      return null;
    }

    final resolvedSender = fromCurrentUser
        ? state.profile?.displayName ?? 'You'
        : (senderName?.trim().isNotEmpty == true
              ? senderName!.trim()
              : 'Guest');

    final message = ChatMessage(
      id: 'msg-${DateTime.now().microsecondsSinceEpoch}',
      roomId: roomId,
      senderName: resolvedSender,
      text: content,
      timestamp: DateTime.now(),
      fromCurrentUser: fromCurrentUser,
    );

    final currentMessages = List<ChatMessage>.from(
      state.messagesByRoom[roomId] ?? <ChatMessage>[],
    )..add(message);

    final updatedMessages = Map<String, List<ChatMessage>>.from(
      state.messagesByRoom,
    )..[roomId] = currentMessages;

    state = state.copyWith(messagesByRoom: updatedMessages);

    _syncServerState();
    if (state.isHosting) {
      final server = ref.read(lanChatServerProvider);
      if (server.isRunning) {
        server.broadcastMessage(_messageToJson(message));
      }
    }

    return message;
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

final messagesByRoomProvider = Provider.family<List<ChatMessage>, String>(
  (ref, roomId) => ref.watch(
    appStateProvider.select((state) => state.messagesForRoom(roomId)),
  ),
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
