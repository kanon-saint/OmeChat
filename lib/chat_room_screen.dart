// chat_room_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'loading_screen.dart';
import 'home_page.dart';
import 'services/room_operations.dart';

class ChatRoomScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Room'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.orange,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              onPressed: () async {
                await deleteCurrentUserFromRoom(roomId, currentUserId);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.red,
              ),
              child: const Text('Stop'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              onPressed: () async {
                await deleteCurrentUserFromRoom(roomId, currentUserId);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoadingScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.green,
              ),
              child: const Text('Next'),
            ),
          ),
        ],
      ),
      body: PopScope(
        canPop: true,
        onPopInvoked: (bool didPop) {
          if (didPop) {
            deleteCurrentUserFromRoom(roomId, currentUserId);
          }
        },
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('rooms')
              .doc(roomId)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            var roomData = snapshot.data!.data() as Map<String, dynamic>?;

            bool userInRoom = roomData != null &&
                (roomData['occupant1'] == currentUserId ||
                    roomData['occupant2'] == currentUserId);

            bool connectionEstablished = userInRoom &&
                roomData != null &&
                (roomData['occupant1'] == occupants[0] &&
                    roomData['occupant2'] == occupants[1]);

            if (connectionEstablished) {
              WidgetsBinding.instance!.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Connection Established'),
                  ),
                );
              });
            }

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

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }

                      return ListView(
                        reverse: true,
                        padding: const EdgeInsets.all(16.0),
                        children: snapshot.data!.docs
                            .map((DocumentSnapshot document) {
                          Map<String, dynamic> data =
                              document.data() as Map<String, dynamic>;
                          return _buildMessage(
                            context: context,
                            isCurrentUser: data['userId'] == currentUserId,
                            message: data['message'],
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
                _buildMessageInputField(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMessage({
    required BuildContext context, // Add BuildContext parameter here
    required bool isCurrentUser,
    required String message,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
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
                color: isCurrentUser ? Colors.blue[100] : Colors.grey[300],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                message,
                style: TextStyle(fontSize: 16.0),
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
        border: Border(
          top: BorderSide(color: Colors.grey),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              minLines: 1,
              maxLines: 3,
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Type your message...',
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              String messageText = _controller.text.trim();

              if (messageText.isNotEmpty) {
                FirebaseFirestore.instance
                    .collection('rooms')
                    .doc(roomId)
                    .collection('messages')
                    .add({
                  'message': messageText,
                  'userId': currentUserId,
                  'timestamp': Timestamp.now(),
                }).then((_) {
                  _controller.clear();
                }).catchError((error) {
                  print("Error sending message: $error");
                });
              }
            },
            icon: const Icon(Icons.send),
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}
