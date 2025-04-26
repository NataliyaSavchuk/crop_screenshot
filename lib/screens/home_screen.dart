import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/subscription_service.dart';
import '../services/screenshot_service.dart';
import '../l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SubscriptionService()),
        ChangeNotifierProvider(create: (_) => ScreenshotService()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.app_title),
        ),
        body: Consumer2<SubscriptionService, ScreenshotService>(
          builder: (context, subscription, screenshot, _) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    subscription.isActive
                        ? AppLocalizations.of(context)!.status_active
                        : AppLocalizations.of(context)!.status_inactive,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    subscription.getSubscriptionText(context),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
