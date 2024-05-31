import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? selectedProfile = 'profile1'; // Default profile selection
  String? gender = 'Male'; // Default gender selection
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _interestController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // Fetch user's profile data when the page initializes
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // fetch user data from firestore
  Future<void> fetchData() async {
    User? user = FirebaseAuth
        .instance.currentUser; // Retrieves the currently authenticated user
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore // hold document data that maps key and value
              .instance
              .collection('accounts') // access the account
              .doc(user.uid) // retrieve user id
              .get(); // fetch those from firestore

      // if already exists, access the value, just load
      if (snapshot.exists) {
        setState(() {
          gender = snapshot['gender'];
          _interestController.text = snapshot['interests'] ?? '';
          _nameController.text =
              snapshot['name'] == 'Anonymous' ? '' : snapshot['name'];
          selectedProfile = snapshot['profilePicture'];
        });
      }
    }
  }

  // Access and update
  Future<void> _saveProfileData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('accounts')
          .doc(user.uid)
          .set({
        'gender': gender,
        'interests': _interestController
                .text.isNotEmpty // Check if interests is not empty
            ? _interestController.text
            : null,
        'name': _nameController.text,
        'profilePicture': selectedProfile,
      });

      // ignore: use_build_context_synchronously
      Navigator.pop(context, user); // Pass the user ID back to the caller
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(180, 74, 26, 1),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () async {
                          final selectedProfileTemp =
                              await _showProfileSelectionDialog(); // options to change profile pic
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
                                color:
                                    Colors.black, // Set the border color here
                                width: 1.0, // Set the border width here
                              ),
                            ),
                            // Source of the image choices
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(
                                'https://firebasestorage.googleapis.com/v0/b/omechat-7c75c.appspot.com/o/$selectedProfile.png?alt=media&token=0ddebb1d-56fa-42c9-be1e-5c09b8a55011',
                              ),
                              radius: 40,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      // form input name
                      TextFormField(
                        controller: _nameController,
                        maxLength: 10,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                          labelText: 'Screen Name',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your screen name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10.0),
                      // form input for interest
                      TextFormField(
                        controller: _interestController,
                        maxLength: 50,
                        minLines: 1,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'Separate interest by comma',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                          labelText: 'Interest (Optional)',
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      const Text(
                        'Select your gender:',
                        style: TextStyle(fontSize: 18.0),
                      ),
                      const SizedBox(height: 10.0),
                      // for the genders
                      Column(
                        children: <Widget>[
                          // chosen gender is male
                          Row(
                            children: [
                              Radio<String>(
                                value: 'Male',
                                groupValue: gender,
                                onChanged: (value) {
                                  setState(() {
                                    gender = value;
                                  });
                                },
                                activeColor: Colors
                                    .black, // Set the active color to black
                              ),
                              const Text('Male')
                            ],
                          ),
                          // chosen gender is female
                          Row(
                            children: [
                              Radio<String>(
                                value: 'Female',
                                groupValue: gender,
                                onChanged: (value) {
                                  setState(() {
                                    gender = value;
                                  });
                                },
                                activeColor: Colors
                                    .black, // Set the active color to black
                              ),
                              const Text('Female')
                            ],
                          ),
                          // chosen gender is non binary.
                          Row(
                            children: [
                              Radio<String>(
                                value: 'Non-binary',
                                groupValue: gender,
                                onChanged: (value) {
                                  setState(() {
                                    gender = value;
                                  });
                                },
                                activeColor: Colors
                                    .black, // Set the active color to black
                              ),
                              const Text('Non-binary')
                            ],
                          ),
                        ],
                      ),
                      // save changes button properties
                      Align(
                        alignment: Alignment
                            .centerRight, // Aligns the button to the right
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              await _saveProfileData();
                              await _showSaveConfirmation();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color.fromRGBO(
                                180, 74, 26, 1), // Background color
                            shadowColor: Colors.black, // Shadow color
                            elevation: 5, // Elevation
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(40), // Rounded corners
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15), // Padding
                          ),
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16, // Font size
                              fontWeight: FontWeight.bold, // Font weight
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // display text again to the home_page
  Future<void> _showSaveConfirmation() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Changes Saved',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.0,
          ),
        ),
        duration: const Duration(seconds: 3), // Adjust the duration as needed
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  // shows the available profile pictures
  Future<String?> _showProfileSelectionDialog() async {
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
                (index) => _buildProfileOption('profile${index + 1}'),
              ),
            ),
          ),
        );
      },
    );
  }

  // enables the profile to be clickable and this is its properties
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
            // displays the pictures
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
