import 'package:intl/intl.dart';

class TFormatter {
  static String formatDate(DateTime? date) {
    date ??= DateTime.now();
    return DateFormat('dd-MMM-yyyy').format(date); // Customize the date format as needed
  }

  static String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'en_US', symbol: r'$').format(amount); // Customize the currency locale and symbol as needed
  }

  static String formatPhoneNumber(String phoneNumber) {
    // Ensure it's a valid Algerian number format
    if (phoneNumber.length == 10 && phoneNumber.startsWith("0")) {
      return '${phoneNumber.substring(0, 4)} ${phoneNumber.substring(4, 6)} ${phoneNumber.substring(6, 8)} ${phoneNumber.substring(8)}';
    } else {
      return 'Invalid phone number format';
    }
  }
}
