import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:proctor/constants/auth_constants.dart';
import 'package:proctor/constants/color.dart';
import 'package:proctor/main.dart';
import 'package:proctor/models/faculty.dart';
import 'package:proctor/models/student.dart';
import 'package:proctor/pages/admin_home.dart';
import 'package:proctor/pages/faculty_home_page.dart';
import 'package:proctor/pages/student_home_page.dart';
import 'package:proctor/pages/login_page.dart';
import 'package:proctor/pages/faculty_register_page.dart';
import 'package:proctor/pages/student_register_page.dart';
import 'package:proctor/providers/user_provider.dart';
import 'package:proctor/services/db.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool isloading = true;
  late DB db;

  @override
  void initState() {
    db = DB();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      validateStudent();
    });
  }

  void validateStudent() async {
    try {
      //var signedIn = await google.isSignedIn();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.getString("user")?.isNotEmpty ?? false) {
        debugPrint("Not null");
        if (prefs.getString("user") == "student") {
          debugPrint("Student");
          Student? student = await db.getStudent();
          if (student != null) {
            debugPrint(student.toMap().toString());
            Provider.of<UserProvider>(navigationKey.currentContext!,
                    listen: false)
                .addStudent(student);
          }
        } else if (prefs.getString("user") == "faculty") {
          debugPrint("faculty");
          Faculty? faculty = await db.getFaculty();
          if (faculty != null) {
            //debugPrint(jsonDecode(res.body).toString());
            debugPrint(faculty.toMap().toString());
            Provider.of<UserProvider>(navigationKey.currentContext!,
                    listen: false)
                .setFaculty();
            Provider.of<UserProvider>(navigationKey.currentContext!,
                    listen: false)
                .addFaculty(faculty);
          }
        } else if (prefs.getString("user") == "admin") {
          debugPrint("admin");
          Faculty? faculty = await db.getFaculty();
          if (faculty != null) {
            //debugPrint(jsonDecode(res.body).toString());
            debugPrint(faculty.toMap().toString());
            Provider.of<UserProvider>(navigationKey.currentContext!,
                    listen: false)
                .setAdmin();
            Provider.of<UserProvider>(navigationKey.currentContext!,
                    listen: false)
                .setFaculty();
            Provider.of<UserProvider>(navigationKey.currentContext!,
                    listen: false)
                .addFaculty(faculty);
          }
        }
      }
      /*if (prefs.getString("user")!.isNotEmpty) {
        GoogleSignInAccount? user = await google.signInSilently();
        if (user != null) {
          Response res = await get(Uri.parse('$url/checkUser?email=${user.email}',));
          if (res.statusCode == 200) {
            if (prefs.getString("user")! == "student") {
              try {
                //Response res = await get(Uri.parse('$url/checkStudent?email=${user.email}'));
                    debugPrint("Test");
                Student? student = await db.getData();
                if (student != null) {
                  debugPrint(jsonDecode(res.body).toString());
                  debugPrint(student.toMap().toString());
                  Provider.of<UserProvider>(navigationKey.currentContext!,
                          listen: false)
                      .addStudent(student);
                }
                /*else if (res.statusCode == 400) {
                  debugPrint("Success");
                  Provider.of<UserProvider>(navigationKey.currentContext!,
                          listen: false)

                      .addStudent(Student(
                          name: user.displayName ?? "",
                          email: user.email,
                          phone: "",
                          regnum: "",
                          faculty: Faculty(name: "", email: "", phone: "")));
                } */else {
                  SnackBarGlobal.show("Error occured while validating student");
                }
              } catch (e) {
                debugPrint(e.toString());
              }
            } else {
              bool f = false;
              List<Faculty> faculties = [];
              try {
                Response res = await get(Uri.parse('$url/faculties'));
                if (res.statusCode == 200) {
                  List lt = jsonDecode(res.body);
                  for (int i = 0; i < lt.length; i++) {
                    faculties.add(Faculty.fromMap(lt[i]));
                  }
                } else {
                  SnackBarGlobal.show(
                      "Error occured while fetching proctor names");
                }
              } catch (e) {
                debugPrint(e.toString());
              }
              for (int i = 0; i < faculties.length; i++) {
                debugPrint(faculties[i].email);
                if (user.email == faculties[i].email) {
                  f = true;
                  debugPrint("Success 1212");
                  Provider.of<UserProvider>(navigationKey.currentContext!,
                          listen: false)
                      .setFaculty();
                  try {
                    Response res = await get(
                        Uri.parse('$url/checkFaculty?email=${user.email}'));
                    if (res.statusCode == 200) {
                      Provider.of<UserProvider>(navigationKey.currentContext!,
                              listen: false)
                          .addFaculty(Faculty.fromJson(res.body));
                    } else if (res.statusCode == 400) {
                      debugPrint("Success");
                      Provider.of<UserProvider>(navigationKey.currentContext!,
                              listen: false)
                          .addFaculty(Faculty(
                        name: user.displayName ?? "",
                        email: user.email,
                        phone: "",
                      ));
                    } else {
                      SnackBarGlobal.show(
                          "Error occured while validating faculty");
                    }
                  } catch (e) {
                    debugPrint(e.toString());
                  }
                  break;
                }
              }
              if (!f) {
                SnackBarGlobal.show(
                    "Faculty profile not found. Please contact the Administrator");
                await google.signOut();
              }
            }
          } else if (res.statusCode == 201) {
            debugPrint("Called 201");
            Provider.of<UserProvider>(navigationKey.currentContext!,
                    listen: false)
                .setAdmin();
            Provider.of<UserProvider>(navigationKey.currentContext!,
                    listen: false)
                .setFaculty();
            Provider.of<UserProvider>(navigationKey.currentContext!,
                    listen: false)
                .addFaculty(
                    Faculty(name: "Admin", email: user.email, phone: "Admin"));
          } else {
            SnackBarGlobal.show("Please continue with your college E-Mail ID");
            await google.signOut();
          }
        }
      }*/
      setState(() {
        isloading = false;
      });
    } catch (e) {
      debugPrint("Error ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return isloading
        ? const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_pin_rounded,
                    size: 165,
                    color: kPrimaryColor,
                  ),
                  
                ],
              ),
            ),
          )
        : Provider.of<UserProvider>(context).student.email.isNotEmpty ||
                Provider.of<UserProvider>(context).faculty.email.isNotEmpty
            ? Provider.of<UserProvider>(context).student.regnum.isEmpty
                ? Provider.of<UserProvider>(context).isFaculty
                    ? Provider.of<UserProvider>(context).faculty.phone.isEmpty
                        ? FRegisterPage(
                            readOnly: true,
                            faculty: Faculty(name: "", email: "", phone: ""),
                          )
                        : Provider.of<UserProvider>(context).isAdmin
                            ? const AdminPage()
                            : const FHomePage()
                    : const RegisterPage()
                : const HomePage()
            : const LoginPage();
  }
}
