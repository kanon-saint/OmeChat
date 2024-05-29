// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, use_build_context_synchronously, library_private_types_in_public_api, use_super_parameters

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool likeBoys = false;
  bool likeGirls = false;
  String? selectedProfile = 'profile4'; // Default profile selection
  String? gender = 'boy'; // Default gender selection
  String? preference = 'girls'; // Default preference selection
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _interestController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch user's profile data when the page initializes
  }

  Future<void> fetchData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('accounts')
          .doc(user.uid)
          .get();

      if (snapshot.exists) {
        setState(() {
          selectedProfile = snapshot['profilePicture'];
          _nameController.text = snapshot['name'] ?? '';
          _interestController.text = snapshot['interests'] ?? '';
          gender = snapshot['gender'];
          preference = snapshot['preference'];
        });
      }
    }
  }

  Future<void> _saveProfileData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('accounts')
          .doc(user.uid)
          .set({
        'profilePicture': selectedProfile,
        'name': _nameController.text,
        'interests': _interestController.text,
        'gender': gender,
        'preference': preference,
      });

      Navigator.pop(context, user); // Pass the user ID back to the caller
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(180, 74, 26, 1),
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/background.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  GestureDetector(
                    onTap: () async {
                      final selectedProfileTemp =
                          await _showProfileSelectionDialog();
                      if (selectedProfileTemp != null) {
                        setState(() {
                          selectedProfile = selectedProfileTemp;
                        });
                      }
                    },
                    child: Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black, // Set the border color here
                            width: 1.0, // Set the border width here
                          ),
                        ),
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                            'https://firebasestorage.googleapis.com/v0/b/omechat-7c75c.appspot.com/o/$selectedProfile.png?alt=media&token=0ddebb1d-56fa-42c9-be1e-5c09b8a55011',
                          ),
                          radius: 40,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.0),
                  TextField(
                    controller: _nameController,
                    maxLength: 10,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      labelText: 'Screen Name',
                    ),
                  ),
                  SizedBox(height: 10.0),
                  TextField(
                    controller: _interestController,
                    maxLength: 50,
                    minLines: 1,
                    maxLines: 2,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      labelText: 'Interest (Optional)',
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    'Select your gender:',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  SizedBox(height: 10.0),
                  Column(
                    children: <Widget>[
                      Row(
                        children: [
                          Radio<String>(
                            value: 'boy',
                            groupValue: gender,
                            onChanged: (value) {
                              setState(() {
                                gender = value;
                              });
                            },
                            activeColor:
                                Colors.black, // Set the active color to black
                          ),
                          Text('Male')
                        ],
                      ),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'girl',
                            groupValue: gender,
                            onChanged: (value) {
                              setState(() {
                                gender = value;
                              });
                            },
                            activeColor:
                                Colors.black, // Set the active color to black
                          ),
                          Text('Female')
                        ],
                      ),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'both',
                            groupValue: gender,
                            onChanged: (value) {
                              setState(() {
                                gender = value;
                              });
                            },
                            activeColor:
                                Colors.black, // Set the active color to black
                          ),
                          Text('Non-binary')
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    'Select your preferences:',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  SizedBox(height: 10.0),
                  Column(
                    children: <Widget>[
                      Row(
                        children: [
                          Radio<String>(
                            value: 'boys',
                            groupValue: preference,
                            onChanged: (value) {
                              setState(() {
                                preference = value;
                              });
                            },
                            activeColor:
                                Colors.black, // Set the active color to black
                          ),
                          Text('Male')
                        ],
                      ),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'girls',
                            groupValue: preference,
                            onChanged: (value) {
                              setState(() {
                                preference = value;
                              });
                            },
                            activeColor:
                                Colors.black, // Set the active color to black
                          ),
                          Text('Female')
                        ],
                      ),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'both',
                            groupValue: preference,
                            onChanged: (value) {
                              setState(() {
                                preference = value;
                              });
                            },
                            activeColor:
                                Colors.black, // Set the active color to black
                          ),
                          Text('Non-binary')
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () async {
                      await _saveProfileData();
                      await _showSaveConfirmation();
                    },
                    child: Text('Save'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showSaveConfirmation() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Changes Saved'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _showProfileSelectionDialog() async {
    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Profile Picture'),
          content: Container(
            width: double.maxFinite,
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              children: List.generate(
                8,
                (index) => _buildProfileOption('profile${index + 1}'),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileOption(String profileName) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context,
              profileName); // Pass the selected profile name back to the dialog caller
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
}
