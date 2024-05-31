import 'package:flutter/material.dart';
import 'services/profile_operations.dart';

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
    fetchData(
        _nameController, _interestController, setGender, setSelectedProfile);
  }

  void setGender(String? value) {
    setState(() {
      gender = value;
    });
  }

  void setSelectedProfile(String? value) {
    setState(() {
      selectedProfile = value;
    });
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
                              await showProfileSelectionDialog(
                                  context); // options to change profile pic
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
                          // chosen gender prefer not to say.
                          Row(
                            children: [
                              Radio<String>(
                                value: 'Unknown',
                                groupValue: gender,
                                onChanged: (value) {
                                  setState(() {
                                    gender = value;
                                  });
                                },
                                activeColor: Colors
                                    .black, // Set the active color to black
                              ),
                              const Text('Prefer not to say')
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
                              await saveProfileData(context, _nameController,
                                  _interestController, gender, selectedProfile);
                              await showSaveConfirmation(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color.fromRGBO(
                                180, 74, 26, 1), // Background color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: const BorderSide(
                                  color: Color.fromRGBO(103, 45, 18, 1),
                                  width: 1.0), // Rounded corners
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
}
