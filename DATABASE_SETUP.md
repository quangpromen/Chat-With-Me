# Database Setup Instructions

## Vấn đề về phụ thuộc

Hiện tại có xung đột phiên bản giữa:
- `isar_generator` 3.x (yêu cầu analyzer <6.0.0)
- `build_runner` >=2.0.0 (yêu cầu analyzer >=6.0.0)
- `flutter_riverpod` 3.0.3 (yêu cầu analyzer >=6.0.0)

## Giải pháp tạm thời

Code đã được viết sẵn cho Isar database, nhưng cần giải quyết xung đột phụ thuộc trước khi chạy:

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

## Các file cần generate

Sau khi giải quyết phụ thuộc, chạy build_runner để tạo:
- `lib/data/models/message.g.dart`
- `lib/data/models/peer_db.g.dart`
- `lib/data/models/room_db.g.dart`

## Các chức năng đã hoàn thành

1. ✅ Database models (Message, PeerDb, RoomDb)
2. ✅ DatabaseService với đầy đủ CRUD operations
3. ✅ ChatService tích hợp database
4. ✅ AppState tích hợp database (load/save)
5. ✅ EncryptionService với mã hóa thực sự
6. ✅ Retry/backoff mechanism trong SignalingService

## Lưu ý

- Database sẽ tự động fallback về in-memory nếu Isar không khả dụng
- Code đã được viết để hoạt động với hoặc không có database
- Web platform không hỗ trợ Isar, sẽ tự động fallback

