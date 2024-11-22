import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart'
    show FirebaseFirestore, DocumentSnapshot;
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../../../../models/transaction_model.dart';
import '../../home/controllers/home_controller.dart';

class TransferController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var selectedContacts = <Map<String, dynamic>>[].obs;

  Future<bool> performSingleTransfer({
    required String receiverPhoneNumber,
    required double amount,
    String? description,
  }) async {
    return performTransfer(
      receivers: [
        {'phone': receiverPhoneNumber, 'name': ''}
      ],
      amount: amount,
      description: description,
    );
  }

  Future<bool> performMultipleTransfer({
    required List<Map<String, dynamic>> receivers,
    required double amount,
    String? description,
  }) async {
    return performTransfer(
      receivers: receivers,
      amount: amount,
      description: description,
    );
  }

  Future<bool> performTransfer({
    required List<Map<String, dynamic>> receivers,
    required double amount,
    String? description,
  }) async {
    isLoading(true);
    errorMessage('');

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        errorMessage('Utilisateur non connecté');
        return false;
      }

      // Read sender's balance
      final senderBalanceDoc =
          await _firestore.collection('balances').doc(currentUser.uid).get();
      if (!senderBalanceDoc.exists) {
        errorMessage('Solde de l\'expéditeur non trouvé');
        return false;
      }
      final currentBalance =
          (senderBalanceDoc.data() as Map<String, dynamic>)['solde'] as num;

      // Vérifier si le solde est suffisant pour tous les transferts
      final totalAmount = amount * receivers.length;
      if (currentBalance < totalAmount) {
        errorMessage('Solde insuffisant pour effectuer tous les transferts');
        return false;
      }

      // Préparer toutes les informations des destinataires
      List<Map<String, dynamic>> transferDetails = [];

      for (var receiver in receivers) {
        final normalizedPhoneNumber =
            receiver['phone'].replaceAll(RegExp(r'\D'), '');
        final receiverQuery = await _firestore
            .collection('users')
            .where('telephone', isEqualTo: normalizedPhoneNumber)
            .limit(1)
            .get();

        if (receiverQuery.docs.isEmpty) {
          errorMessage(
              'Destinataire non trouvé pour le numéro de téléphone: $normalizedPhoneNumber');
          return false;
        }

        final receiverId = receiverQuery.docs.first.id;
        final receiverBalanceDoc =
            await _firestore.collection('balances').doc(receiverId).get();

        if (!receiverBalanceDoc.exists) {
          errorMessage(
              'Solde du destinataire non trouvé pour l\'ID: $receiverId');
          return false;
        }

        transferDetails.add({
          'receiverId': receiverId,
          'balanceDoc': receiverBalanceDoc,
          'currentBalance': (receiverBalanceDoc.data()
              as Map<String, dynamic>)['solde'] as num,
        });
      }

      // Effectuer la transaction atomique
      await _firestore.runTransaction((tx) async {
        // Mettre à jour le solde de l'expéditeur
        tx.update(senderBalanceDoc.reference,
            {'solde': currentBalance - totalAmount});

        // Pour chaque destinataire
        for (var details in transferDetails) {
          // Mettre à jour le solde du destinataire
          tx.update((details['balanceDoc'] as DocumentSnapshot).reference,
              {'solde': details['currentBalance'] + amount});

          // Créer une nouvelle transaction
          final transactionRef = _firestore.collection('transactions').doc();
          final transaction = Transaction(
            id: transactionRef.id,
            senderId: currentUser.uid,
            receiverId: details['receiverId'],
            amount: amount,
            date: DateTime.now(),
            status: 'completed',
            description: description,
          );

          // Sauvegarder la transaction
          tx.set(transactionRef, transaction.toJson());
        }
      });

      // Réinitialiser les contacts sélectionnés après un transfert réussi
      if (receivers.length > 1) {
        selectedContacts.clear();
      }

      // Notifier le HomeController pour mettre à jour le solde et les transactions récentes
      Get.find<HomeController>()
          .updateUserBalance(currentBalance - totalAmount);
      Get.find<HomeController>().addTransaction({
        'id': '',
        'amount': amount,
        'date': DateTime.now(),
        'description': description ?? 'Transfert effectué',
        'receiverId': '',
        'status': 'completed',
      });

      return true;
    } catch (e) {
      print('Erreur de transfert: $e'); // Pour le débogage
      errorMessage('Erreur lors du transfert: $e');
      return false;
    } finally {
      isLoading(false);
    }
  }
}
