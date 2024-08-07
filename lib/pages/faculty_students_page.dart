import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:proctor/constants/auth_constants.dart';
import 'package:proctor/constants/color.dart';
import 'package:proctor/main.dart';
import 'package:proctor/models/chat_card.dart';
import 'package:proctor/models/student.dart';
import 'package:proctor/pages/individual_chat_page.dart';
import 'package:proctor/providers/user_provider.dart';
import 'package:provider/provider.dart';

class FacultyStudentShowPage extends StatefulWidget {
  const FacultyStudentShowPage({
    super.key,
  });

  @override
  State<FacultyStudentShowPage> createState() => _FacultyPageState();
}

class _FacultyPageState extends State<FacultyStudentShowPage> {
  bool isloading = true;
  String search = "";
  TextEditingController searchcontroller = TextEditingController();
  List<String> filter = ['Name', 'Register Number', 'Email', 'Phone'];
  String selectedFilter = "Name";
  bool selection = false;
  bool issearch = false;
  List<String> students = [];
  List<String> selectedStudents = [];

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
      floatingActionButton: selectedStudents.length >= 2
          ? FloatingActionButton(
              child: const Icon(
                Icons.send,
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
              })
          : null,
      appBar: AppBar(
        leading: issearch
            ? const SizedBox()
            : IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                ),
              ),
        centerTitle: issearch,
        backgroundColor: kPrimaryColor,
        title: const Text(
          "Select Student",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          issearch
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 45,
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: TextFormField(
                        autofocus: true,
                        textAlignVertical: TextAlignVertical.center,
                        textInputAction: TextInputAction.done,
                        textDirection: TextDirection.ltr,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onChanged: (val) {
                          setState(() {
                            search = val;
                          });
                        },
                        keyboardType: selectedFilter == 'Phone'
                            ? TextInputType.number
                            : selectedFilter == 'Email'
                                ? TextInputType.emailAddress
                                : TextInputType.text,
                        controller: searchcontroller,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Search",
                          hintStyle: const TextStyle(color: Colors.white),
                          prefixIcon: issearch
                              ? IconButton(
                                  onPressed: () {
                                    setState(() {
                                      issearch = false;
                                      searchcontroller.text = "";
                                      search = "";
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white,
                                  ))
                              : const Icon(Icons.search),
                          suffixIcon: DropdownButton(
                            padding: const EdgeInsets.only(right: 15),
                            icon: const Icon(
                              Icons.arrow_drop_down_circle_sharp,
                              color: Colors.white,
                            ),
                            underline: const SizedBox(),
                            alignment: Alignment.topCenter,
                            borderRadius: BorderRadius.circular(8),
                            dropdownColor: kPrimaryLight,
                            value: selectedFilter,
                            items: filter
                                .map<DropdownMenuItem<String>>(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    alignment: Alignment.center,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Text(
                                        e,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (String? value) => setState(
                              () {
                                if (value != null) selectedFilter = value;
                              },
                            ),
                          ),
                          contentPadding:
                              const EdgeInsets.only(top: 10, bottom: 10),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[100]!),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[100]!),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                      ),
                    ),
                    /*const SizedBox(
                        width: MediaQuery.of(context).size.width * 0.05,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: kPrimaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: */
                  ],
                )
              : const SizedBox(),
          issearch
              ? SizedBox(
                  width: MediaQuery.of(context).size.width * 0.05,
                )
              : IconButton(
                  onPressed: () {
                    setState(() {
                      issearch = true;
                    });
                    //Navigator.push(context, MaterialPageRoute(builder: (_)=> const NotifyPage()));
                  },
                  icon: const Icon(
                    Icons.search,
                    size: 27,
                    color: Colors.white,
                  ),
                ),
          const SizedBox(
            width: 10,
          ),
          selectedStudents.isNotEmpty
              ? !selection &&
                      !students.every(
                          (element) => selectedStudents.contains(element))
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          selectedStudents = students;
                          selection = true;
                        });
                      },
                      icon: const Icon(Icons.check_box_outline_blank_rounded,
                          color: Colors.white))
                  : IconButton(
                      onPressed: () {
                        setState(() {
                          selectedStudents = [];
                          selection = false;
                        });
                      },
                      icon: const Icon(Icons.check_box, color: Colors.white))
              : const SizedBox()
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: FutureBuilder<List<Student>>(
              future: fetchStudents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  debugPrint(snapshot.error.toString());
                  SnackBarGlobal.show("Error while fetching students");
                }
                if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                  debugPrint(snapshot.data!.toString());
                  if (snapshot.data!.where((s) {
                    if (selectedFilter == 'Name') {
                      return s.name
                          .toLowerCase()
                          .contains(search.toLowerCase());
                    } else if (selectedFilter == 'Register Number') {
                      return s.regnum
                          .toLowerCase()
                          .contains(search.toLowerCase());
                    } else if (selectedFilter == 'Email') {
                      return s.email
                          .toLowerCase()
                          .contains(search.toLowerCase());
                    } else if (selectedFilter == 'Phone') {
                      return s.phone
                          .toLowerCase()
                          .contains(search.toLowerCase());
                    } else {
                      return true;
                    }
                  }).isEmpty) {
                    students = [];
                    return const Center(
                        child: Text(
                      "No Student found !",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
                    ));
                  } else {
                    students = snapshot.data!
                        .where((s) {
                          if (selectedFilter == 'Name') {
                            return s.name
                                .toLowerCase()
                                .contains(search.toLowerCase());
                          } else if (selectedFilter == 'Register Number') {
                            return s.regnum
                                .toLowerCase()
                                .contains(search.toLowerCase());
                          } else if (selectedFilter == 'Email') {
                            return s.email
                                .toLowerCase()
                                .contains(search.toLowerCase());
                          } else if (selectedFilter == 'Phone') {
                            return s.phone
                                .toLowerCase()
                                .contains(search.toLowerCase());
                          } else {
                            return true;
                          }
                        })
                        .map((e) => e.email)
                        .toList();

                    return ListView(
                        //return Card(child: IdCard(name: snapshot.data![index].name, regnum: snapshot.data![index].regnum, pname: snapshot.data![index].faculty.name, pphone: snapshot.data![index].faculty.phone, pemail: snapshot.data![index].faculty.email));
                        children: snapshot.data!.where((s) {
                      if (selectedFilter == 'Name') {
                        return s.name
                            .toLowerCase()
                            .contains(search.toLowerCase());
                      } else if (selectedFilter == 'Register Number') {
                        return s.regnum
                            .toLowerCase()
                            .contains(search.toLowerCase());
                      } else if (selectedFilter == 'Email') {
                        return s.email
                            .toLowerCase()
                            .contains(search.toLowerCase());
                      } else if (selectedFilter == 'Phone') {
                        return s.phone
                            .toLowerCase()
                            .contains(search.toLowerCase());
                      } else {
                        return true;
                      }
                    }).map<Widget>((e) {
                      return InkWell(
                        onLongPress: () {
                          setState(() {
                            if (selectedStudents.contains(e.email)) {
                              selectedStudents.remove(e.email);
                            } else {
                              selectedStudents.add(e.email);
                            }
                          });
                        },
                        onTap: () {
                          if (selectedStudents.isNotEmpty) {
                            debugPrint("Test");
                            setState(() {
                              if (selectedStudents.contains(e.email)) {
                                selectedStudents.remove(e.email);
                              } else {
                                selectedStudents.add(e.email);
                              }
                            });
                          } else {
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
                          }
                        },
                        child: CustomCard(
                            selected: selectedStudents.contains(e.email),
                            student: Student(
                                name: e.name,
                                email: e.email,
                                phone: e.phone,
                                regnum: e.regnum,
                                faculty: e.faculty)),
                      );
                    }).toList());
                  }
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
