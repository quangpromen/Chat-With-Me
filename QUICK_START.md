# ⚡ Quick Start Guide - LanChat

Bắt đầu nhanh chóng với LanChat trong 5 phút!

---

## 📥 Cài Đặt

### Android
```bash
# Tùy chọn 1: Từ APK
adb install build/app/outputs/flutter-apk/app-debug.apk

# Tùy chọn 2: Từ source
flutter run
```

### iOS / Windows / Web
```bash
flutter run
```

---

## 🎯 5 Bước Đầu Tiên

### 1️⃣ Khởi Động App (30 giây)
- ✅ Mở app
- ✅ Chuyển qua hướng dẫn onboarding
- ✅ Nhấn "Bắt Đầu"

### 2️⃣ Cấp Quyền (1 phút)
- ✅ WiFi: **Cho Phép** (bắt buộc)
- ✅ Máy Ảnh: **Cho Phép** (để quét QR code)
- ✅ Bộ Nhớ: **Cho Phép** (để lưu tin nhắn)

### 3️⃣ Tạo Hồ Sơ (1 phút)
- 📝 Nhập **Tên**: "Minh", "Alice", v.v...
- 📸 Thêm **Ảnh Đại Diện** (tùy chọn)
- 💬 Thiết Lập **Trạng Thái**: "Sẵn sàng" (tùy chọn)
- ✅ Nhấn **Hoàn Tất**

### 4️⃣ Tìm Bạn Bè (2 phút)
**Cách 1: Tìm Tự Động**
- Tab **"Discovery"**
- Chờ danh sách peer xuất hiện
- Nhấn vào người bạn

**Cách 2: Quét QR Code**
- Icon 📱 QR Code
- Quét từ thiết bị khác
- Tự động thêm

**Cách 3: Nhập Thủ Công**
- Tab **"Manual Host"**
- Nhập IP: `192.168.x.x`
- Nhấn **"Kết Nối"**

### 5️⃣ Chat Ngay (1 phút)
- ✅ Xác Minh Khóa (nếu lần đầu)
- 💬 Gửi tin nhắn test
- 🎉 Thành Công!

---

## 💬 Gửi Tin Nhắn

### Chat 1-1
```
Peers → Chọn bạn → Chat
```

### Nhóm Chat
```
Rooms → Create → Mời bạn → Chat
```

### Gửi File
```
Dùng icon 📎 → Chọn file → Upload
```

---

## 📝 Cheat Sheet

| Hành Động | Cách Làm |
|-----------|---------|
| **Tìm bạn** | Discovery tab hoặc QR code |
| **Tạo phòng** | Rooms → "+" |
| **Mời bạn** | Room info → Add members |
| **Xem setting** | ⚙️ icon |
| **Chat 1-1** | Peers → Chọn bạn |
| **Gửi file** | 📎 icon trong chat |

---

## 🔗 Links Hữu Ích

- 📖 **Full User Guide**: [`USER_GUIDE.md`](./USER_GUIDE.md)
- 👨‍💻 **Developer Guide**: [`DEVELOPER_GUIDE.md`](./DEVELOPER_GUIDE.md)
- 🐛 **Troubleshooting**: [`USER_GUIDE.md#khắc-phục-sự-cố`](./USER_GUIDE.md#khắc-phục-sự-cố)
- 📦 **Project Status**: [`DEPLOYMENT_STATUS.md`](./DEPLOYMENT_STATUS.md)

---

## 🆘 Vấn Đề Phổ Biến

### Không tìm thấy bạn?
✅ Kiểm tra cùng WiFi → Chỉnh sửa firewall → Dùng Manual Host

### Tin nhắn không gửi?
✅ Kiểm tra WiFi → Đợi app reconnect → Khởi động lại app

### Máy ảnh không hoạt động?
✅ Cấp quyền trong Settings → Dùng Manual Host thay thế

---

## 🚀 Chạy Trên Emulator

### Android Emulator
```bash
# Tạo emulator (nếu chưa có)
flutter emulators --create

# List emulator
flutter emulators

# Chạy emulator
flutter emulators --launch emulator_id

# Chạy app
flutter run -d emulator-5554
```

### iOS Simulator (macOS)
```bash
open -a Simulator

flutter run -d iphone
```

---

## 🎮 Test Offline Chat

### Setup 2 Devices
1. Device A: Cài app, tạo hồ sơ "Alice"
2. Device B: Cài app, tạo hồ sơ "Bob"
3. Kết nối trên cùng WiFi

### Test Flow
1. A khám phá B (Discovery)
2. A gửi tin nhắn cho B
3. B gửi tin nhắn cho A
4. A tạo phòng, mời B
5. Cả 2 chat trong phòng
6. A gửi file cho B
7. B tải file xuống

### ✅ Kết Quả
- Tin nhắn đã gửi (✓✓)
- File được tải
- Không cần Internet
- **App hoạt động!** 🎉

---

## 📊 Kiểm Tra Hiệu Năng

```bash
# Profile mode (tốt nhất để đo performance)
flutter run --profile

# DevTools
flutter pub global activate devtools
devtools

# Xem Frame rate, Memory, CPU
# Target: 60 FPS, < 100MB RAM
```

---

## 🔍 Debug Mode

```bash
# Chạy với logs
flutter run

# View logs
flutter logs

# Hot reload (sau sửa code)
# Press 'r' in terminal
```

---

## 📦 Build Release

### Android
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### iOS
```bash
flutter build ios --release
# Open in Xcode for signing
```

### Web
```bash
flutter build web --release
# Serve: python3 -m http.server 8080 -d build/web
```

---

## ✅ Pre-Launch Checklist

- [ ] App chạy không lỗi
- [ ] Có thể kết nối bạn bè
- [ ] Tin nhắn gửi được
- [ ] File tải được
- [ ] UI responsive (no jank)
- [ ] Không có memory leak
- [ ] Battery OK (< 15% per hour)
- [ ] Offline hoạt động tốt

---

## 🎓 Tiếp Theo

1. **Đọc Full Guide**: [`USER_GUIDE.md`](./USER_GUIDE.md)
2. **Phát Triển Thêm**: [`DEVELOPER_GUIDE.md`](./DEVELOPER_GUIDE.md)
3. **Tìm Lỗi**: Sử dụng Diagnostics screen
4. **Báo Cáo**: Gửi feedback qua app

---

**Vui lòng chat! 🎉**

*Phiên bản: 1.0.0 | Cập nhật: 2025-11-06*
