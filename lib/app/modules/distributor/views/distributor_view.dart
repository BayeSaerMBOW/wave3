import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/distributor_controller.dart';
import '../../../modules/login/controllers/login_controller.dart';
import 'package:intl/intl.dart';
import '../../../modules/transfer/views/transfer_view.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:wave3/app/modules/scan/views/scan_view.dart';

class DistributorHomeView extends StatefulWidget {
  @override
  _DistributorHomeViewState createState() => _DistributorHomeViewState();
}

class _DistributorHomeViewState extends State<DistributorHomeView> {
  final DistributorController distributorController = Get.put(DistributorController());
  final LoginController loginController = Get.put(LoginController());
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
              backgroundColor: Colors.purple.shade100,
              child: Icon(Icons.business, color: Colors.purple),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Distributeur',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Obx(() => Text(
                      distributorController.distributorName.value.isEmpty
                          ? 'Utilisateur'
                          : distributorController.distributorName.value,
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
      body: Obx(() => distributorController.isLoading.value
          ? Center(child: CircularProgressIndicator())
          : _buildDistributorContent()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Clients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sync_alt),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Paramètres',
          ),
        ],
      ),
    );
  }

  Widget _buildDistributorContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBalanceCard(),
          _buildStatsGrid(),
          _buildRecentTransactions(),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple, Colors.purple.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Solde disponible',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Obx(() => Text(
                currencyFormat.format(distributorController.balance.value),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              )),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickAction(
                icon: Icons.add_circle_outline,
                label: 'Recharger',
                onTap: () {},
              ),
              _buildQuickAction(
                icon: Icons.person_add_outlined,
                label: 'Nouveau Client',
                onTap: () {},
              ),
              _buildQuickAction(
                icon: Icons.receipt_long_outlined,
                label: 'Rapports',
                onTap: () {},
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildDepositWithdrawForm(),
          SizedBox(height: 20),
          Obx(() => distributorController.isTransactionLoading.value
              ? Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
              : Obx(() =>
                  distributorController.transactionMessage.value.isNotEmpty
                      ? Text(
                          distributorController.transactionMessage.value,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        )
                      : SizedBox.shrink())),
        ],
      ),
    );
  }

  Widget _buildDepositWithdrawForm() {
    final TextEditingController clientPhoneController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    return Column(
      children: [
        TextField(
          controller: clientPhoneController,
          decoration: InputDecoration(
            labelText: 'Numéro de téléphone du client',
            fillColor: Colors.white,
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 10),
        TextField(
          controller: amountController,
          decoration: InputDecoration(
            labelText: 'Montant',
            fillColor: Colors.white,
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                final clientPhone = clientPhoneController.text;
                final amount = double.tryParse(amountController.text) ?? 0.0;
                distributorController.deposit(clientPhone, amount);
              },
              child: Text('Dépôt'),
            ),
            ElevatedButton(
              onPressed: () {
                final clientPhone = clientPhoneController.text;
                final amount = double.tryParse(amountController.text) ?? 0.0;
                distributorController.withdraw(clientPhone, amount);
              },
              child: Text('Retrait'),
            ),
            ElevatedButton(
              onPressed: () {
                // Use Navigator.push with the current context
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QRScannerPage()),
                );
              },
              child: Text('Scanner QR'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistiques',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Clients Total',
                  '${distributorController.totalClients}',
                  Icons.people_outline,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Transactions du mois',
                  '${distributorController.monthlyTransactions}',
                  Icons.sync_alt,
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
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

  Widget _buildRecentTransactions() {
    return Container(
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
          Obx(() => distributorController.recentTransactions.isEmpty
              ? Center(child: Text('Aucune transaction récente'))
              : Column(
                  children: distributorController.recentTransactions
                      .map((transaction) => _buildTransactionItem(transaction))
                      .toList(),
                )),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
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
              color: Colors.purple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.swap_horiz,
              color: Colors.purple,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['description'] ?? 'Transaction',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm')
                      .format(transaction['date'] as DateTime),
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            currencyFormat.format(transaction['amount']),
            style: TextStyle(
              color: Colors.purple,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}