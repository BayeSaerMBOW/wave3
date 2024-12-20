import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class HomeController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  var userName = ''.obs;
  var userBalance = 0.0.obs;
  var isLoading = false.obs;
  var recentTransactions = <Map<String, dynamic>>[].obs;
  var isBalanceVisible = true.obs;
  var userQRData = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    isLoading(true);
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Récupérer les détails de l'utilisateur
        final userDoc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();
        // Récupérer le solde de l'utilisateur
        final balanceDoc = await _firestore
            .collection('balances')
            .doc(currentUser.uid)
            .get();
        // Débogage de l'impression pour vérifier les données réelles
        print('Balance Document Data: ${balanceDoc.data()}');
        // Récupérer le numéro de téléphone pour le code QR
        if (userDoc.exists && userDoc.data()!.containsKey('telephone')) {
          userQRData.value = userDoc.data()!['telephone'].toString();
        } else {
          print('Aucun numéro de téléphone trouvé pour l\'utilisateur');
          userQRData.value = ''; // Valeur par défaut si pas de numéro
        }
        // Mettre à jour les valeurs observables avec une vérification nulle
        userName.value = '${userDoc['prenom']} ${userDoc['nom']}';
        userBalance.value = balanceDoc.exists
            ? (balanceDoc.data()?['solde'] as num?)?.toDouble() ?? 0.0
            : 0.0;
        // Récupérer les transactions récentes
        await fetchRecentTransactions();
      }
    } catch (e) {
      print('Erreur lors de la récupération des données utilisateur : $e');
      userBalance.value = 0.0;
      userQRData.value = ''; // Réinitialiser les données QR en cas d'erreur
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
            .where('senderId', isEqualTo: currentUser.uid)
            .get();
        final transactions = transactionsSnapshot.docs.map((doc) {
          final dateString = doc['date'];
          DateTime date;
          try {
            date = DateTime.parse(dateString);
          } catch (e) {
            print('Erreur d\'analyse de la date : $e');
            date = DateTime.now();
          }
          return {
            'id': doc.id,
            'amount': doc['amount'],
            'date': date,
            'description': doc['description'],
            'receiverId': doc['receiverId'],
            'status': doc['status'],
          };
        }).toList();
        transactions.sort((a, b) => b['date'].compareTo(a['date']));
        recentTransactions.value = transactions.take(5).toList();
      }
    } catch (e) {
      print('Erreur lors de la récupération des transactions : $e');
    }
  }

  void toggleBalanceVisibility() {
    isBalanceVisible.value = !isBalanceVisible.value;
  }

  void updateUserBalance(double newBalance) {
    userBalance.value = newBalance;
  }

  void addTransaction(Map<String, dynamic> transaction) {
    recentTransactions.insert(0, transaction);
    if (recentTransactions.length > 5) {
      recentTransactions.removeLast();
    }
  }
}
