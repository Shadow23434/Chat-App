import 'package:flutter/material.dart';
import 'call_notification.dart';

class CallService extends ChangeNotifier {
  CallNotification? _incomingCall;

  CallNotification? get incomingCall => _incomingCall;

  void showIncomingCall(CallNotification call) {
    _incomingCall = call;
    notifyListeners();
  }

  void clearIncomingCall() {
    _incomingCall = null;
    notifyListeners();
  }
}
