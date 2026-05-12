class User {
  int? id;
  String username;
  String password;

  User({this.id, required this.username, required this.password});

  // Konversi dari Objek ke Map (untuk Insert ke SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
    };
  }

  // Konversi dari Map SQLite ke Objek
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
    );
  }
}