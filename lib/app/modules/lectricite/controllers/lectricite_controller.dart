import 'package:get/get.dart';
import 'package:flutter/material.dart';

class LectriciteController extends GetxController {
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
      // Simulate payment processing
      // In a real app, you would integrate with a payment gateway
      await Future.delayed(Duration(seconds: 2));

      // Show success message
      Get.snackbar(
        'Succès',
        'Paiement de ${amount.value} F CFA pour ${selectedProvider.value} effectué',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return true;
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
}