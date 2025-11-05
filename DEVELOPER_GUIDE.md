# 👨‍💻 Hướng Dẫn Lập Trình & Phát Triển LanChat

Hướng dẫn này dành cho nhà phát triển muốn hiểu và mở rộng ứng dụng LanChat.

---

## 📋 Mục Lục

1. [Kiến Trúc Ứng Dụng](#kiến-trúc-ứng-dụng)
2. [Setup Môi Trường](#setup-môi-trường)
3. [Cấu Trúc Thư Mục](#cấu-trúc-thư-mục)
4. [Core Services](#core-services)
5. [API Documentation](#api-documentation)
6. [Quy Trình Phát Triển](#quy-trình-phát-triển)
7. [Testing](#testing)
8. [Deployment](#deployment)

---

## 🏗️ Kiến Trúc Ứng Dụng

### Layers (Tầng Ứng Dụng)

```
┌─────────────────────────────────────┐
│         UI Layer (Screens)          │
│   Flutter Widgets & GoRouter        │
├─────────────────────────────────────┤
│      State Management (Riverpod)    │
│   AppState, Providers               │
├─────────────────────────────────────┤
│        Services Layer (Core)        │
│ Discovery, Signaling, Chat,         │
│ File Transfer, Encryption           │
├─────────────────────────────────────┤
│       Network Layer (Socket)        │
│  UDP Broadcast, TCP Sockets         │
├─────────────────────────────────────┤
│    Database Layer (Hive Storage)    │
│   Messages, Peers, Rooms (persistent)
├─────────────────────────────────────┤
│      Crypto Layer (Encryption)      │
│   AES-256, SHA-256, HMAC            │
└─────────────────────────────────────┘
```

### Flow Diagram

```
User Action (UI)
     ↓
Provider (Riverpod State)
     ↓
Service Layer
     ├→ DiscoveryService (UDP)
     ├→ SignalingService (TCP)
     ├→ ChatService (Protocol)
     ├→ FileService (File Transfer)
     └→ EncryptionService (E2EE)
     ↓
Network (Socket Communication)
     ↓
Database (Hive - Persistent Storage)
     ↓
UI Update (Reactive)
```

---

## 🔧 Setup Môi Trường

### Yêu Cầu

```bash
# Dart/Flutter SDK
flutter --version
# Kiểm tra: Flutter 3.9.2+

# IDE
- Android Studio / IntelliJ IDEA
- Visual Studio Code
- Xcode (macOS)

# Emulator
- Android Emulator (API 21+)
- iOS Simulator (macOS)
```

### Cài Đặt

```bash
# Clone repo
git clone <repository>
cd chat_offline

# Cài dependencies
flutter pub get

# Generate code (Hive adapters)
flutter pub run build_runner build --delete-conflicting-outputs

# Chạy tests
flutter test

# Chạy app
flutter run
```

---

## 📁 Cấu Trúc Thư Mục

```
lib/
├── main.dart                          # Entrypoint, Router setup
├── core/                              # Core services
│   ├── discovery_service.dart        # UDP peer discovery
│   ├── signaling_service.dart        # TCP connection management
│   ├── chat_service.dart             # Chat protocol, message handling
│   ├── file_service.dart             # File transfer protocol
│   ├── encryption_service.dart       # AES-256 encryption
│   ├── database_service.dart         # Hive database persistence
│   └── notification_service.dart     # User notifications
├── data/
│   └── models/
│       ├── message.dart              # @HiveType Message model
│       ├── peer_db.dart              # @HiveType Peer database model
│       ├── room_db.dart              # @HiveType Room database model
│       ├── peer.dart                 # Runtime Peer model
│       └── room.dart                 # Runtime Room model
├── providers/
│   └── app_state.dart                # Riverpod state management
├── screens/                          # UI Screens
│   ├── onboarding_screen.dart
│   ├── discovery_screen.dart
│   ├── rooms_screen.dart
│   ├── chat_screen.dart
│   ├── settings_screen.dart
│   └── ... (other screens)
├── widgets/                          # Reusable components
│   └── (custom widgets)
└── services/                         # Additional services
    └── (notification, logging, etc)

test/
└── widget_test.dart                  # Widget tests

android/
├── app/build.gradle.kts              # Android build config
└── ... (Android native files)

ios/
├── Runner.xcodeproj
└── ... (iOS native files)

web/
└── ... (Web files)

pubspec.yaml                          # Dependencies & metadata
analysis_options.yaml                 # Lint rules
```

---

## 🔌 Core Services

### 1. DiscoveryService

**Mục đích**: Tìm kiếm các peer khác trên mạng LAN

```dart
final discoveryService = DiscoveryService();

// Bắt đầu khám phá
await discoveryService.startDiscovery();

// Lắng nghe cập nhật
discoveryService.stream.listen((peers) {
  print('Found peers: $peers');
});

// Dừng khám phá
await discoveryService.stopDiscovery();
```

**Kỹ Thuật**:
- UDP broadcast trên port 5555
- Gửi beacon mỗi 2 giây
- TTL: 1 (chỉ LAN cục bộ)
- Timeout: 10 giây để xóa peer cũ

---

### 2. SignalingService

**Mục đích**: Quản lý kết nối TCP và signaling

```dart
final signalingService = SignalingService();

// Kết nối đến peer
await signalingService.connectToHost(hostIp, port);

// Gửi signaling message
await signalingService.sendSignalingMessage({
  'type': 'chat',
  'content': 'Hello!'
});

// Lắng nghe tin nhắn
signalingService.messageStream.listen((message) {
  print('Received: $message');
});
```

**Features**:
- TCP socket connection
- Retry với exponential backoff (1s, 2s, 4s, ..., max 16s)
- Automatic reconnection
- Connection pooling

---

### 3. ChatService

**Mục đích**: Xử lý giao thức chat, lưu trữ tin nhắn

```dart
final chatService = ChatService();

// Gửi tin nhắn
await chatService.sendMessage(
  roomId: 'room123',
  content: 'Hello everyone!',
  senderName: 'Alice'
);

// Lắng nghe tin nhắn mới
chatService.messageStream.listen((message) {
  print('New message: ${message.content}');
  // Tự động lưu vào database
});

// Load tin nhắn từ phòng
final messages = await chatService.getMessagesForRoom('room123');

// Phát lại tin nhắn nếu host
if (isHost) {
  await chatService.broadcastMessageToRoom('room123', message);
}
```

**Protocol**:
- JSON newline-delimited
- Format: `{"type": "msg", "content": "...", "timestamp": "..."}`
- Phát lại tự động khi host
- Stream per room

---

### 4. EncryptionService

**Mục đích**: Mã hóa và giải mã tin nhắn

```dart
final encService = EncryptionService();

// Generate key
final key = encService.generateKey();

// Mã hóa tin nhắn
final encrypted = encService.encrypt(
  plaintext: 'Secret message',
  password: 'user_password'
);

// Giải mã
final decrypted = encService.decrypt(
  ciphertext: encrypted,
  password: 'user_password'
);

// Hash
final hash = encService.hash('data');
```

**Thuật Toán**:
- AES-256-GCM cho encryption
- SHA-256 cho key derivation
- HMAC cho authentication
- Constant-time comparison để tránh timing attacks

---

### 5. DatabaseService

**Mục đích**: Lưu trữ persistent trên Hive

```dart
final dbService = DatabaseService();

// Initialize
await dbService.initialize();

// Save message
await dbService.saveMessage(message);

// Load messages
final messages = await dbService.loadMessagesForRoom('room123');

// Save peer
await dbService.savePeer(peer);

// Load all peers
final peers = await dbService.loadAllPeers();

// Save room
await dbService.saveRoom(room);

// Delete room
await dbService.deleteRoom('room123');
```

**Boxes**:
- `messages`: Lưu tin nhắn
- `peers`: Lưu danh sách bạn bè
- `rooms`: Lưu thông tin phòng
- Fallback: In-memory nếu Hive không khả dụng (web)

---

## 📚 API Documentation

### Message Protocol

**Format**: JSON newline-delimited

```json
{
  "type": "msg",
  "roomId": "room123",
  "senderId": "peer456",
  "senderName": "Alice",
  "content": "Hello!",
  "timestamp": "2025-11-06T10:30:00Z",
  "encrypted": true,
  "signature": "hmac_signature_here"
}
```

### Peer Structure

```dart
class Peer {
  String id;                    // UUID
  String name;                  // Display name
  String ip;                    // IPv4 address
  bool verified;               // Key verified?
  DateTime lastSeen;           // Last activity
  bool isHosting;              // Running as host?
  int? hostPort;              // Host port
  String? publicKey;          // For key verification
}
```

### Room Structure

```dart
class Room {
  String id;                   // UUID
  String name;                 // Room name
  DateTime createdAt;          // Creation time
  String? hostId;             // Host peer ID
  List<String> members;       // Member IDs
  bool isPrivate;            // Private room?
}
```

---

## 🚀 Quy Trình Phát Triển

### 1. Thêm Feature Mới

**Ví dụ**: Thêm tính năng "Typing Indicator"

```dart
// 1. Định nghĩa model trong core/
class TypingIndicator {
  final String userId;
  final bool isTyping;
}

// 2. Thêm method vào service (ChatService)
Future<void> sendTypingIndicator(String roomId, bool isTyping) async {
  await signalingService.sendSignalingMessage({
    'type': 'typing',
    'roomId': roomId,
    'isTyping': isTyping,
  });
}

// 3. Lắng nghe trong UI (Provider)
final typingProvider = StateNotifierProvider<TypingNotifier, Map>((ref) {
  return TypingNotifier();
});

// 4. Render trong UI
Text(typingUser != null ? '${typingUser.name} is typing...' : '')
```

### 2. Fix Bug

1. **Xác định vấn đề**: Chạy diagnostics, kiểm tra logs
2. **Tạo test case**: Thêm unit test để reproduce
3. **Fix code**: Sửa logic, thêm null safety checks
4. **Verify**: Chạy tests, manual testing
5. **Commit**: `git commit -m "fix: [issue #123] description"`

### 3. Refactoring

```bash
# Run analysis
flutter analyze

# Fix lints
flutter pub run dartfmt -r -w lib/

# Run tests
flutter test

# Kiểm tra performance
flutter run --profile
```

---

## 🧪 Testing

### Unit Tests

```dart
// test/services/encryption_service_test.dart

void main() {
  test('encrypt and decrypt should be symmetric', () {
    final service = EncryptionService();
    final plaintext = 'Hello, World!';
    final password = 'mypassword';
    
    final encrypted = service.encrypt(
      plaintext: plaintext,
      password: password,
    );
    final decrypted = service.decrypt(
      ciphertext: encrypted,
      password: password,
    );
    
    expect(decrypted, equals(plaintext));
  });
}
```

### Widget Tests

```dart
// test/screens/chat_screen_test.dart

void main() {
  testWidgets('ChatScreen displays messages', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    
    // Navigate to chat screen
    await tester.tap(find.byIcon(Icons.chat));
    await tester.pumpAndSettle();
    
    // Verify message list appears
    expect(find.byType(ListView), findsOneWidget);
  });
}
```

### Run Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/encryption_service_test.dart

# Run with coverage
flutter test --coverage

# Generate coverage report
# install lcov: brew install lcov (macOS)
genhtml coverage/lcov.info -o coverage/report
```

---

## 📦 Deployment

### Android

```bash
# Build APK
flutter build apk --release

# Build AAB (Google Play)
flutter build appbundle --release

# Install locally
adb install build/app/outputs/flutter-apk/app-release.apk
```

### iOS

```bash
# Build IPA
flutter build ios --release

# Open in Xcode for signing & upload
open ios/Runner.xcworkspace
```

### Web

```bash
# Build web
flutter build web

# Deploy ke server
# Copy ./build/web/* to web hosting
```

### Windows/Linux

```bash
# Build Windows
flutter build windows --release

# Build Linux
flutter build linux --release
```

---

## 🔍 Debugging

### Enable Debug Logging

```dart
// lib/core/chat_service.dart
if (kDebugMode) {
  debugPrint('Received message: $message');
}
```

### Use DevTools

```bash
flutter pub global activate devtools
devtools

# Then in app:
# Flutter DevTools available at: http://127.0.0.1:9100
```

### Profile Performance

```bash
# Generate timeline
flutter run --profile

# Use DevTools to check:
# - Frame rendering time (60 FPS target)
# - Memory usage
# - CPU usage
```

---

## 📝 Code Style

### Naming Conventions

```dart
// Classes: PascalCase
class ChatService { }

// Variables & methods: camelCase
String userName = 'Alice';
void sendMessage() { }

// Constants: camelCase
const int maxRetries = 3;

// Private: prefix with _
class _PrivateHelper { }

// Private method
Future<void> _internalMethod() async { }
```

### Formatting

```bash
# Auto format
dart format .

# Check formatting
dart format --set-exit-if-changed .
```

### Linting

```bash
# Check lints
flutter analyze

# Fix auto-fixable issues
flutter pub run dartfmt -r -w lib/
```

---

## 🤝 Contributing

### Pull Request Process

1. **Fork** repository
2. **Create branch**: `git checkout -b feature/my-feature`
3. **Make changes**: Implement feature + tests
4. **Commit**: `git commit -m "feat: add my feature"`
5. **Push**: `git push origin feature/my-feature`
6. **Create PR**: Mô tả changes rõ ràng
7. **Review**: Chờ code review
8. **Merge**: Sau khi approved

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Code style
- `refactor`: Code restructuring
- `test`: Test cases
- `chore`: Dependency updates

---

## 📚 Resources

- [Flutter Docs](https://flutter.dev/docs)
- [Dart Docs](https://dart.dev/guides)
- [Riverpod Guide](https://riverpod.dev)
- [Hive Documentation](https://docs.hivedb.dev)
- [Socket Programming](https://dart.dev/guides/libraries/library-tour#dart-io)

---

## ❓ FAQ

**Q: Làm sao để thêm ngôn ngữ mới?**
A: Tạo file i18n mới trong `assets/i18n/`, cập nhật `main.dart` router

**Q: Làm sao để customize giao diện?**
A: Sửa theme trong `main.dart` → `ThemeData`

**Q: Làm sao để thêm plugin native?**
A: `flutter pub add plugin_name`, sau đó setup Android/iOS code

**Q: Làm sao để optimize hiệu năng?**
A: Dùng `--profile` mode, check DevTools, avoid rebuilds

---

**Happy Coding! 🚀**

---

*Phiên bản: 1.0.0*
*Cập nhật: 2025-11-06*
