import 'package:flutter/material.dart';

class AuthenticationScreen extends StatefulWidget {
    const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}
class _AuthenticationScreenState extends State<AuthenticationScreen>{
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body:
        Form(
          key: _formKey,
          child: Column(
          children: [
            TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                    if (value == null || value.isEmpty) return 'Email is required';
                    if (!value.contains('@')) return 'Enter a valid email address';
                    return null;
                },
            ),
            TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                    if (value == null || value.length < 6) {
                        return 'Password must be at least 6 characters';
                    }
                    return null;
                },
            ),
            ElevatedButton(
                onPressed: () {
                    if (_formKey.currentState!.validate()) {
                        // Call the appropriate AuthService method here.
                    }
                },
                child: const Text('Continue'),
            ),
        ],
    ),
)
    );
  
}
}


