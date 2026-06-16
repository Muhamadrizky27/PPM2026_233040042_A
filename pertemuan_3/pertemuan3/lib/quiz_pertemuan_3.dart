import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'profile_model.dart';

class QuizPertemuan3 extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile) onSave;

  const QuizPertemuan3({
    super.key,
    required this.profile,
    required this.onSave,
  });

  @override
  State<QuizPertemuan3> createState() => _QuizPertemuan3State();
}

class _QuizPertemuan3State extends State<QuizPertemuan3> {
  late TextEditingController _nameController;
  late TextEditingController _subtitleController;
  late TextEditingController _bioController;
  late TextEditingController _educationController;
  late TextEditingController _contactController;
  late TextEditingController _skillsController;
  
  Uint8List? _newImageBytes;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _subtitleController = TextEditingController(text: widget.profile.subtitle);
    _bioController = TextEditingController(text: widget.profile.bio);
    _educationController = TextEditingController(text: widget.profile.education);
    _contactController = TextEditingController(text: widget.profile.contact);
    _skillsController = TextEditingController(text: widget.profile.skillsString);
    _newImageBytes = widget.profile.profileImageBytes;
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _newImageBytes = bytes;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subtitleController.dispose();
    _bioController.dispose();
    _educationController.dispose();
    _contactController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Profil'),
        actions: [
          IconButton(
            onPressed: _save,
            icon: const Icon(Icons.check, color: Colors.blueAccent),
          ),
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Image Section
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blueAccent,
                    backgroundImage: _newImageBytes != null
                        ? MemoryImage(_newImageBytes!)
                        : const NetworkImage('https://avatars.githubusercontent.com/u/147137839?v=4') as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: const CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.blueAccent,
                        child: Icon(Icons.camera_alt, color: Colors.white, size: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            _buildInputField('Nama', Icons.person_outline, _nameController),
            _buildInputField('Subtitle', Icons.work_outline, _subtitleController),
            _buildInputField('Tentang Saya', Icons.info_outline, _bioController, maxLines: 3),
            _buildInputField('Pendidikan', Icons.school_outlined, _educationController, hint: 'Universitas - Semester\nIPK: 0.00'),
            _buildInputField('Kontak', Icons.email_outlined, _contactController, maxLines: 2),
            _buildInputField('Skills', Icons.star_outline, _skillsController, hint: 'Flutter, Dart, Firebase'),
            
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E3A59), // Dark blue as in the new image
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save, size: 18, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, IconData icon, TextEditingController controller, {int maxLines = 1, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          alignLabelWithHint: true,
        ),
      ),
    );
  }

  void _save() {
    final updatedProfile = UserProfile(
      name: _nameController.text,
      subtitle: _subtitleController.text,
      bio: _bioController.text,
      education: _educationController.text,
      contact: _contactController.text,
      skillsString: _skillsController.text,
      location: widget.profile.location,
      email: widget.profile.email,
      skills: [], // Will be updated in main.dart
      experiences: widget.profile.experiences,
      profileImageBytes: _newImageBytes,
    );
    widget.onSave(updatedProfile);
    Navigator.pop(context);
  }
}
