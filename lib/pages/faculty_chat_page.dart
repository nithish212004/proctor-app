import 'package:flutter/material.dart';
import 'package:proctor/main.dart';
import 'package:proctor/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late Socket socketIO;
  List<List> messages = [];
  double height = 0, width = 0;
  TextEditingController textController = TextEditingController();
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    initSocket();
    super.initState();
  }

  initSocket() {
    try {
      socketIO = io("http://192.168.106.70:3000/", <String, dynamic>{
        'autoConnect': true,
        'transports': ['websocket'],
      });
      socketIO.connect();
      socketIO.onConnect((_) {
        debugPrint("Connection established");
      });

      socketIO
          .on(Provider.of<UserProvider>(context, listen: false).student.email,
              (data) {
        SnackBarGlobal.show(data.toString());
        debugPrint(data.toString());
        setState(() => messages.add([data.toString(), "received"]));
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 600),
          curve: Curves.ease,
        );
      });

      socketIO.onDisconnect((_) => debugPrint("connection Disconnection"));
      socketIO.onConnectError((err) => debugPrint(err.toString()));
      socketIO.onError((err) => debugPrint(err.toString()));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  sendMessage(String sender, String receiver, String msg) {
    Map messageMap = {'message': msg, 'senderId': sender, 'receiverId': sender};
    socketIO.emit('sendMessage', messageMap);
  }

  Widget buildSingleMessage(int index, String isSent) {
  return Container(
    alignment: isSent == 'sent' ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      padding: const EdgeInsets.all(20.0),
      margin: const EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
      decoration: BoxDecoration(
        color: isSent == 'sent' ? Colors.blue : Colors.deepPurple,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        messages[index][0],
        style: const TextStyle(color: Colors.white, fontSize: 15.0),
      ),
    ),
  );
}

  Widget buildMessageList() {
    return SizedBox(
      height: height * 0.8,
      width: width,
      child: ListView.builder(
        controller: scrollController,
        itemCount: messages.length,
        itemBuilder: (BuildContext context, int index) {
          return buildSingleMessage(index, messages[index][1]);
        },
      ),
    );
  }

  Widget buildChatInput() {
    return Container(
      width: width * 0.7,
      padding: const EdgeInsets.all(2.0),
      margin: const EdgeInsets.only(left: 40.0),
      child: TextField(
        decoration: const InputDecoration.collapsed(
          hintText: 'Send a message...',
        ),
        controller: textController,
      ),
    );
  }

  Widget buildSendButton() {
    return FloatingActionButton(
      backgroundColor: Colors.deepPurple,
      onPressed: () {
        //Check if the textfield has text or not
        if (textController.text.isNotEmpty) {
          //Send the message as JSON data to send_message event
          sendMessage(
              Provider.of<UserProvider>(context, listen: false).student.email,
              Provider.of<UserProvider>(context, listen: false)
                  .student
                  .faculty
                  .email,
              textController.text);
          //Add the message to the list
          setState(() => messages.add([textController.text, 'sent']));
          textController.text = '';
          //Scrolldown the list to show the latest message
          
        }
      },
      child: const Icon(
        Icons.send,
        size: 30,
      ),
    );
  }

  Widget buildInputArea() {
    return SizedBox(
      height: height * 0.1,
      width: width,
      child: Row(
        children: <Widget>[
          buildChatInput(),
          buildSendButton(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: (){
      }),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: height * 0.1),
            messages.isEmpty
            ? SizedBox(
              height: height * 0.8,
              width: width,
            )
            : buildMessageList(),
            buildInputArea(),
          ],
        ),
      ),
    );
  }
}
