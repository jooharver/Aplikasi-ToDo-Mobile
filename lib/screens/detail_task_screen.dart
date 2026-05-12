import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/todo_model.dart';
import 'add_task_screen.dart';

class DetailTaskScreen extends StatefulWidget {
  final Todo task;
  const DetailTaskScreen({super.key, required this.task});

  @override
  State<DetailTaskScreen> createState() => _DetailTaskScreenState();
}

class _DetailTaskScreenState extends State<DetailTaskScreen> {
  final DbHelper _dbHelper = DbHelper();
  late bool _isDone;

  // Palet Warna iOS Notes
  final Color _notesYellow = const Color(0xFFFFB800);
  final Color _iosBg = const Color(0xFFF2F2F7);
  final Color _textSub = const Color(0xFF8E8E93);

  @override
  void initState() {
    super.initState();
    _isDone = widget.task.statusSelesai == 1;
  }

  void _toggleStatus() async {
    int newStatus = _isDone ? 0 : 1;
    await _dbHelper.updateTaskStatus(widget.task.id!, newStatus);
    setState(() => _isDone = !_isDone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _iosBg,
      appBar: AppBar(
        backgroundColor: _iosBg,
        elevation: 0,
        iconTheme: IconThemeData(color: _notesYellow),

        title: const Text(
          'Detail',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row Judul & Checkbox
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Transform.scale(
                        scale: 1.3,
                        child: Checkbox(
                          value: _isDone,
                          activeColor: _notesYellow,
                          shape: const CircleBorder(),
                          side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                          onChanged: (value) => _toggleStatus(),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.task.judul,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                decoration: _isDone ? TextDecoration.lineThrough : null,
                                color: _isDone ? _textSub : Colors.black,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.task.tanggal,
                              style: TextStyle(
                                color: _notesYellow, 
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Divider(color: Colors.grey.shade100, thickness: 1),
                  const SizedBox(height: 20),

                  // Tag Kategori 
                  Row(
                    children: [
                      Icon(
                        widget.task.kategori == 'penting' ? Icons.star_rounded : Icons.folder_rounded,
                        color: widget.task.kategori == 'penting' ? Colors.redAccent : _notesYellow,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.task.kategori.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.w800, 
                          fontSize: 11, 
                          letterSpacing: 1.2,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'CATATAN',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFBCBCC0), letterSpacing: 1),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.task.deskripsi.isEmpty ? 'Tidak ada deskripsi.' : widget.task.deskripsi,
                    style: const TextStyle(
                      fontSize: 16, 
                      height: 1.6, 
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            
            const SizedBox(height: 30),

            // TOMBOL EDIT 
            Center(
              child: TextButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddTaskScreen(
                        isPenting: widget.task.kategori == 'penting',
                        taskToEdit: widget.task,
                      ),
                    ),
                  );
                  if (mounted) Navigator.pop(context);
                },
                icon: Icon(Icons.edit_note_rounded, color: _notesYellow, size: 22),
                label: Text(
                  'Edit Tugas',
                  style: TextStyle(
                    color: _notesYellow,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}