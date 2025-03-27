import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_flutter_app/Jobs/ApplicationFormPage.dart';

class JobDetailPage extends StatefulWidget {
  final String jobId;

  const JobDetailPage({super.key, required this.jobId});

  @override
  State<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<JobDetailPage> {
  final User? user = FirebaseAuth.instance.currentUser;

  bool hasApplied = false;
  bool shouldReload = false;
  @override
  void initState() {
    super.initState();
    checkApplicationStatus();
  }

  void checkApplicationStatus() async {
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('jobsposted')
          .doc(widget.jobId)
          .collection('applications')
          .doc(user!.uid)
          .get();

      setState(() {
        hasApplied = snapshot.exists;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Job Details',
          style: TextStyle(color: Colors.white),
        ),
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back_outlined, color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('jobsposted')
            .doc(widget.jobId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var jobData = snapshot.data!.data() as Map<String, dynamic>;
          var jobTitle =
              jobData['jobTitle'] as String? ?? 'Job Title Not Provided';
          var companyName =
              jobData['companyName'] as String? ?? 'Company Name Not Provided';
          var jobDescription = jobData['jobDescription'] as String? ??
              'Job Description Not Provided';
          var salary = jobData['salary'] as String? ?? 'Salary Not Provided';
          var companyImageURL = jobData['companyImageURL'] as String? ?? '';
          var skills = jobData['skills'] as List<dynamic>?;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*Container(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.asset(
                          'assets/1.jpg',
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),*/
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(jobTitle,
                          style: const TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue)),
                      const SizedBox(height: 10.0),
                      Text('Company: $companyName',
                          style: const TextStyle(color: Colors.green)),
                      Text('Salary: $salary',
                          style: const TextStyle(color: Colors.orange)),
                      const SizedBox(height: 20.0),
                      Container(
                        width: 450,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(1.0)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Job Description',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            Text(
                              jobDescription,
                              style: const TextStyle(
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (companyImageURL.isNotEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.network(
                          companyImageURL,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                if (skills != null && skills.isNotEmpty)
                  Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        width: 300,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Skills Required',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            Wrap(
                              spacing: 8.0,
                              children: skills.map((skill) {
                                    return Chip(
                                      label: Text(
                                        skill,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      backgroundColor: Colors.indigo,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4.0,
                                        horizontal: 8.0,
                                      ),
                                    );
                                  }).toList() ??
                                  [],
                            ),
                          ],
                        ),
                      )),
                const SizedBox(height: 16.0),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!hasApplied) {
                        final shouldReloadFromSecondPage = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ApplicationFormPage(
                              jobId: widget.jobId,
                              currentUser: user,
                            ),
                          ),
                        );
                        if (shouldReloadFromSecondPage == true) {
                          setState(() {
                            shouldReload = true;
                          });
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasApplied ? Colors.grey : Colors.blue,
                    ),
                    child: Text(hasApplied ? 'Already Applied' : 'Apply'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
