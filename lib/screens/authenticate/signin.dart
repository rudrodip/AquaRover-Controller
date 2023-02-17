import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aquarover/services/auth.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  String? errorMessage = '';
  bool isLogin = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerName = TextEditingController();
  final Auth firebaseAuth = Auth();

  Future<void> signInWithEmailAndPassWord() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> createUserWithEmailAndPassWord() async {
    try {
      await Auth().createUserWithEmailAndPassword(
          email: _controllerEmail.text,
          password: _controllerPassword.text,
          name: _controllerName.text);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Widget _title() {
    return const Text('AquaRover login');
  }

  Widget _entryFieldText(
    String title,
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
      ),
    );
  }

  Widget _entryFieldPassword(
    String title,
    TextEditingController controller,
  ) {
    return TextField(
      obscureText: true,
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
      ),
    );
  }

  Widget _errorMessage() {
    return Text(
      errorMessage == '' ? '' : 'Humm ? $errorMessage',
      style: const TextStyle(color: Colors.red),
    );
  }

  Widget _submitButton() {
    return ElevatedButton(
        onPressed: isLogin
            ? signInWithEmailAndPassWord
            : createUserWithEmailAndPassWord,
        child: Text(isLogin ? 'Login' : 'Register'));
  }

  Widget _loginOrRegisterButton() {
    return TextButton(
        onPressed: () {
          setState(() {
            isLogin = !isLogin;
          });
        },
        child: Text(isLogin ? 'Register' : 'Login'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
      ),
      body: Padding(
        // height: double.infinity,
        // width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (!isLogin) _entryFieldText('Name', _controllerName),
            _entryFieldText('Email', _controllerEmail),
            _entryFieldPassword('Password', _controllerPassword),
            _errorMessage(),
            _submitButton(),
            _loginOrRegisterButton(),
          ],
        ),
      ),
    );
  }
}
