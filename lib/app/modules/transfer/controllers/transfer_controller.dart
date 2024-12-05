import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseFirestore, DocumentSnapshot;
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

  Future<bool> performScheduledTransfer({
    required String receiverPhoneNumber,
    required double amount,
    String? description,
    required DateTime scheduledTime,
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

      // Vérifier si le solde est suffisant pour le transfert
      if (currentBalance < amount) {
        errorMessage('Solde insuffisant pour effectuer le transfert');
        return false;
      }

      // Préparer les informations du destinataire
      final normalizedPhoneNumber =
          receiverPhoneNumber.replaceAll(RegExp(r'\D'), '');
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

      // Créer un document pour le transfert planifié
      await _firestore.collection('scheduled_transfers').add({
        'senderId': currentUser.uid,
        'receiverId': receiverId,
        'amount': amount,
        'description': description,
        'scheduledTime': scheduledTime,
      });

      return true;
    } catch (e) {
      print('Erreur de planification du transfert: $e');
      errorMessage('Erreur lors de la planification du transfert: $e');
      return false;
    } finally {
      isLoading(false);
    }
  }

 Future<bool> cancelTransaction(String transactionId) async {
  if (transactionId.isEmpty) {
    errorMessage('ID de transaction invalide');
    return false;
  }

  isLoading(true);
  errorMessage('');

  try {
    // Récupérer la transaction
    final transactionDoc = await _firestore
        .collection('transactions')
        .doc(transactionId)
        .get();

    if (!transactionDoc.exists) {
      errorMessage('Transaction non trouvée');
      return false;
    }

    final transactionData = transactionDoc.data()!;

    // Vérifier que les IDs sont non vides
    if (transactionData['senderId']?.isEmpty ?? true ||
        transactionData['receiverId']?.isEmpty ?? true) {
      errorMessage('IDs expéditeur ou destinataire manquants');
      return false;
    }

    final transaction = Transaction.fromJson({
      'id': transactionDoc.id,
      ...transactionData
    });

    // Vérifier si la transaction peut être annulée
    if (!transaction.isCancelable) {
      errorMessage('Cette transaction ne peut plus être annulée (délai de 30 minutes dépassé)');
      return false;
    }

    // Vérifier si la transaction est un achat de crédit
    if (transaction.description?.toLowerCase().contains('crédit') ?? false) {
      errorMessage('Les achats de crédits ne peuvent pas être annulés');
      return false;
    }

    // Récupérer les documents de solde
    final senderBalanceDoc = await _firestore
        .collection('balances')
        .doc(transaction.senderId)
        .get();

    final receiverBalanceDoc = await _firestore
        .collection('balances')
        .doc(transaction.receiverId)
        .get();

    if (!senderBalanceDoc.exists || !receiverBalanceDoc.exists) {
      errorMessage('Impossible de récupérer les soldes des utilisateurs');
      return false;
    }

    final senderBalance = (senderBalanceDoc.data()!['solde'] as num).toDouble();
    final receiverBalance = (receiverBalanceDoc.data()!['solde'] as num).toDouble();

    // Vérifier si le destinataire a suffisamment de fonds pour l'annulation
    if (receiverBalance < transaction.amount) {
      errorMessage('Le destinataire ne dispose pas de fonds suffisants pour l\'annulation');
      return false;
    }

    // Effectuer la transaction atomique pour l'annulation
    await _firestore.runTransaction((tx) async {
      // Mettre à jour le solde de l'expéditeur (recréditer)
      tx.update(senderBalanceDoc.reference, {
        'solde': senderBalance + transaction.amount
      });

      // Mettre à jour le solde du destinataire (débiter)
      tx.update(receiverBalanceDoc.reference, {
        'solde': receiverBalance - transaction.amount
      });

      // Mettre à jour le statut de la transaction
      tx.update(transactionDoc.reference, {
        'status': 'cancelled',
        'cancellationDate': DateTime.now().toIso8601String(),
      });

      // Créer une nouvelle transaction pour tracer l'annulation
      final reversalTransactionRef = _firestore.collection('transactions').doc();
      final reversalTransaction = Transaction(
        id: reversalTransactionRef.id,
        senderId: transaction.receiverId,
        receiverId: transaction.senderId,
        amount: transaction.amount,
        date: DateTime.now(),
        status: 'completed',
        description: 'Annulation de la transaction ${transaction.id}',
      ).toJson();

      tx.set(reversalTransactionRef, reversalTransaction);
    });

    // Mettre à jour le HomeController
    final homeController = Get.find<HomeController>();
    homeController.updateUserBalance(senderBalance + transaction.amount);
    await homeController.fetchRecentTransactions();

    return true;
  } catch (e) {
    print('Erreur lors de l\'annulation de la transaction: $e');
    errorMessage('Erreur lors de l\'annulation: $e');
    return false;
  } finally {
    isLoading(false);
  }
}


  Future<bool> cancelScheduledTransfer(String transferId) async {
    isLoading(true);
    errorMessage('');

    try {
      await _firestore.collection('scheduled_transfers').doc(transferId).delete();
      return true;
    } catch (e) {
      print('Erreur lors de l\'annulation du transfert planifié: $e');
      errorMessage('Erreur lors de l\'annulation du transfert planifié: $e');
      return false;
    } finally {
      isLoading(false);
    }
  }
}
