import 'package:flutter/material.dart';

class AuthWidget extends StatelessWidget {
  const AuthWidget({
    super.key,
    this.enableEmail = true,
    this.enableGoogle = true,
    this.enableApple = true,
  });

  final bool enableEmail;
  final bool enableGoogle;
  final bool enableApple;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login"),),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (enableEmail) 
            ElevatedButton(
              onPressed: () {}, 
              child: const Text('Continue with Email')
            ),

            if (enableGoogle) 
            ElevatedButton(
              onPressed: () {}, 
              child: const Text('Continue with Google')
            ),

            if (enableApple) 
            ElevatedButton(
              onPressed: () {}, 
              child: const Text('Continue with Apple')
            )
          ],
        ),
      ),
    );
  }
}