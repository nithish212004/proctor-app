import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proctor/models/faculty.dart';
import 'package:proctor/models/message_model.dart';
import 'package:proctor/models/student.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DB {
  Future<Database> initDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, "MYDB.db"),
      onCreate: (database, verison) async {
        await database.execute("""
        CREATE TABLE student(
        name text,
        email text,
        phone text,
        regnum text,
        proctor text
        );
        """);
        await database.execute("""
        CREATE TABLE faculty(
        name text,
        email text,
        phone text
        );
        """);
        await database.execute("""
        CREATE TABLE message(
        message text,
        sender text,
        receiver text,
        time text
        );
        """);
      },
      version: 1,
    );
  }

  Future<bool> insertStudent(Student student) async {
    try {
      await deleteDB();
      final Database db = await initDB();
      db.insert("student", student.toMap());
      db.insert("faculty", student.faculty.toMap());
    } catch (e) {
      debugPrint(e.toString());
    }
    return true;
  }

  Future<bool> insertFaculty(Faculty faculty) async {
    try {
      await deleteDB();
      final Database db = await initDB();
      db.insert("faculty", faculty.toMap());
    } catch (e) {
      debugPrint(e.toString());
    }
    return true;
  }

  Future<bool> insertMessage(Message message) async {
    try {
      final Database db = await initDB();
      db.insert("message", {
        'message': message.message,
        'sender': message.sender,
        'receiver': message.receiver,
        'time': message.time
      });
    } catch (e) {
      debugPrint(e.toString());
    }
    return true;
  }

  Future<Student?> getStudent() async {
    try {
      final Database db = await initDB();
      final List<Map<String, Object?>> data = await db.rawQuery('''
      select s.name as name, s.email as email, s.phone as phone, s.regnum as regnum, f.name as pname, f.email as pemail, f.phone as pphone
      from student s, faculty f
      where s.proctor = f.email or s.proctor is null;
    ''');

      if (data.isNotEmpty) {
        for (int i = 0; i < data.length; i++) {
          debugPrint("Hello");
          debugPrint(data[i].toString());
        }
        return Student.fromMap(data[0]);
      } else {
        debugPrint("Empty");
        return null;
      }
    } on DatabaseException catch (e) {
      debugPrint('DB error in DB ${e.toString()}');
      return null;
    } catch (e) {
      debugPrint('error in DB ${e.toString()}');
      return null;
    }
  }

  Future<Faculty?> getFaculty() async {
    try {
      final Database db = await initDB();
      final List<Map<String, Object?>> data = await db.rawQuery('''
      select name, phone, email
      from faculty;
    ''');

      if (data.isNotEmpty) {
        for (int i = 0; i < data.length; i++) {
          debugPrint("Hello");
          debugPrint(data[i].toString());
        }
        return Faculty.fromMap(data[0]);
      } else {
        return null;
      }
    } on DatabaseException catch (e) {
      debugPrint('DB error in DB ${e.toString()}');
      return null;
    } catch (e) {
      debugPrint('error in DB ${e.toString()}');
      return null;
    }
  } 

  Future<List<Student>?> getChat(String email) async {
    try {
      final Database db = await initDB();
      final List<Map<String, Object?>> data = await db.rawQuery('''
      select name from student;
      
    ''');

      if (data.isNotEmpty) {
        for (int i = 0; i < data.length; i++) {
          debugPrint("Hello");
          debugPrint(data[i].toString());
        }
        return data.map((e) => Student.fromMap(e)).toList();
      } else {
        debugPrint("Empty...");
        return null;
      }
    } on DatabaseException catch (e) {
      debugPrint('DB error in DB ${e.toString()}');
      return null;
    } catch (e) {
      debugPrint('error in DB ${e.toString()}');
      return null;
    }
  }

  Future<List<Message>?> getMessage(String sender, String receiver) async {
    try {
      final Database db = await initDB();
      debugPrint(sender + " " + receiver);
      final List<Map<String, Object?>> data = await db.rawQuery('''
      select *
      from message
      where (sender = ? and receiver = ?)
      or (sender = ? and receiver = ?)
      order by time;
    ''', [sender, receiver, receiver, sender]);
      if (data.isNotEmpty) {
        for (int i = 0; i < data.length; i++) {
          debugPrint("Hello");
          debugPrint(data[i].toString());
        }
        return data.map((e) => Message.fromMap(e)).toList();
      } else {
        return null;
      }
    } on DatabaseException catch (e) {
      debugPrint('DB error in DB ${e.toString()}');
      return null;
    } catch (e) {
      debugPrint('error in DB ${e.toString()}');
      return null;
    }
  }

  Future<void> updateStudent(Student student, String email) async {
    final Database db = await initDB();
    debugPrint(student.toMap().toString());
    await db.update("student", student.toMap(),
        where: "email=?", whereArgs: [email]);
  }

  Future<void> updateFaculty(Faculty faculty, String email) async {
    final Database db = await initDB();
    await db
        .update("faculty", faculty.toMap(), where: "id=?", whereArgs: [email]);
  }

  Future<void> truncateStudents() async {
    final Database db = await initDB();
    await db.delete("student");
  }

  Future deleteDB() async {
    String path = await getDatabasesPath();
    await deleteDatabase(join(path, "MYDB.db"));
  }
}
