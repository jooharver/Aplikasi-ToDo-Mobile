import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../models/todo_model.dart';

class AddTaskScreen extends StatefulWidget {
  final bool isPenting;
  final Todo? taskToEdit; // Parameter opsional untuk mode edit

  const AddTaskScreen({super.key, required this.isPenting, this.taskToEdit});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final DbHelper _dbHelper = DbHelper();
  
  DateTime? _selectedDate;

  final Color _notesYellow = const Color(0xFFFFB800);
  final Color _iosBg = const Color(0xFFF2F2F7);
  final Color _textSub = const Color(0xFF8E8E93);

  @override
  void initState() {
    super.initState();
    // Jika dalam mode edit, isi data lama ke field
    if (widget.taskToEdit != null) {
      _judulController.text = widget.taskToEdit!.judul;
      _deskripsiController.text = widget.taskToEdit!.deskripsi;
      // Parsing tanggal string kembali ke DateTime (asumsi format dd MMMM yyyy)
      try {
        _selectedDate = DateFormat('dd MMMM yyyy', 'id_ID').parse(widget.taskToEdit!.tanggal);
      } catch (e) {
        _selectedDate = DateTime.now();
      }
    }
  }

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: _notesYellow, onPrimary: Colors.black),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _simpanTugas() async {
    if (_judulController.text.isEmpty || _selectedDate == null) {
      _showSnackBar('Judul dan Tanggal wajib diisi!', Colors.redAccent);
      return;
    }

    String formattedDate = DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate!);

    if (widget.taskToEdit != null) {
      // MODE UPDATE (EDIT)
      Todo updatedTodo = Todo(
        id: widget.taskToEdit!.id,
        judul: _judulController.text,
        deskripsi: _deskripsiController.text,
        tanggal: formattedDate,
        kategori: widget.isPenting ? 'penting' : 'biasa',
        statusSelesai: widget.taskToEdit!.statusSelesai,
      );
      await _dbHelper.updateTask(updatedTodo);
      _showSnackBar('Tugas berhasil diperbarui!', _notesYellow);
    } else {
      // MODE INSERT (BARU)
      Todo newTodo = Todo(
        judul: _judulController.text,
        deskripsi: _deskripsiController.text,
        tanggal: formattedDate,
        kategori: widget.isPenting ? 'penting' : 'biasa',
      );
      await _dbHelper.insertTask(newTodo);
      _showSnackBar('Tugas berhasil disimpan!', _notesYellow);
    }

    if (mounted) Navigator.pop(context);
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.taskToEdit != null;
    return Scaffold(
      backgroundColor: _iosBg,
      appBar: AppBar(
        backgroundColor: _iosBg,
        elevation: 0,
        iconTheme: IconThemeData(color: _notesYellow),
        title: Text(
          isEdit ? 'Edit Tugas' : (widget.isPenting ? 'Tugas Penting' : 'Tugas Biasa'),
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('TANGGAL JATUH TEMPO'),
              const SizedBox(height: 10),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: _iosBg.withOpacity(0.5), borderRadius: BorderRadius.circular(15)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_selectedDate == null ? 'Pilih Tanggal' : DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate!),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      Icon(Icons.calendar_month_rounded, color: _notesYellow),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('JUDUL TUGAS'),
              const SizedBox(height: 10),
              _buildTextField(controller: _judulController, hint: 'Masukkan judul tugas'),
              const SizedBox(height: 24),
              _buildSectionTitle('DESKRIPSI'),
              const SizedBox(height: 10),
              _buildTextField(controller: _deskripsiController, hint: 'Tambahkan detail...', maxLines: 5),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _simpanTugas,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _notesYellow,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: Text(isEdit ? 'Perbarui Tugas' : 'Simpan Tugas', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _textSub, letterSpacing: 0.5));

  Widget _buildTextField({required TextEditingController controller, required String hint, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: _iosBg.withOpacity(0.5),
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: _notesYellow, width: 1.5)),
      ),
    );
  }
}