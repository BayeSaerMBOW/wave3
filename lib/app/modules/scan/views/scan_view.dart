import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:get/get.dart';
import '../../../modules/distributor/controllers/distributor_controller.dart';

class _QRScannerPageState extends State<QRScannerPage> {
  final DistributorController distributorController = Get.find();
  MobileScannerController cameraController = MobileScannerController();
  bool isScanning = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner QR'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                return Icon(
                  state == TorchState.off ? Icons.flash_off : Icons.flash_on,
                );
              },
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.cameraFacingState,
              builder: (context, state, child) {
                return Icon(
                  state == CameraFacing.front
                      ? Icons.camera_front
                      : Icons.camera_rear,
                );
              },
            ),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: MobileScanner(
        controller: cameraController,
        onDetect: _foundBarcode,
        errorBuilder: (context, error, child) {
          return Center(
            child: Text(
              'Erreur de scanner: ${error.errorDetails?.message}',
              style: TextStyle(color: Colors.red),
            ),
          );
        },
      ),
    );
  }

  void _foundBarcode(BarcodeCapture barcodeCapture) {
    if (!isScanning) return;
    
    final List<Barcode> barcodes = barcodeCapture.barcodes;
    if (barcodes.isEmpty) return;

    isScanning = false; // Évite les scans multiples
    
    final String rawValue = barcodes.first.rawValue ?? "";
    print('Code QR détecté: $rawValue'); // Debug

    try {
      List<String> data = rawValue.split(',');
      if (data.length == 2) {
        String clientPhone = data[0];
        double amount = double.tryParse(data[1]) ?? 0.0;
        
        // Afficher un feedback à l'utilisateur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Code QR détecté avec succès!')),
        );

        distributorController.deposit(clientPhone, amount);
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Format de code QR invalide')),
        );
        isScanning = true; // Réactive le scan
      }
    } catch (e) {
      print('Erreur lors du traitement du code QR: $e');
      isScanning = true; // Réactive le scan
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}