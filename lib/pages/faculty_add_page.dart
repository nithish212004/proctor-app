import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:proctor/constants/auth_constants.dart';
import 'package:proctor/constants/color.dart';
import 'package:proctor/main.dart';
import 'package:proctor/pages/splash_page.dart';
import 'package:proctor/providers/user_provider.dart';
import 'package:provider/provider.dart';

class FAddPage extends StatefulWidget {
  const FAddPage({super.key});

  @override
  State<FAddPage> createState() => _FRegisterPageState();
}

class _FRegisterPageState extends State<FAddPage> {
  bool isloading = false;
  String oemail = "";

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isPhone(String input) =>
      RegExp(r'^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$')
          .hasMatch(input);

  bool isRegNum(String s) => RegExp(
         r'^\d{2}[A-Za-z]{1,3}\d{3}$')
      .hasMatch(s);

  bool isName(String input) => RegExp(r'^[a-zA-Z .]+$').hasMatch(input);

  bool isEmail(String s) => RegExp(
      r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
      .hasMatch(s);

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(onPressed: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> const SplashPage()));
          }, icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white,))
      ,
          actions: [
          isloading
              ? const SizedBox()
              : IconButton(onPressed: () async {
            setState(() {
              isloading  = true;
            });
            await google.signOut();
            
            setState(() {
              isloading  = false;
            });
            Provider.of<UserProvider>(navigationKey.currentContext!, listen: false).removeStudent();
          }, icon: const Icon(Icons.login_rounded)),
          const SizedBox(
            width: 20,
          ),
        ],
          title: const Text(
            "REGISTRATION",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Form(
            key: _formKey,
            child: ScrollConfiguration(
              behavior:
                  ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                        const Icon(
                          Icons.three_p_rounded,
                          size: 100,
                          color: kPrimaryColor,
                        ),
                        const SizedBox(height: 50),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 1.3,
                      child: TextFormField(
                        enabled: !isloading,
                        textInputAction: TextInputAction.done,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "Please enter your name";
                          } else if (!isName(val)){
                            return "Please enter a valid name";
                          }
                          return null;
                        },
                        keyboardType: TextInputType.text,
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: "Name",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          prefixIcon: Icon(Icons.align_horizontal_left),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20,),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 1.3,
                      child: TextFormField( 
                        enabled: !isloading,
                        textInputAction: TextInputAction.next,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        autofocus: false,
                        validator: (val) {
                          if (val == null || val.isEmpty){
                            return "Please enter the email";
                          } else if (!isEmail(val)  || !val.contains("tce.edu")) {
                            return "Please enter a valid email";
                          }
                          return null;
                        },
                        keyboardType: TextInputType.text,
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          prefixIcon: Icon(Icons.lock),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20,),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 1.3,
                      child: TextFormField(
                        enabled: !isloading,
                        textInputAction: TextInputAction.done,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (val) {
                          if (val == null || val.isEmpty){
                            return "Please enter your phone number";
                          } else if (!isPhone(val)) {
                            return "Please enter a valid phone number";
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: "Phone Number",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          prefixIcon: Icon(Icons.phone),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    isloading
                        ? SizedBox(
                            width: kIsWeb
                                ? MediaQuery.of(context).size.width / 3
                                : MediaQuery.of(context).size.width / 2,
                            child: const LinearProgressIndicator())
                        : InkWell(
                            onTap: () async {
                              final navigator = Navigator.of(context);
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  isloading = true;
                                });
                                  debugPrint("Success");
                                  try{
                                    debugPrint({
                                    'name': _nameController.text,
                                    'email': _emailController.text, 
                                    'phone': _phoneController.text,
                                  }.toString());
                                  Map<String, dynamic> data = {
                                    'name': _nameController.text,
                                    'email': _emailController.text, 
                                    'phone': _phoneController.text,
                                  };
                                  Response res = await post(Uri.parse('$url/addnewFaculty'), 
                                  headers: <String, String>{
                                    'Content-Type': 'application/json; charset=UTF-8',
                                  },
                                  body: jsonEncode(data));
                                  debugPrint("hello1");
                                  if(res.statusCode == 200){
                                    debugPrint("hello ${jsonDecode(res.body)}");
                                    
                                      SnackBarGlobal.show("Profile Created");
                                      navigator.pushReplacement(MaterialPageRoute(builder: (_)=> const SplashPage()));
                                  }else{
                                    SnackBarGlobal.show("Error while registering user");
                                  }
                                  }catch(e){
                                    debugPrint(e.toString());
                                    SnackBarGlobal.show("Error while registering user");
                                  }
                                
                                setState(() {
                                  isloading = false;
                                });
                              }
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width / 2,
                              height: 50,
                              decoration: BoxDecoration(
                                color: kPrimaryColor,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Center(
                                child: Text(
                                  "Submit",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(
                      height: 40,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}