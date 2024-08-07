import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:proctor/constants/auth_constants.dart';
import 'package:proctor/constants/color.dart';
import 'package:proctor/main.dart';
import 'package:proctor/models/faculty.dart';
import 'package:proctor/pages/faculty_add_page.dart';
import 'package:proctor/providers/user_provider.dart';
import 'package:proctor/widgets/fcard.dart';
import 'package:provider/provider.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _FacultyPageState();
}

class _FacultyPageState extends State<AdminPage> {
  bool isloading = true;
  String search = "";
  final _searchcontroller = TextEditingController();
  List<String> filter = ['Name', 'Email', 'Phone'];
  String selectedFilter = 'Name';

  Future<List<Faculty>> fetchFaculties() async {
    debugPrint("Try");
    List<Faculty> l = [];
    try{
      debugPrint("Called");
    Response res = await get(Uri.parse('$url/faculties'));
    debugPrint(res.statusCode.toString());
    if(res.statusCode == 200){
      debugPrint(jsonDecode(res.body).toString());
      List t = jsonDecode(res.body);
      for(int i=0; i<t.length; i++){
        l.add(Faculty.fromMap(t[i]));
      }
    }
    }catch(e){
      debugPrint(e.toString());
      SnackBarGlobal.show("Error Occured while fetching students list");
    }
    debugPrint(l.toString());
    return l;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: () async {
            setState(() {
              isloading  = true;
            });
            await google.signOut();
            setState(() {
              isloading  = false;
            });
            Provider.of<UserProvider>(navigationKey.currentContext!, listen: false).removeStudent();
          }, icon: const Icon(Icons.login_rounded))
        ],
      ),
      body: Column(
            children: [
              const SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: TextFormField(
                          textInputAction: TextInputAction.done,
                          textDirection: TextDirection.ltr,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onChanged: (val){
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
                          decoration: const InputDecoration(
                            labelText: "Search",
                            
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                            ),
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.05,),
                Container(
  decoration: BoxDecoration(
    color: kPrimaryLight,
    borderRadius: BorderRadius.circular(10),
  ),
  child: DropdownButton(
    padding: const EdgeInsets.only(right: 15),
    icon: const Icon(Icons.arrow_drop_down_circle_sharp, color: Colors.white,),
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
              padding: const EdgeInsets.all(8.0),
              child: Text(e, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
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
),
            SizedBox(width: MediaQuery.of(context).size.width * 0.05,),

IconButton(onPressed: (){
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const FAddPage()));
}, icon: const Icon(Icons.add_box_rounded, color: kPrimaryColor, size: 45,))
              ],),
          const SizedBox(
            height: 10
          ),
          Expanded(
                flex: 1,
                child: FutureBuilder<List<Faculty>>(
                                  future: fetchFaculties(),
                                  builder: (context, snapshot){
                                    if (snapshot.connectionState == ConnectionState.waiting){
                                      const Center(child: CircularProgressIndicator());
                                    }else if (snapshot.hasError) {
                debugPrint(snapshot.error.toString());
                SnackBarGlobal.show("Error while fetching students");
                                        }
                                        if(snapshot.data != null && snapshot.data!.isNotEmpty){
                debugPrint(snapshot.data!.toString());
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: snapshot.data!.where((s)
                            {if(selectedFilter == 'Name'){
                              return s.name.toLowerCase().contains(search.toLowerCase());
                            }else if(selectedFilter == 'Email'){
                              return s.email.toLowerCase().contains(search.toLowerCase());
                            }else if(selectedFilter == 'Phone'){
                              return s.phone.toLowerCase().contains(search.toLowerCase());
                            }else{
                              return true;
                            }
                          }
                        ).isEmpty
                      ? const Center(child: Text("No Faculty found !", style:  TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w500
                      ),))
                      : ListView(
                        //return Card(child: IdCard(name: snapshot.data![index].name, regnum: snapshot.data![index].regnum, pname: snapshot.data![index].faculty.name, pphone: snapshot.data![index].faculty.phone, pemail: snapshot.data![index].faculty.email));
                        children: snapshot.data!.where((s)
                            {if(selectedFilter == 'Name'){
                              return s.name.toLowerCase().contains(search.toLowerCase());
                            }else if(selectedFilter == 'Email'){
                              return s.email.toLowerCase().contains(search.toLowerCase());
                            }else if(selectedFilter == 'Phone'){
                              return s.phone.toLowerCase().contains(search.toLowerCase());
                            }else{
                              return true;
                            }
                          }
                        ).map<Widget>((e){
                          return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FIdCard(name: e.name, phone: e.phone, email: e.email,),
                        );
                      }).toList()
                      ),
                  );
                                      }else if(snapshot.data == null){
                                            return const Center(child: CircularProgressIndicator());
                                        }
                                        else{
                                          return const Center(child: Text("No Faculty found"));
                                        }
                                        },),
              )
                            ],
                          ),
       
    );
  }
}