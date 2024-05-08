// room_operations.dart
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> deleteCurrentUserFromRoom(
    String roomId, String currentUserId) async {
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
          // await deleteSubcollection(roomDocRef.collection('messages'));
          print('Room document deleted: $roomId');
        }

        // Delete current user from the room
        if (occupant1 == currentUserId) {
          await roomDocRef.update({'occupant1': ""});
          // await roomDocRef.delete();
          print('Current user deleted from occupant1 field.');
        } else if (occupant2 == currentUserId) {
          await roomDocRef.update({'occupant2': ""});
          // await roomDocRef.delete();
          print('Current user deleted from occupant2 field.');
        } else {
          print('Current user is not an occupant of this room.');
          return;
        }
      } else {
        // Delete the subcollection
        await deleteSubcollection(roomDocRef.collection('messages'));
        // Delete the document at /rooms/lrwu27
        await roomDocRef.delete();
        print('No data found in the room document.');
      }
    } else {
      // Delete the subcollection
      await deleteSubcollection(roomDocRef.collection('messages'));
      // Delete the document at /rooms/lrwu27
      await roomDocRef.delete();
      print('Room document does not exist.');
    }
  } catch (error) {
    final roomDocRef =
        FirebaseFirestore.instance.collection('rooms').doc(roomId);

    // Delete the subcollection
    await deleteSubcollection(roomDocRef.collection('messages'));
    // Delete the document at /rooms/lrwu27
    await roomDocRef.delete();

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
