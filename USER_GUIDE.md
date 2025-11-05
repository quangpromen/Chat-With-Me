# 📱 Hướng Dẫn Sử Dụng LanChat App

**LanChat** là một ứng dụng chat ngoại tuyến (offline) cho phép giao tiếp qua mạng LAN cục bộ mà không cần internet hoặc máy chủ tập trung.

---

## 📋 Mục Lục
1. [Yêu Cầu Hệ Thống](#yêu-cầu-hệ-thống)
2. [Cài Đặt & Khởi Động](#cài-đặt--khởi-động)
3. [Hướng Dẫn Từng Bước](#hướng-dẫn-từng-bước)
4. [Các Tính Năng Chính](#các-tính-năng-chính)
5. [Khắc Phục Sự Cố](#khắc-phục-sự-cố)
6. [Câu Hỏi Thường Gặp](#câu-hỏi-thường-gặp)

---

## 🔧 Yêu Cầu Hệ Thống

### Thiết Bị
- **Android**: 5.0+ (API 21+)
- **iOS**: 11.0+
- **Windows/Linux**: Desktop version
- **Web**: Trình duyệt hỗ trợ WebSocket

### Mạng
- ✅ Mạng WiFi LAN cục bộ (cùng SSID)
- ✅ Mạng Ethernet nội bộ
- ❌ Không cần Internet
- ❌ Hoạt động hoàn toàn offline

### Quyền Truy Cập (Android)
- **WiFi**: Để kết nối mạng
- **Bluetooth**: Để quét QR code (tùy chọn)
- **Bộ Nhớ**: Để lưu trữ tin nhắn và file
- **Máy Ảnh**: Để quét mã QR hoặc chụp ảnh

---

## 📲 Cài Đặt & Khởi Động

### Android
```bash
# Cài đặt APK
adb install build/app/outputs/flutter-apk/app-debug.apk

# Hoặc: Chạy trực tiếp trên emulator
flutter run -d emulator-5554
```

### iOS
```bash
flutter run -d iphone
# hoặc: Mở trong Xcode
open ios/Runner.xcworkspace
```

### Windows/Linux
```bash
flutter run -d windows
# hoặc
flutter run -d linux
```

### Web
```bash
flutter run -d chrome
# hoặc: Build web
flutter build web
```

---

## 🚀 Hướng Dẫn Từng Bước

### Bước 1: Màn Hình Onboarding (Hướng Dẫn Khởi Động)

Khi mở app lần đầu tiên:
1. ✅ Nhấn **"Tiếp Tục"** hoặc **"Next"** để xem hướng dẫn
2. 📖 Đọc các thông tin về tính năng app
3. ✅ Nhấn **"Bắt Đầu"** khi sẵn sàng

**Lưu ý**: Màn hình này chỉ xuất hiện lần đầu, dữ liệu được lưu vĩnh viễn trên thiết bị.

---

### Bước 2: Cấp Quyền Truy Cập

Ứng dụng sẽ yêu cầu các quyền cần thiết:

| Quyền | Mục Đích | Bắt Buộc? |
|--------|---------|----------|
| 📡 WiFi | Kết nối mạng LAN | ✅ Có |
| 💾 Bộ Nhớ | Lưu tin nhắn & file | ✅ Có |
| 📷 Máy Ảnh | Quét QR code | ⭕ Tùy chọn |
| 🎤 Microphone | Cuộc gọi thoại (tương lai) | ⭕ Tùy chọn |

**Cách cấp quyền:**
- Nhấn **"Cho Phép"** cho mỗi quyền được yêu cầu
- Nếu từ chối: Vào **Cài Đặt > Quyền** để cấp thủ công

---

### Bước 3: Thiết Lập Hồ Sơ

Nhập thông tin của bạn:

| Trường | Ví Dụ | Yêu Cầu |
|--------|-------|--------|
| **Tên Người Dùng** | "Minh" | 3-20 ký tự |
| **Email** (tùy chọn) | user@example.com | Hợp lệ |
| **Ảnh Đại Diện** (tùy chọn) | 📸 | JPG/PNG |
| **Trạng Thái** | "Sẵn sàng chat!" | Tự do |

**Nhấn "Hoàn Tất"** để lưu hồ sơ.

---

### Bước 4: Khám Phá Các Peer (Người Dùng Khác)

#### 🔍 Cách Tìm Bạn Bè

**Phương Pháp 1: Discovery (Tự Động)**
1. Vào tab **"Discovery"** hoặc **"Khám Phá"**
2. App tự động quét mạng LAN
3. Chờ 2-5 giây để hiển thị danh sách người dùng
4. Nhấn vào người dùng để xem hồ sơ

**Phương Pháp 2: QR Code**
1. Nhấn icon **📱 QR Code** 
2. Cho phép truy cập máy ảnh
3. Quét mã QR từ người khác
4. Tự động thêm vào danh sách bạn

**Phương Pháp 3: Manual Input (Nhập Thủ Công)**
1. Vào **"Manual Host"** hoặc **"Nhập IP"**
2. Nhập IP địa chỉ của máy khác (ví dụ: `192.168.1.100`)
3. Nhập port (mặc định: `9999`)
4. Nhấn **"Kết Nối"**

#### ✅ Xác Thực Bạn Bè

Khi kết nối với ai đó lần đầu:
1. 🔒 Hệ thống yêu cầu **xác minh khóa bảo mật** (Key Verification)
2. 👥 So sánh **mã xác minh 6 chữ số** với bạn bè
   - Nếu giống nhau → Nhấn **"Xác Minh"** ✅
   - Nếu khác nhau → Có thể có vấn đề bảo mật ⚠️
3. Sau khi xác minh → Được phép gửi tin nhắn

---

### Bước 5: Tạo Phòng Chat

#### 📌 Tạo Phòng Mới

1. Vào tab **"Rooms"** hoặc **"Phòng Chat"**
2. Nhấn nút **"+" hoặc "Tạo Phòng"**
3. Nhập thông tin:
   - **Tên Phòng**: "Kỹ Sư - Dự Án A" (tùy ý)
   - **Mô Tả** (tùy chọn): "Bàn luận về kiến trúc"
   - **Quyền Riêng Tư**: 
     - 🟢 Công Khai: Ai cũng có thể tham gia
     - 🔵 Riêng Tư: Chỉ người được mời
     - 🔴 Bí Mật: Chỉ quản trị viên biết

4. Nhấn **"Tạo"**

#### 📣 Mời Người Tham Gia

1. Mở phòng vừa tạo
2. Nhấn icon **"👥 Mời"** hoặc **"Add Members"**
3. Chọn người dùng từ danh sách Peers
4. Nhấn **"Mời"** → Gửi yêu cầu
5. Chờ họ **"Chấp Nhận"** ✅

---

### Bước 6: Chat & Gửi Tin Nhắn

#### 💬 Gửi Tin Nhắn

1. Mở phòng chat
2. Nhập tin nhắn vào ô **"Aa"** ở dưới cùng
3. Nhấn icon **📤 "Gửi"** hoặc **Enter** (trên PC)
4. Tin nhắn sẽ được:
   - ✅ Mã hóa end-to-end
   - 💾 Lưu vĩnh viễn trên thiết bị
   - 📤 Gửi đến tất cả thành viên phòng

#### ⏱️ Trạng Thái Tin Nhắn

- 📤 **Đang gửi** (quay tròn)
- ✓ **Đã gửi** (1 dấu check)
- ✓✓ **Đã nhận** (2 dấu check)
- 👁️ **Đã xem** (check xanh)

#### 📎 Gửi File

1. Nhấn icon **"📎 Tệp"** hoặc **"Attachment"**
2. Chọn file từ bộ nhớ
3. Xem **tiến độ upload** (%)
4. Tin nhắn file sẽ xuất hiện trong chat
5. Người khác có thể tải xuống

#### 🎨 Định Dạng Tin Nhắn

```
**In đậm**: **text**
_Nghiêng_: _text_
~~Gạch ngang~~: ~~text~~
`Mã`: `code`
```

---

### Bước 7: Quản Lý Phòng & Cài Đặt

#### ⚙️ Cài Đặt Phòng

1. Mở phòng → Nhấn **"..."** (3 chấm) ở góc phải
2. Chọn **"Thông Tin Phòng"** hoặc **"Room Info"**
3. Có thể:
   - 📝 Sửa tên phòng
   - 🔐 Thay đổi quyền riêng tư
   - 👥 Xem danh sách thành viên
   - 🚫 Xóa thành viên
   - 🔔 Tắt/Bật thông báo

#### 👤 Quản Lý Hồ Sơ

1. Vào **"Profile"** hoặc **"Hồ Sơ"** (icon người)
2. Có thể:
   - 📝 Sửa tên, email, trạng thái
   - 📸 Đổi ảnh đại diện
   - 🔐 Xem khóa công khai (cho xác minh)
   - 🗑️ Xóa dữ liệu cục bộ

#### 🔧 Cài Đặt Ứng Dụng

1. Vào **"Settings"** hoặc **"Cài Đặt"**
2. Các tùy chọn:
   - 🌙 **Dark Mode**: Chế độ tối
   - 🔔 **Notifications**: Bật/Tắt thông báo
   - 📊 **Sync**: Đồng bộ hóa dữ liệu
   - 🌍 **Language**: Chọn ngôn ngữ
   - 🗑️ **Clear Cache**: Xóa bộ nhớ tạm
   - 📋 **About**: Thông tin app

---

## ⭐ Các Tính Năng Chính

### 🔐 Bảo Mật & Mã Hóa

- ✅ **End-to-End Encryption (E2EE)**: Tin nhắn được mã hóa AES-256
- ✅ **Key Verification**: Xác minh bạn bè qua 6 chữ số
- ✅ **No Server**: Không có máy chủ tập trung, hoàn toàn offline
- ✅ **Local Storage**: Dữ liệu chỉ lưu trên thiết bị của bạn

### 💾 Lưu Trữ Offline

- ✅ **Tin Nhắn**: Tất cả tin nhắn được lưu vĩnh viễn
- ✅ **File**: Các file được lưu và có thể tải lại
- ✅ **Danh Bạ**: Danh sách bạn bè được ghi nhớ
- ✅ **Phòng Chat**: Lịch sử phòng chat được giữ lại

### 🚀 Tốc Độ & Hiệu Năng

- ⚡ **Gửi Tin Nhắn**: < 100ms trên LAN
- ⚡ **Truyền File**: Tối đa tốc độ WiFi (100+ Mbps)
- ⚡ **Tìm Kiếm**: Tức thì trên dữ liệu cục bộ
- ⚡ **Không Lag**: Không phụ thuộc internet

### 👥 Quản Lý Người Dùng

- ✅ **Khám Phá Tự Động**: Tìm người dùng trên mạng
- ✅ **Mã QR**: Kết nối nhanh qua quét mã
- ✅ **Danh Sách Bạn**: Lưu trữ danh bạ cá nhân
- ✅ **Trạng Thái Online**: Xem ai đang hoạt động

### 📱 Phòng Chat

- ✅ **Phòng Công Khai/Riêng**: Kiểm soát truy cập
- ✅ **Nhóm**: Chat với nhiều người cùng lúc
- ✅ **Quản Trị**: Kiểm soát thành viên
- ✅ **Lịch Sử**: Xem lại tin nhắn cũ

---

## 🐛 Khắc Phục Sự Cố

### ❌ Không Thể Kết Nối Được

**Vấn Đề**: Không tìm thấy người dùng khác

**Giải Pháp**:
1. ✅ Kiểm tra cả 2 thiết bị đều kết nối WiFi
2. ✅ Kiểm tra cùng SSID (tên WiFi) giống nhau
3. ✅ Tắt Firewall tạm thời để kiểm tra
4. ✅ Khởi động lại app trên cả 2 thiết bị
5. ✅ Sử dụng **Manual Input** để nhập IP tay

**Kiểm tra IP**:
- Android: **Cài Đặt > WiFi > Nhấn giữ WiFi > Xem chi tiết > IP địa chỉ**
- Windows: `ipconfig | findstr IPv4`
- Mac/Linux: `ifconfig | grep inet`

---

### ❌ Tin Nhắn Bị Đẩy Lùi

**Vấn Đề**: Tin nhắn không được gửi

**Giải Pháp**:
1. ✅ Kiểm tra kết nối WiFi (phải vẫn còn hoạt động)
2. ✅ Chờ app tự động kết nối lại (retry mechanism)
3. ✅ Nếu không được: Đóng app và mở lại
4. ✅ Kiểm tra **Diagnostics** screen để xem lỗi chi tiết

---

### ❌ Không Thể Quét QR Code

**Vấn Đề**: Máy ảnh không hoạt động

**Giải Pháp**:
1. ✅ Cấp quyền máy ảnh:
   - Android: **Cài Đặt > Quyền > Máy Ảnh > Cho Phép**
   - iOS: **Cài Đặt > LanChat > Camera > Cho Phép**
2. ✅ Kiểm tra ứng dụng khác có sử dụng máy ảnh không
3. ✅ Khởi động lại thiết bị
4. ✅ Sử dụng **Manual Input** thay thế

---

### ❌ File Không Được Tải Lên

**Vấn Đề**: Upload file thất bại

**Giải Pháp**:
1. ✅ Kiểm tra kích thước file (< 100MB)
2. ✅ Kiểm tra bộ nhớ trống (ít nhất 500MB)
3. ✅ Kiểm tra người nhận vẫn kết nối
4. ✅ Thử lại sau 5 giây
5. ✅ Khởi động lại app nếu lỗi vẫn tiếp tục

---

### ❌ Ứng Dụng Bị Crash

**Vấn Đề**: App đột ngột đóng

**Giải Pháp**:
1. ✅ Xóa cache: **Cài Đặt > Clear Cache**
2. ✅ Xóa dữ liệu app:
   - Android: **Cài Đặt > Ứng Dụng > LanChat > Lưu Trữ > Xóa Dữ Liệu**
   - iOS: **Cài Đặt > Chung > iPhone Storage > LanChat > Xóa App > Cài Lại**
3. ✅ Cập nhật app lên phiên bản mới nhất
4. ✅ Báo lỗi nếu vẫn gặp sự cố

---

## ❓ Câu Hỏi Thường Gặp

### Q: Tôi cần Internet để sử dụng app không?
**A**: Không! LanChat hoàn toàn offline, chỉ cần mạng WiFi LAN cục bộ.

### Q: Dữ liệu của tôi có được lưu trên máy chủ không?
**A**: Không. Dữ liệu chỉ lưu trên thiết bị của bạn, không ai khác có thể truy cập.

### Q: Tôi có thể xóa tin nhắn không?
**A**: Hiện tại chưa hỗ trợ xóa tin nhắn, nhưng có thể lên kế hoạch cho phiên bản tương lai.

### Q: Có giới hạn số lượng phòng chat không?
**A**: Không có giới hạn, nhưng tốc độ có thể giảm nếu quá nhiều.

### Q: Làm sao để backup dữ liệu?
**A**: Dữ liệu tự động lưu trong ứng dụng. Để backup:
- Android: Sao chép folder `/sdcard/Android/data/com.example.chat_offline/`
- iOS: Sử dụng iCloud hoặc backup qua iTunes

### Q: Tôi quên tên người dùng, làm sao?
**A**: Xóa app và cài lại, sau đó thiết lập tên mới. Danh sách bạn sẽ được lưu lại nếu không xóa dữ liệu.

### Q: Ứng dụng hỗ trợ bao nhiêu ngôn ngữ?
**A**: Hiện tại hỗ trợ Tiếng Anh và Tiếng Việt (có thể thêm ngôn ngữ khác).

### Q: Có thể sử dụng app trên máy tính được không?
**A**: Có! Web version và Windows/Linux desktop version có sẵn.

### Q: File được mã hóa không?
**A**: Có, tất cả file cũng được mã hóa end-to-end như tin nhắn.

### Q: Tôi có thể sử dụng app trên nhiều thiết bị không?
**A**: Có, nhưng dữ liệu sẽ riêng biệt trên từng thiết bị. Để đồng bộ, cần chạy trên cùng mạng.

---

## 📞 Hỗ Trợ & Phản Hồi

Nếu bạn gặp vấn đề hoặc có ý kiến:
1. 📧 Email: support@lanchat.local
2. 🐛 Báo lỗi: Sử dụng **Diagnostics** screen
3. 💬 Cộng Đồng: Tham gia nhóm chat LanChat chính thức

---

## 🎓 Mẹo & Thủ Thuật

### ⚡ Mẹo Sử Dụng Hiệu Quả

1. **Tìm Bạn Nhanh**: 
   - Sử dụng QR code nếu 2 thiết bị gần nhau
   - Sử dụng Manual Host nếu biết IP

2. **Bảo Mật Tốt Nhất**:
   - Luôn xác minh khóa với bạn bè trước khi chat
   - Kiểm tra số xác minh khớp nhau

3. **Tiết Kiệm Pin**:
   - Tắt thông báo nếu không cần
   - Tắt WiFi khi không sử dụng

4. **Tối Ưu Tốc Độ**:
   - Duy trì khoảng cách < 10 mét để WiFi tốt nhất
   - Tránh vùng có nhiều can thiệp (điều hòa, lò vi sóng)

5. **Quản Lý Bộ Nhớ**:
   - Định kỳ xóa file cũ không cần
   - Xóa cache trong Settings

---

**Cảm ơn vì sử dụng LanChat! Chúc bạn trò chuyện vui vẻ! 🎉**

---

*Phiên bản: 1.0.0*  
*Cập nhật: 2025-11-06*  
*Hỗ trợ: Android 5.0+, iOS 11.0+, Windows, Mac, Linux, Web*
