import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// ===============================
// MODEL DATA CATATAN
// ===============================
class Catatan {
  final String judul;
  final String isi;
  final String kategori;
  final DateTime dibuatPada;
  final String emailPengirim; // BARU: Tambahan field email

  Catatan({
    required this.judul,
    required this.isi,
    required this.kategori,
    required this.dibuatPada,
    required this.emailPengirim, // BARU
  });
}

// ===============================
// ROOT APP
// ===============================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan Mahasiswa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/tambah':
          // BARU: Menangkap argument Catatan (jika ada) untuk mode Edit
            final catatan = settings.arguments as Catatan?;
            return MaterialPageRoute(
              builder: (_) => TambahCatatanPage(catatanLama: catatan),
            );

          case '/detail':
          // BARU: Menangkap Map berisi catatan dan index agar bisa di-update
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => DetailCatatanPage(
                catatan: args['catatan'] as Catatan,
                index: args['index'] as int,
              ),
            );
        }

        return null;
      },
    );
  }
}

// ===============================
// HOME PAGE
// ===============================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // BARU: Data dummy ditambahkan field email
  final List<Catatan> _catatan = [
    Catatan(
      judul: 'Belajar Flutter',
      isi: 'Mempelajari Stateful Widget, Form, dan Navigation.',
      kategori: 'Kuliah',
      dibuatPada: DateTime.now(),
      emailPengirim: 'mhs@kampus.id',
    ),
  ];

  // BARU: State untuk filter kategori
  String _filterKategori = 'Semua';
  final List<String> _opsiFilter = ['Semua', 'Kuliah', 'Tugas', 'Pribadi', 'Lainnya'];

  Future<void> _bukaTambahCatatan() async {
    final hasil = await Navigator.pushNamed(context, '/tambah');

    if (hasil is Catatan) {
      setState(() {
        _catatan.add(hasil);
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Catatan "${hasil.judul}" ditambahkan'),
        ),
      );
    }
  }

  void _hapusCatatan(int index) {
    final catatanDihapus = _catatan[index];

    setState(() {
      _catatan.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Catatan "${catatanDihapus.judul}" dihapus'),
      ),
    );
  }

  String _formatTanggal(DateTime tanggal) {
    final hari = tanggal.day.toString().padLeft(2, '0');
    final bulan = tanggal.month.toString().padLeft(2, '0');
    final tahun = tanggal.year.toString();

    return '$hari/$bulan/$tahun';
  }

  @override
  Widget build(BuildContext context) {
    // BARU: Filter list berdasarkan dropdown pilihan kategori
    final listTampil = _filterKategori == 'Semua'
        ? _catatan
        : _catatan.where((c) => c.kategori == _filterKategori).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Mahasiswa'),
        actions: [
          // BARU: Dropdown Filter di AppBar
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: DropdownButton<String>(
              value: _filterKategori,
              dropdownColor: Theme.of(context).colorScheme.primaryContainer,
              underline: const SizedBox(), // Hilangkan garis bawah
              icon: const Icon(Icons.filter_list),
              items: _opsiFilter.map((opsi) {
                return DropdownMenuItem(
                  value: opsi,
                  child: Text(opsi),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _filterKategori = value;
                  });
                }
              },
            ),
          ),
        ],
      ),
      body: listTampil.isEmpty
          ? const _EmptyState()
          : ListView.builder(
        itemCount: listTampil.length,
        itemBuilder: (context, index) {
          final c = listTampil[index];
          // BARU: Cari index asli di _catatan agar Hapus & Edit tidak salah target saat difilter
          final realIndex = _catatan.indexOf(c);

          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            child: ListTile(
              leading: CircleAvatar(
                child: Text('${realIndex + 1}'),
              ),
              title: Text(
                c.judul,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${c.kategori} • ${_formatTanggal(c.dibuatPada)}',
              ),
              onTap: () async {
                // BARU: Tangkap hasil kembalian dari halaman detail (apabila ada proses edit)
                final hasil = await Navigator.pushNamed(
                  context,
                  '/detail',
                  arguments: {'catatan': c, 'index': realIndex},
                );

                // BARU: Jika user melakukan Edit dari halaman Detail, update list-nya
                if (hasil is Map && hasil['action'] == 'edit') {
                  setState(() {
                    _catatan[hasil['index']] = hasil['catatan'];
                  });
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Catatan diperbarui')),
                  );
                }
              },
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _hapusCatatan(realIndex); // Gunakan realIndex
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _bukaTambahCatatan,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ===============================
// EMPTY STATE
// ===============================
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_alt_outlined,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Belum ada catatan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tekan tombol + untuk menambah catatan.',
          ),
        ],
      ),
    );
  }
}

