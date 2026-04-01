import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/providers.dart';
import '../../models/models.dart';
import '../../utils/appwrite_service.dart';
import 'signup_screen.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _goGuest() async {
    // Mock guest user
    final guestName =
        'Guest #${DateTime.now().millisecondsSinceEpoch.toString().substring(10)}';
    context.read<AuthProvider>().signIn('guest@example.com', 'guest123');
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final mutedColor = AppTheme.textMuted(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background circles
          Positioned(
            top: -100,
            left: -120,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primary.withOpacity(0.5),
                    AppTheme.primary.withOpacity(0.02)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            right: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.secondary.withOpacity(0.8),
                    AppTheme.secondary.withOpacity(0.03)
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Center(
                    child: Image.asset(
                      'assets/logos/logow.jpg',
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 100,
                        height: 100,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.restaurant_menu_rounded,
                            size: 40, color: AppTheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Welcome',
                    style: GoogleFonts.cairo(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Sign in or continue as guest',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      color: mutedColor,
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: _emailCtrl,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: auth.loading
                          ? null
                          : () async {
                              final err = await auth.signIn(
                                  _emailCtrl.text.trim(), _passCtrl.text);
                              if (err == null && mounted) {
                                Navigator.pushReplacementNamed(
                                    context, '/home');
                              } else if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(err ?? 'Login failed'),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                      ),
                      child: auth.loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              'Sign In',
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupScreen()),
                      ),
                      child: Text(
                        "Don't have account? Sign Up",
                        style: GoogleFonts.cairo(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: Text(
                      'OR',
                      style: GoogleFonts.cairo(
                        color: mutedColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: _goGuest,
                      icon: Icon(Icons.person_off,
                          size: 20, color: AppTheme.secondary),
                      label: Text(
                        'Continue as Guest',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.secondary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.secondary, width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
