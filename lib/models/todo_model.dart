class Todo {
  int? id;
  String judul;
  String deskripsi;
  String tanggal;
  String kategori; 
  int statusSelesai;

  Todo({
    this.id,
    required this.judul,
    required this.deskripsi,
    required this.tanggal,
    required this.kategori,
    this.statusSelesai = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'judul': judul,
      'deskripsi': deskripsi,
      'tanggal': tanggal,
      'kategori': kategori,
      'status_selesai': statusSelesai,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      judul: map['judul'],
      deskripsi: map['deskripsi'],
      tanggal: map['tanggal'],
      kategori: map['kategori'],
      statusSelesai: map['status_selesai'],
    );
  }
}