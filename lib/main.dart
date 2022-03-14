// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // @TODO: cookie manager 이용해 secure storage에 refresh token 있으면 cookie 설정
  runApp(MyApp());
  await Future.delayed(const Duration(seconds: 1));
  FlutterNativeSplash.remove();
}

class MyApp extends StatefulWidget {
  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<MyApp> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Builder(builder: (BuildContext context) {
          return SafeArea(child: WebView(
            initialUrl: 'https://www.devook.com',
          userAgent: "random",
            javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _controller.complete(webViewController);
            _webViewController = webViewController;
          },
        }),
      ));
  }
}
