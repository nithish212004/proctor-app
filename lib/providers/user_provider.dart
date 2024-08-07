import 'package:flutter/material.dart';
import 'package:proctor/models/faculty.dart';
import 'package:proctor/models/student.dart';

class UserProvider extends ChangeNotifier{
  Faculty _faculty = Faculty(name: "", email: "", phone: "");
  Student _student = Student(name: "", email: "", phone: "", regnum: "", faculty: Faculty(name: "", email: "", phone: ""));

  bool _isFaculty = false;
  bool _isAdmin = false;
  
  Student get student => _student;
  bool get isFaculty => _isFaculty;
  bool get isAdmin => _isAdmin;
  Faculty get faculty => _faculty;

  void addStudent(Student user){
    _student = user;
    notifyListeners();
  }

  void addFaculty(Faculty faculty){
    _faculty = faculty;
    notifyListeners();
  }

  void removeStudent(){
    _student = Student(name: "", email: "", phone: "", regnum: "", faculty: _faculty); 
    _faculty = Faculty(name: "", email: "", phone: "");
    _isFaculty = false;
    _isAdmin = false;
    notifyListeners();
  }

  void setFaculty(){
    _isFaculty = true;
    notifyListeners();
  }

  void setAdmin(){
    _isAdmin = true;
    notifyListeners();
  }
}