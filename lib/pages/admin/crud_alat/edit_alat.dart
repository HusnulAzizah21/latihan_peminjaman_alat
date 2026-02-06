import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../controllers/app_controller.dart';

class EditAlatPage extends StatefulWidget {
  final Map<String, dynamic> alat;

  const EditAlatPage({super.key, required this.alat});

  @override
  State<EditAlatPage> createState() => _EditAlatPageState();
}

class _EditAlatPageState extends State<EditAlatPage> {
  final AppController c = Get.find<AppController>();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController stockController;
  String? selectedCategory;
  
  // State untuk Image Picker
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.alat['nama_alat']);
    stockController = TextEditingController(text: widget.alat['stok_total'].toString());
    selectedCategory = widget.alat['nama_kategori'];
  }

  // Fungsi untuk mengambil gambar dari galeri
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Kompres agar upload lebih ringan
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateAlat() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String? imageUrl = widget.alat['gambar_url'];

      // LOGIKA UPLOAD KE SUPABASE STORAGE
      if (_imageFile != null) {
        final fileExt = _imageFile!.path.split('.').last;
        final fileName = 'alat_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        final filePath = 'daftar_alat/$fileName';

        // Upload file ke bucket 'alat_images'
        await c.supabase.storage.from('alat_images').upload(filePath, _imageFile!);

        // Ambil URL publiknya
        imageUrl = c.supabase.storage.from('alat_images').getPublicUrl(filePath);
      }

      // UPDATE DATABASE
      await c.supabase.from('alat').update({
        'nama_alat': nameController.text,
        'stok_total': int.parse(stockController.text),
        'gambar_url': imageUrl,
      }).eq('id_alat', widget.alat['id_alat']);

      Get.back();
      Get.snackbar("Sukses", "Data berhasil diubah", backgroundColor: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Gagal update: $e", backgroundColor: Colors.red.shade100);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Header (Back Button & Title)
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF1F3C58)),
                      onPressed: () => Get.back(),
                    ),
                    const Expanded(
                      child: Text(
                        "Edit Alat",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F3C58)),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 40),

                // AREA IMAGE PICKER (Persis seperti gambar kamu)
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        height: 120,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: _imageFile != null
                              ? Image.file(_imageFile!, fit: BoxFit.contain) // Gambar baru
                              : (widget.alat['gambar_url'] != null
                                  ? Image.network(widget.alat['gambar_url'], fit: BoxFit.contain) // Gambar lama
                                  : const Icon(Icons.monitor, size: 80)),
                        ),
                      ),
                      // Ikon Kamera Kecil
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF1F3C58),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
                _buildLabel("Nama Alat"),
                TextFormField(
                  controller: nameController,
                  decoration: _inputDecoration("Monitor"),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Kategori"),
                          TextFormField(
                            initialValue: selectedCategory,
                            readOnly: true,
                            decoration: _inputDecoration("Elektronika"),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Stok"),
                          TextFormField(
                            controller: stockController,
                            textAlign: TextAlign.center,
                            decoration: _inputDecoration("5"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                // Tombol Simpan
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _updateAlat,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F3C58),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    child: const Text("Simpan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper UI
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 5),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1F3C58))),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: const BorderSide(color: Color(0xFF1F3C58)),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
    );
  }
}