import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../database/db_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DbHelper _dbHelper = DbHelper();
  bool _isLoading = false;

  // Warna
  final Color _notesYellow = const Color(0xFFFFB800); 
  final Color _bgLight = const Color(0xFFF2F2F7);
  final Color _textDark = const Color(0xFF000000);
  final Color _textSub = const Color(0xFF8E8E93);

  void _login() async {
    setState(() => _isLoading = true);
    bool isValid = await _dbHelper.login(_usernameController.text, _passwordController.text);
    setState(() => _isLoading = false);

    if (isValid) {
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Username atau Password salah!'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24), 
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: _notesYellow.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.edit_note_rounded, size: 50, color: _notesYellow),
                ),
                const SizedBox(height: 24),
                Text('Agenda Nusantara', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: _textDark, letterSpacing: -0.5)),
                const SizedBox(height: 8),
                Text('Catat ide dan tugasmu hari ini', style: TextStyle(fontSize: 14, color: _textSub)),
                const SizedBox(height: 32),
                _buildInputField(controller: _usernameController, label: 'Username', hint: 'Masukkan username', icon: Icons.person_outline_rounded),
                const SizedBox(height: 20),
                _buildInputField(controller: _passwordController, label: 'Password', hint: '••••••••', icon: Icons.lock_outline_rounded, isPassword: true),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _notesYellow,
                      foregroundColor: Colors.black, 
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text('Login Sekarang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({required TextEditingController controller, required String label, required String hint, required IconData icon, bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(left: 8, bottom: 8), child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: _notesYellow, size: 20),
            filled: true,
            fillColor: _bgLight.withOpacity(0.5),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: _notesYellow, width: 1.5)),
          ),
        ),
      ],
    );
  }
}