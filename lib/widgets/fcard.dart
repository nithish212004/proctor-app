import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:proctor/constants/auth_constants.dart';
import 'package:proctor/constants/color.dart';
import 'package:proctor/main.dart';
import 'package:proctor/models/faculty.dart';
import 'package:proctor/pages/faculty_register_page.dart';
import 'package:proctor/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class FIdCard extends StatefulWidget { 
  final String name;
  final String phone;
  final String email;
  const FIdCard(
      {super.key,
      required this.name,
      required this.email,
      required this.phone});

  @override
  State<FIdCard> createState() => _SIdCardState();
}

class _SIdCardState extends State<FIdCard> {
  final _smsgController = TextEditingController();
  bool issendingF = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: const BoxDecoration(
                  color: kPrimaryLight,
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.person_pin_rounded,
                          color: Colors.white, size: 27),
                      const SizedBox(
                        width: 12,
                      ),
                      Text(
                        widget.name,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 19,
                          color: Colors.white,
                          letterSpacing: 1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () async {
                          if (widget.phone.isNotEmpty) {
                            try {
                              if (await canLaunchUrl(
                                  Uri.parse("tel:${widget.phone}"))) {
                                await launchUrl(
                                    Uri.parse("tel:${widget.phone}"));
                              } else {
                                throw 'Could not launch';
                              }
                            } catch (e) {
                              debugPrint(e.toString());
                              SnackBarGlobal.show("Try Again later");
                            }
                          } else {
                            SnackBarGlobal.show("Phone number not available");
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(2, 1, 1, 3),
                          width: MediaQuery.of(context).size.width * 0.1,
                          height: MediaQuery.of(context).size.width * 0.1,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.shade400,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.phone,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.1,
                      ),
                      InkWell(
                        onTap: () async {
                          try {
                            if (await canLaunchUrl(
                                Uri.parse("tel:${widget.phone}"))) {
                              launchUrl(Uri.parse("mailto:${widget.email}"));
                            } else {
                              throw 'Could not launch';
                            }
                          } catch (e) {
                            debugPrint(e.toString());
                            SnackBarGlobal.show("Try Again later");
                          }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.1,
                          height: MediaQuery.of(context).size.width * 0.1,
                          decoration: BoxDecoration(
                            color: Colors.redAccent.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.mail,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.1,
                      ),
                      InkWell(
                        onTap: () async {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => FRegisterPage(
                                        readOnly: false,
                                        faculty: Faculty(
                                            name: widget.name,
                                            email: widget.email,
                                            phone: widget.phone),
                                      )));
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.1,
                          height: MediaQuery.of(context).size.width * 0.1,
                          decoration: const BoxDecoration(
                            color: Colors.black26,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 1.5,
                        child: TextFormField(
                          maxLines: null,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 17,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          controller: _smsgController,
                          cursorColor: Colors.white,
                          decoration: const InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors
                                    .white, // Set your desired border color here
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors
                                    .white, // Set your desired border color here
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            labelText: "Enter your message",
                            labelStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      issendingF
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : InkWell(
                              onTap: () async {
                                if (_smsgController.text.isNotEmpty) {
                                  setState(() {
                                    issendingF = true;
                                  });
                                  Map data = {
                                    'sname': Provider.of<UserProvider>(context,
                                            listen: false)
                                        .faculty
                                        .name,
                                    'semail': "admin",
                                    'remail': widget.email,
                                    'message': _smsgController.text
                                  };
                                  try {
                                    Response res = await post(
                                        Uri.parse('$url/sendmessage'),
                                        headers: <String, String>{
                                          'Content-Type':
                                              'application/json; charset=UTF-8',
                                        },
                                        body: jsonEncode(data));
                                    debugPrint("hello1");
                                    if (res.statusCode == 200) {
                                      setState(() {
                                        _smsgController.text = "";
                                      });
                                      SnackBarGlobal.show("Message sent");
                                    } else {
                                      SnackBarGlobal.show(
                                          "Error while sending message");
                                    }
                                  } catch (e) {
                                    debugPrint(e.toString());
                                    SnackBarGlobal.show(
                                        "Error while sending message");
                                  }
                                  setState(() {
                                    issendingF = false;
                                  });
                                }
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.1,
                                height: MediaQuery.of(context).size.width * 0.1,
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.shade400,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            )
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