// ===============================
// TAMBAH / EDIT CATATAN PAGE
// ===============================
class TambahCatatanPage extends StatefulWidget {
  // BARU: Terima data lama jika dalam mode Edit
  final Catatan? catatanLama;

  const TambahCatatanPage({super.key, this.catatanLama});

  @override
  State<TambahCatatanPage> createState() => _TambahCatatanPageState();
}

class _TambahCatatanPageState extends State<TambahCatatanPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _judulCtrl;
  late TextEditingController _isiCtrl;
  late TextEditingController _emailCtrl; // BARU: Controller untuk Email

  String _kategori = 'Kuliah';

  final _kategoriOpsi = const [
    'Kuliah',
    'Tugas',
    'Pribadi',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    // BARU: Inisialisasi form. Jika catatanLama tidak null, isi form dengan data lama (Mode Edit)
    _judulCtrl = TextEditingController(text: widget.catatanLama?.judul ?? '');
    _isiCtrl = TextEditingController(text: widget.catatanLama?.isi ?? '');
    _emailCtrl = TextEditingController(text: widget.catatanLama?.emailPengirim ?? '');
    _kategori = widget.catatanLama?.kategori ?? 'Kuliah';
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _isiCtrl.dispose();
    _emailCtrl.dispose(); // BARU: Jangan lupa dispose
    super.dispose();
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;

    final catatanBaru = Catatan(
      judul: _judulCtrl.text.trim(),
      isi: _isiCtrl.text.trim(),
      kategori: _kategori,
      emailPengirim: _emailCtrl.text.trim(), // BARU
      // BARU: Pertahankan tanggal lama jika sedang edit, jika baru pakai waktu sekarang
      dibuatPada: widget.catatanLama?.dibuatPada ?? DateTime.now(),
    );

    Navigator.pop(context, catatanBaru);
  }

  @override
  Widget build(BuildContext context) {
    // BARU: Ubah judul AppBar dinamis sesuai mode (Tambah / Edit)
    final isEdit = widget.catatanLama != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Catatan' : 'Tambah Catatan'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _judulCtrl,
              decoration: const InputDecoration(
                labelText: 'Judul',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Judul wajib diisi';
                }
                if (value.trim().length < 3) {
                  return 'Minimal 3 karakter';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // BARU: Field Validasi Email Pengirim
            TextFormField(
              controller: _emailCtrl,
              decoration: const InputDecoration(
                labelText: 'Email Pengirim',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email wajib diisi';
                }
                // Validasi format Regex Email
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value)) {
                  return 'Format email tidak valid (contoh: user@mail.com)';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _kategori,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              items: _kategoriOpsi.map((kategori) {
                return DropdownMenuItem(
                  value: kategori,
                  child: Text(kategori),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _kategori = value!;
                });
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _isiCtrl,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Isi',
                prefixIcon: Icon(Icons.notes),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Isi wajib diisi';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _simpan,
              icon: const Icon(Icons.save),
              label: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================
// DETAIL CATATAN PAGE
// ===============================
class DetailCatatanPage extends StatelessWidget {
  final Catatan catatan;
  final int index; // BARU: Simpan index agar bisa dikirim kembali ke Home

  const DetailCatatanPage({
    super.key,
    required this.catatan,
    required this.index,
  });

  String _formatTanggal(DateTime tanggal) {
    final hari = tanggal.day.toString().padLeft(2, '0');
    final bulan = tanggal.month.toString().padLeft(2, '0');
    final tahun = tanggal.year.toString();

    return '$hari/$bulan/$tahun';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Catatan'),
        actions: [
          // BARU: Tombol Edit di Appbar halaman detail
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              // Buka form edit dan kirim data lama
              final updatedCatatan = await Navigator.pushNamed(
                  context,
                  '/tambah',
                  arguments: catatan
              );

              // Jika data berhasil diperbarui dan form disimpan
              if (updatedCatatan is Catatan) {
                // Langsung Pop 2 kali (kembali ke Home) membawa data yang di-update
                if (!context.mounted) return;
                Navigator.pop(context, {
                  'action': 'edit',
                  'catatan': updatedCatatan,
                  'index': index
                });
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              catatan.judul,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Chip(
                  label: Text(catatan.kategori),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTanggal(catatan.dibuatPada),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // BARU: Tampilkan Email Pengirim
            Row(
              children: [
                const Icon(Icons.email, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  catatan.emailPengirim,
                  style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ],
            ),

            const Divider(height: 32),

            Text(
              catatan.isi,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Kembali ke Daftar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}