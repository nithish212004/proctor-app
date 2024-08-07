import 'package:flutter/material.dart';
import 'package:proctor/constants/color.dart';
import 'package:proctor/pages/academic_info.dart';
import 'package:proctor/pages/personal_info.dart';

class ProfilePage extends StatefulWidget{
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context){
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              indicatorColor:Colors.white,
              indicatorWeight: 8,

              tabs: [
                Tab(icon: Icon(Icons.photo_camera_front_sharp, color: Colors.white), child: Text("Personal Information", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),),),
                Tab(icon: Icon(Icons.class_rounded, color: Colors.white), child: Text("Academic Information", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),),),
              ],
            ), // TabBar
            leading: Padding(
              padding: const EdgeInsets.only(left: 15),
              child: IconButton(onPressed: (){
              Navigator.of(context).pop();
                      }, icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20,)),
            ),
            title: const Text('Profile',style: TextStyle(color: Colors.white)
            ),
            backgroundColor: kPrimaryColor,
          ), // AppBar
          body: const TabBarView(
          
            children: [
              PersonalPage(),
              AcademicPage()
            ],
          ), // TabBarView
        ), // Scaffold
      );
  }
}