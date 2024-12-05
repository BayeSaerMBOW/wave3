import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ElectricityView extends StatefulWidget {
  const ElectricityView({Key? key}) : super(key: key);

  @override
  _ElectricityViewState createState() => _ElectricityViewState();
}

class _ElectricityViewState extends State<ElectricityView> {
  // Professional color palette
  final Color primaryColor = Color(0xFF2C3E50);     // Dark blue-gray
  final Color secondaryColor = Color(0xFF34495E);   // Slightly lighter blue-gray
  final Color accentColor = Color(0xFF3498DB);      // Bright blue
  final Color backgroundColor = Color(0xFFF4F6F7); // Light gray-blue
  final Color cardColor = Colors.white;
  final Color textColor = Color(0xFF2C3E50);       // Dark text color

  // Input controllers
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  String? _selectedProvider;
  String? _selectedProviderDescription;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Electricity',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Selectionner un Service'),
                const SizedBox(height: 16),
                _buildProviderGrid(),
                const SizedBox(height: 24),
                if (_selectedProvider != null) ...[
                  _buildProviderDetails(),
                  const SizedBox(height: 16),
                  _buildPaymentForm(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );
  }

  Widget _buildProviderGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      children: [
        _buildProviderCard(
          'Senelec',
          'assets/images/senelec.png',
          () => setState(() {
            _selectedProvider = 'Senelec';
            _selectedProviderDescription = 'National Electricity Company of Senegal';
          }),
        ),
        _buildProviderCard(
          'Woyofal',
          'assets/images/woyofal.png',
          () => setState(() {
            _selectedProvider = 'Woyofal';
            _selectedProviderDescription = 'Prepaid Electricity Distribution Service';
          }),
        ),
      ],
    );
  }

  Widget _buildProviderCard(String title, String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: cardColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 80,
              height: 80,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderDetails() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.electrical_services,
                color: accentColor,
                size: 24,
              ),
              SizedBox(width: 10),
              Text(
                _selectedProvider ?? '',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            _selectedProviderDescription ?? '',
            style: TextStyle(
              fontSize: 14,
              color: secondaryColor,
            ),
          ),
          if (_selectedProvider == 'Senelec') ...[
            SizedBox(height: 10),
           
          ],
          if (_selectedProvider == 'Woyofal') ...[
            SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(''),
        const SizedBox(height: 16),
        _buildTextField(
          _accountNumberController,
          _selectedProvider == 'Senelec' 
            ? 'Numero Compteur'
            : 'Numero Compteur',
          Icons.numbers,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          _amountController,
          'Montant',
          Icons.attach_money,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _processPayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
          ),
          child: Text(
            'Payer ${_selectedProvider ?? ''} ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller, 
    String label, 
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: accentColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: secondaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: secondaryColor.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
      ),
    );
  }

  void _processPayment() {
    String accountNumber = _accountNumberController.text;
    String amount = _amountController.text;

    if (accountNumber.isEmpty || amount.isEmpty) {
      _showSnackBar('Please fill in all fields.');
      return;
    }

    // Payment logic would be implemented here
    _showPaymentConfirmation();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: accentColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showPaymentConfirmation() {
    _showSnackBar('Payment for $_selectedProvider processed successfully.');
  }
}