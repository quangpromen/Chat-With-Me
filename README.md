# 🚀 LanChat - Offline LAN Messaging App

> **Giao tiếp mà không cần Internet! Chat trên mạng LAN cục bộ với mã hóa end-to-end.**

[![Flutter](https://img.shields.io/badge/Flutter-3.9.2-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9.2-blue.svg)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Windows%20%7C%20Linux-blue.svg)](https://flutter.dev)

---

## 📋 Mục Lục

- [Tính Năng](#tính-năng)
- [Yêu Cầu](#yêu-cầu)
- [Cài Đặt Nhanh](#cài-đặt-nhanh)
- [Hướng Dẫn Sử Dụng](#hướng-dẫn-sử-dụng)
- [Kiến Trúc](#kiến-trúc)
- [Phát Triển](#phát-triển)
- [Testing](#testing)
- [Deployment](#deployment)
- [Contributing](#contributing)
- [Câu Hỏi Thường Gặp](#câu-hỏi-thường-gặp)

---

## ⭐ Tính Năng

### 🔐 Bảo Mật
- ✅ **End-to-End Encryption (E2EE)** - AES-256-GCM
- ✅ **Key Verification** - Xác minh 6 chữ số
- ✅ **No Server** - Hoàn toàn peer-to-peer
- ✅ **Local Storage** - Dữ liệu chỉ lưu trên thiết bị

### 💬 Giao Tiếp
- ✅ **1-1 Chat** - Tin nhắn riêng tư
- ✅ **Group Chat** - Phòng chat đa người
- ✅ **File Transfer** - Chia sẻ file nhanh chóng
- ✅ **Message History** - Lịch sử đầy đủ offline

### 🔍 Khám Phá
- ✅ **Auto Discovery** - Tìm bạn bè tự động qua UDP
- ✅ **QR Code Scan** - Kết nối nhanh qua mã QR
- ✅ **Manual Connection** - Nhập IP thủ công
- ✅ **Peer Status** - Xem ai đang online

### 💾 Lưu Trữ
- ✅ **Hive Database** - Persistent local storage
- ✅ **Message Sync** - Đồng bộ qua LAN
- ✅ **Offline First** - Hoạt động không cần internet
- ✅ **Automatic Backup** - Sao lưu tự động

### 🚀 Hiệu Năng
- ⚡ **Sub-100ms Messaging** - Chat nhanh trên LAN
- ⚡ **No Lag UI** - 60 FPS rendering
- ⚡ **Automatic Retry** - Exponential backoff
- ⚡ **Battery Efficient** - Tiết kiệm pin

---

## 📦 Yêu Cầu

### Phần Mềm
- **Flutter**: 3.9.2+
- **Dart**: 3.9.2+
- **Android SDK**: API 21+ (Android 5.0+)
- **Xcode**: 12.0+ (iOS 11.0+)

### Mạng
- ✅ WiFi LAN cục bộ
- ✅ Mạng Ethernet
- ❌ Không cần Internet (offline first)

### Thiết Bị
- Android 5.0+ / iOS 11.0+
- Windows 10+ / macOS 10.15+
- Modern web browser

---

## ⚡ Cài Đặt Nhanh

### 1️⃣ Clone & Setup
```bash
git clone <repository>
cd chat_offline
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2️⃣ Chạy
```bash
# Android / iOS
flutter run

# Emulator cụ thể
flutter run -d emulator-5554

# Web
flutter run -d chrome

# Windows
flutter run -d windows
```

### 3️⃣ Build
```bash
# APK
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

👉 **[Xem Chi Tiết: QUICK_START.md](./QUICK_START.md)**

---

## 📖 Hướng Dẫn Sử Dụng

| Hướng Dẫn | Nội Dung |
|-----------|---------|
| 🚀 **[Quick Start](./QUICK_START.md)** | Bắt đầu trong 5 phút |
| 📱 **[User Guide](./USER_GUIDE.md)** | Sử dụng app chi tiết |
| 👨‍💻 **[Developer Guide](./DEVELOPER_GUIDE.md)** | Lập trình & phát triển |
| 📊 **[Project Status](./DEPLOYMENT_STATUS.md)** | Tình trạng dự án |

---

## 🏗️ Kiến Trúc

```
┌─────────────────────────┐
│    UI Layer (Screens)   │  Flutter Widgets
├─────────────────────────┤
│  State Management       │  Riverpod Providers
├─────────────────────────┤
│  Services               │  Discovery, Chat, Encryption
├─────────────────────────┤
│  Network Layer          │  UDP Broadcast, TCP Sockets
├─────────────────────────┤
│  Database               │  Hive (Persistent Storage)
├─────────────────────────┤
│  Crypto                 │  AES-256, SHA-256, HMAC
└─────────────────────────┘
```

### Core Services

| Service | Mục Đích |
|---------|---------|
| **DiscoveryService** | Tìm kiếm peer qua UDP |
| **SignalingService** | Quản lý TCP connections |
| **ChatService** | Xử lý giao thức chat |
| **FileService** | Truyền file an toàn |
| **EncryptionService** | Mã hóa end-to-end |
| **DatabaseService** | Lưu trữ persistent |

---

## 👨‍💻 Phát Triển

### Project Structure
```
lib/
├── core/              # Services
├── data/              # Models & Database
├── providers/         # State Management
├── screens/           # UI Screens
└── widgets/           # Reusable Components
```

### Development Flow

```bash
# 1. Fetch dependencies
flutter pub get

# 2. Generate code
flutter pub run build_runner build --delete-conflicting-outputs

# 3. Run with hot reload
flutter run

# 4. Check code quality
flutter analyze

# 5. Format code
dart format .
```

### Adding Dependencies

```bash
# Add package
flutter pub add package_name

# Get dependencies
flutter pub get

# Generate code if needed
flutter pub run build_runner build
```

---

## 🧪 Testing

### Run Tests
```bash
# All tests
flutter test

# Specific test file
flutter test test/services/encryption_service_test.dart

# With coverage
flutter test --coverage
```

### Test Coverage
```bash
# Generate HTML report
genhtml coverage/lcov.info -o coverage/report
open coverage/report/index.html
```

---

## 📦 Deployment

### Android
```bash
# Build APK
flutter build apk --release

# Build AAB (Play Store)
flutter build appbundle --release

# Install
adb install build/app/outputs/flutter-apk/app-release.apk
```

### iOS
```bash
# Build
flutter build ios --release

# Open for code signing
open ios/Runner.xcworkspace
```

### Web
```bash
# Build
flutter build web --release

# Deploy
# Upload build/web/* to hosting service
```

### Windows/Linux
```bash
flutter build windows --release
flutter build linux --release
```

---

## 🤝 Contributing

Kami menyambut kontribusi! Silakan:

1. **Fork** repository
2. **Create** feature branch: `git checkout -b feature/my-feature`
3. **Commit** changes: `git commit -m "feat: add feature"`
4. **Push** to branch: `git push origin feature/my-feature`
5. **Create** Pull Request

Silakan baca [DEVELOPER_GUIDE.md](./DEVELOPER_GUIDE.md) untuk detail teknis.

---

## ❓ Câu Hỏi Thường Gặp

**Q: Tôi cần Internet không?**  
A: Không! LanChat hoàn toàn offline, chỉ cần WiFi LAN.

**Q: Dữ liệu có được lưu trên server không?**  
A: Không. Dữ liệu chỉ lưu cục bộ trên thiết bị của bạn.

**Q: Tôi có thể sử dụng trên nhiều thiết bị không?**  
A: Có, nhưng dữ liệu sẽ riêng biệt trên từng thiết bị.

**Q: Làm sao để xóa tin nhắn?**  
A: Hiện tại chưa hỗ trợ, nhưng có thể thêm trong phiên bản tương lai.

**Q: File có được mã hóa không?**  
A: Có, tất cả file được mã hóa end-to-end như tin nhắn.

👉 **[Xem thêm: USER_GUIDE.md#câu-hỏi-thường-gặp](./USER_GUIDE.md#câu-hỏi-thường-gặp)**

---

## 📄 Giấy Phép

MIT License - Xem [LICENSE](LICENSE) file

---

## 📞 Liên Hệ & Hỗ Trợ

- 🐛 **Report Bug**: Sử dụng Diagnostics screen trong app
- 💡 **Feature Request**: Thảo luận trong issue tracker
- 📧 **Email**: support@lanchat.local

---

## 🎓 Học Thêm

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Programming](https://dart.dev/guides)
- [Riverpod State Management](https://riverpod.dev)
- [Socket Programming in Dart](https://dart.dev/guides/libraries/library-tour#dart-io)
- [Hive Database](https://docs.hivedb.dev)

---

## 🙏 Cảm Ơn

Cảm ơn tất cả những người đã đóng góp, báo lỗi, và yêu thích project này!

---

**⭐ Nếu bạn thích project này, hãy star nó! ⭐**

---

*Phiên bản: 1.0.0*  
*Cập nhật: 2025-11-06*  
*Hỗ trợ: Android 5.0+, iOS 11.0+, Windows, macOS, Linux, Web*
