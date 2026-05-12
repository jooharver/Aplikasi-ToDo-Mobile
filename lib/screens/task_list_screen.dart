import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../models/todo_model.dart';
import 'detail_task_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final DbHelper _dbHelper = DbHelper();
  
  // simpan dalam Map: Key adalah Tanggal, Value adalah List Tugas di tanggal tersebut
  Map<String, List<Todo>> _groupedTasks = {};
  bool _isLoading = true;

  final Color _notesYellow = const Color(0xFFFFB800);
  final Color _iosBg = const Color(0xFFF2F2F7);
  final Color _textSub = const Color(0xFF8E8E93);
  final Color _iosRed = const Color(0xFFFF3B30);
  final Color _iosBlue = const Color.fromARGB(255, 78, 70, 223);

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    final tasks = await _dbHelper.getTasks();

    // 1. Sort semua tugas berdasarkan tanggal asli (DateTime)
    tasks.sort((a, b) {
      DateTime dateA = DateFormat('dd MMMM yyyy', 'id_ID').parse(a.tanggal);
      DateTime dateB = DateFormat('dd MMMM yyyy', 'id_ID').parse(b.tanggal);
      return dateB.compareTo(dateA);
    });

    // 2. Kelompokkan ke dalam Map
    Map<String, List<Todo>> tempGrouped = {};
    for (var task in tasks) {
      if (!tempGrouped.containsKey(task.tanggal)) {
        tempGrouped[task.tanggal] = [];
      }
      tempGrouped[task.tanggal]!.add(task);
    }

    setState(() {
      _groupedTasks = tempGrouped;
      _isLoading = false;
    });
  }

  void _toggleStatus(Todo task) async {
    int newStatus = task.statusSelesai == 1 ? 0 : 1;
    await _dbHelper.updateTaskStatus(task.id!, newStatus);
    _loadTasks(); 
  }

  void _deleteTask(int id) async {
    await _dbHelper.deleteTask(id);
    _loadTasks();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tugas telah dihapus'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil daftar tanggal (Keys) untuk di-loop di ListView utama
    List<String> sortedDates = _groupedTasks.keys.toList();

    return Scaffold(
      backgroundColor: _iosBg,
      appBar: AppBar(
        backgroundColor: _iosBg,
        elevation: 0,
        iconTheme: IconThemeData(color: _notesYellow),
        title: const Text(
          'Daftar Tugas',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _notesYellow))
          : _groupedTasks.isEmpty
              ? Center(child: Text('Tidak ada tugas.', style: TextStyle(color: _textSub)))
              : ListView.builder(
                  padding: const EdgeInsets.all(20.0),
                  itemCount: sortedDates.length,
                  itemBuilder: (context, index) {
                    String dateKey = sortedDates[index];
                    List<Todo> tasksForDate = _groupedTasks[dateKey]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // HEADER TANGGAL
                        Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 12, top: 8),
                          child: Text(
                            dateKey.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: _textSub,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        
                        // KARTU TUGAS UNTUK TANGGAL INI
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                            ],
                          ),
                          child: Column(
                            children: tasksForDate.asMap().entries.map((entry) {
                              int idx = entry.key;
                              Todo task = entry.value;
                              bool isLast = idx == tasksForDate.length - 1;
                              bool isPenting = task.kategori == 'penting';
                              bool isDone = task.statusSelesai == 1;

                              return Column(
                                children: [
                                  Dismissible(
                                    key: Key(task.id.toString()),
                                    direction: DismissDirection.endToStart,
                                    confirmDismiss: (direction) async {
                                      return await showCupertinoDialog<bool>(
                                        context: context,
                                        builder: (context) => CupertinoAlertDialog(
                                          title: const Text('Hapus Tugas?'),
                                          content: const Text('Tugas ini akan dihapus secara permanen.'),
                                          actions: [
                                            CupertinoDialogAction(
                                              child: Text('Batal', style: TextStyle(color: _iosBlue)),
                                              onPressed: () => Navigator.of(context).pop(false),
                                            ),
                                            CupertinoDialogAction(
                                              isDestructiveAction: true,
                                              child: const Text('Hapus'),
                                              onPressed: () => Navigator.of(context).pop(true),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    onDismissed: (direction) => _deleteTask(task.id!),
                                    background: Container(
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 24),
                                      decoration: BoxDecoration(
                                        color: _iosRed, 
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      leading: SizedBox(
                                        width: 50,
                                        child: Stack(
                                          alignment: Alignment.centerLeft,
                                          children: [
                                            Transform.scale(
                                              scale: 1.2,
                                              child: Checkbox(
                                                value: isDone,
                                                activeColor: _notesYellow,
                                                shape: const CircleBorder(),
                                                side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                                                onChanged: (bool? value) => _toggleStatus(task),
                                              ),
                                            ),
                                            if (isPenting)
                                              Positioned(
                                                top: 0,
                                                right: 0,
                                                child: Icon(Icons.star_rounded, color: _iosRed, size: 16),
                                              ),
                                          ],
                                        ),
                                      ),
                                      title: Text(
                                        task.judul,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: isDone ? _textSub : Colors.black,
                                          decoration: isDone ? TextDecoration.lineThrough : null,
                                        ),
                                      ),
                                      subtitle: Text(
                                        isPenting ? "Penting" : "Biasa",
                                        style: TextStyle(color: _textSub, fontSize: 13),
                                      ),
                                      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: _notesYellow),
                                      onTap: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => DetailTaskScreen(task: task)),
                                        );
                                        _loadTasks();
                                      },
                                    ),
                                  ),
                                  // Garis pemisah antar tugas dalam satu tanggal, kecuali yang terakhir
                                  if (!isLast)
                                    Divider(height: 1, indent: 70, color: Colors.grey.shade100),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 24), // Jarak antar grup tanggal
                      ],
                    );
                  },
                ),
    );
  }
}