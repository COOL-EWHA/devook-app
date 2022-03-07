// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<MyApp> {
  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Builder(builder: (BuildContext context) {
          return SafeArea(child: WebView(
            initialUrl: 'https://www.devook.com',
            javascriptMode: JavascriptMode.unrestricted,
          )) ;
        }),
      ));
  }
}