import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:proctor/constants/color.dart';
import 'package:proctor/main.dart';
import 'package:proctor/models/faculty.dart';
import 'package:proctor/models/student.dart';
import 'package:proctor/providers/user_provider.dart';
import 'package:proctor/constants/auth_constants.dart';
import 'package:proctor/services/db.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isloading = false;
  late DB db;

  @override
  void initState() {
    super.initState();
    db = DB();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add your aesthetic elements here
            const Icon(
              Icons.three_p_rounded,
              size: 150,
              color: kPrimaryColor,
            ),
            const SizedBox(height: 100),
            isloading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: MaterialButton(
                      color: kPrimaryColor,
                      onPressed: () async {
                        setState(() {
                          isloading = true;
                        });
                        GoogleSignInAccount? user;
                        try {
                          user = await google.signIn();
                        } catch (e) {
                          SnackBarGlobal.show(
                              "Error occured while logging in. Try again");
                        }
                        if (user != null) {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          try {
                            Response res = await get(Uri.parse(
                              '$url/checkUser?email=${user.email}',
                            ));
                            if (res.statusCode == 200) {
                              if (user.email.contains("student.tce.edu")) {
                                debugPrint("student");
                                try {
                                  Response res = await get(Uri.parse(
                                      '$url/checkStudent?email=${user.email}'));
                                  if (res.statusCode == 200) {
                                    debugPrint(jsonDecode(res.body).toString());

                                    String? t = prefs.getString('token');
                                    if (t != null && t.isNotEmpty) {
                                      debugPrint("Token not null");
                                      Response res = await get(Uri.parse(
                                          '$url/savetoken?token=$t&&email=${user.email}'));
                                      if (res.statusCode == 200) {
                                        debugPrint("Success");
                                      } else {
                                        debugPrint("Error in saving token");
                                      }
                                    }
                                    Provider.of<UserProvider>(
                                            navigationKey.currentContext!,
                                            listen: false)
                                        .addStudent(Student.fromMap(
                                            jsonDecode(res.body)));
                                    prefs.setString("user", "student");
                                    await db.insertStudent(
                                        Student.fromMap(jsonDecode(res.body)));
                                    //await db.truncateStudents();
                                  } else if (res.statusCode == 400) {
                                    prefs.setString("user", "student");
                                    await db.insertStudent(
                                        Student(
                                            name: user.displayName ?? "",
                                            email: user.email,
                                            phone: "",
                                            regnum: "",
                                            faculty: Faculty(
                                                name: "",
                                                email: "",
                                                phone: "")));
                                    Provider.of<UserProvider>(
                                            navigationKey.currentContext!,
                                            listen: false)
                                        .addStudent(Student(
                                            name: user.displayName ?? "",
                                            email: user.email,
                                            phone: "",
                                            regnum: "",
                                            faculty: Faculty(
                                                name: "",
                                                email: "",
                                                phone: "")));
                                  } else {
                                    SnackBarGlobal.show(
                                        "Error occured while validating student");
                                  }
                                } catch (e) {
                                  debugPrint(e.toString());
                                }
                              } else {
                                bool f = false;
                                List<Faculty> faculties = [];
                                try {
                                  Response res =
                                      await get(Uri.parse('$url/faculties'));
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

                                    Provider.of<UserProvider>(
                                            navigationKey.currentContext!,
                                            listen: false)
                                        .setFaculty();
                                    try {
                                      Response res = await get(Uri.parse(
                                          '$url/checkFaculty?email=${user.email}'));
                                      if (res.statusCode == 200) {
                                        SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                        String? t = prefs.getString('token');
                                        if (t != null && t.isNotEmpty) {
                                          debugPrint("Token not null");
                                          Response res = await get(Uri.parse(
                                              '$url/savetoken?token=$t&&email=${user.email}'));
                                          if (res.statusCode == 200) {
                                            debugPrint("Success");
                                          } else {
                                            debugPrint("Error in saving token");
                                          }
                                        }
                                        prefs.setString("user", "faculty");
                                        await db.insertFaculty(Faculty.fromMap(
                                            jsonDecode(res.body)));
                                        Provider.of<UserProvider>(
                                                navigationKey.currentContext!,
                                                listen: false)
                                            .addFaculty(
                                                Faculty.fromJson(res.body));
                                      } else if (res.statusCode == 400) {
                                        debugPrint("Success");
                                        prefs.setString("user", "faculty");
                                        await db.insertFaculty(Faculty.fromMap(
                                            jsonDecode(res.body)));
                                        Provider.of<UserProvider>(
                                                navigationKey.currentContext!,
                                                listen: false)
                                            .addFaculty(Faculty(
                                          name: user.displayName ?? "",
                                          email: user.email,
                                          phone: "",
                                        ));
                                      } else {
                                        SnackBarGlobal.show(
                                            "Error occured while validating student");
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
                              await db.insertFaculty(Faculty(
                                  name: "Admin",
                                  email: user.email,
                                  phone: "Admin"));
                              prefs.setString("user", "admin");
                              Provider.of<UserProvider>(
                                      navigationKey.currentContext!,
                                      listen: false)
                                  .setFaculty();
                              Provider.of<UserProvider>(
                                      navigationKey.currentContext!,
                                      listen: false)
                                  .addFaculty(Faculty(
                                      name: "Admin",
                                      email: user.email,
                                      phone: "Admin"));
                              Provider.of<UserProvider>(
                                      navigationKey.currentContext!,
                                      listen: false)
                                  .setAdmin();
                            } else {
                              SnackBarGlobal.show(
                                  "Please continue with your college E-Mail ID");
                              await google.signOut();
                            }
                          } catch (e) {
                            debugPrint(e.toString());
                            SnackBarGlobal.show("Error occured while ");
                          }
                        }
                        if (mounted) {
                          setState(() {
                            isloading = false;
                          });
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              'assets/google.png', // Replace with your Google logo image
                              height: 50,
                              width: 50,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Text(
                            'CONTINUE WITH GOOGLE',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.045),
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
