import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../home/controllers/home_controller.dart';
import 'package:flutter/material.dart';

class PhoneCreditController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final HomeController _homeController = Get.find<HomeController>();
  var phoneNumber = ''.obs;
  var amount = 0.0.obs;
  var contacts = <Contact>[].obs;
  var selectedContact = Rx<Contact?>(null);
  final phoneNumberController = TextEditingController().obs;
  var selectedOperator = ''.obs;

  @override
  void onInit() {
    super.onInit();
    ever(selectedContact, (Contact? contact) {
      if (contact != null && contact.phones.isNotEmpty) {
        phoneNumber.value = contact.phones.first.number;
        phoneNumberController.value.text = contact.phones.first.number;
      }
    });
  }

  @override
  void onClose() {
    phoneNumberController.value.dispose();
    super.onClose();
  }

  Future<void> loadContacts() async {
    if (await FlutterContacts.requestPermission()) {
      contacts.value = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );
    }
  }

  void selectContact(Contact contact) {
    if (contact.phones.isNotEmpty) {
      selectedContact.value = contact;
      phoneNumber.value = contact.phones.first.number;
      phoneNumberController.value.text = contact.phones.first.number;
    }
  }

  String? validatePhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return 'Veuillez entrer un numéro de téléphone';
    }
    if (selectedOperator.value == 'Orange') {
      if (!RegExp(r'^(77|78)\d{7}$').hasMatch(phoneNumber)) {
        return 'Numéro de téléphone invalide pour Orange';
      }
    } else if (selectedOperator.value == 'Expresso') {
      if (!RegExp(r'^70\d{7}$').hasMatch(phoneNumber)) {
        return 'Numéro de téléphone invalide pour Expresso';
      }
    } else if (selectedOperator.value == 'Free') {
      if (!RegExp(r'^76\d{7}$').hasMatch(phoneNumber)) {
        return 'Numéro de téléphone invalide pour Free';
      }
    }
    return null;
  }

  Future<void> buyPhoneCredit() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final balanceDoc = await _firestore.collection('balances').doc(currentUser.uid).get();
        if (balanceDoc.exists) {
          final currentBalance = (balanceDoc.data()?['solde'] as num?)?.toDouble() ?? 0.0;
          if (currentBalance >= amount.value) {
            // Update user balance
            await _firestore.collection('balances').doc(currentUser.uid).update({
              'solde': FieldValue.increment(-amount.value),
            });

            // Create transaction record
            final transactionRef = await _firestore.collection('transactions').add({
              'senderId': currentUser.uid,
              'receiverId': 'phone_credit',
              'amount': amount.value,
              'date': DateTime.now().toIso8601String(),
              'description': 'Achat de crédit téléphonique',
              'status': 'completed',
            });

            // Update home controller balance and transactions
            _homeController.updateUserBalance(currentBalance - amount.value);
            await _homeController.fetchRecentTransactions();

            Get.snackbar(
              'Succès',
              'Crédit téléphonique acheté avec succès',
              backgroundColor: Colors.green.withOpacity(0.8),
              colorText: Colors.white,
              duration: Duration(seconds: 3),
              snackPosition: SnackPosition.TOP,
            );

            // Clear form
            phoneNumber.value = '';
            amount.value = 0.0;
            phoneNumberController.value.clear();
            selectedContact.value = null;

          } else {
            Get.snackbar(
              'Erreur',
              'Solde insuffisant',
              backgroundColor: Colors.red.withOpacity(0.8),
              colorText: Colors.white,
              duration: Duration(seconds: 3),
              snackPosition: SnackPosition.TOP,
            );
          }
        }
      }
    } catch (e) {
      print('Erreur lors de l\'achat de crédit téléphonique : $e');
      Get.snackbar(
        'Erreur',
        'Erreur lors de l\'achat de crédit téléphonique',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
      );
    }
  }
}
