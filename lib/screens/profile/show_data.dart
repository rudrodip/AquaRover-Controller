import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aquarover/services/database.dart';
import 'package:aquarover/widgets/loading_screen.dart';
import 'package:aquarover/services/auth.dart';
import 'package:aquarover/screens/authenticate/signin.dart';

class ShowUserInfo extends StatefulWidget {
  final String? uid;

  const ShowUserInfo({required this.uid, Key? key}) : super(key: key);

  @override
  State<ShowUserInfo> createState() => _ShowUserInfoState();
}

class _ShowUserInfoState extends State<ShowUserInfo> {
  Map<String, dynamic>? userInfo;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    DocumentSnapshot? snapshot =
        await DatabaseService(uid: widget.uid).getUserInfo();
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

    return Scaffold(
      body: isLoading
          ? const LoadingScreen()
          : userInfo != null
              ? Column(
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
                    Text('Sample Collected: ${userInfo!['location']}'),
                    logoutButton()
                  ],
                )
              : loginButton(),
    );
  }
}
