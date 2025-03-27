import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_flutter_app/Jobs/JobDetails.dart';

import '../Profile Components/AllAPpliedJobs.dart';

class jobsList extends StatefulWidget {
  const jobsList({super.key});

  @override
  State<jobsList> createState() => _jobsListState();
}

class _jobsListState extends State<jobsList> {
  int _formDone = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  @override
  void initState() {
    super.initState();
    checkForm();
  }

  Future<void> checkForm() async {
    _user = _auth.currentUser;
    if (_user != null) {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection('userdata').doc(_user!.uid).get();

      if (documentSnapshot.exists) {
        final userData = documentSnapshot.data() as Map<String, dynamic>?;
        if (userData != null && userData.containsKey('formdone')) {
          setState(() {
            _formDone = userData['formdone'];
          });
        } else {
          _firestore
              .collection('userdata')
              .doc(_user!.uid)
              .set({'formdone': 3}, SetOptions(merge: true));

          setState(() {
            _formDone = 3;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.blue,
          title: const Text(
            'Jobs',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.chat,
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
        body: JobList(),
      ),
    );
  }
}

class JobList extends StatelessWidget {
  JobList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('jobsposted').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        List<DocumentSnapshot> jobDocs = snapshot.data!.docs;

        if (jobDocs.isEmpty) {
          return const Center(
            child: Text('No jobs available.'),
          );
        }

        return ListView.builder(
          itemCount: jobDocs.length,
          itemBuilder: (context, index) {
            var job = jobDocs[index].data() as Map<String, dynamic>;
            var jobId = jobDocs[index].id;

            var companyName =
                job['companyName'] as String? ?? 'Company Name Not Provided';

            var jobTitle =
                job['jobTitle'] as String? ?? 'Job Title Not Provided';

            var salary = job['salary'] as String? ?? 'Salary Not Provided';
            var postedDate = job['postedDate'] as String? ?? 'no date';

            var skills = job['skills'] as List<dynamic>?;

            var skillsText =
                skills != null ? skills.join(', ') : 'Skills Not Provided';

            var imageUrl = job['imageUrl'] as String? ?? '';

            return Container(
              margin: const EdgeInsets.all(6),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 161, 216, 211),
                borderRadius: BorderRadius.circular(5),
              ),
              child: ListTile(
                title: Text(
                  jobTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Company: $companyName',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 26, 4, 107),
                      ),
                    ),
                    Text(
                      'Salary: $salary',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 5, 94, 15),
                      ),
                    ),
                    Text(
                      'Skills: $skillsText',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 176, 60, 132),
                      ),
                    ),
                    Text(
                      'postedDate: $postedDate',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 44, 123, 214),
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JobDetailPage(jobId: jobId),
                    ),
                  );
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                // trailing: imageUrl.isNotEmpty
                //     ? Icon(Icons.image)
                //     : Padding(
                //         padding:  EdgeInsets.all(4.0),
                //         child: ClipRRect(
                //           borderRadius: BorderRadius.circular(10.0),
                //           child: BackdropFilter(
                //             filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                //             child: Container(
                //               width: 80,
                //               height: 80,
                //               color: Colors.transparent,
                //               child: Image(
                //                 image: AssetImage('assets/1.jpg'),
                //                 fit: BoxFit.cover,
                //               ),
                //             ),
                //           ),
                //         ),
                //       ),
              ),
            );
          },
        );
      },
    );
  }
}
