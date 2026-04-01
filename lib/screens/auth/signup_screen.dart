import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/providers.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Full name is required';
    if (v.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.isEmpty) return 'Email is required';
    final reg = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!reg.hasMatch(v)) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : const Color(0xFFF8F8F8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Top Header ──────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : Colors.white,
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.darkBg
                              : const Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color:
                              isDark ? AppTheme.textDark : AppTheme.textLight,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Logo + title
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.restaurant_menu_rounded,
                              color: AppTheme.primary, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Create Account',
                              style: GoogleFonts.cairo(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppTheme.textDark
                                    : AppTheme.textLight,
                              ),
                            ),
                            Text(
                              'Join Wajbati & start ordering',
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                color: isDark
                                    ? AppTheme.textMutedDark
                                    : AppTheme.textMutedLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Form ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FormLabel(label: 'Full Name'),
                      const SizedBox(height: 8),
                      _FormField(
                        controller: _nameCtrl,
                        hint: 'Ahmed Ben Ali',
                        icon: Icons.person_outline_rounded,
                        validator: _validateName,
                        isDark: isDark,
                      ),

                      const SizedBox(height: 18),
                      _FormLabel(label: 'Email Address'),
                      const SizedBox(height: 8),
                      _FormField(
                        controller: _emailCtrl,
                        hint: 'ahmed@email.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                        isDark: isDark,
                      ),

                      const SizedBox(height: 18),
                      _FormLabel(label: 'Password'),
                      const SizedBox(height: 8),
                      _FormField(
                        controller: _passCtrl,
                        hint: 'Min. 8 characters',
                        icon: Icons.lock_outline_rounded,
                        obscure: _obscurePass,
                        isDark: isDark,
                        validator: _validatePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePass
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 18,
                            color: isDark
                                ? AppTheme.textMutedDark
                                : AppTheme.textMutedLight,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePass = !_obscurePass),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Register button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: auth.loading
                              ? null
                              : () async {
                                  if (!_formKey.currentState!.validate()) {
                                    return;
                                  }
                                  final err = await auth.register(
                                    _nameCtrl.text.trim(),
                                    _emailCtrl.text.trim(),
                                    _passCtrl.text,
                                  );
                                  if (err != null && mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(_friendlyError(err),
                                          style: GoogleFonts.cairo()),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ));
                                  } else if (mounted) {
                                    Navigator.pushNamedAndRemoveUntil(
                                        context, '/home', (_) => false);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: auth.loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  'Create Account',
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Sign in link
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                color: isDark
                                    ? AppTheme.textMutedDark
                                    : AppTheme.textMutedLight,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Text(
                                'Sign In',
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _friendlyError(String raw) {
    if (raw.contains('already exists') || raw.contains('409')) {
      return 'This email is already registered. Try signing in.';
    }
    if (raw.contains('Invalid email')) return 'Please enter a valid email.';
    if (raw.contains('password')) {
      return 'Password must be at least 8 characters.';
    }
    return 'Something went wrong. Please try again.';
  }
}

// ── Form helpers ───────────────────────────────────────────────────

class _FormLabel extends StatelessWidget {
  final String label;
  const _FormLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      label,
      style: GoogleFonts.cairo(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isDark ? AppTheme.textDark : AppTheme.textLight,
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final bool isDark;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  const _FormField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.isDark,
    this.obscure = false,
    this.keyboardType,
    this.validator,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.cairo(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.cairo(
          fontSize: 13,
          color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
        ),
        prefixIcon: Icon(icon,
            size: 18,
            color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDark ? AppTheme.darkCard : Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: isDark ? AppTheme.darkDivider : AppTheme.lightDivider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: isDark ? AppTheme.darkDivider : AppTheme.lightDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}
