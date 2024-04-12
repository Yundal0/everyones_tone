import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:everyones_tone/app/models/user_model.dart';
import 'package:everyones_tone/app/utils/firestore_data.dart';

class RegisterProfileRemoteRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> registerUserData(UserModel userModel) async {
    DocumentReference userRef = _firestore.collection('user').doc(FirestoreData.currentUserEmail);

    await userRef.set(userModel.toMap());
  }
}
