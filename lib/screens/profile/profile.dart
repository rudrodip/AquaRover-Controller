import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aquarover/screens/authenticate/signin.dart';
import 'package:aquarover/services/database.dart';
import 'package:aquarover/widgets/loading_screen.dart';
import 'package:aquarover/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic>? userInfo;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = Provider.of<User?>(context, listen: false);
    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    DocumentSnapshot? snapshot =
        await DatabaseService(uid: user.uid).getUserInfo();
    if (snapshot != null) {
      setState(() {
        userInfo = snapshot.data() as Map<String, dynamic>?;
        isLoading = false;
      });
    } else {
      setState(() {
        userInfo = null;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Auth firebaseAuth = Auth();

    Widget loginButton() {
      return ElevatedButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const SignIn()));
          },
          child: const Text('Login'));
    }

    Widget logoutButton() {
      return ElevatedButton(
          onPressed: () {
            firebaseAuth.signOut();
          },
          child: const Text('Logout'));
    }

    final user = Provider.of<User?>(context);

    return isLoading == false
        ? user != null && userInfo != null
            ? Scaffold(
                appBar: AppBar(
                  title: const Text('Profile'),
                  automaticallyImplyLeading: false,
                ),
                body: Column(
                  children: [
                    // Show user info
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(userInfo!['photoURL']),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userInfo!['name'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Sample Collected: ${userInfo!['sampleCollected']}'),
                    Text('Location: ${userInfo!['location']}'),
                    logoutButton()
                  ],
                ))
            : Center(child: loginButton())
        : const LoadingScreen();
  }
}
