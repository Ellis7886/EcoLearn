import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {

  static Future<void> addTestData() async {

    await FirebaseFirestore.instance
        .collection('test')
        .add({

      'message': 'Firebase is working!',
      'time': DateTime.now(),

    });
  }
}