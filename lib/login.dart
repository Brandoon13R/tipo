import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: loginPage(),
  ));
}

class loginPage extends StatelessWidget {
  const loginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Login Page',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle login button press
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}