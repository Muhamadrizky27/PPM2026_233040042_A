import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../catatan.dart';
import '../db_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Gunakan key untuk memaksa refresh FutureBuilder
  Key _refreshKey = UniqueKey();

  void _muatUlang() {
    debugPrint("HOME_PAGE: Memuat ulang data...");
    setState(() {
      _refreshKey = UniqueKey();
    });
  }

  Future<void> _bukaForm({Catatan? initial}) async {
    debugPrint("HOME_PAGE: Membuka form...");
    await Navigator.pushNamed(context, '/form', arguments: initial);
    debugPrint("HOME_PAGE: Kembali dari form, memicu muat ulang.");
    _muatUlang();
  }

  Future<void> _bukaDetail(Catatan c) async {
    await Navigator.pushNamed(context, '/detail', arguments: c);
    _muatUlang();
  }

  Future<void> _konfirmasiHapus(Catatan c) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus catatan?'),
        content: Text('"${c.judul}" akan dihapus permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (yakin == true) {
      await DbHelper.instance.delete(c.id!);
      _muatUlang();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Mahasiswa', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _muatUlang)],
      ),
      body: FutureBuilder<List<Catatan>>(
        key: _refreshKey, // Memastikan widget dibangun ulang sepenuhnya
        future: DbHelper.instance.getAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return const Center(
              child: Text('Belum ada catatan.\nKlik tombol + di bawah untuk menambah.', 
              textAlign: TextAlign.center),
            );
          }
          return ListView.builder(
            itemCount: data.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, i) {
              final c = data[i];
              return Card(
                child: ListTile(
                  title: Text(c.judul, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(c.isi, maxLines: 2),
                  onTap: () => _bukaDetail(c),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _bukaForm(initial: c)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _konfirmasiHapus(c)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _bukaForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
