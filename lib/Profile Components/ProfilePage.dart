import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_flutter_app/Profile%20Components/Logine.dart';
import 'package:my_flutter_app/formsForFirst/education.dart';
import 'package:my_flutter_app/formsForFirst/jobdata.dart';
import 'package:my_flutter_app/formsForFirst/userInfoData.dart';
import 'package:my_flutter_app/utils/widget_utils.dart';

import '../UpdateProfile/EditExperience.dart';
import '../UpdateProfile/UpdateBio.dart';
import '../UpdateProfile/updateskills.dart';

void main() {
  runApp(const JobProfilePage());
}

class JobProfilePage extends StatefulWidget {
  const JobProfilePage({super.key});

  @override
  State<JobProfilePage> createState() => _JobProfilePageState();
}

class _JobProfilePageState extends State<JobProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  List<Map<String, dynamic>> _experiences = [];
  Map<String, dynamic> _userData = {};
  List<dynamic> _skills = [];
  int _formDone = 0;
  List<Color> skillColors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
    // Add more colors as needed
  ];
  @override
  void initState() {
    super.initState();
    checkForm();
    _getUserData();
  }

  Future<void> checkForm() async {
    _user = _auth.currentUser;
    if (_user != null) {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('userdata')
          .doc(_user!.uid) // Use the current user's UID as the document ID
          .get();

      if (documentSnapshot.exists) {
        final userData = documentSnapshot.data() as Map<String, dynamic>?;
        if (userData != null && userData.containsKey('formdone')) {
          // If 'formdone' field is present, set its value
          setState(() {
            _formDone = userData['formdone'];
          });
        } else {
          // If 'formdone' field is not present, set it to 5
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

  Future<void> _getUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _user = user;
      });
      final userData =
          await _firestore.collection('userdata').doc(user.uid).get();
      if (userData.exists) {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return WidgetUtils().showProgress();
            });
        final userDataMap = userData.data() as Map<String, dynamic>;

        setState(() {
          _userData = userDataMap;
        });

        final experiencesData = await _firestore
            .collection('userdata')
            .doc(user.uid)
            .collection('experiences')
            .get();
        setState(() {
          _experiences = experiencesData.docs.map((doc) => doc.data()).toList();
        });

        // Fetch the "skills" field from the user's Firestore document
        final skills = userData['skills'] as List<dynamic>;
        setState(() {
          _skills =
              skills.cast<String>(); // Assign the skills to the _skills list
        });

        log("skills====${_skills.asMap().entries.map((e) => e.value)}");
        Navigator.of(context).pop();
        // Now you can access the 'email' property from userDataMap
        log('User Email: ${userDataMap['email']}');

        // Update your widget with the user data
      }
    }
  }

  Future<void> signOutUser() async {
    try {
      await _auth.signOut();
      log("User signed out successfully");
    } catch (e) {
      log("Error signing out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WillPopScope(
        onWillPop: () async {
          // Return true to allow navigation back, return false to prevent it
          return false; // Prevent back navigation
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue,
            title: const Text('Profile', style: TextStyle(color: Colors.white)),
            actions: [
              IconButton(
                  onPressed: () {
                    signOutUser().then((value) {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()),
                          (route) => false);
                    });
                  },
                  icon: const Icon(Icons.logout, color: Colors.white))
            ],
          ),
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Stack(
              children: <Widget>[
                // Background Gradient
                Stack(
                  alignment: Alignment
                      .bottomCenter, // Align the white border and shading to the bottom
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.2,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/back.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height *
                          0.2, // Match the height of the image container
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.5),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 4.0,
                      color: Colors.white,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.only(top: 100),
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4.0,
                          ),
                        ),
                        child: const CircleAvatar(
                          radius: 60,
                          backgroundImage: AssetImage('assets/profile.png'),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(6),
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, bottom: 8),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 161, 216, 211),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.topRight,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EditUserDataPage(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    '${_userData['name'] ?? 'N/A'}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      color: Color.fromARGB(255, 84, 30, 210),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: RichText(
                                    text: TextSpan(
                                      children: <TextSpan>[
                                        const TextSpan(
                                          text: 'Bio: ',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(255, 0, 0, 0),
                                          ),
                                        ),
                                        TextSpan(
                                          text: '${_userData['bio'] ?? 'N/A'}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Color.fromARGB(
                                                255, 59, 183, 25),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.all(16),
                        child: Stack(
                          children: <Widget>[
                            Container(
                              margin: const EdgeInsets.all(6),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 135, 212, 229),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        const Text(
                                          'Experience',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        for (var experience in _experiences)
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
                                                  style: const TextStyle(
                                                      fontSize: 15),
                                                ),
                                                Text(
                                                  'Description: ${experience['description'] ?? 'N/A'}',
                                                  style: const TextStyle(
                                                      fontSize: 15),
                                                ),
                                                Text(
                                                  'Start Date: ${experience['startDate'] ?? 'N/A'}',
                                                  style: const TextStyle(
                                                      fontSize: 15),
                                                ),
                                                Text(
                                                  'End Date: ${experience['endDate'] ?? 'N/A'}',
                                                  style: const TextStyle(
                                                      fontSize: 15),
                                                ),
                                                Text(
                                                  'Skills: ${experience['skills'] ?? 'N/A'}',
                                                  style: const TextStyle(
                                                      fontSize: 15),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditExperience(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.all(16),
                        child: Stack(
                          children: <Widget>[
                            Container(
                              margin: const EdgeInsets.all(6),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 135, 212, 229),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        const Text(
                                          'Skills',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 8.0,
                                          runSpacing: 8.0,
                                          children: _skills
                                              .asMap()
                                              .entries
                                              .map((entry) {
                                            final skill = entry.value;
                                            final skillIndex = entry.key;
                                            final skillColor = skillColors[
                                                skillIndex %
                                                    skillColors.length];

                                            return Chip(
                                              label: Text(skill),
                                              backgroundColor: skillColor,
                                              labelStyle: const TextStyle(
                                                  color: Colors.white),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SkillsPage(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    /*_formDone == 0
        ? MaterialApp(
            debugShowCheckedModeBanner: false,
            home: WillPopScope(
              onWillPop: () async {
                // Return true to allow navigation back, return false to prevent it
                return false; // Prevent back navigation
              },
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.blue,
                  title: Text('Profile', style: TextStyle(color: Colors.white)),
                ),
                backgroundColor: Colors.white,
                body: SingleChildScrollView(
                  child: Stack(
                    children: <Widget>[
                      // Background Gradient
                      Stack(
                        alignment: Alignment
                            .bottomCenter, // Align the white border and shading to the bottom
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.2,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/back.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height *
                                0.2, // Match the height of the image container
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.5),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 4.0,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 100),
                        child: Column(
                          children: <Widget>[
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4.0,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundImage:
                                    AssetImage('assets/profile.png'),
                              ),
                            ),
                            SizedBox(height: 4),
                            Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Container(
                                margin: EdgeInsets.all(6),
                                padding: EdgeInsets.only(
                                    left: 16, right: 16, bottom: 8),
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 161, 216, 211),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.only(left: 8, right: 8),
                                  child: Column(
                                    children: [
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    EditUserDataPage(),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      Center(
                                        child: RichText(
                                          text: TextSpan(
                                            children: <TextSpan>[
                                              TextSpan(
                                                text: 'Bio: ',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromARGB(
                                                      255, 0, 0, 0),
                                                ),
                                              ),
                                              TextSpan(
                                                text:
                                                    '${_userData?['bio'] ?? 'N/A'}',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: Color.fromARGB(
                                                      255, 59, 183, 25),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: Text(
                                          '${_userData?['name'] ?? 'N/A'}',
                                          style: TextStyle(
                                            fontSize: 24,
                                            color: Color.fromARGB(
                                                255, 84, 30, 210),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 6.0),
                            Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: EdgeInsets.all(16),
                              child: Stack(
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.all(6),
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 135, 212, 229),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                'Education',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              for (var experience
                                                  in _experiences)
                                                ListTile(
                                                  leading: Icon(
                                                    Icons.work,
                                                    color: Colors.amber,
                                                  ),
                                                  title: Text(
                                                      'Company: ${experience['companyName'] ?? 'N/A'}'),
                                                  subtitle: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Company Name: ${experience['companyName'] ?? 'N/A'}',
                                                        style: TextStyle(
                                                            fontSize: 15),
                                                      ),
                                                      Text(
                                                        'Description: ${experience['description'] ?? 'N/A'}',
                                                        style: TextStyle(
                                                            fontSize: 15),
                                                      ),
                                                      Text(
                                                        'Start Date: ${experience['startDate'] ?? 'N/A'}',
                                                        style: TextStyle(
                                                            fontSize: 15),
                                                      ),
                                                      Text(
                                                        'End Date: ${experience['endDate'] ?? 'N/A'}',
                                                        style: TextStyle(
                                                            fontSize: 15),
                                                      ),
                                                      Text(
                                                        'Skills: ${experience['skills'] ?? 'N/A'}',
                                                        style: TextStyle(
                                                            fontSize: 15),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        // Navigator.push(
                                        //   context,
                                        //   MaterialPageRoute(
                                        //     builder: (context) =>
                                        //         EditExperience(),
                                        //   ),
                                        // );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: EdgeInsets.all(16),
                              child: Stack(
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.all(6),
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 135, 212, 229),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                'Skills',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Wrap(
                                                spacing: 8.0,
                                                runSpacing: 8.0,
                                                children: _skills
                                                    .asMap()
                                                    .entries
                                                    .map((entry) {
                                                  final skill = entry.value;
                                                  final skillIndex = entry.key;
                                                  final skillColor =
                                                      skillColors[skillIndex %
                                                          skillColors.length];

                                                  return Chip(
                                                    label: Text(skill),
                                                    backgroundColor: skillColor,
                                                    labelStyle: TextStyle(
                                                        color: Colors.white),
                                                  );
                                                }).toList(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        // Navigator.push(
                                        //   context,
                                        //   MaterialPageRoute(
                                        //     builder: (context) => SkillsPage(),
                                        //   ),
                                        // );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            */
    /*Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: EdgeInsets.all(16),
                              child: Stack(
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.all(6),
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 135, 212, 229),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                'Educations',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              for (var experience
                                                  in _experiences)
                                                ListTile(
                                                  leading: Icon(
                                                    Icons.school,
                                                    color: Colors.amber,
                                                  ),
                                                  title: Text(
                                                      'Company: ${experience['companyName'] ?? 'N/A'}'),
                                                  subtitle: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Company Name: ${experience['companyName'] ?? 'N/A'}',
                                                        style: TextStyle(
                                                            fontSize: 15),
                                                      ),
                                                      Text(
                                                        'Description: ${experience['description'] ?? 'N/A'}',
                                                        style: TextStyle(
                                                            fontSize: 15),
                                                      ),
                                                      Text(
                                                        'Start Date: ${experience['startDate'] ?? 'N/A'}',
                                                        style: TextStyle(
                                                            fontSize: 15),
                                                      ),
                                                      Text(
                                                        'End Date: ${experience['endDate'] ?? 'N/A'}',
                                                        style: TextStyle(
                                                            fontSize: 15),
                                                      ),
                                                      Text(
                                                        'Skills: ${experience['skills'] ?? 'N/A'}',
                                                        style: TextStyle(
                                                            fontSize: 15),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        // Navigator.push(
                                        //   context,
                                        //   MaterialPageRoute(
                                        //     builder: (context) =>
                                        //         JobsPostedPage(),
                                        //   ),
                                        // );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),*/
    /*
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : _buildPageForFormDoneValue(_formDone);*/
  }

  Widget _buildPageForFormDoneValue(int formDone) {
    switch (formDone) {
      case 1:
        return const AddExperiencePage();
      case 2:
        return const AddEducationPage();
      case 3:
        return const UserInfoPage();
      case 4:
        return const Page4();
      case 5:
        return const Page5();
      default:
        return Text('Invalid formdone value: $formDone');
    }
  }
}

class Page1 extends StatelessWidget {
  const Page1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Page 1')),
        body: const Center(child: Text("This is Page 1")));
  }
}

class Page2 extends StatelessWidget {
  const Page2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page 2'),
      ),
      body: const Center(
        child: Text('This is Page 2'),
      ),
    );
  }
}

class Page3 extends StatelessWidget {
  const Page3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page 3'),
      ),
      body: const Center(
        child: Text('This is Page 3'),
      ),
    );
  }
}

class Page4 extends StatelessWidget {
  const Page4({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page 4'),
      ),
      body: const Center(
        child: Text('This is Page 4'),
      ),
    );
  }
}

class Page5 extends StatelessWidget {
  const Page5({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page 5'),
      ),
      body: const Center(
        child: Text('This is Page 5'),
      ),
    );
  }
}
