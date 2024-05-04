import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomScreen extends StatefulWidget {
  final String roomId;
  final List<String> occupants;
  final String currentUserId;

  const ChatRoomScreen({
    Key? key,
    required this.roomId,
    required this.occupants,
    required this.currentUserId,
  }) : super(key: key);

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _textController = TextEditingController();
  late CollectionReference _messagesCollection;

  @override
  void initState() {
    super.initState();
    _messagesCollection = FirebaseFirestore.instance.collection('messages');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Room - ${widget.roomId}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messagesCollection
                  .where('roomId', isEqualTo: widget.roomId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<QueryDocumentSnapshot> messages =
                      snapshot.data!.docs.reversed.toList();
                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      var message = messages[index].data()!;
                      return ListTile(
                        title: Text('sender'),
                        subtitle: Text('content'),
                      );
                    },
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
          _buildMessageInputField(),
        ],
      ),
    );
  }

  Widget _buildMessageInputField() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              _sendMessage();
            },
            icon: Icon(Icons.send),
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    String message = _textController.text.trim();
    if (message.isNotEmpty) {
      _messagesCollection.add({
        'roomId': widget.roomId,
        'sender': widget.currentUserId,
        'content': message,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      }).then((_) {
        _textController.clear();
      }).catchError((error) {
        // Handle error
        print('Failed to send message: $error');
      });
    }
  }
}
