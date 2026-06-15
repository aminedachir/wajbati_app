import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslatorService {
  static final Map<String, String> _cache = {};

  static Future<String> translateToArabic(String text) async {
    if (text.trim().isEmpty) return text;
    if (_cache.containsKey(text)) return _cache[text]!;

    try {
      final url = Uri.parse(
          'https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=ar&dt=t&q=${Uri.encodeComponent(text)}');
      final response = await http.get(url).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final translated = json[0][0][0] as String;
        _cache[text] = translated;
        return translated;
      }
    } catch (e) {
      // Fallback to original text on error
    }
    return text;
  }
}
