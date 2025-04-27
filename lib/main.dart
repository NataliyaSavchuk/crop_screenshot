import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'subscription.dart';
import 'screenshot_service.dart';

void main() {
  runApp(const SpecialScreenshotApp());
}

class SpecialScreenshotApp extends StatelessWidget {
  const SpecialScreenshotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Special Screenshot App',
      theme: ThemeData(useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Subscription? _subscription;
  bool _isLoading = true;
  bool _showScreenshot = false;

  @override
  void initState() {
    super.initState();
    _loadSubscription();
  }

  Future<void> _loadSubscription() async {
    // Mock subscription: dated, valid for 30 days
    await Subscription.saveSubscription(
      SubscriptionType.dated,
      endDate: DateTime.now().add(const Duration(days: 30)),
    );
    final subscription = await Subscription.loadSubscription();
    setState(() {
      _subscription = subscription;
      _isLoading = false;
    });
  }

  Future<void> _takeScreenshot() async {
    if (_subscription?.isActive != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('App is inactive')),
      );
      return;
    }

    final service = ScreenshotService();
    final image = await service.captureScreenshot();
    if (image != null) {
      setState(() {
        _showScreenshot = true;
      });
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _showScreenshot = false;
      });
      final saved = await service.saveToGallery(image);
      if (saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Screenshot saved')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final subscriptionText = _subscription?.type == SubscriptionType.trial
        ? 'Trial Subscription'
        : _subscription?.type == SubscriptionType.dated
            ? 'Subscription until ${DateFormat('dd.MM.yyyy').format(_subscription!.endDate!)}'
            : _subscription?.type == SubscriptionType.lifetime
                ? 'Lifetime Subscription'
                : 'No Subscription';

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Status: ${_subscription?.isActive == true ? 'Active' : 'Inactive'}',
              style: const TextStyle(fontSize: 24),
            ),
            Text(
              'Subscription: $subscriptionText',
              style: const TextStyle(fontSize: 20),
            ),
            if (_showScreenshot)
              Container(
                color: Colors.grey[200],
                padding: const EdgeInsets.all(8),
                child: const Text(
                  'Mock Cropped Screenshot\nWith Text Above',
                  textAlign: TextAlign.center,
                ),
              )
            else
              TextButton(
                onPressed: _takeScreenshot,
                child: const Text('Take Screenshot'),
              ),
          ],
        ),
      ),
    );
  }
}