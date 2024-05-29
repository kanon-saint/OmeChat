import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'loading_screen.dart';
import 'services/room_operations.dart';
import 'package:audioplayers/audioplayers.dart';

Completer<void> _popCompleter = Completer<void>();

class ChatRoomScreen extends StatelessWidget {
  ChatRoomScreen({
    Key? key,
    required this.roomId,
    required this.occupants,
    required this.currentUserId,
  }) : super(key: key);

  final String roomId;
  final List<String> occupants;
  final String currentUserId;
  final AudioPlayer audioPlayer = AudioPlayer();

    Future<void> _playreceivedSound() async {
      await audioPlayer.play(AssetSource('receive.mp3'));
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
                backgroundImage: NetworkImage(
                  'https://firebasestorage.googleapis.com/v0/b/omechat-7c75c.appspot.com/o/profile1.png?alt=media&token=0ddebb1d-56fa-42c9-be1e-5c09b8a55011',
                ),
                radius: 20,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Anonymous',
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
                await deleteCurrentUserFromRoom(roomId, currentUserId);

                Navigator.pop(
                  context,
                );
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
                await deleteCurrentUserFromRoom(roomId, currentUserId);

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
              await deleteCurrentUserFromRoom(roomId, currentUserId);
              _popCompleter.complete();
            }
          },
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('rooms')
                .doc(roomId)
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
                  (roomData['occupant1'] == currentUserId ||
                      roomData['occupant2'] == currentUserId);

              bool connectionEstablished = userInRoom &&
                  roomData != null &&
                  (roomData['occupant1'] == occupants[0] &&
                      roomData['occupant2'] == occupants[1]);

              // if (connectionEstablished) {
              //   WidgetsBinding.instance!.addPostFrameCallback((_) {
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       SnackBar(
              //         content: Text('Connection Established'),
              //       ),
              //     );
              //   });
              // }

              if (!connectionEstablished && userInRoom) {
                WidgetsBinding.instance!.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('User left the room.'),
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
                          .doc(roomId)
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

                        return ListView(
                          reverse: true,
                          padding: const EdgeInsets.all(16.0),
                          children: [
                            ...snapshot.data!.docs.asMap().entries.map((entry) {
                              DocumentSnapshot document = entry.value;
                              Map<String, dynamic> data =
                                  document.data() as Map<String, dynamic>;

                              bool isCurrentUser =
                                  data['userId'] == currentUserId;

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
                                        'https://firebasestorage.googleapis.com/v0/b/omechat-7c75c.appspot.com/o/profile1.png?alt=media&token=0ddebb1d-56fa-42c9-be1e-5c09b8a55011',
                                      ),
                                      radius: 70,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Anonymous',
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'You have nothing in common',
                                    style: TextStyle(
                                        fontSize: 15,
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
  // // Play received sound message when a message is received
  // Future<void> _playSound(String soundFile) async {
  //   await audioPlayer.play(AssetSource(soundFile));
  // }

  // // Determine which sound to play based on the current user
  // if (!isCurrentUser && !isSameUserAsPrevious) {
  //   _playSound('receive.mp3'); // Play the received sound
  // } else if (isCurrentUser){
  //   _playSound('send.mp3'); // Play the send sound
  // }

  // Call _playReceivedSound when a new message is received
  if (!isCurrentUser) {
    _playreceivedSound();
  }

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
    Future<void> _playSound() async {
      await audioPlayer.play(AssetSource('send.mp3'));
    }

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
                    .doc(roomId)
                    .collection('messages')
                    .add({
                  'message': messageText,
                  'userId': currentUserId,
                  'timestamp': Timestamp.now(),
                }).catchError((error) {
                  print("Error sending message: $error");
                });
                 _playSound();
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
