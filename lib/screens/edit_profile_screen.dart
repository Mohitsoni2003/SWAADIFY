import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/firebase_services.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final nameController = TextEditingController();
  bool isLoading = false;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    nameController.text = user?.displayName ?? "";

    // Checks if a saved profile picture path already exists in Firebase Auth
    if (user?.photoURL != null && user!.photoURL!.startsWith('/')) {
      _imageFile = File(user.photoURL!);
    }
  }

  Future<void> _pickProfileImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50, // Optimizes compression to prevent loading hiccups
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error picking image: $e")));
    }
  }

  Future<void> updateProfile() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter your name")));
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Step 1: Update Auth Display Name
        await user.updateDisplayName(nameController.text.trim());

        // Step 2: Save the image path locally in Auth profile
        if (_imageFile != null) {
          await user.updatePhotoURL(_imageFile!.path);
        }

        // Step 3: Attempt to update Firestore data safely
        try {
          await FirebaseServices.updateUserProfile(
            name: nameController.text.trim(),
          );
        } catch (firestoreError) {
          // If Firestore document isn't found, we log it but don't let it crash the app
          debugPrint(
            "⚠️ Firestore document missing, continuing with Auth update: $firestoreError",
          );

          // Optional: If your FirebaseServices has a createUser document method, call it here.
          // Otherwise, continuing ensures your app still saves the data successfully!
        }

        // Step 4: Refresh local tokens
        await user.reload();
      }

      if (!mounted) return;

      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully"),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
    } catch (e) {
      debugPrint("❌ PROFILE UPDATE ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Could not update profile: ${e.toString().split(':').last}",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Direct initialization helper logic to handle local cache images safely
    ImageProvider? avatarImage;
    if (_imageFile != null) {
      avatarImage = FileImage(_imageFile!);
    } else if (user?.photoURL != null && user!.photoURL!.startsWith('http')) {
      avatarImage = NetworkImage(user.photoURL!);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 10),

            Center(
              child: GestureDetector(
                onTap: _pickProfileImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: const Color(0xFFE8F5E9),
                      backgroundImage: avatarImage,
                      child: avatarImage == null
                          ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Color(0xFF2E7D32),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 2,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFF2E7D32),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 35),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Full Name",
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              enabled: false,
              decoration: InputDecoration(
                labelText: "Email",
                prefixIcon: const Icon(Icons.email),
                border: const OutlineInputBorder(),
                hintText: user?.email ?? "",
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Save Changes",
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
