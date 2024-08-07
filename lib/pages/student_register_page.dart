import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:proctor/constants/auth_constants.dart';
import 'package:proctor/constants/color.dart';
import 'package:proctor/main.dart';
import 'package:proctor/models/faculty.dart';
import 'package:proctor/models/student.dart';
import 'package:proctor/providers/user_provider.dart';
import 'package:proctor/services/db.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool isloading = false;
  bool ispageloading = true;
  String proctor = "";

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _regnumController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isPhone(String input) =>
      RegExp(r'^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$')
          .hasMatch(input);

  bool isRegNum(String s) => RegExp(
         r'^\d{2}[A-Za-z]{1,3}\d{3}$')
      .hasMatch(s);

  bool isName(String input) => RegExp(r'^[a-zA-Z ]+$').hasMatch(input);

  final List<Faculty> faculties = [];

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      init();
    });
  }

  void init() async {
    _nameController.text = Provider.of<UserProvider>(context, listen: false).student.name;
      _emailController.text = Provider.of<UserProvider>(context, listen: false).student.email;
      try{
     Response res = await get(Uri.parse('$url/faculties'));
     if(res.statusCode == 200){
        List lt = jsonDecode(res.body);
        for(int i=0; i<lt.length; i++){
          faculties.add(Faculty.fromMap(lt[i]));
        }
     }else{
        SnackBarGlobal.show("Error occured while fetching proctor names");
     }
     }catch(e){
      debugPrint(e.toString());
     }
      setState(() {
        ispageloading = false; 
      });
  }

  @override
  Widget build(BuildContext context) {
    return ispageloading
      ? Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_pin_rounded, size: 165, color: kPrimaryColor,),
              SizedBox(height: MediaQuery.of(context).size.height * 0.15,),
              SizedBox(
                width: MediaQuery.of(context).size.width*0.8,
                child: const LinearProgressIndicator(
                  minHeight: 10,
                  color: kPrimaryColor,
                ),
              )
            ],
          ),
        ),
      )
      : Scaffold(
        appBar: AppBar(
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
                    const SizedBox(height: 30),
                    CarouselSlider(

              items: faculties.map((e) {
                return Center(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.all(Radius.circular(25))
                    ),
                    
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 50.0,
                        foregroundImage: NetworkImage("https://t4.ftcdn.net/jpg/01/97/15/87/360_F_197158744_1NBB1dEAHV2j9xETSUClYqZo7SEadToU.jpg"),
                      ),
                      const SizedBox(height: 10,),
                      Text(e.name, style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold
                      ),),
                      const SizedBox(height: 10,),
                      MaterialButton(
                        color: proctor == e.email 
                          ? Colors.green
                          : Colors.redAccent,
                        onPressed: (){
                          if(isloading == false){
                            setState(() {
                              proctor = e.email;
                            });
                          }
                      }, child: Text(proctor == e.email ? "Selected" : "Select",
                        style: const TextStyle(color: Colors.white, fontSize: 16,
                        fontWeight: FontWeight.bold),
                      ))
                    ],
                  ),
                                ),
                );}).toList(),
              options: CarouselOptions( 
                height: MediaQuery.of(context).size.height*0.3,// Customize the height of the carousel
                autoPlay: false, // Enable auto-play
                enlargeCenterPage: true, // Increase the size of the center item
                enableInfiniteScroll: true, // Enable infinite scroll
                onPageChanged: (index, reason) {
                  
                },
              ),
            ),
                    const SizedBox(height: 40),
                    SizedBox(
                      
                      width: MediaQuery.of(context).size.width / 1.3,
                      child: TextFormField(
                        enabled: !isloading,
                        textInputAction: TextInputAction.done,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "Please enter your name";
                          } else if (!isName(val)) {
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
                        readOnly: true,
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
                        textInputAction: TextInputAction.next,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "Please enter your phone number";
                          } else if (!isPhone(val)) {
                            return "Please enter a valid phone number";
                          }
                          return null;
                        },
                        keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: false),
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
                    const SizedBox(height: 20,),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 1.3,
                      child: TextFormField(
                        enabled: !isloading,
                        textInputAction: TextInputAction.done,
                        textCapitalization: TextCapitalization.characters,
                        
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "Please enter your register number";
                          } else if (!isRegNum(val)) {
                            return "Please enter a valid register number";
                          }
                          return null;
                        },
                        keyboardType: TextInputType.text,
                        controller: _regnumController,
                        decoration: const InputDecoration(
                          labelText: "Register Number",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          prefixIcon: Icon(Icons.numbers_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    isloading
                        ? SizedBox(
                            width: kIsWeb
                                ? MediaQuery.of(context).size.width / 3
                                : MediaQuery.of(context).size.width / 2,
                            child: const LinearProgressIndicator())
                        : InkWell(
                            onTap: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  isloading = true;
                                });
                                if(proctor != ""){
                                  debugPrint("Success");
                                  try{
                                    debugPrint({
                                    'name': _nameController.text,
                                    'email': _emailController.text, 
                                    'phone': _phoneController.text,
                                    'regnum': _regnumController.text,
                                    'proctor': proctor
                                  }.toString());
                                  Map<String, dynamic> data = {
                                    'name': _nameController.text,
                                    'email': _emailController.text, 
                                    'phone': _phoneController.text,
                                    'regnum': _regnumController.text,
                                    'proctor': proctor
                                  };
                                  Response res = await post(Uri.parse('$url/addStudent'), 
                                  headers: <String, String>{
                                    'Content-Type': 'application/json; charset=UTF-8',
                                  },
                                  body: jsonEncode(data));
                                  debugPrint("hello1");
                                  if(res.statusCode == 200){
                                    debugPrint("hello ${jsonDecode(res.body)}");
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    String? t = prefs.getString('token');
                                    if(t != null && t.isNotEmpty){
                                      Response res = await get(
                                        Uri.parse('$url/savetoken?token=$t&&email=${_emailController.text}')
                                      );
                                      if(res.statusCode == 200){
                                        debugPrint("Success");
                                      }else{
                                        debugPrint("Error in saving token");
                                      }
                                    }
                                    DB().insertStudent(Student.fromMap(jsonDecode(res.body)));
                                    Provider.of<UserProvider>(navigationKey.currentContext!, listen: false).addStudent(Student.fromMap(jsonDecode(res.body)));
                                  }else{
                                    SnackBarGlobal.show("Error while registering user");
                                  }
                                  }catch(e){
                                    debugPrint(e.toString());
                                    SnackBarGlobal.show("Error while registering user");
                                  }
                                }else{
                                    SnackBarGlobal.show("Please select your proctor");
                                }
                                setState(() {
                                  isloading = false;
                                });
                              }
                            },
                            child: Container(
                              width: kIsWeb
                                  ? MediaQuery.of(context).size.width / 2
                                  : MediaQuery.of(context).size.width / 2,
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