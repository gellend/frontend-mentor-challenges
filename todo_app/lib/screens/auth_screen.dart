import 'package:flutter/material.dart';
import 'package:todo_app/services/auth_service.dart';
import 'package:todo_app/constants/text_styles.dart';
import 'package:todo_app/screens/todo_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  bool _isLoginMode = true;
  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitAuthForm() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLoginMode) {
        await _authService.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await _authService.signUpWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
      
      // Add navigation after successful authentication
      if (mounted) {
        // Navigate to TodoScreen and remove all previous routes
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const TodoScreen(title: 'TODO')),
          (route) => false,
        );
      }
      
    } catch (error) {
      // Error is already printed in AuthService, but we can show a SnackBar here
      String errorMessage = 'Authentication failed. Please try again.';
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage, style: bodyTextStyle.copyWith(color: Theme.of(context).colorScheme.onError)),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }

    if (mounted) { // Check if the widget is still in the tree
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        // Add ConstrainedBox to limit the width on larger screens
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400), // Max width for the form content
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    _isLoginMode ? 'Welcome Back!' : 'Create Account',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ) ?? bodyTextStyleBold.copyWith(fontSize: 24, color: theme.colorScheme.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLoginMode ? 'Login to continue' : 'Sign up to get started',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant) 
                           ?? bodyTextStyle.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'you@example.com',
                      prefixIcon: Icon(Icons.email_outlined, color: theme.colorScheme.onSurfaceVariant),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                    ),
                    style: bodyTextStyle.copyWith(color: theme.colorScheme.onSurface),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty || !value.contains('@')) {
                        return 'Please enter a valid email address.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline, color: theme.colorScheme.onSurfaceVariant),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                    ),
                    style: bodyTextStyle.copyWith(color: theme.colorScheme.onSurface),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty || value.length < 6) {
                        return 'Password must be at least 6 characters long.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            textStyle: bodyTextStyleBold.copyWith(fontSize: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          onPressed: _submitAuthForm,
                          child: Text(_isLoginMode ? 'Login' : 'Sign Up'),
                        ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLoginMode = !_isLoginMode;
                        _formKey.currentState?.reset(); // Reset validation errors
                      });
                    },
                    child: Text(
                      _isLoginMode ? 'Need an account? Sign Up' : 'Have an account? Login',
                      style: bodyTextStyle.copyWith(color: theme.colorScheme.primary, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 