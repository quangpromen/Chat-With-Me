# Project Progress Log

_Last updated: 2025-11-06 (UTC)_

## Completed
- 2025-11-05: Thiết lập lớp giao tiếp nội bộ cơ bản bằng UDP broadcast cho discovery và TCP socket cho signaling (`lib/core/discovery_service.dart`, `lib/core/signaling_service.dart`).
- 2025-11-05: Đồng bộ `ChatService` với `SignalingService`, bổ sung giao thức JSON newline-delimited, phát lại khi host và stream theo phòng (`lib/core/chat_service.dart`).
- 2025-11-05: Hiện thực truyền file nội bộ với gói offer/chunk/complete, phát lại khi host và phát stream tiến độ (`lib/core/file_service.dart`).
- 2025-11-06: Tạo Isar database models và DatabaseService cho việc lưu trữ peers, rooms, và messages (`lib/data/models/message.dart`, `lib/data/models/peer_db.dart`, `lib/data/models/room_db.dart`, `lib/core/database_service.dart`).
- 2025-11-06: Tích hợp database vào ChatService và AppState để tự động lưu và tải dữ liệu (`lib/core/chat_service.dart`, `lib/providers/app_state.dart`).
- 2025-11-06: Triển khai mã hóa thực sự với AES-256-GCM và key derivation trong EncryptionService (`lib/core/encryption_service.dart`).
- 2025-11-06: Thêm cơ chế retry với exponential backoff và tự động reconnect trong SignalingService (`lib/core/signaling_service.dart`).
- 2025-11-06 (tiếp - buổi 1): Giải quyết xung đột phụ thuộc giữa isar_generator, build_runner, flutter_riverpod bằng cách downgrade flutter_riverpod từ 3.0.3 -> 2.6.1 và analyzer từ 6.4.1 -> 5.13.0. Chạy build_runner thành công để generate `.g.dart` files cho database models. Sửa lỗi syntax trong `SignalingService` (rethrow vs throw) và lỗi type conversion (num -> int) trong `_calculateBackoff()`. Sửa `EncryptionService` để sử dụng đúng crypto API (`sha256.convert()` thay vì `Hmac`).
- 2025-11-06 (tiếp - buổi 2): **Thay thế Isar bằng Hive** để giải quyết vấn đề namespace trên Android AGP mới:
  - Cập nhật `pubspec.yaml`: thay isar/isar_flutter_libs bằng hive/hive_flutter; isar_generator bằng hive_generator
  - Chuyển đổi database models để sử dụng @HiveType/@HiveField annotations thay vì @Collection/@Index (Message, PeerDb, RoomDb)
  - Rewrite `DatabaseService` để sử dụng Hive Boxes thay vì Isar collections (OpenBox, put/get/delete operations)
  - Chạy `flutter clean && flutter pub get && build_runner build --delete-conflicting-outputs` thành công
  - **APK build thành công** và app chạy trên Android emulator
  - Flutter analyze: 0 errors, chỉ 18 infos/warnings (không blocking)

## Đang thực hiện / Còn thiếu
- ✅ App đang chạy trên Android emulator - verify UI rendering và basic functionality
- Viết test tích hợp cho các chức năng mới (database, encryption, retry logic)
- Hỗ trợ build web hoặc đưa ra cơ chế fallback khi UDP/TCP nội bộ không khả dụng
- Performance optimization nếu cần thiết
- Viết documentation cho các service modules

## Hướng dẫn cập nhật
1. Sau khi hoàn thành hạng mục, thêm mốc thời gian (định dạng `YYYY-MM-DD`) vào mục "Completed" nêu rõ phần việc và file liên quan.
2. Nếu phát sinh việc mới, ghi chú trong mục "Đang thực hiện / Còn thiếu" để người tiếp theo nắm được.
3. Giữ tệp ở dạng Markdown ngắn gọn, cập nhật mốc _Last updated_ khi chỉnh sửa.
