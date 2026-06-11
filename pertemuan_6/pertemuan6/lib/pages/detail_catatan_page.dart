import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../catatan.dart';

class DetailCatatanPage extends StatelessWidget {
  final Catatan catatan;
  const DetailCatatanPage({super.key, required this.catatan});

  Color _warnaKategori(String kategori) {
    switch (kategori) {
      case 'Kuliah': return const Color(0xFF6366F1);
      case 'Tugas': return const Color(0xFFF59E0B);
      case 'Pribadi': return const Color(0xFF10B981);
      default: return const Color(0xFF8B5CF6);
    }
  }

  IconData _iconKategori(String kategori) {
    switch (kategori) {
      case 'Kuliah': return Icons.school_rounded;
      case 'Tugas': return Icons.assignment_rounded;
      case 'Pribadi': return Icons.person_rounded;
      default: return Icons.more_horiz_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('EEEE, dd MMMM yyyy — HH:mm');
    final warna = _warnaKategori(catatan.kategori);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Catatan',
            style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Edit catatan',
            onPressed: () async {
              await Navigator.pushNamed(context, '/form', arguments: catatan);
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kategori badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: warna.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_iconKategori(catatan.kategori), size: 16, color: warna),
                  const SizedBox(width: 6),
                  Text(catatan.kategori, style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: warna,
                  )),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Judul
            Text(catatan.judul, style: const TextStyle(
              fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5, height: 1.3,
            )),
            const SizedBox(height: 12),
            // Tanggal
            Row(children: [
              Icon(Icons.calendar_today_rounded, size: 14,
                  color: cs.onSurface.withOpacity(0.45)),
              const SizedBox(width: 6),
              Text(dateFormat.format(catatan.dibuatPada), style: TextStyle(
                fontSize: 13, color: cs.onSurface.withOpacity(0.45),
              )),
            ]),
            const SizedBox(height: 24),
            Divider(color: cs.outlineVariant.withOpacity(0.4)),
            const SizedBox(height: 20),
            // Isi catatan
            Text(catatan.isi, style: TextStyle(
              fontSize: 16, height: 1.7, color: cs.onSurface.withOpacity(0.8),
            )),
          ],
        ),
      ),
    );
  }
}