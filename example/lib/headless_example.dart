import 'dart:async';
import 'package:auth_sdk/auth_sdk.dart';
import 'package:flutter/material.dart';

/// Example of using AuthRepository in headless mode with custom UI
/// and custom state management (using StatefulWidget + setState).
///
/// This demonstrates that users DON'T need to use BLoC/Cubit.
class HeadlessExample extends StatefulWidget {
  const HeadlessExample({
    super.key,
    required this.authRepository,
    this.onBack,
  });

  final AuthRepository authRepository;
  final VoidCallback? onBack;

  @override
  State<HeadlessExample> createState() => _HeadlessExampleState();
}

class _HeadlessExampleState extends State<HeadlessExample>
    with SingleTickerProviderStateMixin {
  final TextEditingController _signInEmailController = TextEditingController();
  final TextEditingController _signInPasswordController =
      TextEditingController();

  final TextEditingController _signUpEmailController = TextEditingController();
  final TextEditingController _signUpPasswordController =
      TextEditingController();

  late TabController _tabController;

  AuthUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _errorTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Listen to auth state changes using the stream
    widget.authRepository.authStateStream.listen((user) {
      debugPrint(
          'Headless: Auth state changed - User: ${user?.email ?? "null"}');
      setState(() {
        _currentUser = user;
      });
    });

    // Clear errors when switching tabs
    _tabController.addListener(() {
      setState(() {
        _errorMessage = null;
      });
    });
  }

  @override
  void dispose() {
    _errorTimer?.cancel();
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    _signUpEmailController.dispose();
    _signUpPasswordController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  /// Set error message and auto-clear after 5 seconds
  void _setError(String message) {
    _errorTimer?.cancel();
    setState(() {
      _errorMessage = message;
    });

    // Auto-clear error after 5 seconds
    _errorTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _errorMessage = null;
        });
      }
    });
  }

  Future<void> _signInWithEmail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.authRepository.signInWithEmail(
        _signInEmailController.text.trim(),
        _signInPasswordController.text,
      );
    } on InvalidCredentialsException catch (e) {
      _setError(e.message);
    } on UserNotFoundException catch (e) {
      _setError(e.message);
    } on NetworkException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signUpWithEmail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.authRepository.signUpWithEmail(
        _signUpEmailController.text.trim(),
        _signUpPasswordController.text,
      );
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on EmailAlreadyInUseException catch (e) {
      _setError(e.message);
    } on WeakPasswordException catch (e) {
      _setError(e.message);
    } on InvalidCredentialsException catch (e) {
      _setError(e.message);
    } on NetworkException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.authRepository.signInWithGoogle();
    } catch (e) {
      _setError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    await widget.authRepository.signOut();
  }

  @override
  Widget build(BuildContext context) {
    // If user is authenticated, show home screen
    if (_currentUser != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          title: const Text(
            'Headless Mode',
            style: TextStyle(color: Colors.white),
          ),
          leading: widget.onBack != null
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: widget.onBack,
                )
              : null,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: _signOut,
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_user, size: 80, color: Colors.green),
              const SizedBox(height: 20),
              Text(
                'Welcome!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              Text('Email: ${_currentUser!.email ?? 'N/A'}'),
              const SizedBox(height: 5),
              Text(
                'UID: ${_currentUser!.uid}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // Show custom login/signup UI with tabs
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Headless Mode - Custom UI',
          style: TextStyle(color: Colors.white),
        ),
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: widget.onBack,
              )
            : null,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Sign In'),
            Tab(text: 'Sign Up'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Sign In Tab
          _buildSignInTab(),

          // Sign Up Tab
          _buildSignUpTab(),
        ],
      ),
    );
  }

  // Sign In Tab Content
  Widget _buildSignInTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Welcome back!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sign in to continue',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 32),

          // Error message
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Email field
          TextField(
            controller: _signInEmailController,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.email, color: Colors.blueAccent),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            keyboardType: TextInputType.emailAddress,
            enabled: !_isLoading,
          ),
          const SizedBox(height: 16),

          // Password field
          TextField(
            controller: _signInPasswordController,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock, color: Colors.blueAccent),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            obscureText: true,
            enabled: !_isLoading,
          ),
          const SizedBox(height: 24),

          // Sign In Button
          ElevatedButton(
            onPressed: _isLoading ? null : _signInWithEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Sign In',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),

          const SizedBox(height: 24),
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('OR', style: TextStyle(color: Colors.grey)),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 24),

          // Google Sign In Button
          OutlinedButton.icon(
            onPressed: _isLoading ? null : _signInWithGoogle,
            icon: const Icon(Icons.g_mobiledata, size: 32),
            label: const Text('Sign In with Google'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: Colors.grey[50],
              foregroundColor: Colors.black87,
              side: BorderSide(color: Colors.grey[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Sign Up Tab Content
  Widget _buildSignUpTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Create Account',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sign up to get started',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 32),

          // Error message
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Email field
          TextField(
            controller: _signUpEmailController,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.email, color: Colors.blueAccent),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            keyboardType: TextInputType.emailAddress,
            enabled: !_isLoading,
          ),
          const SizedBox(height: 16),

          // Password field
          TextField(
            controller: _signUpPasswordController,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'At least 6 characters',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock, color: Colors.blueAccent),
              helperText: 'Minimum 6 characters',
              filled: true,
              fillColor: Colors.grey[50],
            ),
            obscureText: true,
            enabled: !_isLoading,
          ),
          const SizedBox(height: 24),

          // Sign Up Button
          ElevatedButton(
            onPressed: _isLoading ? null : _signUpWithEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Create Account',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),

          const SizedBox(height: 24),
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('OR', style: TextStyle(color: Colors.grey)),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 24),

          // Google Sign In Button
          OutlinedButton.icon(
            onPressed: _isLoading ? null : _signInWithGoogle,
            icon: const Icon(Icons.g_mobiledata, size: 32),
            label: const Text('Sign Up with Google'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: Colors.grey[50],
              foregroundColor: Colors.black87,
              side: BorderSide(color: Colors.grey[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Info box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This example uses setState (no BLoC required). You can use any state management solution!',
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
