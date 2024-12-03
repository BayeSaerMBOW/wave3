import 'package:flutter/material.dart';

class TransactionUtils {
  static IconData getTransactionIcon(String description) {
    if (description.toLowerCase().contains('crédit téléphonique')) {
      return Icons.phone_android;
    } else if (description.toLowerCase().contains('transfert')) {
      return Icons.currency_exchange;
    } else if (description.toLowerCase().contains('reçu')) {
      return Icons.arrow_downward;
    } else if (description.toLowerCase().contains('envoyé')) {
      return Icons.arrow_upward;
    }
    return Icons.receipt_long;
  }

  static Color getTransactionColor(String description) {
    if (description.toLowerCase().contains('crédit téléphonique')) {
      return Colors.purple;
    } else if (description.toLowerCase().contains('transfert')) {
      return Colors.blue;
    } else if (description.toLowerCase().contains('reçu')) {
      return Colors.green;
    } else if (description.toLowerCase().contains('envoyé')) {
      return Colors.orange;
    }
    return Colors.grey;
  }

  static bool isCredit(String description) {
    return description.toLowerCase().contains('reçu');
  }
}