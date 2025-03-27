import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_flutter_app/utils/widget_utils.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SkillsPage(),
    );
  }
}

class SkillsPage extends StatefulWidget {
  SkillsPage({super.key});

  @override
  _SkillsPageState createState() => _SkillsPageState();
}

class _SkillsPageState extends State<SkillsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  List<String> _userSkills = [];

  final List<Color> _itemColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _currentUser = user;
      });
      _getUserSkills(user.uid);
    }
  }

  Future<void> _getUserSkills(String uid) async {
    final userData = await _firestore.collection('userdata').doc(uid).get();
    if (userData.exists) {
      final skills = userData['skills'] as List<dynamic>;
      setState(() {
        _userSkills = skills.cast<String>();
      });
    }
  }

  Future<void> _deleteSkill(int index) async {
    final uid = _currentUser!.uid;
    final skills = List<String>.from(_userSkills);
    skills.removeAt(index);

    await _firestore.collection('userdata').doc(uid).update({
      'skills': skills,
    });

    setState(() {
      _userSkills = skills;
    });
  }

  Future<void> _addSkill(String newSkill) async {
    final uid = _currentUser!.uid;
    final skills = List<String>.from(_userSkills);
    skills.add(newSkill);

    await _firestore.collection('userdata').doc(uid).update({
      'skills': skills,
    }).onError((error, stackTrace) {
      return WidgetUtils().showToast(error.toString());
    });

    setState(() {
      _userSkills = skills;
    });
  }

  void _showAddSkillDialog(BuildContext context) {
    String newSkill = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add a Skill'),
          content: TextField(
            onChanged: (value) {
              newSkill = value;
            },
            decoration: InputDecoration(labelText: 'Skill Name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addSkill(newSkill);
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back, color: Colors.white)),
        title: Text('User Skills', style: TextStyle(color: Colors.white)),
      ),
      body: _currentUser == null
          ? Center(child: CircularProgressIndicator())
          : _userSkills.isEmpty
              ? Center(child: Text('No skills found.'))
              : ListView.builder(
                  itemCount: _userSkills.length,
                  itemBuilder: (context, index) {
                    final color = _itemColors[index % _itemColors.length];

                    return Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      margin: EdgeInsets.all(2.0),
                      child: ListTile(
                        title: Text(
                          _userSkills[index],
                          style: TextStyle(color: Colors.white),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deleteSkill(index);
                          },
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 12, 12, 12),
          borderRadius: BorderRadius.circular(20.0),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: InkWell(
          onTap: () {
            _showAddSkillDialog(context);
          },
          child: Text(
            'Add Skills',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            ),
          ),
        ),
      ),
    );
  }
}
