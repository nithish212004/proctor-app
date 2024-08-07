import 'dart:convert';

class Faculty{
  final String name;
  final String email;
  final String phone;

  Faculty({required this.name, required this.email, required this.phone});
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
    };
  }

    factory Faculty.fromMap(Map<String, dynamic> map) {
    return Faculty(
        name: map['name'] ?? '',
        phone: map['phone'] ?? '',
        email: map['email'] ?? '',);
  }

  String toJson() => json.encode(toMap());

  factory Faculty.fromJson(String source) => Faculty.fromMap(json.decode(source));

}