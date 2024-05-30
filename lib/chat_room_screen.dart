// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';
import 'loading_screen.dart';
import 'services/room_operations.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:sound_mode/sound_mode.dart';

Completer<void> _popCompleter = Completer<void>();

class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({
    Key? key,
    required this.roomId,
    required this.occupants,
    required this.currentUserId,
  }) : super(key: key);

  final String roomId;
  final List<String> occupants;
  final String currentUserId;

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  String otherUserName = 'Anonymous';
  String otherUserProfilePic =
      'https://firebasestorage.googleapis.com/v0/b/omechat-7c75c.appspot.com/o/profile1.png?alt=media&token=0ddebb1d-56fa-42c9-be1e-5c09b8a55011';
  String otherUserInterest = 'Nothing';
  String interestMessage = 'Nothing in common';
  String otherUserGender = 'Unknown';
  final AudioPlayer audioPlayer = AudioPlayer();
  int previousDocsLength = 0;

  Future<void> _playReceivedSound() async {
    RingerModeStatus mode = await SoundMode.ringerModeStatus;
    if (mode == RingerModeStatus.normal) {
      await audioPlayer.play(AssetSource('receive.mp3'));
    } else {
      print("Silent mode enabled, sound not played.");
    }
  }

  Future<void> _playSendSound() async {
    RingerModeStatus mode = await SoundMode.ringerModeStatus;
    if (mode == RingerModeStatus.normal) {
      await audioPlayer.play(AssetSource('send.mp3'));
    } else {
      print("Silent mode enabled, sound not played.");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    String otherUserId =
        widget.occupants.firstWhere((id) => id != widget.currentUserId);

    // Fetch other user's data
    DocumentSnapshot<Map<String, dynamic>> otherUserSnapshot =
        await FirebaseFirestore.instance
            .collection('accounts')
            .doc(otherUserId)
            .get();

    // Fetch current user's data
    DocumentSnapshot<Map<String, dynamic>> currentUserSnapshot =
        await FirebaseFirestore.instance
            .collection('accounts')
            .doc(widget.currentUserId)
            .get();

    if (otherUserSnapshot.exists && currentUserSnapshot.exists) {
      // Debugging prints to check the data retrieved
      print('Other User Data: ${otherUserSnapshot.data()}');
      print('Current User Data: ${currentUserSnapshot.data()}');

// Extracting interests from the user data
      List<String> otherUserInterests =
          ((otherUserSnapshot.data()?['interests'] ?? '') as String)
              .toLowerCase()
              .split(',')
              .map((interest) => interest.trim())
              .toList();
      List<String> currentUserInterests =
          ((currentUserSnapshot.data()?['interests'] ?? '') as String)
              .toLowerCase()
              .split(',')
              .map((interest) => interest.trim())
              .toList();

      print('Other User Interests: $otherUserInterests');
      print('Current User Interests: $currentUserInterests');

// Check for common interests
      List<String> commonInterests = [];
      for (String interest in currentUserInterests) {
        if (otherUserInterests.contains(interest)) {
          commonInterests.add(interest);
        }
      }

      print('Room common interests: $commonInterests');
      print(commonInterests.length);

      if (commonInterests[0] == '') {
        var makeNull = null;
        commonInterests = makeNull;
      }
      print(commonInterests.length);

      setState(() {
        otherUserName = otherUserSnapshot.data()?['name'] ?? 'Anonymous';
        otherUserProfilePic = otherUserSnapshot.data()?['profilePicture'] !=
                null
            ? 'https://firebasestorage.googleapis.com/v0/b/omechat-7c75c.appspot.com/o/${otherUserSnapshot.data()?['profilePicture']}.png?alt=media&token=0ddebb1d-56fa-42c9-be1e-5c09b8a55011'
            : otherUserProfilePic;
        otherUserInterest = otherUserSnapshot.data()?['interests'] ?? 'Nothing';
        interestMessage = commonInterests.isEmpty
            ? 'You have nothing in common'
            : 'You both like ${commonInterests.join(", ")}';
        otherUserGender = otherUserSnapshot.data()?['gender'];
      });
    } else {
      setState(() {
        otherUserName = otherUserSnapshot.data()?['name'] ?? 'Anonymous';
        otherUserProfilePic = otherUserSnapshot.data()?['profilePicture'] !=
                null
            ? 'https://firebasestorage.googleapis.com/v0/b/omechat-7c75c.appspot.com/o/${otherUserSnapshot.data()?['profilePicture']}.png?alt=media&token=0ddebb1d-56fa-42c9-be1e-5c09b8a55011'
            : otherUserProfilePic;
        otherUserGender = otherUserSnapshot.data()?['gender'];
      });
      print('User data not found.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black,
                  width: 1.0,
                ),
              ),
              child: CircleAvatar(
                backgroundImage: NetworkImage(otherUserProfilePic),
                radius: 20,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                otherUserName,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromRGBO(180, 74, 26, 1),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              onPressed: () async {
                _popCompleter = Completer<void>();
                await deleteCurrentUserFromRoom(
                    widget.roomId, widget.currentUserId);

                Navigator.pop(context);
                await _popCompleter.future;
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
              ),
              child: const Text('STOP'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              onPressed: () async {
                _popCompleter = Completer<void>();
                await deleteCurrentUserFromRoom(
                    widget.roomId, widget.currentUserId);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoadingScreen()),
                );
                await _popCompleter.future;
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
              ),
              child: const Text('NEXT'),
            ),
          ),
        ],
      ),
      backgroundColor: Color.fromRGBO(254, 243, 227, 1),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background.png"), // Path to your image
            fit: BoxFit.cover,
          ),
        ),
        child: PopScope(
          canPop: true,
          onPopInvoked: (bool didPop) async {
            if (didPop) {
              await deleteCurrentUserFromRoom(
                  widget.roomId, widget.currentUserId);
              _popCompleter.complete();
            }
          },
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('rooms')
                .doc(widget.roomId)
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Visibility(
                    visible: false, child: CircularProgressIndicator());
              }

              var roomData = snapshot.data!.data() as Map<String, dynamic>?;

              bool userInRoom = roomData != null &&
                  (roomData['occupant1'] == widget.currentUserId ||
                      roomData['occupant2'] == widget.currentUserId);

              bool connectionEstablished = userInRoom &&
                  roomData != null &&
                  (roomData['occupant1'] == widget.occupants[0] &&
                      roomData['occupant2'] == widget.occupants[1]);

              if (!connectionEstablished && userInRoom) {
                WidgetsBinding.instance!.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '$otherUserName left the room',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),

                      duration:
                          Duration(seconds: 2), // Adjust the duration as needed
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  );
                });
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('rooms')
                          .doc(widget.roomId)
                          .collection('messages')
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Visibility(
                              visible: false,
                              child: CircularProgressIndicator());
                        }

                        var docs = snapshot.data!.docs;

                        // Check if the previous and current doc lengths are different
                        if (snapshot.hasData &&
                            docs.length > previousDocsLength) {
                          // Play received sound when new message is detected
                          if (docs.first['userId'] != widget.currentUserId) {
                            _playReceivedSound();
                          }
                          previousDocsLength = docs.length;
                        }

                        return ListView(
                          reverse: true,
                          padding: const EdgeInsets.all(16.0),
                          children: [
                            ...snapshot.data!.docs.asMap().entries.map((entry) {
                              DocumentSnapshot document = entry.value;
                              Map<String, dynamic> data =
                                  document.data() as Map<String, dynamic>;

                              bool isCurrentUser =
                                  data['userId'] == widget.currentUserId;

                              // Check if the current message is from the same user as the previous one
                              bool isSameUserAsPrevious = false;
                              if (entry.key > 0) {
                                Map<String, dynamic> previousData =
                                    snapshot.data!.docs[entry.key - 1].data()
                                        as Map<String, dynamic>;
                                String previousUserId = previousData['userId'];
                                isSameUserAsPrevious =
                                    previousUserId == data['userId'];
                              }

                              return _buildMessage(
                                context: context,
                                isCurrentUser: isCurrentUser,
                                message: data['message'],
                                isSameUserAsPrevious: isSameUserAsPrevious,
                              );
                            }).toList(),
                            SizedBox(
                                height:
                                    20), // Add some spacing before the avatar
                            Center(
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors
                                            .black, // Set the border color here
                                        width: 1.0, // Set the border width here
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        otherUserProfilePic,
                                      ),
                                      radius: 70,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    otherUserName,
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    otherUserGender,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    interestMessage,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Visibility(
                    visible: (connectionEstablished && userInRoom),
                    child: _buildMessageInputField(),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMessage({
    required BuildContext context,
    required bool isCurrentUser,
    required String message,
    required bool isSameUserAsPrevious,
  }) {
    final double verticalMargin = isSameUserAsPrevious ? 4.0 : 15.0;

    return Container(
      margin: EdgeInsets.only(bottom: verticalMargin),
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 100,
              ),
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: isCurrentUser
                    ? Color.fromARGB(255, 46, 46, 46)
                    : Color.fromARGB(255, 216, 216, 216),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message,
                style: TextStyle(
                    fontSize: 16.0,
                    color: isCurrentUser ? Colors.white : Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInputField() {
    TextEditingController _controller = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: const BoxDecoration(
        color: Color.fromRGBO(180, 74, 26, 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 216, 216, 216), // Background color
                borderRadius: BorderRadius.circular(25.0), // Rounded corners
              ),
              child: TextField(
                minLines: 1,
                maxLines: 3,
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  border: InputBorder.none, // Remove default border
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              String messageText = _controller.text.trim();

              if (messageText.isNotEmpty) {
                _controller.clear();
                FirebaseFirestore.instance
                    .collection('rooms')
                    .doc(widget.roomId)
                    .collection('messages')
                    .add({
                  'message': messageText,
                  'userId': widget.currentUserId,
                  'timestamp': Timestamp.now(),
                }).catchError((error) {
                  print("Error sending message: $error");
                });
                _playSendSound();
              }
            },
            icon: const Icon(Icons.send),
            // color: Color.fromRGBO(9, 193, 199, 1),
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
