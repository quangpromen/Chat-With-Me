import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CallState { idle, calling, ringing, connected, ended }

class CallService {
  CallState state = CallState.idle;
  Future<void> startCall() async {
    state = CallState.calling;
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> acceptCall() async {
    state = CallState.connected;
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> endCall() async {
    state = CallState.ended;
    await Future.delayed(const Duration(milliseconds: 200));
  }
}

final callServiceProvider = Provider((ref) => CallService());
