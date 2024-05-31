// profile_operations.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<void> fetchData(
    TextEditingController nameController,
    TextEditingController interestController,
    Function(String?) setGender,
    Function(String?) setSelectedProfile) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('accounts')
        .doc(user.uid)
        .get();

    if (snapshot.exists) {
      setGender(snapshot['gender']);
      interestController.text = snapshot['interests'] ?? '';
      nameController.text =
          snapshot['name'] == 'Anonymous' ? '' : snapshot['name'];
      setSelectedProfile(snapshot['profilePicture']);
    }
  }
}

Future<void> saveProfileData(
    BuildContext context,
    TextEditingController nameController,
    TextEditingController interestController,
    String? gender,
    String? selectedProfile) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    await FirebaseFirestore.instance.collection('accounts').doc(user.uid).set({
      'gender': gender,
      'interests':
          interestController.text.isNotEmpty ? interestController.text : null,
      'name': nameController.text,
      'profilePicture': selectedProfile,
    });

    Navigator.pop(context, user);
  }
}

Future<void> showSaveConfirmation(BuildContext context) async {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text(
        'Changes Saved',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16.0,
        ),
      ),
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    ),
  );
}

Future<String?> showProfileSelectionDialog(BuildContext context) async {
  return await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Select Profile Picture'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            children: List.generate(
              8,
              (index) => _buildProfileOption(context, 'profile${index + 1}'),
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildProfileOption(BuildContext context, String profileName) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: GestureDetector(
      onTap: () {
        Navigator.pop(context, profileName);
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.black,
            width: 1.0,
          ),
        ),
        child: CircleAvatar(
          backgroundImage: NetworkImage(
            'https://firebasestorage.googleapis.com/v0/b/omechat-7c75c.appspot.com/o/$profileName.png?alt=media&token=0ddebb1d-56fa-42c9-be1e-5c09b8a55011',
          ),
          radius: 40,
        ),
      ),
    ),
  );
}
