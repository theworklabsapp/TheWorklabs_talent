import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:my_flutter_app/Profile%20Components/Logine.dart';
import 'package:my_flutter_app/utils/widget_utils.dart';

/// ORIGINAL CODE
/*Future<void> registerWithEmailAndPassword(String email, String name,
    String username, String address, String phoneNumber) async {
  try {
    User? userid = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance
        .collection('userdata')
        .doc(userid!.uid)
        .set({
      'uid': userid.uid,
      'email': email,
      'name': name,
      'username': username,
      'address': address,
      'phoneNumber': phoneNumber,
    });
    await FirebaseFirestore.instance.collection('users').doc(userid.uid).set({
      'uid': userid.uid,
      'email': email,
      'name': name,
      'username': username,
      'address': address,
      'phoneNumber': phoneNumber,
    }).then((value) => {
          FirebaseAuth.instance.signOut(),
          Get.to(() => LoginPage()),
        });
  } catch (e) {
    log("ERROR$e");
  }
}*/

Future<void> registerWithEmailAndPassword(String email, String password,
    String name, String username, String address, String phoneNumber) async {
  try {
    UserCredential? userCredential;
    // Create user with email and password
    userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: email,
      password: password,
    )
        .then((value) async {
      log("SUCCESSSSS${value.user!.email}====${value.user!.uid}");
      if (value.user != null) {
        String uid = value.user!.uid;
        log("UID$uid");

        DocumentReference userdata =
            FirebaseFirestore.instance.collection('userdata').doc(uid);
        // Save user details in Firestore
        userdata.set({
          'uid': uid,
          'email': email,
          'name': name,
          'username': username,
          'address': address,
          'phoneNumber': phoneNumber,
        });

        DocumentReference bill =
            FirebaseFirestore.instance.collection('users').doc(uid);
        bill.set({
          'uid': uid,
          'email': email,
          'name': name,
          'username': username,
          'address': address,
          'phoneNumber': phoneNumber,
        });

        // Sign out and navigate to login
        await FirebaseAuth.instance.signOut();
        Get.to(() => const LoginPage());
      }
    }).onError((error, stackTrace) {
      WidgetUtils().showToast(error.toString());
      log("ERRORRRRR$error====$stackTrace");
    });
  } catch (e) {
    log("ERROR: $e");
  }
}
