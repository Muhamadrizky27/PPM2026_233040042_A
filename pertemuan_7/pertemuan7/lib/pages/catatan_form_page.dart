import 'package:flutter/material.dart';
import '../catatan.dart';
import '../api_client.dart';

class CatatanFormPage extends StatefulWidget {
  final Catatan? initial;
  const CatatanFormPage({super.key, this.initial});
  @override
  State<CatatanFormPage> createState() => _CatatanFormPageState();
}

class _CatatanFormPageState extends State<CatatanFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _judulCtrl;
  late final TextEditingController _isiCtrl;
  late String _kategori;
  final _kategoriOpsi = const ['Kuliah', 'Tugas', 'Pribadi', 'Lainnya'];
  bool get _isEdit => widget.initial != null;
  bool _menyimpan = false;

  @override
  void initState() {
    super.initState();
    _judulCtrl = TextEditingController(text: widget.initial?.judul ?? '');
    _isiCtrl = TextEditingController(text: widget.initial?.isi ?? '');
    _kategori = widget.initial?.kategori ?? 'Kuliah';
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _isiCtrl.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _menyimpan = true);
    try {
      if (_isEdit) {
        final updated = widget.initial!.copyWith(
          judul: _judulCtrl.text.trim(),
          isi: _isiCtrl.text.trim(),
          kategori: _kategori,
        );
        await ApiClient.instance.update(updated);
      } else {
        final baru = Catatan(
          judul: _judulCtrl.text.trim(),
          isi: _isiCtrl.text.trim(),
          kategori: _kategori,
          dibuatPada: DateTime.now(),
        );
        await ApiClient.instance.insert(baru);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEdit ? 'Catatan diperbarui ✓' : 'Catatan ditambahkan ✓'),
        behavior: SnackBarBehavior.floating,
      ));
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _menyimpan = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: ${e.message}'), 
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _menyimpan = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'), 
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating
        ),
      );
    }
  }

  IconData _iconKategori(String k) {
    switch (k) {
      case 'Kuliah': return Icons.school_rounded;
      case 'Tugas': return Icons.assignment_rounded;
      case 'Pribadi': return Icons.person_rounded;
      default: return Icons.more_horiz_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Catatan' : 'Tambah Catatan',
            style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    _isEdit ? Icons.edit_note_rounded : Icons.note_add_rounded,
                    size: 36, color: cs.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(child: Text(
                _isEdit ? 'Perbarui catatan yang ada' : 'Buat catatan baru',
                style: TextStyle(fontSize: 14, color: cs.onSurface.withOpacity(0.5)),
              )),
              const SizedBox(height: 28),
              TextFormField(
                controller: _judulCtrl,
                decoration: InputDecoration(
                  labelText: 'Judul', hintText: 'Masukkan judul catatan',
                  prefixIcon: const Icon(Icons.title_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true, fillColor: cs.surfaceContainerLow,
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Judul tidak boleh kosong' : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _kategori,
                decoration: InputDecoration(
                  labelText: 'Kategori', prefixIcon: Icon(_iconKategori(_kategori)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true, fillColor: cs.surfaceContainerLow,
                ),
                items: _kategoriOpsi.map((k) => DropdownMenuItem(
                  value: k, child: Row(children: [
                  Icon(_iconKategori(k), size: 18), const SizedBox(width: 8), Text(k),
                ]),
                )).toList(),
                onChanged: (v) { if (v != null) setState(() => _kategori = v); },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _isiCtrl,
                decoration: InputDecoration(
                  labelText: 'Isi Catatan', hintText: 'Tulis isi catatan di sini...',
                  alignLabelWithHint: true,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 100),
                    child: Icon(Icons.notes_rounded),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true, fillColor: cs.surfaceContainerLow,
                ),
                maxLines: 8, minLines: 5,
                textCapitalization: TextCapitalization.sentences,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Isi catatan tidak boleh kosong' : null,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _menyimpan ? null : _simpan,
                icon: _menyimpan
                    ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save_rounded),
                label: Text(
                  _menyimpan ? 'Menyimpan...' : (_isEdit ? 'Perbarui Catatan' : 'Simpan Catatan'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
