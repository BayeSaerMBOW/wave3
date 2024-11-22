import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class DistributorController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  var distributorName = ''.obs;
  var balance = 0.0.obs;
  var isLoading = false.obs;
  var recentTransactions = <Map<String, dynamic>>[].obs;
  var totalClients = 0.obs;
  var monthlyTransactions = 0.obs;
  var transactionMessage = ''.obs;
  var isTransactionLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDistributorData();
  }

  Future<void> fetchDistributorData() async {
    isLoading(true);
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Récupérer les données du distributeur
        final userDoc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();

        final balanceDoc = await _firestore
            .collection('balances')
            .doc(currentUser.uid)
            .get();

        distributorName.value = '${userDoc['prenom']} ${userDoc['nom']}';
        balance.value = balanceDoc.exists
            ? (balanceDoc.data()?['solde'] as num?)?.toDouble() ?? 0.0
            : 0.0;

        // Compter le nombre total de clients
        final clientsCount = await _firestore
            .collection('users')
            .where('distributeurId', isEqualTo: currentUser.uid)
            .count()
            .get();

        totalClients.value = clientsCount.count ?? 0; // Ajout de la valeur par défaut

        // Calculer le nombre de transactions du mois
        final now = DateTime.now();
        final firstDayOfMonth = DateTime(now.year, now.month, 1);

        final transactionsCount = await _firestore
            .collection('transactions')
            .where('distributorId', isEqualTo: currentUser.uid)
            .where('date', isGreaterThanOrEqualTo: firstDayOfMonth.toIso8601String())
            .count()
            .get();

        monthlyTransactions.value = transactionsCount.count ?? 0; // Ajout de la valeur par défaut

        await fetchRecentTransactions();
      }
    } catch (e) {
      print('Error fetching distributor data: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchRecentTransactions() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final transactionsSnapshot = await _firestore
            .collection('transactions')
            .where('distributorId', isEqualTo: currentUser.uid)
            .orderBy('date', descending: true)
            .limit(5)
            .get();

        recentTransactions.value = transactionsSnapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'amount': doc['amount'],
                  'date': DateTime.parse(doc['date']),
                  'description': doc['description'],
                  'clientId': doc['clientId'],
                  'type': doc['type'],
                  'status': doc['status'],
                })
            .toList();
      }
    } catch (e) {
      print('Error fetching transactions: $e');
    }
  }

  Future<void> deposit(String clientPhone, double amount) async {
    isTransactionLoading(true);
    transactionMessage.value = '';
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Rechercher le client par son numéro de téléphone
        final clientQuery = await _firestore
            .collection('users')
            .where('telephone', isEqualTo: clientPhone)
            .limit(1)
            .get();

        if (clientQuery.docs.isNotEmpty) {
          final clientDoc = clientQuery.docs.first;
          final clientId = clientDoc.id;

          // Mettre à jour le solde du client
          final clientDocRef = _firestore.collection('balances').doc(clientId);
          final clientBalanceDoc = await clientDocRef.get();

          if (clientBalanceDoc.exists) {
            final newClientBalance = (clientBalanceDoc.data()?['solde'] as num?)?.toDouble() ?? 0.0 + amount;
            await clientDocRef.update({'solde': newClientBalance});

            // Mettre à jour le solde du distributeur
            final distributorBalanceDoc = await _firestore.collection('balances').doc(currentUser.uid).get();
            if (distributorBalanceDoc.exists) {
              final newDistributorBalance = (distributorBalanceDoc.data()?['solde'] as num?)?.toDouble() ?? 0.0 - amount;
              await _firestore.collection('balances').doc(currentUser.uid).update({'solde': newDistributorBalance});
              balance.value = newDistributorBalance;
              print('Distributor balance updated: $newDistributorBalance'); // Log
            }

            // Enregistrer la transaction
            await _firestore.collection('transactions').add({
              'distributorId': currentUser.uid,
              'clientId': clientId,
              'amount': amount,
              'date': DateTime.now().toIso8601String(),
              'description': 'Dépôt',
              'type': 'deposit',
              'status': 'completed',
            });

            // Mettre à jour les transactions récentes
            await fetchRecentTransactions();
            transactionMessage.value = 'Dépôt effectué avec succès';

            // Recharger les données du distributeur
            await fetchDistributorData();
            update(); // Forcer la mise à jour de l'interface utilisateur
          }
        } else {
          transactionMessage.value = 'Client non trouvé';
        }
      }
    } catch (e) {
      print('Error depositing: $e');
      transactionMessage.value = 'Erreur lors du dépôt';
    } finally {
      isTransactionLoading(false);
    }
  }

  Future<void> withdraw(String clientPhone, double amount) async {
    isTransactionLoading(true);
    transactionMessage.value = '';
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Rechercher le client par son numéro de téléphone
        final clientQuery = await _firestore
            .collection('users')
            .where('telephone', isEqualTo: clientPhone)
            .limit(1)
            .get();

        if (clientQuery.docs.isNotEmpty) {
          final clientDoc = clientQuery.docs.first;
          final clientId = clientDoc.id;

          // Mettre à jour le solde du client
          final clientDocRef = _firestore.collection('balances').doc(clientId);
          final clientBalanceDoc = await clientDocRef.get();

          if (clientBalanceDoc.exists) {
            final newClientBalance = (clientBalanceDoc.data()?['solde'] as num?)?.toDouble() ?? 0.0 - amount;
            if (newClientBalance >= 0) {
              await clientDocRef.update({'solde': newClientBalance});

              // Mettre à jour le solde du distributeur
              final distributorBalanceDoc = await _firestore.collection('balances').doc(currentUser.uid).get();
              if (distributorBalanceDoc.exists) {
                final newDistributorBalance = (distributorBalanceDoc.data()?['solde'] as num?)?.toDouble() ?? 0.0 + amount;
                await _firestore.collection('balances').doc(currentUser.uid).update({'solde': newDistributorBalance});
                balance.value = newDistributorBalance;
                print('Distributor balance updated: $newDistributorBalance'); // Log
              }

              // Enregistrer la transaction
              await _firestore.collection('transactions').add({
                'distributorId': currentUser.uid,
                'clientId': clientId,
                'amount': amount,
                'date': DateTime.now().toIso8601String(),
                'description': 'Retrait',
                'type': 'withdrawal',
                'status': 'completed',
              });

              // Mettre à jour les transactions récentes
              await fetchRecentTransactions();
              transactionMessage.value = 'Retrait effectué avec succès';

              // Recharger les données du distributeur
              await fetchDistributorData();
              update(); // Forcer la mise à jour de l'interface utilisateur
            } else {
              transactionMessage.value = 'Solde insuffisant';
            }
          }
        } else {
          transactionMessage.value = 'Client non trouvé';
        }
      }
    } catch (e) {
      print('Error withdrawing: $e');
      transactionMessage.value = 'Erreur lors du retrait';
    } finally {
      isTransactionLoading(false);
    }
  }
  
}
