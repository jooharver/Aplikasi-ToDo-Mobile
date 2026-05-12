import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../models/todo_model.dart';
import 'add_task_screen.dart';
import 'task_list_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DbHelper _dbHelper = DbHelper();
  int _tugasSelesai = 0;
  int _belumSelesai = 0;
  List<int> _weeklyStats = List.filled(7, 0);
  List<String> _weekLabels = [];
  int _maxStat = 1; 

  final Color _notesYellow = const Color(0xFFFFB800); 
  final Color _softYellow = const Color(0xFFF2F2F7); 
  final Color _iosBg = const Color(0xFFF2F2F7); 
  final Color _iosGrey = const Color(0xFF8E8E93); 
  final Color _iosRed = const Color(0xFFFF3B30);

  @override
  void initState() {
    super.initState();
    _loadStatistik();
  }

  void _loadStatistik() async {
    int selesai = await _dbHelper.getCount(1);
    int belum = await _dbHelper.getCount(0);
    
    List<String> labels = [];
    List<String> dbDateFormats = [];
    for (int i = 6; i >= 0; i--) {
      DateTime d = DateTime.now().subtract(Duration(days: i));
      labels.add(DateFormat('dd/MM').format(d));
      dbDateFormats.add(DateFormat('dd MMMM yyyy', 'id_ID').format(d));
    }

    List<int> counts = List.filled(7, 0);
    final List<Todo> allTasks = await _dbHelper.getTasks();
    for (var task in allTasks) {
      if (task.statusSelesai == 1) { 
        int index = dbDateFormats.indexOf(task.tanggal);
        if (index != -1) counts[index]++;
      }
    }

    int maxVal = counts.isEmpty ? 1 : counts.reduce((curr, next) => curr > next ? curr : next);
    setState(() {
      _tugasSelesai = selesai;
      _belumSelesai = belum;
      _weekLabels = labels;
      _weeklyStats = counts;
      _maxStat = maxVal == 0 ? 1 : maxVal;
    });
  }

  void _navigateAndRefresh(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
    _loadStatistik();
  }

  @override
  Widget build(BuildContext context) {
    String today = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now());

    return Scaffold(
      backgroundColor: _iosBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            pinned: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: _softYellow,
            surfaceTintColor: _softYellow,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: const Text('Beranda', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              background: Container(color: _iosBg), 
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(today, style: const TextStyle(fontSize: 14, color: Color(0xFF8E8E93))),
                  const SizedBox(height: 24),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(24), 
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        _buildStatItem('TUGAS SELESAI', _tugasSelesai, _notesYellow),
                        Container(width: 1, height: 40, color: Colors.grey.shade200),
                        _buildStatItem('BELUM SELESAI', _belumSelesai, _belumSelesai > 0 ? _iosRed : _iosGrey), 
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildChartCard(),
                  const SizedBox(height: 32),

                  const Text('MAIN MENU', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF8E8E93))),
                  const SizedBox(height: 12),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      // Ditambahkan showAddIcon: true
                      _buildMenuCard(Icons.folder_open_rounded, 'Tugas Biasa', _notesYellow, () => _navigateAndRefresh(const AddTaskScreen(isPenting: false)), showAddIcon: true),
                      _buildMenuCard(Icons.star_rounded, 'Tugas Penting', _notesYellow, () => _navigateAndRefresh(const AddTaskScreen(isPenting: true)), showAddIcon: true),
                      _buildMenuCard(Icons.format_list_bulleted_rounded, 'Daftar Tugas', _notesYellow, () => _navigateAndRefresh(const TaskListScreen())),
                      _buildMenuCard(Icons.settings_rounded, 'Pengaturan', Colors.blueGrey, () => _navigateAndRefresh(const SettingsScreen())),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int val, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Text('$val', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('STATISTIK TUGAS SELESAI/HARI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF8E8E93), letterSpacing: 0.5)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              double barHeight = (_weeklyStats[index] / _maxStat) * 100; 
              if (barHeight == 0) barHeight = 6;
              bool hasData = _weeklyStats[index] > 0;
              return Column(
                children: [
                  Text('${_weeklyStats[index]}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: hasData ? Colors.black : Colors.transparent)),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: 28,
                    height: barHeight,
                    decoration: BoxDecoration(color: hasData ? _notesYellow : const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(8)),
                  ),
                  const SizedBox(height: 12),
                  Text(_weekLabels.isNotEmpty ? _weekLabels[index] : '', style: const TextStyle(fontSize: 11, color: Color(0xFF8E8E93), fontWeight: FontWeight.w500)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // Menambahkan parameter showAddIcon
  Widget _buildMenuCard(IconData icon, String title, Color color, VoidCallback onTap, {bool showAddIcon = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Stack( // Menggunakan Stack untuk menimpa ikon +
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.circular(24), 
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1), 
                    shape: BoxShape.circle
                  ),
                  child: Icon(icon, color: color, size: 30),
                ),
                const SizedBox(height: 12),
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          // Ikon Plus di pojok kanan atas
          if (showAddIcon)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add_rounded, color: color, size: 18),
              ),
            ),
        ],
      ),
    );
  }
}