import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';

class LectriciteController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  // Reactive variables for form inputs
  final RxString selectedProvider = RxString('');
  final RxString accountNumber = RxString('');
  final RxDouble amount = RxDouble(0.0);

  // List of electricity providers
  final List<Map<String, String>> providers = [
    {
      'name': 'Senelec',
      'description': 'National Electricity Company of Senegal',
      'logo': 'assets/images/senelec.png'
    },
    {
      'name': 'Woyofal',
      'description': 'Prepaid Electricity Distribution Service',
      'logo': 'assets/images/woyofal.png'
    }
  ];

  // List of transactions
  final RxList<Map<String, dynamic>> transactions = RxList<Map<String, dynamic>>([]);

  // Method to select a provider
  void selectProvider(String providerName) {
    selectedProvider.value = providerName;
  }

  // Method to validate payment details
  bool validatePaymentDetails() {
    return selectedProvider.isNotEmpty &&
           accountNumber.value.isNotEmpty &&
           amount.value > 0;
  }

  // Method to process payment
  Future<bool> processPayment() async {
    // Validate payment details
    if (!validatePaymentDetails()) {
      Get.snackbar(
        'Erreur',
        'Veuillez remplir tous les champs',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Create transaction record
        final transactionRef = await _firestore.collection('transactions').add({
          'senderId': currentUser.uid,
          'receiverId': selectedProvider.value,
          'amount': amount.value,
          'date': DateTime.now().toIso8601String(),
          'description': 'Paiement de facture ${selectedProvider.value}',
          'status': 'completed',
        });

        // Log the transaction reference
        print('Transaction added with ID: ${transactionRef.id}');

        // Update the transactions list
        transactions.add({
          'id': transactionRef.id,
          'senderId': currentUser.uid,
          'receiverId': selectedProvider.value,
          'amount': amount.value,
          'date': DateTime.now(),
          'description': 'Paiement de facture ${selectedProvider.value}',
          'status': 'completed',
        });

        // Show success message
        Get.snackbar(
          'Succès',
          'Paiement de ${amount.value} F CFA pour ${selectedProvider.value} effectué',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Reset form
        resetForm();

        return true;
      } else {
        // Handle the case where the user is not authenticated
        Get.snackbar(
          'Erreur',
          'Utilisateur non authentifié',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      // Handle any payment errors
      Get.snackbar(
        'Erreur',
        'Échec du paiement: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // Method to reset form
  void resetForm() {
    selectedProvider.value = '';
    accountNumber.value = '';
    amount.value = 0.0;
  }

  // Getter for available providers
  List<Map<String, String>> get availableProviders => providers;

  // Getter for transactions
  List<Map<String, dynamic>> get recentTransactions => transactions;
}
