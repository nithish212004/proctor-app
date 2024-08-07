import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:proctor/constants/auth_constants.dart';
import 'package:proctor/constants/color.dart';
import 'package:proctor/main.dart';
import 'package:proctor/models/chat_card.dart';
import 'package:proctor/models/student.dart';
import 'package:proctor/pages/faculty_students_page.dart';
import 'package:proctor/pages/individual_chat_page.dart';
import 'package:proctor/providers/user_provider.dart';
import 'package:proctor/services/db.dart';
import 'package:provider/provider.dart';

class FacultyStudentPage extends StatefulWidget {
  final String search;
  final TextEditingController searchcontroller;
  final String selectedFilter;
  const FacultyStudentPage(
      {super.key,
      required this.searchcontroller,
      required this.search,
      required this.selectedFilter});

  @override
  State<FacultyStudentPage> createState() => _FacultyPageState();
}

class _FacultyPageState extends State<FacultyStudentPage> {
  bool isloading = true;

  Future<List<Student>> fetchStudents() async {
    debugPrint("Try");
    List<Student> l = [];
    try {
      debugPrint("Called");
      Response res = await get(Uri.parse(
          '$url/fetchStudents?proctor=${Provider.of<UserProvider>(context).faculty.email}'));
      debugPrint(res.statusCode.toString());
      if (res.statusCode == 200) {
        debugPrint(jsonDecode(res.body).toString());
        List t = jsonDecode(res.body);
        for (int i = 0; i < t.length; i++) {
          l.add(Student.fromMap(t[i]));
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      SnackBarGlobal.show("Error Occured while fetching students list");
    }
    debugPrint(l.toString());
    return l;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: const Icon(
            Icons.chat_bubble_rounded,
            color: kPrimaryColor,
            size: 30,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const FacultyStudentShowPage(),
              ),
            );
          }),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: FutureBuilder<List<Student>?>(
              future: fetchStudents(),
              //DB().getChat(Provider.of<UserProvider>(context).faculty.email),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  debugPrint(snapshot.error.toString());
                  SnackBarGlobal.show("Error while fetching students");
                }
                if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                  debugPrint(snapshot.data!.toString());
                  return snapshot.data!.where((s) {
                    if (widget.selectedFilter == 'Name') {
                      return s.name
                          .toLowerCase()
                          .contains(widget.search.toLowerCase());
                    } else if (widget.selectedFilter == 'Register Number') {
                      return s.regnum
                          .toLowerCase()
                          .contains(widget.search.toLowerCase());
                    } else if (widget.selectedFilter == 'Email') {
                      return s.email
                          .toLowerCase()
                          .contains(widget.search.toLowerCase());
                    } else if (widget.selectedFilter == 'Phone') {
                      return s.phone
                          .toLowerCase()
                          .contains(widget.search.toLowerCase());
                    } else {
                      return true;
                    }
                  }).isEmpty
                      ? const Center(
                          child: Text(
                          "No Student found !",
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.w500),
                        ))
                      : ListView(
                          //return Card(child: IdCard(name: snapshot.data![index].name, regnum: snapshot.data![index].regnum, pname: snapshot.data![index].faculty.name, pphone: snapshot.data![index].faculty.phone, pemail: snapshot.data![index].faculty.email));
                          children: snapshot.data!.where((s) {
                          if (widget.selectedFilter == 'Name') {
                            return s.name
                                .toLowerCase()
                                .contains(widget.search.toLowerCase());
                          } else if (widget.selectedFilter ==
                              'Register Number') {
                            return s.regnum
                                .toLowerCase()
                                .contains(widget.search.toLowerCase());
                          } else if (widget.selectedFilter == 'Email') {
                            return s.email
                                .toLowerCase()
                                .contains(widget.search.toLowerCase());
                          } else if (widget.selectedFilter == 'Phone') {
                            return s.phone
                                .toLowerCase()
                                .contains(widget.search.toLowerCase());
                          } else {
                            return true;
                          }
                        }).map<Widget>((e) {
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => IndividualPage(
                                    student: Student(
                                        name: e.name,
                                        email: e.email,
                                        phone: e.phone,
                                        regnum: e.regnum,
                                        faculty: e.faculty),
                                  ),
                                ),
                              );
                            },
                            child: CustomCard(
                                selected: false,
                                student: Student(
                                    name: e.name,
                                    email: e.email,
                                    phone: e.phone,
                                    regnum: e.regnum,
                                    faculty: e.faculty)),
                          );
                        }).toList());
                } else if (snapshot.data == null) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return const Center(child: Text("No students found"));
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
