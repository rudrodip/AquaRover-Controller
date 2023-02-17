import 'package:aquarover/screens/authenticate/signin.dart';
import 'package:aquarover/screens/home/home.dart';
import 'package:aquarover/screens/data/data.dart';
import 'package:aquarover/screens/profile/profile.dart';
import 'package:aquarover/screens/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  int currentPage = 0;
  List<Widget> pages = [
    const Home(),
    const Data(),
    const Profile(),
    const Settings(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    return user != null
        ? Scaffold(
            body: pages[currentPage],
            bottomNavigationBar: NavigationBar(
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
                NavigationDestination(
                    icon: Icon(Icons.data_exploration), label: 'Data'),
                NavigationDestination(
                    icon: Icon(Icons.person), label: 'Profile'),
                NavigationDestination(
                    icon: Icon(Icons.settings), label: 'Settings'),
              ],
              onDestinationSelected: (int index) {
                setState(() {
                  currentPage = index;
                });
              },
              selectedIndex: currentPage,
            ),
          )
        : const SignIn();
  }
}
