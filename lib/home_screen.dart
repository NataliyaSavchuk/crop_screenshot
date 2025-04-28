import 'package:flutter/material.dart';
import 'subscription_service.dart';
import 'screenshot_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isActive = false;

  @override
  void initState() {
    super.initState();
    ScreenshotService.init();
  }

  void toggleActive() {
    setState(() {
      isActive = !isActive;
    });
    ScreenshotService.setActive(isActive);
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionStatus = SubscriptionService.getStatus();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Screenshot Cropper'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: const Text('App Status'),
                subtitle: Text(isActive ? 'Active' : 'Inactive'),
                trailing: Switch(
                  value: isActive,
                  onChanged: (_) => toggleActive(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                title: const Text('Subscription Status'),
                subtitle: Text(subscriptionStatus),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'To make a square screenshot, double-press the side button.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
