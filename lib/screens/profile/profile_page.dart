import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../welcome/welcome_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String name = "";
  String email = "";

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  // ✅ LOAD USER DATA FROM FIRESTORE
  Future<void> loadUserData() async {
    User? user = _auth.currentUser;

    if (user != null) {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists && doc.data() != null) {
        var data = doc.data() as Map<String, dynamic>;

        setState(() {
          name = data['name'] ?? "";
          email = data['email'] ?? "";

          nameController.text = name;
          emailController.text = email;
        });
      }
    }
  }

  // ✅ UPDATE DATA
  Future<void> saveUserData() async {
    User? user = _auth.currentUser;

    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'name': nameController.text,
        'email': emailController.text,
      });

      setState(() {
        isEditing = false;
      });

      loadUserData();
    }
  }

  // ✅ LOGOUT
  Future<void> logout() async {
    await _auth.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),

      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (isEditing) {
                saveUserData();
              } else {
                setState(() {
                  isEditing = true;
                });
              }
            },
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const SizedBox(height: 20),

            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/profile.jpeg'),
            ),

            const SizedBox(height: 30),

            // 👤 NAME
            TextField(
              controller: nameController,
              enabled: isEditing,
              decoration: InputDecoration(
                labelText: "Name",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // 📧 EMAIL
            TextField(
              controller: emailController,
              enabled: isEditing,
              decoration: InputDecoration(
                labelText: "Email",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 🚪 LOGOUT
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: logout,
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}