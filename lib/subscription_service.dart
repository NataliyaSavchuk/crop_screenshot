class SubscriptionService {
  static DateTime testSubscriptionExpiry = DateTime(2050, 10, 10);

  static bool isActive() {
    final now = DateTime.now();
    return now.isBefore(testSubscriptionExpiry);
  }

  static String getSubscriptionStatus() {
    final now = DateTime.now();
    if (testSubscriptionExpiry.year == 2050) {
      return "Lifetime";
    } else if (now.isBefore(testSubscriptionExpiry)) {
      return "Trial until ${_formatDate(testSubscriptionExpiry)}";
    } else {
      return "No Subscription";
    }
  }

  static String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";
  }
}
