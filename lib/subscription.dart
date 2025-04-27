import 'package:shared_preferences/shared_preferences.dart';

enum SubscriptionType { trial, dated, lifetime, none }

class Subscription {
  final SubscriptionType type;
  final DateTime? endDate;

  Subscription({required this.type, this.endDate});

  bool get isActive {
    switch (type) {
      case SubscriptionType.trial:
      case SubscriptionType.lifetime:
        return true;
      case SubscriptionType.dated:
        return endDate != null && DateTime.now().isBefore(endDate!);
      case SubscriptionType.none:
        return false;
    }
  }

  static Future<Subscription> loadSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    final type = prefs.getString('subscription_type') ?? 'none';
    final endDateStr = prefs.getString('subscription_end_date');

    switch (type) {
      case 'trial':
        return Subscription(type: SubscriptionType.trial);
      case 'dated':
        return Subscription(
          type: SubscriptionType.dated,
          endDate: endDateStr != null ? DateTime.parse(endDateStr) : null,
        );
      case 'lifetime':
        return Subscription(type: SubscriptionType.lifetime);
      default:
        return Subscription(type: SubscriptionType.none);
    }
  }

  static Future<void> saveSubscription(SubscriptionType type, {DateTime? endDate}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('subscription_type', type.toString().split('.').last);
    if (endDate != null) {
      await prefs.setString('subscription_end_date', endDate.toIso8601String());
    }
  }
}