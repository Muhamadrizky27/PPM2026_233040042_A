import 'dart:typed_data';

class UserProfile {
  String name;
  String subtitle; // New field
  String bio;
  String education;
  String contact; // New field for multi-line contact
  String skillsString; // New field to edit skills as a single string
  String location;
  String email;
  List<String> skills;
  List<Experience> experiences;
  Uint8List? profileImageBytes;

  UserProfile({
    required this.name,
    required this.subtitle,
    required this.bio,
    required this.education,
    required this.contact,
    required this.skillsString,
    required this.location,
    required this.email,
    required this.skills,
    required this.experiences,
    this.profileImageBytes,
  });
}

class Experience {
  final String title;
  final String description;
  final String imagePath;
  final Uint8List? imageBytes;
  final bool isFile;

  Experience({
    required this.title,
    required this.description,
    required this.imagePath,
    this.imageBytes,
    this.isFile = false,
  });
}
