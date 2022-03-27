import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

Future<void> addDevice(String accessToken, FlutterSecureStorage storage) async {
  final apiHost = dotenv.get('API_HOST');
  final onesignalAppId = dotenv.get(
      Platform.isIOS ? 'ONESIGNAL_IOS_APP_ID' : 'ONESIGNAL_ANDROID_APP_ID');
  final deviceType = Platform.isIOS ? "0" : "1";
  final response = await http.post(
    Uri.parse("$apiHost/devices"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $accessToken'
    },
    body: jsonEncode(
        <String, String>{'appId': onesignalAppId, 'deviceType': deviceType}),
  );
  if (response.statusCode == 200) {
    var deviceId = jsonDecode(response.body)['deviceId'];
    await storage.write(key: "deviceId", value: deviceId);
  }
}

Future<void> removeDevice(
    String accessToken, FlutterSecureStorage storage) async {
  final apiHost = dotenv.get('API_HOST');
  final deviceId = await storage.read(key: "deviceId");
  final response = await http.delete(
    Uri.parse("$apiHost/devices/$deviceId"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $accessToken'
    },
  );
  if (response.statusCode == 200) {
    await storage.delete(key: "deviceId");
  }
}
