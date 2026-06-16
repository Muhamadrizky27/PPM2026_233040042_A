import 'package:flutter/material.dart';

class GaleryWidget extends StatelessWidget {
  const GaleryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Widget Gallery'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: const Center(
        child: Text('Halaman Widget Gallery'),
      ),
    );
  }
}
