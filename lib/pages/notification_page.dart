import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:proctor/constants/auth_constants.dart';
import 'package:proctor/constants/color.dart';
import 'package:proctor/main.dart';
import 'package:proctor/models/message.dart';
import 'package:proctor/providers/user_provider.dart';
import 'package:provider/provider.dart';

class NotifyPage extends StatefulWidget {
  const NotifyPage({super.key});

  @override
  State<NotifyPage> createState() => _NotifyPageState();
}

class _NotifyPageState extends State<NotifyPage> with SingleTickerProviderStateMixin {
  late AnimationController _transController;

  Future<List<Message>> getMessages() async {
    List<Message> l = [];
    String semail = Provider.of<UserProvider>(context, listen: false).student.email;
    String femail = Provider.of<UserProvider>(context, listen: false).faculty.email;
  try{
    Response res = await get(Uri.parse('$url/getmessages?email=${semail.isEmpty ? femail : semail}'));
    if(res.statusCode == 200){
      debugPrint(jsonDecode(res.body).toString());
      List t = jsonDecode(res.body);
      for(int i=0; i<t.length; i++){
        l.add(Message.fromMap(t[i]));
      }
    }else{
      SnackBarGlobal.show("Error occured while fetching messages");
    }
  }catch(e){
    debugPrint(e.toString());
    SnackBarGlobal.show("Error occured while fetching messages");
  }
    return l;
  }

  @override
  void initState() {
    super.initState();
    _transController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _transController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //var userprovider = Provider.of<UserProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 26.0,
          ),
        ),
        title: const Text(
          "Messages",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
            padding: const EdgeInsets.all(10),
            onPressed: () {
              setState(() {});
            },
            icon: const Icon(
              Icons.refresh,
              size: 26.0,
            ),
          ),
          
          const SizedBox(
            width: 20,
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: FutureBuilder<List<Message>>(
                  future: getMessages(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      const Center(child: CircularProgressIndicator());
                    } else if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                      return Center(
                        child: ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(10, 0, 5, 0),
                                child: Card(
                                    child: InkWell(
                                      onTap: () {
                      showDialog(
                        
                        barrierDismissible: false,
                        context: navigationKey.currentContext!,
                        builder:(context) => AlertDialog(
                          
                          title: Text(snapshot.data![index].title, style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),),
                          content: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: kPrimaryColor),
                              borderRadius: BorderRadius.circular(15)
                            ),
                            child: ScrollConfiguration(
                                                      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Text(snapshot.data![index].message, style: TextStyle(color: Colors.grey[900], fontWeight: FontWeight.w500), maxLines: null,),
                                ),
                              ),
                            )),
                          actions: [
                            ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                        "Close",
                        style: TextStyle(
                            color: Colors.grey[900],
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0)),
                  ),
                          ],
                        ));
                      ScaffoldMessenger.of(navigationKey.currentContext!)
                          .hideCurrentMaterialBanner();
                    },
                                      child: MaterialBanner(
                                              actions: const [SizedBox()],
                                              leading: const Icon(
                                                Icons.notifications,
                                                color: Colors.yellow,
                                              ),
                                              content: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [
                                                  Expanded(
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                snapshot.data![index].title,
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                                style: const TextStyle(
                                                                  color: Colors.yellow,
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 16.0,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 20,
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(height: 8.0),
                                                          Text(
                                                                snapshot.data![index].message, 
                                                                  maxLines: 2,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                                                                ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10,),
                                                  Text(snapshot.data![index].time, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),)
                                                ],
                                              ),
                                              backgroundColor: kPrimaryLight,
                                            ),
                                    )),
                              );
                            }),
                      );
                    } else if (snapshot.hasError) {
                      debugPrint(snapshot.error.toString());  
                      SnackBarGlobal.show("Error while fetching messages");
                    } else if (snapshot.data != null && snapshot.data!.isEmpty) {
                      return const Center(child: Text("No Messages yet"));
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
