import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';

Future<void> addDevice(String accessToken) async {
  var deviceState = await OneSignal.shared.getDeviceState();
  if (deviceState == null || deviceState.userId == null) return;
  var playerId = deviceState.userId!;
  final apiHost = dotenv.get('API_HOST');
  await http.post(
    Uri.parse("$apiHost/devices/$playerId"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $accessToken'
    },
  );
}

Future<void> removeDevice(String accessToken) async {
  var deviceState = await OneSignal.shared.getDeviceState();
  if (deviceState == null || deviceState.userId == null) return;
  var playerId = deviceState.userId!;
  final apiHost = dotenv.get('API_HOST');
  await http.delete(
    Uri.parse("$apiHost/devices/$playerId"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $accessToken'
    },
  );
}
