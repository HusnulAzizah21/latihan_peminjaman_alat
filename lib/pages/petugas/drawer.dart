import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/app_controller.dart'; // Sesuaikan path controller Anda

class PetugasDrawer extends StatelessWidget {
  final String currentPage;
  const PetugasDrawer({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AppController>();
    final user = c.supabase.auth.currentUser;
    final String userEmail = user?.email ?? "monica@gmail.com";
    final String userName = userEmail.split('@')[0].capitalizeFirst ?? "Monica";

    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
            // 1. HEADER PROFILE (Navy Blue dengan Ikon Chevron)
            Container(
              padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
              width: double.infinity,
              color: const Color(0xFF1F3C58), // Warna Navy sesuai contoh
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor:Colors.white, // Warna background lingkaran
                  child: Text(
                    // Mengambil nama dari database, jika null pakai 'User'
                    // Lalu ambil karakter pertama dan jadikan huruf kapital
                    (c.supabase.auth.currentUser?.email ?? "U")[0].toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF1F3C58),// Warna huruf
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                  const SizedBox(height: 15),
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    userEmail,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          // 2. LIST MENU
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 10),
              children: [
                _buildMenuItem(
                  icon: Icons.home,
                  title: "Beranda",
                  isActive: currentPage == 'beranda',
                  onTap: () => Get.offAllNamed('/petugas-beranda'),
                ),
                _buildMenuItem(
                  icon: Icons.check_circle,
                  title: "Persetujuan",
                  isActive: currentPage == 'persetujuan',
                  onTap: () => Get.offAllNamed('/persetujuan'),
                ),
                _buildMenuItem(
                  icon: Icons.assignment_return,
                  title: "Pengembalian",
                  isActive: currentPage == 'pengembalian',
                  onTap: () => Get.offAllNamed('/pengembalian'),
                ),
                _buildMenuItem(
                  icon: Icons.bar_chart,
                  title: "Laporan",
                  isActive: currentPage == 'laporan',
                  onTap: () => Get.offAllNamed('/laporan'),
                ),
                _buildMenuItem(
                  icon: Icons.logout,
                  title: "Keluar",
                  onTap: () => _showLogoutDialog(context, c),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // HELPER UNTUK ITEM MENU
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.grey[300] : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF1F3C58), size: 24),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1F3C58),
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  // 3. DIALOG KONFIRMASI KELUAR (Sama persis dengan gambar)
  void _showLogoutDialog(BuildContext context, AppController c) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Keluar",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F3C58),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "Anda yakin ingin keluar dari aplikasi?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF1F3C58),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  // TOMBOL BATAL (Outlined)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF1F3C58)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "Batal",
                        style: TextStyle(
                          color: Color(0xFF1F3C58),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  // TOMBOL YA (Filled)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => c.logout(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F3C58),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "Ya",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}