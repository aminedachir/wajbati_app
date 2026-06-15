import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:appwrite/models.dart';
import 'package:wajbati_dz/models/models.dart';
import '../utils/environment.dart';
import 'translator_service.dart';

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
  static Messaging? _messaging;

  static Databases get databases => _databases ??= Databases(client);
  static Storage get storage => _storage ??= Storage(client);
  static Messaging get messaging => _messaging ??= Messaging(client);

  static Future<void> setUserRole(String role) async {
    try {
      await account.updatePrefs(prefs: {'role': role});
    } catch (e) {
      debugPrint('Error setting role: $e');
    }
  }

  static Future<String?> getUserRole() async {
    try {
      final prefs = await account.getPrefs();
      return prefs.data['role'] as String?;
    } catch (e) {
      debugPrint('Error getting role: $e');
      return null;
    }
  }

  static Future<String?> getRestaurantIdByName(String name) async {
    try {
      final response = await databases.listDocuments(
        databaseId: Environment.appwriteDatabaseId,
        collectionId: Environment.appwriteRestaurantsCollectionId,
      );
      
      final lowerName = name.trim().toLowerCase();
      final normUser = lowerName.replaceAll(RegExp(r'[^a-z0-9\u0600-\u06FF]'), '');

      for (var doc in response.documents) {
        final docName = (doc.data['name']?.toString() ?? '').trim().toLowerCase();
        final docNameAr = (doc.data['nameAr']?.toString() ?? '').trim().toLowerCase();
        
        final normDoc = docName.replaceAll(RegExp(r'[^a-z0-9\u0600-\u06FF]'), '');
        final normDocAr = docNameAr.replaceAll(RegExp(r'[^a-z0-9\u0600-\u06FF]'), '');

        if (docName == lowerName || docNameAr == lowerName || 
            docName.contains(lowerName) || lowerName.contains(docName) ||
            docNameAr.contains(lowerName) || lowerName.contains(docNameAr)) {
          return doc.$id;
        }

        if (normUser.isNotEmpty && normDoc.isNotEmpty && (normDoc.contains(normUser) || normUser.contains(normDoc))) return doc.$id;
        if (normUser.isNotEmpty && normDocAr.isNotEmpty && (normDocAr.contains(normUser) || normUser.contains(normDocAr))) return doc.$id;

        final userWords = lowerName.split(RegExp(r'[\s\.\-_]+')).where((w) => w.length >= 4).toList();
        for (final word in userWords) {
          if (docName.contains(word) || docNameAr.contains(word)) {
            return doc.$id;
          }
        }
      }
    } catch (e) {
      debugPrint('Error getting restaurant by name: $e');
    }
    return null;
  }

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

  static Future<List<dynamic>> getRestaurantOrders(String restaurantId, {String? restaurantName}) async {
    try {
      final response = await databases.listDocuments(
        databaseId: Environment.appwriteDatabaseId,
        collectionId: Environment.appwriteOrdersCollectionId,
        queries: [
          Query.equal('restaurantId', restaurantId),
          Query.orderDesc('\$createdAt'),
        ],
      );
      return response.documents;
    } catch (e) {
      debugPrint('Get restaurant orders error: $e');
      return [];
    }
  }

  static Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await databases.updateDocument(
        databaseId: Environment.appwriteDatabaseId,
        collectionId: Environment.appwriteOrdersCollectionId,
        documentId: orderId,
        data: {'status': status},
      );
    } catch (e) {
      debugPrint('Update order status error: $e');
      rethrow;
    }
  }

  static Future<void> addFavorite(String userId, String restaurantId) async {
    try {
      await databases.createDocument(
        databaseId: Environment.appwriteDatabaseId,
        collectionId: Environment.appwriteFavoritesCollectionId,
        documentId: '${userId}_$restaurantId',
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
        documentId: '${userId}_$restaurantId',
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
      final docs = response.documents;
      final items = await Future.wait(docs.map((doc) async {
        final d = doc.data;
        
        String name = d['name'] ?? '';
        String nameAr = d['nameAr'] ?? '';
        if (nameAr.isEmpty && name.isNotEmpty) {
          nameAr = await TranslatorService.translateToArabic(name);
        }

        String description = d['description'] ?? '';
        String descriptionAr = d['descriptionAr'] ?? '';
        if (descriptionAr.isEmpty && description.isNotEmpty) {
          descriptionAr = await TranslatorService.translateToArabic(description);
        }

        String category = d['category'] ?? '';
        if (category.isNotEmpty) {
          category = await TranslatorService.translateToArabic(category);
        }

        return MenuItem(
          id: doc.$id,
          name: name,
          nameAr: nameAr,
          description: description,
          descriptionAr: descriptionAr,
          price: (d['price'] as num?)?.toDouble() ?? 0.0,
          category: category,
          imageUrl: d['imageUrl'] ?? '',
          isPopular: d['isPopular'] ?? false,
        );
      }));
      return items;
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

class AuthExceptionHandler {
  static String handleException(dynamic e) {
    if (e is AppwriteException) {
      final message = e.message?.toLowerCase() ?? '';
      if (message.contains('invalid credentials') || message.contains('invalid email') || message.contains('invalid password')) {
        return 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
      } else if (message.contains('user already exists')) {
        return 'البريد الإلكتروني مستخدم بالفعل.';
      } else if (message.contains('user not found') || message.contains('user (role: guests) missing scope')) {
        return 'المستخدم غير موجود أو الجلسة منتهية.';
      } else if (message.contains('password must be at least') || message.contains('password must be between')) {
        return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل.';
      } else if (message.contains('network error') || message.contains('socket') || message.contains('connection')) {
        return 'خطأ في الاتصال بالشبكة. يرجى التحقق من الإنترنت.';
      } else if (message.contains('rate limit')) {
        return 'تم تجاوز الحد المسموح به للمحاولات. يرجى المحاولة لاحقاً.';
      } else if (message.contains('blocked')) {
        return 'هذا الحساب محظور. يرجى التواصل مع الدعم.';
      }
      return 'حدث خطأ: ${e.message}';
    }
    return 'حدث خطأ غير متوقع. يرجى المحاولة مجدداً.';
  }
}
