import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Untuk gaya dialog iOS jika diperlukan
import '../database/db_helper.dart';
import 'login_screen.dart'; // Pastikan import file login kamu

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final DbHelper _dbHelper = DbHelper();
  bool _isLoading = false;

  // Palet Warna iOS Notes
  final Color _notesYellow = const Color(0xFFFFB800);
  final Color _iosBg = const Color(0xFFF2F2F7);
  final Color _textSub = const Color(0xFF8E8E93);
  final Color _iosRed = const Color(0xFFFF3B30); // Merah iOS untuk Logout

  void _gantiPassword() async {
    if (_oldPasswordController.text.isEmpty || _newPasswordController.text.isEmpty) {
      _showSnackBar('Semua kolom wajib diisi!', Colors.redAccent);
      return;
    }

    setState(() => _isLoading = true);
    bool success = await _dbHelper.updatePassword(_oldPasswordController.text, _newPasswordController.text);
    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        _showSnackBar('Password berhasil diperbarui!', _notesYellow);
        _oldPasswordController.clear();
        _newPasswordController.clear();
      }
    } else {
      if (mounted) {
        _showSnackBar('Password lama salah!', Colors.redAccent);
      }
    }
  }

  void _logout() {
    // Navigasi ke Login dan hapus semua history stack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _iosBg,
      appBar: AppBar(
        backgroundColor: _iosBg,
        elevation: 0,
        iconTheme: IconThemeData(color: _notesYellow),
        title: const Text('Pengaturan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // CARD GANTI PASSWORD
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Ganti Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF000000), letterSpacing: 0.5)),
                        const SizedBox(height: 20),
                        _buildLabel('PASSWORD SAAT INI'),
                        const SizedBox(height: 8),
                        _buildTextField(_oldPasswordController, 'Masukkan password lama'),
                        const SizedBox(height: 20),
                        _buildLabel('PASSWORD BARU'),
                        const SizedBox(height: 8),
                        _buildTextField(_newPasswordController, 'Masukkan password baru'),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _gantiPassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _notesYellow,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            ),
                            child: _isLoading 
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                                : const Text('Simpan Perubahan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                  // TOMBOL LOGOUT 
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextButton(
                      onPressed: _logout,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: _iosRed,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      child: const Text('Logout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // KARTU DEVELOPER
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: _notesYellow.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.person_rounded, color: _notesYellow, size: 24),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('PENGEMBANG', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF8E8E93))),
                    Text('Eka Krisna Ferian', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    Text('NIM: 2241720100', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54));

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
        filled: true,
        fillColor: _iosBg.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: _notesYellow, width: 1.5)),
      ),
    );
  }
}