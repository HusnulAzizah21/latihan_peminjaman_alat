import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/admin/manajemen_alat/admin_page.dart';
import '../pages/petugas/petugas_page.dart';
import '../pages/peminjam/beranda.dart';
import '../pages/login_page.dart';

class AppController extends GetxController {
  final supabase = Supabase.instance.client;

  var isLoading = false.obs;
  var emailError = ''.obs;
  var passwordError = ''.obs;

  Future<void> login(String email, String password) async {
    // 1. Reset error setiap kali tombol ditekan
    emailError.value = '';
    passwordError.value = '';

    // 2. Cek validasi input kosong (Lokal)
    if (email.isEmpty) emailError.value = 'Email tidak boleh kosong';
    if (password.isEmpty) passwordError.value = 'Password tidak boleh kosong';
    if (email.isEmpty || password.isEmpty) return;

    try {
      isLoading.value = true;

      // 3. Langkah Cek Email (Pre-check)
      // Kita cek apakah email ini ada di tabel profiles
      final emailCheck = await supabase
          .from('users')
          .select('email')
          .eq('email', email)
          .maybeSingle();

      // 4. Proses Login ke Supabase Auth
      // Kita jalankan login untuk mengecek password
      try {
        await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );

        // Jika berhasil login, ambil data profil untuk navigasi role
        final user = supabase.auth.currentUser;
        if (user != null) {
          final profile = await supabase
              .from('users')
              .select()
              .eq('id_user', user.id)
              .maybeSingle();

          if (profile != null) {
            final role = profile['role'];
            if (role == 'Admin') {
              Get.offAll(() => const AdminPage());
            } else if (role == 'Petugas') {
              Get.offAll(() => const PetugasBerandaPage());
            } else {
              Get.offAll(() => const PeminjamPage());
            }
          }
        }
      } on AuthException catch (e) {
        // --- LOGIKA VALIDASI DINAMIS ANDA ---
        if (e.message.toLowerCase().contains('invalid login credentials')) {
          if (emailCheck == null) {
            // Kasus 1: Email tidak ada di database DAN password salah (atau dianggap salah oleh auth)
            emailError.value = 'Email tidak terdaftar';
            passwordError.value = 'Kata sandi salah';
          } else {
            // Kasus 2: Email ada di database, berarti fiks hanya password yang salah
            passwordError.value = 'Kata sandi salah';
          }
        } else {
          Get.snackbar("Login Gagal", e.message);
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan sistem: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
    Get.offAll(() => LoginPage());
  }
}