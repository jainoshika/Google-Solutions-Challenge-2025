import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'profile_settings.dart';
import 'explore_page.dart';
import 'search_page.dart';

class AthleteDashboard extends StatefulWidget {
  const AthleteDashboard({super.key});

  @override
  State<AthleteDashboard> createState() => _AthleteDashboardState();
}

class _AthleteDashboardState extends State<AthleteDashboard>
    with SingleTickerProviderStateMixin {
  String? profileImagePath;
  String athleteName = '';
  String bio = '';
  String city = '';
  Map<String, dynamic>? additionalDetails;
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _loadAthleteData();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animations = List.generate(4, (index) {
      return Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadAthleteData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('athletes')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        setState(() {
          athleteName = doc.data()?['name'] ?? '';
          bio = doc.data()?['bio'] ?? '';
          city = doc.data()?['city'] ?? '';
          additionalDetails = doc.data()?['additionalDetails'];
        });
      }

      // Load local profile image
      final directory = await getApplicationDocumentsDirectory();
      final imageFile = File('${directory.path}/profile_image.jpg');
      if (imageFile.existsSync()) {
        setState(() {
          profileImagePath = imageFile.path;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (image != null) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final imageFile = File('${directory.path}/profile_image.jpg');

        // Delete existing image if it exists
        if (imageFile.existsSync()) {
          await imageFile.delete();
        }

        // Save new image
        await File(image.path).copy(imageFile.path);

        setState(() {
          profileImagePath = imageFile.path;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.9,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Picture
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 150,
                          height: 150,
                          margin: const EdgeInsets.only(top: 20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.orange, width: 3),
                            image: profileImagePath != null
                                ? DecorationImage(
                                    image: FileImage(File(profileImagePath!)),
                                    fit: BoxFit.cover,
                                  )
                                : const DecorationImage(
                                    image: AssetImage(
                                        'assets/default_profile.png'),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.orange,
                            size: 40,
                          ),
                        ),
                      ),

                      // Athlete Name
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          athleteName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      // Bio Section
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          bio,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      // City
                      Text(
                        city,
                        style: const TextStyle(
                          color: Colors.cyan,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      // Additional Details Section
                      if (additionalDetails != null) ...[
                        const SizedBox(height: 20),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Additional Details',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Qualification: ${additionalDetails!['qualification'] ?? 'Not specified'}',
                                style: const TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                'Languages: ${additionalDetails!['languages'] ?? 'Not specified'}',
                                style: const TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            // Gear Icon in top-right corner
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.settings, color: Colors.orange),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileSettings(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavIcon(Icons.explore, 'Explore', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ExplorePage(),
                  ),
                );
              }, 0),
              _buildNavIcon(Icons.search, 'Search', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchPage(),
                  ),
                );
              }, 1),
              _buildNavIcon(Icons.add_circle, 'Add Media', () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Add Media page coming soon!'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }, 2),
              _buildNavIcon(Icons.person, 'Profile', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileSettings(),
                  ),
                );
              }, 3),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 15),
        child: FloatingActionButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tools page coming soon!'),
                backgroundColor: Colors.orange,
              ),
            );
          },
          backgroundColor: Colors.orange,
          child: const Icon(Icons.build, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildNavIcon(
      IconData icon, String label, VoidCallback onTap, int index) {
    return GestureDetector(
      onTap: onTap,
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _animations[index],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.orange, size: 32),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
