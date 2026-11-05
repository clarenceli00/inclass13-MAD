import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _loading = false;
  String? _message;
  bool _hasError = false;

  Future<void> _updatePassword() async {
    if (_loading || !_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      await _authService.changePasswordWithRecovery(
        _newPasswordController.text,
        _currentPasswordController.text,
      );

      _currentPasswordController.clear();
      _newPasswordController.clear();

      if (mounted) {
        setState(() {
          _hasError = false;
          _message = 'Password updated. Use your new password next time.';
        });
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _message = authErrorMessage(error);
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _message = 'Unable to update your password. Try signing in again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _signOut() async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      await _authService.signOut();
      // AuthGate returns to AuthenticationScreen automatically.
    } catch (_) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _message = 'Unable to sign out. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in to view your profile.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Signed in as: ${user.email ?? "Email unavailable"}'),
              const SizedBox(height: 24),
              Text(
                'Change password',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _currentPasswordController,
                enabled: !_loading,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Current password',
                  helperText: 'Used if Firebase asks you to verify again.',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your current password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                enabled: !_loading,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'New password',
                ),
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  if (value == _currentPasswordController.text) {
                    return 'Choose a different password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              if (_message != null) ...[
                Text(
                  _message!,
                  style: TextStyle(
                    color: _hasError
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (_loading)
                const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loading ? null : _updatePassword,
                child: const Text('Update password'),
              ),
              OutlinedButton(
                onPressed: _loading ? null : _signOut,
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}