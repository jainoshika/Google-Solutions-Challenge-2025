import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'profile_settings.dart';
import 'explore_page.dart';

class AthleteDashboard extends StatefulWidget {
  const AthleteDashboard({super.key});

  @override
  State<AthleteDashboard> createState() => _AthleteDashboardState();
}

class _AthleteDashboardState extends State<AthleteDashboard> {
  String? profileImageUrl;
  String athleteName = '';
  String bio = '';
  String city = '';
  Map<String, dynamic>? additionalDetails;

  @override
  void initState() {
    super.initState();
    _loadAthleteData();
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
          profileImageUrl = doc.data()?['profileImageUrl'];
          additionalDetails = doc.data()?['additionalDetails'];
        });
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
              child: Column(
                children: [
                  // Profile Picture
                  Container(
                    width: 150,
                    height: 150,
                    margin: const EdgeInsets.only(top: 20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.orange, width: 3),
                      image: profileImageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(profileImageUrl!),
                              fit: BoxFit.cover,
                            )
                          : const DecorationImage(
                              image: AssetImage('assets/default_profile.png'),
                              fit: BoxFit.cover,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          ),
                          Text(
                            'Languages: ${additionalDetails!['languages'] ?? 'Not specified'}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Bottom Navigation Icons
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
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
                        }),
                        _buildNavIcon(Icons.search, 'Search', () {}),
                        _buildNavIcon(Icons.add_circle, 'Add Media', () {}),
                        _buildNavIcon(Icons.build, 'Tools', () {
                          // Navigate to tools.dart
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tools page coming soon!'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }),
                        _buildNavIcon(Icons.person, 'Profile', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileSettings(),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
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
    );
  }

  Widget _buildNavIcon(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
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
    );
  }
}
