import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_flutter_app/formsForFirst/education.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Information',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 6, 60, 74),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () async {
              await _signOut();
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.all(16.0),
          color: Colors.grey[200],
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextFormField(
                  controller: _nameController,
                  labelText: 'Full Name',
                  icon: Icons.person,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                _buildTextFormField(
                  controller: _emailController,
                  labelText: 'Email',
                  icon: Icons.email,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your email';
                    } else if (!value.contains('@')) {
                      return 'Email must contain @';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                _buildTextFormField(
                  controller: _phoneController,
                  labelText: 'Phone Number',
                  icon: Icons.phone,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your phone number';
                    } else if (value.length != 10) {
                      return 'Phone number must be 10 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Address',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      _buildTextFormField(
                        controller: _pincodeController,
                        labelText: 'Pincode',
                        icon: Icons.location_on,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter the pincode';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      _buildTextFormField(
                        controller: _cityController,
                        labelText: 'City',
                        icon: Icons.location_city,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter the city';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      _buildTextFormField(
                        controller: _countryController,
                        labelText: 'Country',
                        icon: Icons.location_on,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter the country';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    backgroundColor: const Color.fromARGB(255, 6, 60, 74),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _saveUserDataToFirestore();
                    }
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextFormField _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        icon: Icon(
          icon,
          color: Colors.orange,
        ),
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pop(context);
  }

  Future<void> _saveUserDataToFirestore() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'address': {
          'pincode': _pincodeController.text,
          'city': _cityController.text,
          'country': _countryController.text,
        },
      };
      final docId = currentUser.uid;
      final userRef =
          FirebaseFirestore.instance.collection('userdata').doc(docId);

      await userRef.set(userData);

      await userRef.update({'formdone': 2});

      _showSuccessMessage();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddEducationPage(),
        ),
      );
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('User information saved successfully.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _pincodeController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }
}
