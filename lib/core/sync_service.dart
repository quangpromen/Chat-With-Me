import 'package:flutter_riverpod/flutter_riverpod.dart';

class SyncService {
  Future<void> sync() async {
    // Placeholder for future cloud sync
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

final syncServiceProvider = Provider((ref) => SyncService());
