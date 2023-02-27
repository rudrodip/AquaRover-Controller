import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

// collection reference
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('user');

  Future<void> updateUserData(String name, {int sampleCollected = 0}) async {
    Map<String, dynamic> data = {
      'name': name,
      'sampleCollected': sampleCollected
    };
    return await userCollection
        .doc(uid)
        .set(data)
        .then((value) => debugPrint("User Added"))
        .catchError((error) => debugPrint("Failed to add user: $error"));
  }

  Future<DocumentSnapshot?> getUserInfo() async {
    DocumentReference documentReference = userCollection.doc(uid);

    DocumentSnapshot snapshot = await documentReference.get();
    if (snapshot.exists) {
      return snapshot;
    } else {
      return null;
    }
  }

  Future<void> uploadReading(Map<String, dynamic> data) async {
    return await userCollection
        .doc(uid)
        .set(data, SetOptions(merge: true))
        .then((value) => debugPrint("Updated Reading"))
        .catchError((error) => debugPrint("Failed to add reading: $error"));
  }

  Future<void> addReading(Map<String, dynamic> newReading) async {
    final CollectionReference users =
        FirebaseFirestore.instance.collection('users');
    final DocumentReference userDoc = users.doc(uid);

    // Get the current "readings" map
    DocumentSnapshot userSnapshot = await userDoc.get();
    Map<String, dynamic> reading = userSnapshot.get('reading');

    // Add the new reading to the "readings" map
    String timestamp = newReading['timestamp'];
    reading[timestamp] = newReading;

    // Update the "readings" map in Firestore
    await userDoc.update({'readings': reading});
  }
}
