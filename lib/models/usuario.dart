class Usuario {
  final String email;
  final String password;

  Usuario({required this.email, required this.password});

  factory Usuario.fromJson(Map<String, dynamic> json){
    return Usuario(
      email: json['email'] ?? '',
      password: json['password'] ?? '',
    );
  }
}