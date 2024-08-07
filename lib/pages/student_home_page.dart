import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:proctor/constants/color.dart';
import 'package:proctor/main.dart';
import 'package:proctor/pages/faculty_attendance.dart';
import 'package:proctor/pages/student_individual_chat_page.dart';
import 'package:proctor/providers/user_provider.dart';
import 'package:proctor/constants/auth_constants.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isloading = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            title: Text(
                'Hi, ${Provider.of<UserProvider>(context).student.name} !',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            bottom: isloading
                ? null
                : const TabBar(
                    indicatorColor: Colors.white,
                    indicatorWeight: 2,
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: [
                      Tab(
                        child: Text(
                          "Proctor",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                      ),
                      Tab(
                        child: Text(
                          "Classes",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                      ),
                    ],
                  ),
            actions: [
              isloading
                  ? const SizedBox()
                  : IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (_) {
                              return AlertDialog(
                                title: const Text("Logging Out"),
                                content: const Text(
                                    "Your chats data will be deleted. Are you sure ?"),
                                actions: [
                                  ElevatedButton(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        setState(() {
                                          isloading = true;
                                        });
                                        await google.signOut();
                                        SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                        String? t = prefs.getString('token');
                                        if (t != null && t.isNotEmpty) {
                                          Response res = await get(Uri.parse(
                                              '$url/removetoken?token=$t'));
                                          if (res.statusCode == 200) {
                                            debugPrint("Success");
                                          } else {
                                            debugPrint(
                                                "Error in removing token");
                                          }
                                        }
                                        setState(() {
                                          isloading = false;
                                        });
                                        Provider.of<UserProvider>(
                                                navigationKey.currentContext!,
                                                listen: false)
                                            .removeStudent();
                                      },
                                      child: const Text("Yes")),
                                  ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text("No"))
                                ],
                              );
                            });
                      },
                      icon: const Icon(
                        Icons.login_rounded,
                        size: 30,
                      )),
              const SizedBox(
                width: 15,
              )
            ],
          ),
          body: isloading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : TabBarView(
                  children: [
                    IndividualPage(
                        faculty:
                            Provider.of<UserProvider>(context, listen: false)
                                .student
                                .faculty),
                    const StaffHomePage()
                  ],
                )),
    );
  }
}
