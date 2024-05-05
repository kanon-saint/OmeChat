import 'package:flutter/material.dart';
import 'home_page.dart';
import 'loading_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
                await _deleteCurrentUserFromRoom();

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
                await _deleteCurrentUserFromRoom();

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
      body: Column(
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
                  reverse: true, // To display the latest messages at the bottom
                  padding: const EdgeInsets.all(16.0),
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    return _buildMessage(
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
      ),
    );
  }

  Widget _buildMessage({required bool isCurrentUser, required String message}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
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

  Future<void> _deleteCurrentUserFromRoom() async {
    try {
      final roomDocRef =
          FirebaseFirestore.instance.collection('rooms').doc(roomId);
      final roomSnapshot = await roomDocRef.get();

      if (roomSnapshot.exists) {
        final data = roomSnapshot.data();

        if (data != null) {
          final occupant1 =
              data.containsKey('occupant1') ? data['occupant1'] : null;
          final occupant2 =
              data.containsKey('occupant2') ? data['occupant2'] : null;

          // Check if both occupants are null and delete the room document if so
          if (occupant1 == "" || occupant2 == "") {
            // Delete the document at /rooms/lrwu27
            await roomDocRef.delete();
            // Delete the subcollection
            await deleteSubcollection(roomDocRef.collection('messages'));
            print('Room document deleted: $roomId');
          }

          // Delete current user from the room
          if (occupant1 == currentUserId) {
            await roomDocRef.update({'occupant1': ""});
            print('Current user deleted from occupant1 field.');
          } else if (occupant2 == currentUserId) {
            await roomDocRef.update({'occupant2': ""});
            print('Current user deleted from occupant2 field.');
          } else {
            print('Current user is not an occupant of this room.');
            return;
          }
        } else {
          print('No data found in the room document.');
        }
      } else {
        print('Room document does not exist.');
      }
    } catch (error) {
      print("Error deleting current user from room: $error");
    }
  }

  Future<void> deleteSubcollection(CollectionReference collectionRef) async {
    final QuerySnapshot snapshot = await collectionRef.get();
    final List<Future<void>> futures = [];

    for (DocumentSnapshot doc in snapshot.docs) {
      futures.add(doc.reference.delete());
    }

    await Future.wait(futures);
    print('Subcollection deleted.');
  }
}
