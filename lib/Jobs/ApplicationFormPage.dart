import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_flutter_app/utils/widget_utils.dart'; // Import Firebase Authentication

class ApplicationFormPage extends StatelessWidget {
  final String jobId;
  final User? currentUser; // User object to hold the current user

  ApplicationFormPage(
      {super.key, required this.jobId, required this.currentUser});

  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _projectController = TextEditingController();
  final TextEditingController _salaryExpectationController =
      TextEditingController();
  final TextEditingController _availabilityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Apply for Job',
          style: TextStyle(color: Colors.white),
        ),
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back_outlined, color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 3, 53, 41),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Why should I hire you?',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextField(
                controller: _experienceController,
                decoration: const InputDecoration(
                  hintText: 'Years of experience...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Have you worked on any projects?',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextField(
                controller: _projectController,
                decoration: const InputDecoration(
                  hintText: 'Enter project details...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Salary Expectation',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextField(
                controller: _salaryExpectationController,
                decoration: const InputDecoration(
                  hintText: 'Enter your salary expectation...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Are you available immediately?',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextField(
                controller: _availabilityController,
                decoration: const InputDecoration(
                  hintText: 'Yes or No',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  String experience = _experienceController.text;
                  String projects = _projectController.text;
                  String salaryExpectation = _salaryExpectationController.text;
                  String availability = _availabilityController.text;

                  if (experience.isNotEmpty &&
                      projects.isNotEmpty &&
                      salaryExpectation.isNotEmpty &&
                      availability.isNotEmpty) {
                    String userUid = currentUser?.uid ?? '';
                    FirebaseFirestore.instance
                        .collection('jobsposted')
                        .doc(jobId)
                        .collection('applications')
                        .doc(userUid)
                        .set({
                      'experience': experience,
                      'projects': projects,
                      'salaryExpectation': salaryExpectation,
                      'availability': availability,
                    }).then((_) {
                      log('Application submitted for jobId: $jobId');
                      log('User UID: $userUid');
                      log('Experience: $experience');
                      log('Projects: $projects');
                      log('Salary Expectation: $salaryExpectation');
                      log('Availability: $availability');
                      Navigator.pop(context, true);
                    }).catchError((error) {
                      log('Error submitting application: $error');
                      WidgetUtils().showToast(error);
                    });
                  }
                },
                child: const Text('Submit Application'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
