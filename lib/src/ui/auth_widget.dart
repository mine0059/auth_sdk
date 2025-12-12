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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LoadingOverlay(
      visible: cubit.state.status == AuthStatus.loading,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: widget.onBack != null
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  onPressed: widget.onBack,
                )
              : null,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
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
                      content: Text(state.errorMessage ?? "An error occurred"),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              builder: (context, state) {
                final isLoading = state.status == AuthStatus.loading;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- Header (No Logo, Just Text) ---
                    Text(
                      _isSignUp ? 'Create Account' : 'Welcome Back',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isSignUp
                          ? 'Enter your details to sign up'
                          : 'Enter your details to sign in',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // --- Email & Password Fields ---
                    if (widget.config.enableEmail) ...[
                      EmailTextfield(controller: _emailController),
                      const SizedBox(height: 16),
                      PasswordTextfield(controller: _passwordController),
                      const SizedBox(height: 24),

                      // --- Main Action Button ---
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
                                          'Please enter email and password'),
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
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.black, // Modern black button
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          isLoading
                              ? 'Processing...'
                              : (_isSignUp ? 'Sign Up' : 'Sign In'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],

                    // --- Divider ---
                    if (widget.config.enableEmail &&
                        (widget.config.enableGoogle ||
                            widget.config.enableApple)) ...[
                      const SizedBox(height: 32),
                      const Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Or continue with',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],

                    // --- Social Buttons (Google & Apple Only) ---
                    // Google
                    if (widget.config.enableGoogle)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GoogleSignInButton(
                          onPressed:
                              isLoading ? null : () => cubit.signInWithGoogle(),
                          isLoading: isLoading,
                        ),
                      ),

                    // Apple
                    if (widget.config.enableApple)
                      AppleSignInButton(
                        onPressed:
                            isLoading ? null : () => cubit.SignInWithApple(),
                        isLoading: isLoading,
                      ),

                    const SizedBox(height: 48),

                    // --- Toggle Sign In / Sign Up ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isSignUp
                              ? "Already have an account? "
                              : "Don't have an account? ",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        GestureDetector(
                          onTap: isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _isSignUp = !_isSignUp;
                                    // Clear fields when switching
                                    _emailController.clear();
                                    _passwordController.clear();
                                  });
                                },
                          child: Text(
                            _isSignUp ? "Sign In" : "Sign Up",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black, // Or your primary color
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
