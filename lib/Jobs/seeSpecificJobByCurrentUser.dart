import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../chats/chatByRecruiter.dart';

class SeeSpecificJobApplicants extends StatelessWidget {
  final String documentId;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  SeeSpecificJobApplicants({super.key, required this.documentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'ALL Applicants',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<User?>(
        future: _auth.authStateChanges().first,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            final currentUser = snapshot.data;

            return StreamBuilder<DocumentSnapshot>(
              stream: _firestore
                  .collection('jobsposted')
                  .doc(documentId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData) {
                  return const Center(child: Text('Job not found.'));
                } else {
                  final jobData = snapshot.data!.data() as Map<String, dynamic>;
                  final jobTitle = jobData['jobTitle'];
                  final jobDescription = jobData['jobDescription'];
                  final postedDate = jobData['postedDate'];

                  return StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('jobsposted')
                        .doc(documentId)
                        .collection('applications')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData ||
                          snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No applications found.'));
                      } else {
                        final applicationDocs = snapshot.data!.docs;
                        return Padding(
                          padding:
                              const EdgeInsets.only(left: 12.0, right: 12, top: 10),
                          child: ListView.builder(
                            itemCount: applicationDocs.length,
                            itemBuilder: (context, index) {
                              final applicationData = applicationDocs[index]
                                  .data() as Map<String, dynamic>;
                              final availability =
                                  applicationData['availability'];
                              final experience = applicationData['experience'];
                              final projects = applicationData['projects'];
                              final salaryExpectation =
                                  applicationData['salaryExpectation'];

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatRecruiter(
                                        jobId: documentId,
                                        applicationId:
                                            applicationDocs[index].id,
                                      ),
                                    ),
                                  );
                                },
                                child: Card(
                                  child: Container(
                                    //margin: EdgeInsets.all(8),
                                    // padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      //color: Color.fromARGB(255, 211, 208, 171),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ListTile(
                                      title:
                                          Text('Availability: $availability'),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Experience: $experience'),
                                          Text('Projects: $projects'),
                                          Text(
                                              'Salary Expectation: $salaryExpectation'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
                  );
                }
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
