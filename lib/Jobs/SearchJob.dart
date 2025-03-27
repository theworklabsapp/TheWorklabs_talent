import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:my_flutter_app/Jobs/JobDetails.dart';
import 'package:my_flutter_app/utils/widget_utils.dart';

class JobSearchPage extends StatelessWidget {
  const JobSearchPage({super.key});

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
            'Job Search',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
        ),
        body: JobList(),
      ),
    );
  }
}

class JobList extends StatefulWidget {
  const JobList({super.key});

  @override
  _JobListState createState() => _JobListState();
}

class _JobListState extends State<JobList> {
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> jobDocs = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.blue,
            ),
            decoration: InputDecoration(
              hintText: 'Search Jobs',
              prefixIcon: const Icon(Icons.search),
              contentPadding: const EdgeInsets.all(10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Colors.blue,
                  width: 2.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Colors.blue,
                  width: 2.0,
                ),
              ),
            ),
            onChanged: (value) {
              _searchJobs(value);
            },
          ),
        ),
        Expanded(
          child: jobDocs.isEmpty
              ? Center(
                  child: Lottie.asset(
                    'assets/animation_lmm6bvuc.json',
                    width: 350,
                    repeat: true,
                    reverse: false,
                    animate: true,
                  ),
                )
              : ListView.builder(
                  itemCount: jobDocs.length,
                  itemBuilder: (context, index) {
                    var job = jobDocs[index].data() as Map<String, dynamic>;
                    var jobId = jobDocs[index].id;

                    var jobTitle =
                        job['jobTitle'] as String? ?? 'Job Title Not Provided';
                    var companyName = job['companyName'] as String? ??
                        'Company Name Not Provided';
                    var salary =
                        job['salary'] as String? ?? 'Salary Not Provided';
                    var postedDate = job['postedDate'] as String? ?? 'no date';
                    var skills = job['skills'] as List<dynamic>?;
                    var skillsText = skills != null
                        ? skills.join(', ')
                        : 'Skills Not Provided';
                    return Container(
                      margin: const EdgeInsets.all(4),
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
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _searchJobs(String query) {
    final CollectionReference jobsCollection =
        FirebaseFirestore.instance.collection('jobsposted');

    jobsCollection
        .where('jobTitle', isGreaterThanOrEqualTo: query)
        .where('jobTitle', isLessThan: '${query}z')
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        jobDocs = querySnapshot.docs;
      });
    }).catchError((error) {
      log("Error getting documents: $error");
      WidgetUtils().showToast(error.toString());
    });
  }
}
