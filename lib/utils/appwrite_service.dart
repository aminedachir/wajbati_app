import 'dart:typed_data';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:wajbati_dz/models/models.dart';
import '../utils/environment.dart';

class AppwriteService {
  static Client? _client;
  static Account? _account;

  static Client get client {
    _client ??= Client()
        .setEndpoint(Environment.appwritePublicEndpoint)
        .setProject(Environment.appwriteProjectId)
        .setSelfSigned(status: true);
    return _client!;
  }

  static Account get account => _account ??= Account(client);

  static Future createAccount(
      String email, String password, String name) async {
    try {
      final user = await account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );
      return user;
    } catch (e) {
      debugPrint('Create account error: $e');
      rethrow;
    }
  }

  static Future createEmailPasswordSession(
      String email, String password) async {
    try {
      // Try to clean up any existing session first
      try {
        await account.deleteSession(sessionId: 'current');
      } catch (_) {
        // Ignore errors if no session exists to delete
      }

      final session = await account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      return session;
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
  }

  static Future<void> createAnonymousSession() async {
    try {
      await account.createAnonymousSession();
    } catch (e) {
      debugPrint('Anonymous session error: $e');
    }
  }

  static Future<void> updateName(String name) async {
    try {
      await account.updateName(name: name);
    } catch (e) {
      debugPrint('Update name error: $e');
    }
  }

  static Future deleteCurrentSession() async {
    try {
      // First check if there is an active session to avoid "missing scopes" error for guests
      await account.get();
      // If we reach here, a session exists
      await account.deleteSession(sessionId: 'current');
    } catch (e) {
      if (e is AppwriteException &&
          (e.code == 401 || e.type == 'general_unauthorized_scope')) {
        // User is already unauthorized/logged out, no need to log as error
        return;
      }
      debugPrint('Logout error: $e');
    }
  }

  static Databases? _databases;
  static Storage? _storage;

  static Databases get databases => _databases ??= Databases(client);

  static Storage get storage => _storage ??= Storage(client);

  static Future<List<dynamic>> getRestaurants() async {
    try {
      final response = await databases.listDocuments(
        databaseId: Environment.appwriteDatabaseId,
        collectionId: Environment.appwriteRestaurantsCollectionId,
      );
      return response.documents;
    } catch (e) {
      debugPrint('Get restaurants error: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getReviews(String restaurantId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: Environment.appwriteDatabaseId,
        collectionId: Environment.appwriteReviewsCollectionId,
        queries: [Query.equal('restaurantId', restaurantId)],
      );
      return response.documents;
    } catch (e) {
      debugPrint('Get reviews error: $e');
      return [];
    }
  }

  static Future getCurrentUser() async {
    try {
      return await account.get();
    } catch (e) {
      return null;
    }
  }

  static Future createRestaurant(Map<String, dynamic> data,
      {Uint8List? imageBytes}) async {
    try {
      String? imageId;
      if (imageBytes != null) {
        final file = await storage.createFile(
          bucketId: Environment.appwriteStorageBucketId,
          fileId: ID.unique(),
          file: InputFile.fromBytes(
            bytes: imageBytes,
            filename: 'restaurant_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        );
        imageId = file.$id;
      }

      data['imageFileId'] = imageId;

      final docId = ID.unique();
      await databases.createDocument(
        databaseId: Environment.appwriteDatabaseId,
        collectionId: Environment.appwriteRestaurantsCollectionId,
        documentId: docId,
        data: data,
      );
      return Restaurant.fromAppwrite(data, docId);
    } catch (e) {
      debugPrint('Create restaurant error: $e');
      rethrow;
    }
  }

  static Future<void> saveOrder(Map<String, dynamic> orderData) async {
    try {
      await databases.createDocument(
        databaseId: Environment.appwriteDatabaseId,
        collectionId: Environment.appwriteOrdersCollectionId,
        documentId: ID.unique(),
        data: orderData,
      );
    } catch (e) {
      debugPrint('Save order error: $e');
      rethrow;
    }
  }

  static Future<List<dynamic>> getOrders(String userId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: Environment.appwriteDatabaseId,
        collectionId: Environment.appwriteOrdersCollectionId,
        queries: [Query.equal('userId', userId)],
      );
      return response.documents;
    } catch (e) {
      debugPrint('Get orders error: $e');
      return [];
    }
  }

  static Future<void> addFavorite(String userId, String restaurantId) async {
    try {
      await databases.createDocument(
        databaseId: Environment.appwriteDatabaseId,
        collectionId: Environment.appwriteFavoritesCollectionId,
        documentId: '${userId}_${restaurantId}',
        data: {'userId': userId, 'restaurantId': restaurantId},
      );
    } catch (e) {
      debugPrint('Add favorite error: $e');
      rethrow;
    }
  }

  static Future<void> removeFavorite(String userId, String restaurantId) async {
    try {
      await databases.deleteDocument(
        databaseId: Environment.appwriteDatabaseId,
        collectionId: Environment.appwriteFavoritesCollectionId,
        documentId: '${userId}_${restaurantId}',
      );
    } catch (e) {
      debugPrint('Remove favorite error: $e');
    }
  }

  static Future<List<MenuItem>> getMenuItems(String restaurantId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: Environment.appwriteDatabaseId,
        collectionId: Environment.appwriteMenuItemsCollectionId,
        queries: [Query.equal('restaurantId', restaurantId)],
      );
      return response.documents.map((doc) {
        final d = doc.data;
        return MenuItem(
          id: doc.$id,
          name: d['name'] ?? '',
          nameAr: d['nameAr'] ?? '',
          description: d['description'] ?? '',
          price: (d['price'] as num?)?.toDouble() ?? 0.0,
          category: d['category'] ?? '',
          imageUrl: d['imageUrl'] ?? '',
          isPopular: d['isPopular'] ?? false,
        );
      }).toList();
    } catch (e) {
      debugPrint('Get menu items error: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getFavorites(String userId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: Environment.appwriteDatabaseId,
        collectionId: Environment.appwriteFavoritesCollectionId,
        queries: [Query.equal('userId', userId)],
      );
      return response.documents;
    } catch (e) {
      debugPrint('Get favorites error: $e');
      return [];
    }
  }
}
