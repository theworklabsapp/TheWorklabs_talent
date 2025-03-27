import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_flutter_app/formsForFirst/jobdata.dart';
import 'package:my_flutter_app/utils/widget_utils.dart';

class AddEducationPage extends StatefulWidget {
  const AddEducationPage({super.key});

  @override
  _AddEducationPageState createState() => _AddEducationPageState();
}

class _AddEducationPageState extends State<AddEducationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();

  String _message = '';
  Future<void> _addEducation() async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final User? user = auth.currentUser;

      if (user != null) {
        final uid = user.uid;

        final educationDetails = {
          'educationType': _companyController.text,
          'college/university': _startDateController.text,
          'completion': _endDateController.text,
          'course': _descriptionController.text,
          'cgpa': _skillsController.text,
        };

        await FirebaseFirestore.instance
            .collection('userdata')
            .doc(uid)
            .collection('Educations')
            .add(educationDetails);

        await FirebaseFirestore.instance
            .collection('userdata')
            .doc(uid)
            .update({'formdone': 1});

        setState(() {
          _message = 'Data added successfully';
        });
      }
    } catch (e) {
      WidgetUtils().showToast(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Education',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 6, 60, 74),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.all(16.0),
          color: Colors.grey[200],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _companyController,
                    decoration: const InputDecoration(
                      labelText: 'Education Type',
                      icon: Icon(
                        Icons.person,
                        color: Colors.orange,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a Education Type';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _startDateController,
                    decoration: const InputDecoration(
                      labelText: 'college and univercity',
                      icon: Icon(
                        Icons.person,
                        color: Colors.orange,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a college and univercity';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _endDateController,
                    decoration: const InputDecoration(
                      labelText: 'Completion',
                      icon: Icon(
                        Icons.person,
                        color: Colors.orange,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter an Completion date';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'course',
                      icon: Icon(
                        Icons.person,
                        color: Colors.orange,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a course';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _skillsController,
                    decoration: const InputDecoration(
                      labelText: 'cgpa',
                      icon: Icon(
                        Icons.person,
                        color: Colors.orange,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter cgpa';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 169, 186, 190),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await _addEducation();
                      }
                    },
                    child: const Text('Add Education'),
                  ),
                  const SizedBox(height: 20),
                  if (_message.isNotEmpty)
                    Text(
                      _message,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      backgroundColor: const Color.fromARGB(255, 6, 60, 74),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddExperiencePage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Done',
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
      ),
    );
  }
}

class TempPage extends StatefulWidget {
  const TempPage({super.key});

  @override
  State<TempPage> createState() => _TempPageState();
}

class _TempPageState extends State<TempPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
