import 'package:auth_sdk/auth_sdk.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'headless_example.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final FirebaseAuthService _authService;
  late final AuthCubit _authCubit;
  late final AuthRepository _authRepository;

  @override
  void initState() {
    super.initState();

    _authService = FirebaseAuthService();
    _authCubit = AuthCubit(_authService);
    _authRepository = AuthRepository(_authService);
  }

  @override
  void dispose() {
    _authRepository.dispose();
    _authCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>.value(
      value: _authCubit,
      child: MaterialApp(
        title: 'Auth SDK Example',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: ExampleSelection(authRepository: _authRepository),
      ),
    );
  }
}

class ExampleSelection extends StatefulWidget {
  const ExampleSelection({
    super.key,
    required this.authRepository,
  });

  final AuthRepository authRepository;

  @override
  State<ExampleSelection> createState() => _ExampleSelectionState();
}

class _ExampleSelectionState extends State<ExampleSelection> {
  String? _selectedMode; // null, 'ui', or 'headless'

  @override
  Widget build(BuildContext context) {
    if (_selectedMode == 'ui') {
      return UIModeExample(onBack: () {
        setState(() => _selectedMode = null);
      });
    }

    if (_selectedMode == 'headless') {
      return HeadlessExample(
        authRepository: widget.authRepository,
        onBack: () {
          setState(() => _selectedMode = null);
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Auth SDK Examples'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.security,
                size: 80,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 24),
              const Text(
                'Auth SDK Demo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Choose an authentication mode to test',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 48),

              // UI Mode Button
              ElevatedButton.icon(
                onPressed: () => setState(() => _selectedMode = 'ui'),
                icon: const Icon(Icons.widgets),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pre-built UI Mode',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Ready-to-use AuthWidget with BLoC',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  alignment: Alignment.centerLeft,
                ),
              ),

              const SizedBox(height: 16),

              // Headless Mode Button
              OutlinedButton.icon(
                onPressed: () => setState(() => _selectedMode = 'headless'),
                icon: const Icon(Icons.code),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Headless Mode',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Custom UI with any state management',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  alignment: Alignment.centerLeft,
                ),
              ),

              const SizedBox(height: 48),
              const Text(
                '💡 Tip: Both modes use the same auth logic underneath',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UIModeExample extends StatelessWidget {
  const UIModeExample({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    debugPrint('🔵 UIModeExample building...');

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        debugPrint('🔵 BlocConsumer listener: ${state.status}');
      },
      builder: (context, state) {
        debugPrint('🔵 BlocBuilder building with status: ${state.status}');

        if (state.status == AuthStatus.authenticated) {
          return HomeScreen(onBack: onBack);
        }
        return AuthWidget(
          config: const AuthConfig(
            enableEmail: true,
            enableGoogle: true,
            enableApple: false,
          ),
          onBack: onBack,
        );
      },
    );
  }
}
