import 'package:flutter/material.dart';
import 'dart:io';
import 'lib/subscription_service.dart'; // Подключаем SubscriptionManager
import 'lib/screenshot_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Screenshot Cropper',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isActive = SubscriptionService.isActive();
  String subscriptionStatus = SubscriptionService.getSubscriptionStatus();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Screenshot Cropper")),
      body: Column(
        children: <Widget>[
          Text(
            "Status: ${isActive ? 'Active' : 'Inactive'}",
            style: TextStyle(fontSize: 20),
          ),
          Text(
            "Subscription: $subscriptionStatus",
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 20),
          Text(
            "To make a square screenshot, double press the side button.",
            style: TextStyle(fontSize: 16),
          ),
          ElevatedButton(
            onPressed: () async {
              // Временно для тестирования: захватываем скриншот и обрабатываем
              File screenshot = File('/path/to/screenshot.png'); // Пример пути скриншота
              await ScreenshotService.handleScreenshot(screenshot);
            },
            child: Text("Test Screenshot"),
          ),
        ],
      ),
    );
  }
}
