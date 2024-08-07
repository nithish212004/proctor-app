
import 'dart:convert';

import 'package:proctor/models/faculty.dart';

class Student{
  final String name;
  final String email;
  final String phone;
  final String regnum;
  final Faculty faculty;

  Student({required this.name, required this.email, required this.phone, required this.regnum, required this.faculty});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'regnum': regnum,
      'proctor': faculty.email
    };
  }

      factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
        name: map['name'],
        phone: map['phone'],
        email: map['email'],
        regnum: map['regnum'],
        faculty: Faculty(name: map['pname'], email: map['pemail'], phone: map['pphone'] ?? ""));
  }

  String toJson() => json.encode(toMap());

  factory Student.fromJson(String source) => Student.fromMap(json.decode(source));

}