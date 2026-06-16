import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'profile_model.dart';

class TugasPertemuan extends StatefulWidget {
  final Function(Experience) onSave;

  const TugasPertemuan({super.key, required this.onSave});

  @override
  State<TugasPertemuan> createState() => _TugasPertemuanState();
}

class _TugasPertemuanState extends State<TugasPertemuan> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  Uint8List? _webImage;
  String _imagePath = '';
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      var f = await pickedFile.readAsBytes();
      setState(() {
        _webImage = f;
        _imagePath = pickedFile.path;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Upload Pengalaman'),
        actions: [
          TextButton(
            onPressed: () {
              if (_titleController.text.isNotEmpty && (_webImage != null)) {
                widget.onSave(Experience(
                  title: _titleController.text,
                  description: _descController.text,
                  imagePath: _imagePath,
                  imageBytes: _webImage,
                  isFile: true,
                ));
                Navigator.pop(context);
              } else if (_webImage == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pilih gambar terlebih dahulu')),
                );
              }
            },
            child: const Row(
              children: [
                Icon(Icons.check, size: 16, color: Colors.blueAccent),
                SizedBox(width: 4),
                Text('Simpan', style: TextStyle(color: Colors.blueAccent)),
              ],
            ),
          ),
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F0FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD1C4E9)),
                  image: _webImage != null
                      ? DecorationImage(image: MemoryImage(_webImage!), fit: BoxFit.cover)
                      : null,
                ),
                child: _webImage == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, size: 50, color: Colors.blueAccent),
                          SizedBox(height: 12),
                          Text('Ketuk untuk pilih gambar', style: TextStyle(color: Colors.blueAccent)),
                          Text('dari galeri perangkat kamu', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      )
                    : null,
              ),
            ),
            if (_webImage != null)
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Ganti Gambar'),
              ),
            const SizedBox(height: 30),
            const Text('Informasi Pengalaman', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Judul *',
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Deskripsi',
                prefixIcon: const Icon(Icons.description_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  if (_titleController.text.isNotEmpty && _webImage != null) {
                    widget.onSave(Experience(
                      title: _titleController.text,
                      description: _descController.text,
                      imagePath: _imagePath,
                      imageBytes: _webImage,
                      isFile: true,
                    ));
                    Navigator.pop(context);
                  } else if (_webImage == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pilih gambar terlebih dahulu')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A3AFF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save, size: 18, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Simpan Pengalaman', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
