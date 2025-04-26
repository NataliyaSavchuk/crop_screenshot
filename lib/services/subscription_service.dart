import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

enum SubscriptionType { none, trial, paidUntil, lifetime }

class SubscriptionService with ChangeNotifier {
  SubscriptionType _subscriptionType = SubscriptionType.trial;
  DateTime? _paidUntil;

  bool get isActive =>
      _subscriptionType == SubscriptionType.trial ||
      _subscriptionType == SubscriptionType.paidUntil && _paidUntil != null && _paidUntil!.isAfter(DateTime.now()) ||
      _subscriptionType == SubscriptionType.lifetime;

  SubscriptionType get subscriptionType => _subscriptionType;

  String getSubscriptionText(BuildContext context) {
    switch (_subscriptionType) {
      case SubscriptionType.trial:
        return AppLocalizations.of(context)!.trial_subscription;
      case SubscriptionType.paidUntil:
        if (_paidUntil != null) {
          return '${AppLocalizations.of(context)!.paid_until} ${_formatDate(_paidUntil!)}';
        } else {
          return AppLocalizations.of(context)!.no_subscription;
        }
      case SubscriptionType.lifetime:
        return AppLocalizations.of(context)!.lifetime_subscription;
      default:
        return AppLocalizations.of(context)!.no_subscription;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  // для тестирования
  void setTrial() {
    _subscriptionType = SubscriptionType.trial;
    notifyListeners();
  }

  void setPaidUntil(DateTime date) {
    _subscriptionType = SubscriptionType.paidUntil;
    _paidUntil = date;
    notifyListeners();
  }

  void setLifetime() {
    _subscriptionType = SubscriptionType.lifetime;
    notifyListeners();
  }

  void removeSubscription() {
    _subscriptionType = SubscriptionType.none;
    _paidUntil = null;
    notifyListeners();
  }
}
