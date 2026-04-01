import 'package:flutter/foundation.dart';
import 'appwrite_service.dart';

class AppInitializer {
  static Future<void> initialize() async {
    // Ensuring the Appwrite client is initialized
    try {
      final client = AppwriteService.client;
      // You can add more initialization logic here if needed, 
      // like checking connectivity or pre-fetching essential data.
      debugPrint("Appwrite initialized with project: ${client.config['project']}");
    } catch (e) {
      debugPrint("Error during Appwrite initialization: $e");
      rethrow;
    }
  }
}
