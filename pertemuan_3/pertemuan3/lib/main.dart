import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'profile_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late UserProfile userProfile;

  @override
  void initState() {
    super.initState();
    userProfile = UserProfile(
      name: 'Muhamad Rizky',
      subtitle: 'Mahasiswa Teknik Informatika',
      bio: 'Belajar Flutter!',
      education: 'Teknik Informatika - Semester 8',
      location: 'Bandung, Jawa Barat',
      email: 'rizkyers@gmail.com',
      contact: 'rizkyers@gmail.com\n+62 812-3456-7890',
      skillsString: 'Flutter, Dart, Java, Python, Git',
      skills: ['Flutter', 'Dart', 'Java', 'Python', 'Git'],
      experiences: [],
    );
  }

  void updateProfile(UserProfile newProfile) {
    setState(() {
      userProfile = newProfile;
      // Also update the skills list from the skillsString
      userProfile.skills = newProfile.skillsString
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    });
  }

  void addExperience(Experience exp) {
    setState(() {
      userProfile.experiences.add(exp);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PPM Pertemuan 3 Quiz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ProfilePage(
        profile: userProfile,
        onUpdateProfile: updateProfile,
        onAddExperience: addExperience,
      ),
    );
  }
}
