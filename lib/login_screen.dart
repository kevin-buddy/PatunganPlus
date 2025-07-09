import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            const Text('AyamKu'),
            const SizedBox(
              height: 15,
            ),
            SizedBox(
              width: 300,
              child: TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(20.0),
                  hintText: 'Username',
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            SizedBox(
              width: 300,
              child: TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(20.0),
                  hintText: 'Password',
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            FilledButton(
                onPressed: () {
                  doLogin();
                },
                child: const Text('Masuk'))
          ],
        ),
      ),
    );
  }

  void doLogin() {
    if (usernameController.text == 'username' &&
        passwordController.text == 'password') {
      Navigator.of(context).pushNamed('otp-screen');
    } else {
      setState(() {
        usernameController.text = '';
        passwordController.text = '';
      });
    }
  }
}
