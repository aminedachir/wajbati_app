import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import 'order_confirmation_screen.dart';
import 'checkout_payment_screen.dart';

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
        MaterialPageRoute(builder: (_) => const CheckoutPaymentScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mutedColor = AppTheme.textMuted(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('عنوان التوصيل'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'كيف نصل إليك؟',
              style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),

            // Option 2: GPS Location
            _buildOptionCard(
              title: 'استخدام الموقع الحالي',
              subtitle: 'تفعيل الـ GPS لتحديد عنوانك تلقائياً',
              icon: Icons.my_location_rounded,
              isSelected: _useLocation,
              onTap: () => setState(() => _useLocation = true),
            ),

            const SizedBox(height: 16),

            // Option 1: Manual Entry
            _buildOptionCard(
              title: 'إدخال يدوي',
              subtitle: 'أدخل تفاصيل العنوان يدوياً',
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
                        labelText: 'الاسم الكامل',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) =>
                          v!.isEmpty ? 'يرجى إدخال الاسم' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'رقم الهاتف',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: (v) =>
                          v!.isEmpty ? 'يرجى إدخال رقم الهاتف' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'العنوان الكامل',
                        prefixIcon: Icon(Icons.home_outlined),
                      ),
                      validator: (v) =>
                          v!.isEmpty ? 'يرجى إدخال العنوان' : null,
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.location_on,
                        color: AppTheme.primary, size: 40),
                    const SizedBox(height: 12),
                    Text(
                      'مطلوب تفعيل GPS',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'سنستخدم موقع هاتفك لتوصيل طلبك بدقة.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(fontSize: 13, color: mutedColor),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _handleConfirm,
                child: Text(
                  'متابعة للدفع',
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
              ? AppTheme.primary.withValues(alpha: 0.05)
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
