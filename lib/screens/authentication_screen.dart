import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../auth_service.dart';

class AuthenticationScreen extends StatefulWidget {
    const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}
class _AuthenticationScreenState extends State<AuthenticationScreen>{
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _registering = false;
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (_loading || !_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (_registering) {
        await _authService.register(email, password);
      } else {
        await _authService.signIn(email, password);
      }
      // AuthGate reacts to the authenticated user automatically.
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        setState(() => _error = authErrorMessage(error));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_registering ? 'Create account' : 'Sign in'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                enabled: !_loading,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                textCapitalization: TextCapitalization.none,
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (email.isEmpty) return 'Email is required';

                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                      .hasMatch(email)) {
                    return 'Enter a valid email address';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                enabled: !_loading,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              if (_error != null) ...[
                Text(
                  _error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (_loading)
                const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: Text(_registering ? 'Register' : 'Sign in'),
              ),
              TextButton(
                onPressed: _loading
                    ? null
                    : () {
                        setState(() {
                          _registering = !_registering;
                          _error = null;
                          _passwordController.clear();
                          _formKey.currentState?.reset();
                        });
                      },
                child: Text(
                  _registering
                      ? 'Sign in Page'
                      : 'Register an Account',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}