// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'modules/device.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<MyApp> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  late WebViewController _webViewController;
  var _url = "https://www.devook.com";
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    if (!mounted) return;

    String onesignalAppId = dotenv.get(
        Platform.isIOS ? 'ONESIGNAL_IOS_APP_ID' : 'ONESIGNAL_ANDROID_APP_ID');
    OneSignal.shared.setAppId(onesignalAppId);

    OneSignal.shared.promptUserForPushNotificationPermission();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      backgroundColor: Colors.white,
      body: Builder(builder: (BuildContext context) {
        return SafeArea(
            child: WebView(
          initialUrl: _url,
          userAgent: "random",
          javascriptMode: JavascriptMode.unrestricted,
          javascriptChannels: <JavascriptChannel>{
            _toasterJavascriptChannel(context),
            _urlLaunchChannel(),
            _authJavascriptChannel(storage),
            _deviceJavascriptChannel(),
          },
          onWebViewCreated: (WebViewController webViewController) async {
            _controller.complete(webViewController);
            _webViewController = webViewController;
            String? refreshToken = await storage.read(key: "refreshToken");
            if (refreshToken != null) {
              _url = "https://www.devook.com?rt=$refreshToken";
              setState(() {
                _webViewController.loadUrl(_url);
              });
            }
          },
          onPageFinished: (String url) async {
            FlutterNativeSplash.remove();
            try {
              const javascript =
                  'window.alert = (str) => { window.Toaster.postMessage(str); }';
              await _webViewController.runJavascript(javascript);
            } catch (_) {}
          },
        ));
      }),
    ));
  }
}

JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
  return JavascriptChannel(
      name: 'Toaster',
      onMessageReceived: (JavascriptMessage message) {
        // ignore: deprecated_member_use
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text(message.message),
            backgroundColor: const Color(0xff09AF92),
          ),
        );
      });
}

JavascriptChannel _urlLaunchChannel() {
  return JavascriptChannel(
      name: 'UrlLaunchChannel',
      onMessageReceived: (JavascriptMessage message) {
        launchUrl(
          Uri.parse(message.message),
        );
      });
}

JavascriptChannel _authJavascriptChannel(FlutterSecureStorage storage) {
  return JavascriptChannel(
      name: 'AuthChannel',
      onMessageReceived: (JavascriptMessage message) async {
        final messageText = message.message;
        if (messageText.contains('login')) {
          final refreshToken = messageText.replaceAll("login:", "");
          await storage.write(key: "refreshToken", value: refreshToken);
        }
        if (messageText == 'logout') {
          await storage.delete(key: "refreshToken");
        }
      });
}

JavascriptChannel _deviceJavascriptChannel() {
  return JavascriptChannel(
      name: 'DeviceChannel',
      onMessageReceived: (JavascriptMessage message) async {
        final messageText = message.message;
        if (messageText.contains('login')) {
          final accessToken = messageText.replaceAll("login:", "");
          await addDevice(accessToken);
        }
        if (messageText.contains('logout')) {
          final accessToken = messageText.replaceAll("logout:", "");
          await removeDevice(accessToken);
        }
      });
}
