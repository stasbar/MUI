class User {
  final String id;
  final String email;
  final String role;

  User({this.id, this.email, this.role});

  factory User.fromJson(Map<String,dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      role: json['role'],
    );
  }
}
