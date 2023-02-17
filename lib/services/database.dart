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
}
