import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_io/io.dart' as io;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

// Conditional import for web
import 'web_file_handler.dart' if (dart.library.io) 'mobile_file_handler.dart';

class SupabaseService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static final FirebaseDatabase _database = FirebaseDatabase.instance;

  // Define storage bucket name (singular form)
  static const String _storageBucket = 'athlete-image';

  // Verify bucket exists and check/create policies
  static Future<bool> _verifyBucketAccess() async {
    try {
      print('\n=== Verifying Storage Access ===');
      print('Bucket: $_storageBucket');
      print('Supabase URL: ${_supabase.supabaseUrl}');
      print(
          'Auth Status: ${_supabase.auth.currentSession != null ? 'Authenticated' : 'Not authenticated'}');

      if (_supabase.storage == null) {
        print('Error: Supabase storage not initialized');
        return false;
      }

      try {
        // First, check if we can list buckets (verifies basic access)
        final buckets = await _supabase.storage.listBuckets();
        print('Available buckets: ${buckets.map((b) => b.name).join(', ')}');

        // Check if our bucket exists
        if (!buckets.any((b) => b.name == _storageBucket)) {
          print('\nCreating bucket: $_storageBucket');
          await _supabase.storage.createBucket(_storageBucket);
          print('Bucket created successfully');
        }

        // Verify bucket access by attempting to list files
        print('\nVerifying bucket access...');
        try {
          final files = await _supabase.storage.from(_storageBucket).list();
          print('✓ Bucket access verified (${files.length} files found)');
        } catch (e) {
          print('\n❌ Bucket access failed: $e');
          print('\nPlease add the following policy in Supabase dashboard:');
          print('1. Go to Storage > Policies');
          print('2. Select bucket "$_storageBucket"');
          print('3. Click "New Policy"');
          print('4. Use this policy definition:');
          print('''
          CREATE POLICY "Public Access"
          ON storage.objects
          FOR ALL
          TO public
          USING (true)
          WITH CHECK (true);
          ''');
          return false;
        }

        return true;
      } catch (e) {
        print('\n❌ Storage operation failed: $e');
        if (e.toString().contains('Permission denied')) {
          print('\nPermission denied. Please check:');
          print('1. Supabase anon key is correct');
          print('2. Storage service is enabled');
          print('3. Bucket policies are configured');
        }
        return false;
      }
    } catch (e, stackTrace) {
      print('\n❌ Verification error: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  // Upload image URL to Supabase
  static Future<void> uploadAthleteImage({
    required String athleteId,
    required String imageUrl,
  }) async {
    try {
      await _supabase.from('athlete_images').insert({
        'athlete_id': athleteId,
        'image_url': imageUrl,
      });
    } catch (e) {
      throw Exception('Failed to upload image URL: $e');
    }
  }

  // Get all images for an athlete
  static Future<List<Map<String, dynamic>>> getAthleteImages(
      String athleteId) async {
    try {
      final response = await _supabase
          .from('athlete_images')
          .select()
          .eq('athlete_id', athleteId)
          .order('uploaded_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch athlete images: $e');
    }
  }

  // Delete an athlete's image
  static Future<void> deleteAthleteImage(int imageId) async {
    try {
      await _supabase.from('athlete_images').delete().eq('id', imageId);
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  // Get the most recent image for an athlete
  static Future<Map<String, dynamic>?> getLatestAthleteImage(
      String athleteId) async {
    try {
      final response = await _supabase
          .from('athlete_images')
          .select()
          .eq('athlete_id', athleteId)
          .order('uploaded_at', ascending: false)
          .limit(1)
          .single();

      return response;
    } catch (e) {
      // Return null if no image is found
      return null;
    }
  }

  // Update image metadata
  static Future<void> updateImageMetadata({
    required int imageId,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      await _supabase.from('athlete_images').update(metadata).eq('id', imageId);
    } catch (e) {
      throw Exception('Failed to update image metadata: $e');
    }
  }

  /// Picks an image from gallery/camera and uploads it to Supabase Storage
  static Future<String?> pickAndUploadImage({
    required String athleteId,
    required BuildContext context,
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      print('\n=== Starting Image Upload Process ===');

      // 1. Pick image using ImagePicker
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1920, // Reasonable max width for profile pictures
        maxHeight: 1920,
        imageQuality: 85, // Good balance between quality and file size
      );

      if (pickedFile == null) {
        print('No image selected');
        return null;
      }

      print('Image picked successfully');
      print('Path: ${pickedFile.path}');

      // 2. Read file bytes
      Uint8List fileBytes;
      if (kIsWeb) {
        fileBytes = await pickedFile.readAsBytes();
      } else {
        final File file = File(pickedFile.path);
        fileBytes = await file.readAsBytes();
      }

      // 3. Generate unique filename
      final String fileExt = path.extension(pickedFile.path).toLowerCase();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final String fileName = 'profile_${athleteId}_$timestamp$fileExt';

      print('\nPreparing upload:');
      print('- Filename: $fileName');
      print('- Size: ${(fileBytes.length / 1024).toStringAsFixed(2)} KB');
      print('- Type: ${_getContentType(fileName)}');

      // 4. Verify bucket access
      if (!await _verifyBucketAccess()) {
        throw Exception('''
Storage bucket '$_storageBucket' is not accessible.
Please verify in Supabase dashboard:
1. Storage service is enabled
2. Bucket '$_storageBucket' exists
3. Policy "Allowed_policy" is configured with:
   - SELECT: true
   - INSERT: true
   - UPDATE: true
   - DELETE: true
''');
      }

      // 5. Upload with retry mechanism
      String? uploadResponse;
      int retryCount = 0;
      const maxRetries = 3;
      Exception? lastError;

      while (retryCount < maxRetries && uploadResponse == null) {
        try {
          print('\nUpload attempt ${retryCount + 1}/$maxRetries...');

          // Upload to Supabase Storage
          uploadResponse =
              await _supabase.storage.from(_storageBucket).uploadBinary(
                    fileName,
                    fileBytes,
                    fileOptions: FileOptions(
                      contentType: _getContentType(fileName),
                      upsert: true, // Overwrite if exists
                    ),
                  );

          print('✓ Upload successful!');
        } catch (e) {
          lastError = e as Exception;
          retryCount++;

          print('\n❌ Upload attempt failed:');
          print('Error type: ${e.runtimeType}');
          print('Details: $e');

          // Show error in UI
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Upload failed: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }

          if (e.toString().contains('row-level security')) {
            print('\nSecurity Policy Error:');
            print('1. Verify bucket exists: $_storageBucket');
            print('2. Check if "Allowed_policy" is properly configured');
            print(
                '3. Ensure policy allows all operations (SELECT, INSERT, UPDATE, DELETE)');
          }

          if (retryCount < maxRetries) {
            final delay = Duration(seconds: retryCount * 2);
            print('\nRetrying in ${delay.inSeconds} seconds...');
            await Future.delayed(delay);
          }
        }
      }

      if (uploadResponse == null) {
        throw lastError ??
            Exception('Upload failed after $maxRetries attempts');
      }

      // 6. Get public URL
      final imageUrl =
          _supabase.storage.from(_storageBucket).getPublicUrl(fileName);

      print('\n✓ Upload Complete');
      print('Public URL: $imageUrl');

      // 7. Update Firebase reference
      await _database.ref('athletes/$athleteId/profilePicture').set(imageUrl);

      print('✓ Firebase URL updated');
      print('=== Image Upload Process Complete ===\n');

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      return imageUrl;
    } catch (e, stackTrace) {
      print('\n❌ Upload Error:');
      print('Type: ${e.runtimeType}');
      print('Message: $e');
      print('Stack trace: $stackTrace');

      // Show error in UI
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }

      rethrow;
    }
  }

  // Helper method to determine content type
  static String _getContentType(String fileName) {
    final ext = path.extension(fileName).toLowerCase();
    switch (ext) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      case '.heic':
        return 'image/heic';
      default:
        return 'application/octet-stream';
    }
  }

  // Fetch profile image URL from Firebase
  static Future<String?> fetchProfileImage(String athleteId) async {
    try {
      final ref = _database.ref('athletes/$athleteId/profilePicture');
      final snapshot = await ref.get();

      if (snapshot.exists) {
        return snapshot.value.toString();
      }
      return null;
    } catch (e) {
      print('Error fetching profile image: $e');
      return null;
    }
  }

  // Delete profile picture from Supabase Storage and Firebase
  static Future<void> deleteProfilePicture(
      String athleteId, String imageUrl) async {
    try {
      // Verify bucket access before proceeding
      final hasBucketAccess = await _verifyBucketAccess();
      if (!hasBucketAccess) {
        throw Exception(
            'Storage bucket $_storageBucket is not accessible for deletion. '
            'Please verify the bucket name and permissions.');
      }

      // Extract file name from URL
      final uri = Uri.parse(imageUrl);
      final fileName = path.basename(uri.path);

      print(
          'Attempting to delete file: $fileName from bucket: $_storageBucket');

      // Delete from Supabase Storage
      await _supabase.storage.from(_storageBucket).remove([fileName]);

      // Remove URL from Firebase
      await _database.ref('athletes/$athleteId/profilePicture').remove();

      print('Successfully deleted profile picture');
    } catch (e) {
      print('Error deleting profile picture: $e');
      throw Exception('Failed to delete profile picture: $e');
    }
  }
}
