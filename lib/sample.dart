  //             children: [
  //               Center(
  //                 child: Text(
  //                   'Connection Established',
  //                   style: TextStyle(
  //                     fontSize: 15,
  //                     color: Colors.grey,
  //                   ),
  //                 ),
  //               ),
  //               _buildMessage(isCurrentUser: true, message: 'Hello!'),
  //               _buildMessage(isCurrentUser: false, message: 'Hi there!'),
  //               _buildMessage(isCurrentUser: true, message: 'How are you?'),
  //               _buildMessage(
  //                   isCurrentUser: false, message: 'I\'m good, thank you!'),
  //               _buildMessage(
  //                   isCurrentUser: true, message: 'What are you up to?'),
  //               _buildMessage(
  //                   isCurrentUser: false,
  //                   message: 'Just relaxing at home. You?'),
  //               _buildMessage(
  //                   isCurrentUser: true, message: 'I\'m working on a project.'),
  //               _buildMessage(
  //                   isCurrentUser: false, message: 'Sounds interesting!'),
  //               _buildMessage(
  //                   isCurrentUser: true, message: 'Can I help with something?'),
  //               _buildMessage(
  //                   isCurrentUser: false,
  //                   message: 'Actually, yes! Do you know Flutter?'),
  //               _buildMessage(
  //                   isCurrentUser: true,
  //                   message: 'Yes, I\'m familiar with Flutter.'),
  //               _buildMessage(
  //                   isCurrentUser: false,
  //                   message: 'Great! I need some help with a layout.'),
  //               _buildMessage(
  //                   isCurrentUser: true,
  //                   message: 'Sure, I\'d be happy to help.'),
  //               _buildMessage(isCurrentUser: false, message: 'Thanks a lot!'),
  //               _buildMessage(
  //                   isCurrentUser: true,
  //                   message: 'No problem. Let me know what you need.'),
  //               _buildMessage(isCurrentUser: false, message: 'Will do!'),
  //               _buildMessage(
  //                   isCurrentUser: true, message: 'Looking forward to it!'),
  //               _buildMessage(isCurrentUser: false, message: 'Me too!'),
  //             ],

  //               Widget _buildMessage({required bool isCurrentUser, required String message}) {
  //   return Container(
  //     margin: EdgeInsets.symmetric(vertical: 8.0),
  //     alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
  //     child: Container(
  //       padding: EdgeInsets.all(12.0),
  //       decoration: BoxDecoration(
  //         color: isCurrentUser ? Colors.blue[100] : Colors.grey[300],
  //         borderRadius: BorderRadius.circular(8.0),
  //       ),
  //       child: Text(
  //         message,
  //         style: TextStyle(fontSize: 16.0),
  //       ),
  //     ),
  //   );
  // }