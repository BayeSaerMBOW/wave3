import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../modules/login/controllers/login_controller.dart';
import 'package:intl/intl.dart';
import '../../../modules/transfer/views/transfer_view.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../modules/transfer/controllers/transfer_controller.dart';
import '../../../../models/transaction_model.dart';
import '../../phone_credit/views/phone_credit_view.dart';
import '../../../utilis/transaction_utils.dart';
import '../../lectricite/views/lectricite_view.dart';

class HomeView extends StatelessWidget {
  final HomeController homeController = Get.put(HomeController());
  final LoginController loginController = Get.put(LoginController());
  final TransferController transferController = Get.put(TransferController());
  final currencyFormat = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: 'FCFA',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Icon(Icons.person, color: Colors.blue),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour,',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Obx(() => Text(
                      homeController.userName.value.isEmpty
                          ? 'Utilisateur'
                          : homeController.userName.value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    )),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black),
            onPressed: () => loginController.logout(),
          ),
        ],
      ),
      body: Obx(() => homeController.isLoading.value
          ? Center(child: CircularProgressIndicator())
          : _buildHomeContent()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sync_alt),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Cartes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.blue.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total des soldes',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      icon: Obx(() => Icon(
                            homeController.isBalanceVisible.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.white,
                          )),
                      onPressed: () => homeController.toggleBalanceVisibility(),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => homeController.isBalanceVisible.value
                        ? Text(
                            currencyFormat
                                .format(homeController.userBalance.value),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Text(
                            '••••••••••',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                    GestureDetector(
                      onTap: () => _showQRCodeDialog(Get.context!),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.qr_code,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickAction(
                      icon: Icons.add,
                      label: 'Recharger',
                      onTap: () {},
                    ),
                    _buildQuickAction(
                      icon: Icons.send,
                      label: 'Envoyer',
                      onTap: () => Get.to(() => TransferView()),
                    ),
                    _buildQuickAction(
                      icon: Icons.qr_code_scanner,
                      label: 'Scanner',
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Services rapides',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 16),
          Container(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildServiceCard(
                  icon: Icons.phone_android,
                  label: 'Crédit\nTéléphone',
                  color: Colors.purple,
                  onTap: () => Get.to(() => PhoneCreditView()),
                ),
                _buildServiceCard(
                  icon: Icons.bolt,
                  label: 'Électricité',
                  color: Colors.orange,
                  onTap: () => Get.to(() => ElectricityView()),
                ),
                _buildServiceCard(
                  icon: Icons.water_drop,
                  label: 'Eau',
                  color: Colors.blue,
                  onTap: () {},
                ),
                _buildServiceCard(
                  icon: Icons.tv,
                  label: 'TV',
                  color: Colors.red,
                  onTap: () {},
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transactions récentes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Obx(() => homeController.recentTransactions.isEmpty
                    ? Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Aucune transaction récente',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: homeController.recentTransactions
                            .map((transactionData) => _buildTransactionItem(
                                  icon: TransactionUtils.getTransactionIcon(
                                      transactionData['description']),
                                  title: transactionData['description'],
                                  date: transactionData['date'],
                                  amount: currencyFormat
                                      .format(transactionData['amount']),
                                  isCredit: TransactionUtils.isCredit(
                                      transactionData['description']),
                                  transactionId: transactionData['id'],
                                  status: transactionData['status'],
                                  color: TransactionUtils.getTransactionColor(
                                      transactionData['description']),
                                ))
                            .toList(),
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required String title,
    required dynamic date,
    required String amount,
    required bool isCredit,
    required String transactionId,
    required String status,
    required Color color,
  }) {
    DateTime parsedDate;
    if (date is DateTime) {
      parsedDate = date;
    } else if (date is String) {
      try {
        parsedDate = DateTime.parse(date);
      } catch (e) {
        print('Error parsing date string: $e');
        parsedDate = DateTime.now();
      }
    } else {
      print('Unsupported date format');
      parsedDate = DateTime.now();
    }

    final transaction = Transaction(
      id: transactionId,
      senderId: '',
      receiverId: '',
      amount: double.tryParse(amount.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0,
      date: parsedDate,
      status: status,
      description: title,
    );

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(parsedDate),
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: isCredit ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (status == 'completed' &&
              transaction.isCancelable &&
              !title.toLowerCase().contains('crédit'))
            IconButton(
              icon: Icon(Icons.cancel, color: Colors.red.withOpacity(0.6)),
              onPressed: () => _cancelTransaction(transactionId),
            ),
        ],
      ),
    );
  }

  void _showQRCodeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Mon Code QR'),
          content: Obx(() => QrImageView(
                data: homeController.userQRData.value,
                version: QrVersions.auto,
                size: 280,
              )),
          actions: [
            TextButton(
              child: Text('Fermer'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _cancelTransaction(String transactionId) async {
    if (transactionId.isEmpty) {
      print('ID de transaction manquant');
      return;
    }
    final result = await transferController.cancelTransaction(transactionId);
    if (result) {
      homeController.fetchRecentTransactions();
    }
  }
}
