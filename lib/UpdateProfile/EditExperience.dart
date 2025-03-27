import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_flutter_app/utils/widget_utils.dart';

void main() {
  runApp(const EditExperience());
}

class EditExperience extends StatefulWidget {
  const EditExperience({super.key});

  @override
  State<EditExperience> createState() => _EditExperienceState();
}

class _EditExperienceState extends State<EditExperience> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  List<Map<String, dynamic>> _experiences = [];
  List<DocumentReference> _experiences2 = [];
  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _user = user;
      });
      try {
        final experiencesData = await _firestore
            .collection('userdata')
            .doc(user.uid)
            .collection('experiences')
            .get();
        _experiences2 =
            experiencesData.docs.map((doc) => doc.reference).toList();
        setState(() {
          _experiences = experiencesData.docs.map((doc) => doc.data()).toList();
        });
      } catch (e) {
        WidgetUtils().showToast(e.toString());
      }
    }
  }

  void _openAddExperienceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddExperienceDialog(
          onAddExperience: (newExperience) {
            _addExperience(newExperience);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _addExperience(Map<String, dynamic> newExperience) async {
    if (_user != null) {
      final userUid = _user!.uid;

      await _firestore
          .collection('userdata')
          .doc(userUid)
          .collection('experiences')
          .add(newExperience)
          .catchError((e) {
        WidgetUtils().showToast(e.toString());
      });

      setState(() {
        _experiences.add(newExperience);
      });
    }
  }

  void _deleteExperience(Map<String, dynamic> experienceToDelete) async {
    if (_user != null) {
      final userUid = _user!.uid;

      try {
        final experiencesData = await _firestore
            .collection('userdata')
            .doc(userUid)
            .collection('experiences')
            .where('companyName', isEqualTo: experienceToDelete['companyName'])
            .where('description', isEqualTo: experienceToDelete['description'])
            .get();

        if (experiencesData.docs.isNotEmpty) {
          final documentReference = experiencesData.docs.first.reference;
          await documentReference.delete();
        }

        setState(() {
          _experiences.remove(experienceToDelete);
        });
      } catch (e) {
        log("Error deleting experience: $e");
        WidgetUtils().showToast(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back, color: Colors.white)),
          centerTitle: true,
          title:
              const Text('Experience', style: TextStyle(color: Colors.white)),
        ),
        backgroundColor: const Color.fromARGB(255, 228, 232, 231),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              for (var experience in _experiences)
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.all(16),
                  child: Stack(
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Text(
                                  'Experience',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ListTile(
                                  leading: const Icon(
                                    Icons.work,
                                    color: Colors.amber,
                                  ),
                                  title: Text(
                                      'Company: ${experience['companyName'] ?? 'N/A'}'),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Company Name: ${experience['companyName'] ?? 'N/A'}',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                      Text(
                                        'Description: ${experience['description'] ?? 'N/A'}',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                      Text(
                                        'Start Date: ${experience['startDate'] ?? 'N/A'}',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                      Text(
                                        'End Date: ${experience['endDate'] ?? 'N/A'}',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                      Text(
                                        'Skills: ${experience['skills'] ?? 'N/A'}',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      _deleteExperience(experience);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 12, 12, 12),
            borderRadius: BorderRadius.circular(20.0),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: InkWell(
            onTap: () {
              _openAddExperienceDialog();
            },
            child: Text(
              'Add Experience',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AddExperienceDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onAddExperience;

  AddExperienceDialog({super.key, required this.onAddExperience});

  @override
  _AddExperienceDialogState createState() => _AddExperienceDialogState();
}

class _AddExperienceDialogState extends State<AddExperienceDialog> {
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add Experience"),
      content: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            TextField(
              controller: _companyNameController,
              decoration: InputDecoration(labelText: "Company Name"),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: "Description"),
            ),
            TextField(
              controller: _startDateController,
              decoration: InputDecoration(labelText: "Start Date"),
            ),
            TextField(
              controller: _endDateController,
              decoration: InputDecoration(labelText: "End Date"),
            ),
            TextField(
              controller: _skillsController,
              decoration: InputDecoration(labelText: "Skills"),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            final newExperience = {
              'companyName': _companyNameController.text,
              'description': _descriptionController.text,
              'startDate': _startDateController.text,
              'endDate': _endDateController.text,
              'skills': _skillsController.text,
            };

            widget.onAddExperience(newExperience);
          },
          child: Text("Add"),
        ),
      ],
    );
  }
}
