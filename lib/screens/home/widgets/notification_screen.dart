import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: index % 3 == 0
                      ? AppTheme.primary.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                    index % 3 == 0 ? Icons.restaurant : Icons.shopping_bag,
                    color: index % 3 == 0 ? AppTheme.primary : Colors.green),
              ),
              title: Text(
                  'New order from ${[
                    'Dar El Medina',
                    'Pizza Palace',
                    'Burger House'
                  ][index % 3]}',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
              subtitle:
                  Text('Your order #${1000 + index} is ready • 2 min ago'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Order #${1000 + index} opened')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
