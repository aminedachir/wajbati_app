import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import 'order_confirmation_screen.dart';

class CheckoutAddressScreen extends StatefulWidget {
  const CheckoutAddressScreen({super.key});

  @override
  State<CheckoutAddressScreen> createState() => _CheckoutAddressScreenState();
}

class _CheckoutAddressScreenState extends State<CheckoutAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _useLocation = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    if (_useLocation || _formKey.currentState!.validate()) {
      // Logic for processing address would go here
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const OrderConfirmationScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mutedColor = AppTheme.textMuted(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Address'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How should we deliver?',
              style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),

            // Option 2: GPS Location
            _buildOptionCard(
              title: 'Use Current Location',
              subtitle: 'Activate GPS to find your address automatically',
              icon: Icons.my_location_rounded,
              isSelected: _useLocation,
              onTap: () => setState(() => _useLocation = true),
            ),

            const SizedBox(height: 16),

            // Option 1: Manual Entry
            _buildOptionCard(
              title: 'Manual Entry',
              subtitle: 'Fill in your details manually',
              icon: Icons.edit_location_alt_rounded,
              isSelected: !_useLocation,
              onTap: () => setState(() => _useLocation = false),
            ),

            const SizedBox(height: 32),

            if (!_useLocation)
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) =>
                          v!.isEmpty ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Mobile Phone',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: (v) =>
                          v!.isEmpty ? 'Please enter your phone' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Full Address',
                        prefixIcon: Icon(Icons.home_outlined),
                      ),
                      validator: (v) =>
                          v!.isEmpty ? 'Please enter your address' : null,
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.location_on,
                        color: AppTheme.primary, size: 40),
                    const SizedBox(height: 12),
                    Text(
                      'GPS Activation Required',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'We will use your phone\'s location to deliver your food.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(fontSize: 13, color: mutedColor),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Promo Code Field
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Code promo (optional)',
                prefixIcon: Icon(Icons.local_offer_outlined),
                suffixIcon: IconButton(
                  icon: Icon(Icons.close, size: 18),
                  onPressed: () {},
                ),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _handleConfirm,
                child: Text(
                  _useLocation ? 'Activate & Confirm' : 'Confirm Address',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withOpacity(0.05)
              : (isDark ? AppTheme.darkCard : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : (isDark ? AppTheme.darkDivider : AppTheme.lightDivider),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppTheme.primary : Colors.grey),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                  Text(subtitle,
                      style:
                          GoogleFonts.cairo(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppTheme.primary),
          ],
        ),
      ),
    );
  }
}
