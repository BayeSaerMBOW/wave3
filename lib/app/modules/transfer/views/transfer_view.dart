import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../controllers/transfer_controller.dart';

class TransferView extends StatelessWidget {
  final TransferController transferController = Get.put(TransferController());
  final TextEditingController receiverPhoneNumberController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Transfert d\'argent',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Colors.white,
            ],
            stops: [0.0, 0.3],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCard(_buildSingleTransferSection()),
                SizedBox(height: 24),
                _buildCard(_buildMultipleTransferSection()),
                SizedBox(height: 16),
                Obx(() => Text(
                  transferController.errorMessage.value,
                  style: TextStyle(
                    color: Colors.red[700],
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(Widget child) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: Get.theme.primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? suffixText,
    TextInputType? keyboardType,
    int maxLines = 1,
    Widget? suffix,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          suffixText: suffixText,
          suffixIcon: suffix,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Get.theme.primaryColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    bool isPrimary = true,
  }) {
    return Container(
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? Get.theme.primaryColor : Colors.grey[200],
          foregroundColor: isPrimary ? Colors.white : Colors.black87,
          elevation: isPrimary ? 4 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isPrimary ? Colors.white : Get.theme.primaryColor,
                  ),
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildSingleTransferSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle('Transfert Simple'),
        _buildTextField(
          controller: receiverPhoneNumberController,
          label: 'Numéro de téléphone du destinataire',
          keyboardType: TextInputType.phone,
          suffix: IconButton(
            icon: Icon(Icons.contacts, color: Get.theme.primaryColor),
            onPressed: () => _pickContact(Get.context!),
          ),
        ),
        _buildTextField(
          controller: amountController,
          label: 'Montant',
          suffixText: 'FCFA',
          keyboardType: TextInputType.number,
        ),
        _buildTextField(
          controller: descriptionController,
          label: 'Description (optionnel)',
          maxLines: 2,
        ),
        SizedBox(height: 8),
        Obx(() => _buildButton(
          text: 'Confirmer le transfert simple',
          onPressed: _performSingleTransfer,
          isLoading: transferController.isLoading.value,
        )),
      ],
    );
  }

  Widget _buildMultipleTransferSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle('Transfert Multiple'),
        _buildTextField(
          controller: amountController,
          label: 'Montant par personne',
          suffixText: 'FCFA',
          keyboardType: TextInputType.number,
        ),
        _buildTextField(
          controller: descriptionController,
          label: 'Description (optionnel)',
          maxLines: 2,
        ),
        SizedBox(height: 8),
        _buildButton(
          text: 'Sélectionner les destinataires',
          onPressed: () => _pickMultipleContacts(Get.context!),
          isPrimary: false,
        ),
        SizedBox(height: 16),
        Obx(() => transferController.selectedContacts.isNotEmpty
            ? Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Destinataires sélectionnés (${transferController.selectedContacts.length}):',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    ...transferController.selectedContacts.map((contact) => Container(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.person, size: 20, color: Get.theme.primaryColor),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${contact['name']} (${contact['phone']})',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.remove_circle_outline, 
                              color: Colors.red[400],
                              size: 20,
                            ),
                            onPressed: () => transferController.selectedContacts
                                .removeWhere((c) => c['phone'] == contact['phone']),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              )
            : Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Aucun destinataire sélectionné',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              )),
        SizedBox(height: 16),
        Obx(() => _buildButton(
          text: 'Confirmer le transfert multiple',
          onPressed: _performMultipleTransfer,
          isLoading: transferController.isLoading.value,
        )),
      ],
    );
  }

  void _performSingleTransfer() {
    final receiverPhoneNumber = receiverPhoneNumberController.text.trim();
    final amount = double.tryParse(amountController.text) ?? 0.0;
    final description = descriptionController.text.trim();

    if (receiverPhoneNumber.isEmpty || amount <= 0) {
      transferController.errorMessage('Veuillez remplir tous les champs correctement');
      return;
    }

    transferController.performSingleTransfer(
      receiverPhoneNumber: receiverPhoneNumber,
      amount: amount,
      description: description,
    ).then((success) {
      if (success) {
        Get.snackbar(
          'Succès',
          'Transfert effectué avec succès',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        // Réinitialiser les champs après un transfert réussi
        _resetFields();
      }
    });
  }

  void _performMultipleTransfer() {
    final amount = double.tryParse(amountController.text) ?? 0.0;
    final description = descriptionController.text.trim();

    if (amount <= 0) {
      transferController.errorMessage('Veuillez entrer un montant valide');
      return;
    }

    if (transferController.selectedContacts.isEmpty) {
      transferController.errorMessage('Veuillez sélectionner au moins un destinataire');
      return;
    }

    transferController.performMultipleTransfer(
      receivers: transferController.selectedContacts,
      amount: amount,
      description: description,
    ).then((success) {
      if (success) {
        Get.snackbar(
          'Succès',
          'Transfert multiple effectué avec succès',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        // Réinitialiser les champs après un transfert réussi
        _resetFields();
      }
    });
  }

  void _resetFields() {
    receiverPhoneNumberController.clear();
    amountController.clear();
    descriptionController.clear();
    transferController.selectedContacts.clear();
  }

  Future<void> _pickContact(BuildContext context) async {
    if (await Permission.contacts.request().isGranted) {
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      if (contacts.isNotEmpty) {
        _showContactList(context, contacts, singleSelect: true);
      }
    } else {
      Get.snackbar('Permission refusée', 'Veuillez accorder l\'accès aux contacts');
    }
  }

  Future<void> _pickMultipleContacts(BuildContext context) async {
    if (await Permission.contacts.request().isGranted) {
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      if (contacts.isNotEmpty) {
        _showContactList(context, contacts, singleSelect: false);
      }
    } else {
      Get.snackbar('Permission refusée', 'Veuillez accorder l\'accès aux contacts');
    }
  }

  void _showContactList(BuildContext context, List<Contact> contacts, {required bool singleSelect}) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: Text(
                singleSelect ? 'Sélectionner un contact' : 'Sélectionner les contacts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  if (contact.phones.isEmpty) return SizedBox.shrink();
                  
                  final phoneNumber = contact.phones.first.number ?? '';
                  
                  return ListTile(
                    title: Text(contact.displayName),
                    subtitle: Text(phoneNumber),
                    onTap: () {
                      if (singleSelect) {
                        receiverPhoneNumberController.text = phoneNumber;
                      } else {
                        // Vérifier si le contact n'est pas déjà sélectionné
                        final isAlreadySelected = transferController.selectedContacts
                            .any((c) => c['phone'] == phoneNumber);
                            
                        if (!isAlreadySelected) {
                          transferController.selectedContacts.add({
                            'name': contact.displayName,
                            'phone': phoneNumber,
                          });
                        }
                      }
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}