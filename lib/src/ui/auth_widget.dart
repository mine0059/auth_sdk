import 'package:auth_sdk/auth_sdk.dart';
import 'package:auth_sdk/src/ui/components/email_textfield.dart';
import 'package:auth_sdk/src/ui/components/loading_overlay.dart';
import 'package:auth_sdk/src/ui/components/password_textfield.dart';
import 'package:auth_sdk/src/ui/components/social_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthWidget extends StatefulWidget {
  const AuthWidget({
    super.key,
    this.config = AuthConfig.defaultConfig,
    this.onBack,
  });

  final AuthConfig config;
  final VoidCallback? onBack;

  @override
  State<AuthWidget> createState() => _AuthWidgetState();
}

class _AuthWidgetState extends State<AuthWidget> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();
    return LoadingOverlay(
      visible: cubit.state.status == AuthStatus.loading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isSignUp ? "Sign Up" : "Sign In"),
          leading: widget.onBack != null
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: widget.onBack,
                )
              : null,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state.status == AuthStatus.authenticated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _isSignUp
                          ? "Account created successfully!"
                          : "Logged in successfully!",
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }

              if (state.status == AuthStatus.error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage ?? "Error occurred"),
                    backgroundColor: Colors.red,
                  ),
                );
              }

              if (state.status == AuthStatus.tokenExpired) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Session expired. Please login again."),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            builder: (context, state) {
              final isLoading = state.status == AuthStatus.loading;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Sign In / Sign Up Toggle
                  if (widget.config.enableEmail) ...[
                    // Info banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue[700]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _isSignUp
                                  ? 'Create a new account'
                                  : 'Sign in to your account',
                              style: TextStyle(color: Colors.blue[900]),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Email/Password Fields
                    EmailTextfield(controller: _emailController),
                    const SizedBox(height: 12),
                    PasswordTextfield(controller: _passwordController),
                    const SizedBox(height: 12),

                    // Submit Button
                    ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              final email = _emailController.text.trim();
                              final password = _passwordController.text;

                              if (email.isEmpty || password.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please enter email and password',
                                    ),
                                  ),
                                );
                                return;
                              }

                              if (_isSignUp) {
                                cubit.signUpWithEmail(email, password);
                              } else {
                                cubit.signInWithEmail(email, password);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                      child: Text(
                        isLoading
                            ? 'Loading...'
                            : _isSignUp
                                ? 'Create Account'
                                : 'Sign In',
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Toggle between Sign In and Sign Up
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              setState(() {
                                _isSignUp = !_isSignUp;
                              });
                            },
                      child: Text(
                        _isSignUp
                            ? 'Already have an account? Sign In'
                            : "Don't have an account? Sign Up",
                      ),
                    ),
                  ],

                  if (widget.config.enableEmail &&
                      (widget.config.enableGoogle ||
                          widget.config.enableApple)) ...[
                    const SizedBox(height: 20),
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('OR'),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (widget.config.enableGoogle)
                    GoogleSignInButton(
                      onPressed:
                          isLoading ? null : () => cubit.signInWithGoogle(),
                      isLoading: isLoading,
                    ),
                  if (widget.config.enableGoogle && widget.config.enableApple)
                    const SizedBox(height: 12),
                  if (widget.config.enableApple)
                    AppleSignInButton(
                      onPressed:
                          isLoading ? null : () => cubit.SignInWithApple(),
                      isLoading: isLoading,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
