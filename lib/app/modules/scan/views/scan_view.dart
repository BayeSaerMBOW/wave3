import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:get/get.dart';
import '../../../modules/distributor/controllers/distributor_controller.dart';

class QRScannerPage extends StatefulWidget {
  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final DistributorController distributorController = Get.find();
  MobileScannerController cameraController = MobileScannerController();
  String? scannedValue;
  bool isDeposit = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6A1B9A),
              Color(0xFF8E24AA),
              Color(0xFFAB47BC)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: scannedValue == null
                    ? _buildScannerView()
                    : _buildAmountForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'QR Scanner',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 48), // To center the title
        ],
      ),
    );
  }

 Widget _buildScannerView() {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white54, width: 2),
      boxShadow: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 10,
          spreadRadius: 2,
        )
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: MobileScanner(
        controller: cameraController,
        onDetect: _foundBarcode,
      ),
    ),
  );
}

  void _foundBarcode(BarcodeCapture barcodeCapture) {
    final Barcode? barcode = barcodeCapture.barcodes.firstOrNull;
    if (barcode != null) {
      final String rawValue = barcode.rawValue ?? "";
      setState(() {
        scannedValue = rawValue;
      });
    }
  }

  Widget _buildAmountForm() {
    final TextEditingController amountController = TextEditingController();
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'YONEL',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6A1B9A),
            ),
          ),
          SizedBox(height: 10),
          Text(
            '$scannedValue',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 20),
          _buildTransactionTypeToggle(),
          SizedBox(height: 20),
          _buildAmountTextField(amountController),
          SizedBox(height: 20),
          _buildSubmitButton(amountController),
        ],
      ),
    );
  }

  Widget _buildTransactionTypeToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _transactionTypeButton(
          text: 'Dépôt',
          isSelected: isDeposit,
          onPressed: () => setState(() => isDeposit = true),
        ),
        SizedBox(width: 20),
        _transactionTypeButton(
          text: 'Retrait',
          isSelected: !isDeposit,
          onPressed: () => setState(() => isDeposit = false),
        ),
      ],
    );
  }

  Widget _transactionTypeButton({
    required String text,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Color(0xFF6A1B9A) : Colors.grey[400],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        elevation: 5,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildAmountTextField(TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Montant',
        prefixIcon: Icon(Icons.attach_money, color: Color(0xFF6A1B9A)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Color(0xFF6A1B9A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Color(0xFF6A1B9A), width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
      keyboardType: TextInputType.number,
      style: TextStyle(fontSize: 18),
    );
  }

  Widget _buildSubmitButton(TextEditingController amountController) {
    return ElevatedButton(
      onPressed: () {
        final amount = double.tryParse(amountController.text) ?? 0.0;
        if (isDeposit) {
          distributorController.deposit(scannedValue!, amount);
        } else {
          distributorController.withdraw(scannedValue!, amount);
        }
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF6A1B9A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.symmetric(vertical: 15),
        elevation: 6,
      ),
      child: Text(
        isDeposit ? 'Déposer' : 'Retirer',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}