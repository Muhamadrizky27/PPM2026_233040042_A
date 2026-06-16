import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'quiz_pertemuan_3.dart';
import 'tugas_pertemuan.dart';
import 'galery_widget.dart';
import 'profile_model.dart';

class ProfilePage extends StatelessWidget {
  final UserProfile profile;
  final Function(UserProfile) onUpdateProfile;
  final Function(Experience) onAddExperience;

  const ProfilePage({
    super.key,
    required this.profile,
    required this.onUpdateProfile,
    required this.onAddExperience,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              padding: EdgeInsets.zero,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF8A70FF), Color(0xFF6C47FF)],
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Menu Utama',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profil'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.apps),
              title: const Text('Widget Gallery'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const GaleryWidget()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Upload Pengalaman'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TugasPertemuan(onSave: onAddExperience),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Pengaturan'),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              width: double.infinity,
              color: Colors.white,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundImage: profile.profileImageBytes != null
                        ? MemoryImage(profile.profileImageBytes!)
                        : const NetworkImage('https://avatars.githubusercontent.com/u/147137839?v=4') as ImageProvider,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    profile.subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem('5', 'Post'),
                      _buildStatItem('162', 'Teman'),
                      _buildStatItem('1.7K', 'Like'),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Details Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileItem(Icons.info_outline, 'Tentang', profile.bio),
                  _buildProfileItem(Icons.school_outlined, 'Pendidikan', profile.education),
                  _buildProfileItem(Icons.location_on_outlined, 'Lokasi', profile.location),
                  _buildProfileItem(Icons.email_outlined, 'Kontak', profile.contact),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Icon(Icons.star_outline, color: Colors.blueAccent, size: 20),
                        SizedBox(width: 8),
                        Text('Skills', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Wrap(
                    spacing: 8.0,
                    children: profile.skills.map((skill) => _buildSkillChip(skill)).toList(),
                  ),
                  
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.history_outlined, color: Colors.blueAccent, size: 20),
                          SizedBox(width: 8),
                          Text('Pengalaman', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      if (profile.experiences.isNotEmpty)
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.blueAccent,
                          child: Text(
                            profile.experiences.length.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...profile.experiences.map((exp) => _buildExperienceCard(exp)),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizPertemuan3(
                profile: profile,
                onSave: onUpdateProfile,
              ),
            ),
          );
        },
        label: const Text('Edit Profil'),
        icon: const Icon(Icons.edit_outlined),
        backgroundColor: const Color(0xFFF3F0FF),
        foregroundColor: const Color(0xFF673AB7),
        elevation: 1,
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildProfileItem(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 0.5),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
      ),
    );
  }

  Widget _buildSkillChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: const Color(0xFFF3F0FF),
      side: const BorderSide(color: Color(0xFFD1C4E9), width: 1),
      labelStyle: const TextStyle(color: Color(0xFF673AB7), fontSize: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildExperienceCard(Experience exp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 0.5),
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: exp.imageBytes != null
              ? Image.memory(exp.imageBytes!, width: 50, height: 50, fit: BoxFit.cover)
              : (exp.imagePath.startsWith('http')
                  ? Image.network(exp.imagePath, width: 50, height: 50, fit: BoxFit.cover)
                  : (!kIsWeb && exp.isFile 
                      ? Image.file(File(exp.imagePath), width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.image, size: 50))),
        ),
        title: Text(exp.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(exp.description),
      ),
    );
  }
}
