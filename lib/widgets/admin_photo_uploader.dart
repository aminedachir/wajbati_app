import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:appwrite/appwrite.dart';
import '../utils/appwrite_service.dart';
import '../utils/environment.dart';
import '../theme/app_theme.dart';

class AdminPhotoUploader extends StatefulWidget {
  const AdminPhotoUploader({super.key});

  @override
  State<AdminPhotoUploader> createState() => _AdminPhotoUploaderState();
}

class _AdminPhotoUploaderState extends State<AdminPhotoUploader> {
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() => _imageBytes = bytes);
    }
  }

  Future<void> _uploadPhoto() async {
    if (_imageBytes == null) return;

    final fileName = 'restaurant_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = await AppwriteService.storage.createFile(
      bucketId: Environment.appwriteStorageBucketId,
      fileId: ID.unique(),
      file: InputFile.fromBytes(
        bytes: _imageBytes!,
        filename: fileName,
      ),
    );
    final imageId = file.$id;

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Photo uploaded! ID: $imageId')),
    );
    setState(() => _imageBytes = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Restaurant Photo',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo_library),
              label: const Text('Pick Photo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 20),
            if (_imageBytes != null)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: MemoryImage(_imageBytes!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            if (_imageBytes != null)
              ElevatedButton.icon(
                onPressed: _uploadPhoto,
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Upload to Bucket'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            const SizedBox(height: 20),
            Text(
              'Bucket: restaurant_images_bucket\nPhotos public → imageFileId in restaurant doc',
              style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
