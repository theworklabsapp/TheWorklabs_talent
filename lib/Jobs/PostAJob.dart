import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_flutter_app/Jobs/SeeAllJobPostedByCurrentUser.dart';
import 'package:my_flutter_app/utils/widget_utils.dart';

class JobPostingPage extends StatefulWidget {
  const JobPostingPage({super.key});

  @override
  _JobPostingPageState createState() => _JobPostingPageState();
}

class _JobPostingPageState extends State<JobPostingPage> {
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _jobDescriptionController =
      TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _profileLinkController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'Post a Job',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.list,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => JobsPostedPage(),
                  ),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Job Title',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextField(
                  controller: _jobTitleController,
                  decoration: const InputDecoration(
                    hintText: 'Enter job title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Job Description',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextField(
                  controller: _jobDescriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Enter job description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Company Name',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextField(
                  controller: _companyNameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter company name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Profile Link',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextField(
                  controller: _profileLinkController,
                  decoration: const InputDecoration(
                    hintText: 'Enter profile link',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Salary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextField(
                  controller: _salaryController,
                  decoration: const InputDecoration(
                    hintText: 'Enter salary',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Skills',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextField(
                  controller: _skillsController,
                  decoration: const InputDecoration(
                    hintText: 'Enter required skills (comma-separated)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _postJobToFirestore();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color.fromARGB(255, 3, 53, 41), // Button color
                  ),
                  child: const Text(
                    'Post Job',
                    style: TextStyle(
                      fontSize: 18,
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

  void _postJobToFirestore() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    String uid = user.uid;

    CollectionReference jobsCollection =
        FirebaseFirestore.instance.collection('jobsposted');

    Map<String, dynamic> jobData = {
      'jobTitle': _jobTitleController.text,
      'jobDescription': _jobDescriptionController.text,
      'companyName': _companyNameController.text,
      'profileLink': _profileLinkController.text,
      'salary': _salaryController.text,
      'skills': _skillsController.text.split(','),
      'postedBy': uid,
      'postedDate': DateTime.now().toLocal().toString(),
    };

    try {
      await jobsCollection.add(jobData);

      _showSuccessMessage(context);

      _clearTextFields();
    } catch (e) {
      log('Error posting job: $e');
      WidgetUtils().showToast(e.toString());
    }
  }

  void _showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Job posted successfully!',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _clearTextFields() {
    _jobTitleController.clear();
    _jobDescriptionController.clear();
    _companyNameController.clear();
    _profileLinkController.clear();
    _salaryController.clear();
    _skillsController.clear();
  }
}
