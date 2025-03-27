import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_flutter_app/Components/ChatWithRecruiter.dart';

class ChatWithRecruiterPage extends StatelessWidget {
  final String jobId;
  final String userId;

  const ChatWithRecruiterPage(
      {super.key, required this.jobId, required this.userId});

  @override
  Widget build(BuildContext context) {
    // Use the jobId and userId to set up the chat with the recruiter.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with Recruiter'),
      ),
      body: Center(
        child: Text('Job ID: $jobId\nUser ID: $userId'),
      ),
    );
  }
}

class JobsPostedPage extends StatefulWidget {
  const JobsPostedPage({super.key});

  @override
  _JobsPostedPageState createState() => _JobsPostedPageState();
}

class _JobsPostedPageState extends State<JobsPostedPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late User currentUser;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    currentUser = _auth.currentUser!;
    setState(() {});
  }

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
        title: const Text('All Job Applied',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: currentUser == null
          ? const CircularProgressIndicator()
          : StreamBuilder(
              stream: _firestore.collection('jobsposted').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                final jobDocs = snapshot.data?.docs ?? [];

                return ListView.builder(
                  itemCount: jobDocs.length,
                  itemBuilder: (context, index) {
                    final jobDoc = jobDocs[index];
                    final applicationsCollection =
                        jobDoc.reference.collection('applications');
                    final applicationDoc =
                        applicationsCollection.doc(currentUser.uid);

                    return FutureBuilder(
                      future: applicationDoc.get(),
                      builder: (context,
                          AsyncSnapshot<DocumentSnapshot> applicationSnapshot) {
                        if (applicationSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        final jobId = jobDoc.id;

                        if (applicationSnapshot.hasError) {
                          return Text('Error: ${applicationSnapshot.error}');
                        }

                        if (applicationSnapshot.hasData &&
                            applicationSnapshot.data!.exists) {
                          final jobData = jobDoc.data() as Map<String, dynamic>;
                          final companyName = jobData['companyName'] as String?;
                          final jobTitle = jobData['jobTitle'] as String?;

                          if (companyName != null && jobTitle != null) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatPage(
                                      jobId: jobId,
                                      applicationId: currentUser.uid,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.all(6),
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(255, 132, 227, 127),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: ListTile(
                                  title: Text('Company: $companyName'),
                                  subtitle: Text('Job Title: $jobTitle'),
                                  trailing: const Icon(
                                    Icons.chat,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return ListTile(
                              title: Text('Job ID: $jobId (No Application)'),
                            );
                          }
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: JobsPostedPage(),
  ));
}
