import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ✅ REGISTER
  Future<void> registerUser(String name, String email, String password, String dob) async {
    UserCredential user = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _db.collection('users').doc(user.user!.uid).set({
      'name': name,
      'email': email,
      
    });
  }

  // ✅ LOGIN
  Future<void> loginUser(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // ✅ GET USER DATA
  Future<Map<String, dynamic>?> getUserData() async {
    String uid = _auth.currentUser!.uid;

    DocumentSnapshot doc = await _db.collection('users').doc(uid).get();

    return doc.data() as Map<String, dynamic>;
  }

  // ✅ LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
}