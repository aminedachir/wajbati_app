import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import '../utils/environment.dart';
import '../utils/appwrite_service.dart';

class StorageService {
  static Storage get storage => Storage(AppwriteService.client);

  static Future<String?> uploadRestaurantPhoto(
      String fileName, Uint8List bytes) async {
    try {
      final result = await storage.createFile(
        bucketId: 'restaurant_images', // Create bucket in Appwrite
        fileId: ID.unique(),
        file: InputFile.fromBytes(bytes: bytes, filename: fileName),
      );
      return result.$id;
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    }
  }

  static Future<String?> getRestaurantPhotoUrl(String fileId) async {
    try {
      await storage.getFileView(
        bucketId: 'restaurant_images',
        fileId: fileId,
      );
      return fileId;
    } catch (e) {
      debugPrint('Photo URL error: $e');
      return null;
    }
  }
}
