import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:proctor/constants/auth_constants.dart';
import 'package:proctor/constants/color.dart';
import 'package:proctor/main.dart';
import 'package:proctor/pages/faculty_attendance.dart';
import 'package:proctor/pages/faculty_search_page.dart';
import 'package:proctor/pages/faculty_students.dart';
import 'package:proctor/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FHomePage extends StatefulWidget {
  const FHomePage({super.key});

  @override
  State<FHomePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<FHomePage> {
  bool isloading = false;
  bool issearch = false;
  String search = "";
  final _searchcontroller = TextEditingController();
  List<String> filter = ['Name', 'Register Number', 'Email', 'Phone'];
  String selectedFilter = 'Name';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: isloading
              ? null
              : const TabBar(
                  indicatorColor: Colors.white,
                  indicatorWeight: 2,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: [
                    Tab(
                      child: Text(
                        "Chats",
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
                ), // TabBar
          actions: [
            issearch
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 45,
                        width: MediaQuery.of(context).size.width * 0.9,
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
                          controller: _searchcontroller,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Search",
                            hintStyle: const TextStyle(color: Colors.white),
                            prefixIcon: issearch
                                ? IconButton(
                                    onPressed: () {
                                      setState(() {
                                        issearch = false;
                                        _searchcontroller.text = "";
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
            isloading || issearch
                ? const SizedBox()
                : IconButton(
                    onPressed: () {
                      setState(() {
                        issearch = true;
                      });
                      //Navigator.push(context, MaterialPageRoute(builder: (_)=> const NotifyPage()));
                    },
                    icon: const Icon(Icons.search,
                        size: 27, color: Colors.white)),
            const SizedBox(
              width: 10,
            ),
            isloading || issearch
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
                                          await SharedPreferences.getInstance();
                                      String? t = prefs.getString('token');
                                      if (t != null && t.isNotEmpty) {
                                        Response res = await get(Uri.parse(
                                            '$url/removetoken?token=$t'));
                                        if (res.statusCode == 200) {
                                          debugPrint("Success");
                                        } else {
                                          debugPrint("Error in removing token");
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
                      color: Colors.white
                    )),
            const SizedBox(
              width: 15,
            )
          ],
          title: Text(
              'Hi, ${Provider.of<UserProvider>(context).faculty.name} !',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: kPrimaryColor,
        ), // AppBar
        body: isloading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : TabBarView(
                children: [
                  FacultyStudentPage(
                    searchcontroller: _searchcontroller,
                    search: search,
                    selectedFilter: selectedFilter,
                  ),
                  const StaffHomePage()
                ],
              ), // TabBarView
      ), // Scaffold
    );
  }
}
