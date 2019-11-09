class User {
  final String email;
  final String role;

  User({this.email, this.role});

  factory User.fromJson(Map<String,dynamic> json) {
    return User(
      email: json['email'],
      role: json['role'],
    );
  }
}
