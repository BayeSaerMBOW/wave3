import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/phone_credit_controller.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class PhoneCreditView extends StatefulWidget {
  @override
  _PhoneCreditViewState createState() => _PhoneCreditViewState();
}

class _PhoneCreditViewState extends State<PhoneCreditView> {
  final PhoneCreditController controller = Get.put(PhoneCreditController());
  bool _showForm = false;
  String _selectedOperator = '';

  void _selectOperator(String operator) {
    setState(() {
      _selectedOperator = operator;
      _showForm = true;
    });
  }

  void _showContactPicker(BuildContext context) async {
    await controller.loadContacts();
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Sélectionner un contact',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),
              Expanded(
                child: Obx(() {
                  return ListView.separated(
                    separatorBuilder: (context, index) => Divider(height: 1),
                    itemCount: controller.contacts.length,
                    itemBuilder: (context, index) {
                      final contact = controller.contacts[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Icon(Icons.person, color: Colors.blue.shade800),
                        ),
                        title: Text(
                          contact.displayName,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          contact.phones.isNotEmpty ? contact.phones.first.number : '',
                          style: TextStyle(color: Colors.grey),
                        ),
                        onTap: () {
                          if (contact.phones.isNotEmpty) {
                            controller.selectContact(contact);
                            Navigator.pop(context);
                          }
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOperatorGrid(BoxConstraints constraints) {
    int crossAxisCount = constraints.maxWidth > 600 ? 4 : 3;
    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildOperatorImage(
          imagePath: 'assets/images/free.png',
          label: 'Free',
          onTap: () => _selectOperator('Free'),
        ),
        _buildOperatorImage(
          imagePath: 'assets/images/Orange.png',
          label: 'Orange',
          onTap: () => _selectOperator('Orange'),
        ),
        _buildOperatorImage(
          imagePath: 'assets/images/expresso.jpg',
          label: 'Expresso',
          onTap: () => _selectOperator('Expresso'),
        ),
        if (constraints.maxWidth > 600)
          _buildOperatorImage(
            imagePath: 'assets/images/free.png',
            label: 'Autre',
            onTap: () => _selectOperator('Autre'),
          ),
      ],
    );
  }

  Widget _buildOperatorImage({
    required String imagePath,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 80,
              height: 80,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditPurchaseForm(BoxConstraints constraints) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 10),
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Achat de Crédit - $_selectedOperator',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          SizedBox(height: 20),
          _buildPhoneNumberField(),
          SizedBox(height: 16),
          _buildAmountField(),
          SizedBox(height: 20),
          _buildPurchaseButton(),
        ],
      ),
    );
  }

  Widget _buildPhoneNumberField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller.phoneNumberController.value,
            decoration: InputDecoration(
              labelText: 'Numéro de téléphone',
              prefixIcon: Icon(Icons.phone, color: Colors.blue),
              border: _outlineInputBorder(),
              focusedBorder: _outlineInputBorder(isFocused: true),
            ),
            onChanged: (value) => controller.phoneNumber.value = value,
          ),
        ),
        SizedBox(width: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(Icons.contacts, color: Colors.blue),
            onPressed: () => _showContactPicker(context),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountField() {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Montant',
        prefixIcon: Icon(Icons.attach_money, color: Colors.blue),
        border: _outlineInputBorder(),
        focusedBorder: _outlineInputBorder(isFocused: true),
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) => controller.amount.value = double.tryParse(value) ?? 0.0,
    );
  }

  Widget _buildPurchaseButton() {
    return ElevatedButton(
      onPressed: () => controller.buyPhoneCredit(),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 48),
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
      ),
      child: Text(
        'Acheter du Crédit',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  OutlineInputBorder _outlineInputBorder({bool isFocused = false}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(
        color: isFocused ? Colors.blue : Colors.grey.shade300,
        width: isFocused ? 2 : 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            title: Text(
              'Crédit Téléphonique',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.blue,
            elevation: 0,
            centerTitle: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(constraints.maxWidth > 600 ? 40.0 : 20.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choisissez votre opérateur',
                          style: TextStyle(
                            fontSize: constraints.maxWidth > 600 ? 32 : 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        SizedBox(height: 20),
                        _buildOperatorGrid(constraints),
                        SizedBox(height: 20),
                        if (_showForm) _buildCreditPurchaseForm(constraints),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}