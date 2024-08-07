import 'package:proctor/constants/auth_constants.dart';
import 'package:proctor/main.dart';
import 'package:proctor/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:proctor/models/student.dart';
import 'package:proctor/providers/user_provider.dart';
import 'package:proctor/services/db.dart';
import 'package:proctor/widgets/own_message.dart';
import 'package:proctor/widgets/reply_card.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/color.dart';

class IndividualPage extends StatefulWidget {
  final Student student;
  const IndividualPage({super.key, required this.student});

  @override
  State<IndividualPage> createState() => _IndividualPageState();
}

class _IndividualPageState extends State<IndividualPage> {
  bool show = false;
  FocusNode focusNode = FocusNode();
  bool sendButton = false;
  List<Message> messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late Socket socket;
  @override
  void initState() {
    getMessages();
    super.initState();
    connect();
  }

  @override
  void dispose() {
    debugPrint("called");
    socket.close();
    super.dispose();
  }

  void getMessages() async {
    List<Message>? tempmessages = await DB().getMessage(widget.student.email,
        Provider.of<UserProvider>(context, listen: false).faculty.email);
    setState(() {
      messages = tempmessages ?? [];
    });
  }

  void connect() {
    // MessageModel messageModel = MessageModel(sourceId: widget.sourceChat.id.toString(),targetId: );
    socket = io(url, <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": true,
    });
    socket.connect();
    socket.emit("signin",
        Provider.of<UserProvider>(context, listen: false).faculty.email);
    socket.onConnect((data) {
      debugPrint("Connected");
    });

    socket.on("message", (msg) {
      try {
        debugPrint(msg["message"]);
        debugPrint("hello");
        setMessage(
            msg['sender'],
            Provider.of<UserProvider>(context, listen: false).faculty.email,
            msg["message"]);
      } catch (e) {
        debugPrint(e.toString());
      }
    });
    debugPrint(socket.connected.toString());
  }

  void sendMessage(String message, String sourceId, String targetId) {
    setMessage(Provider.of<UserProvider>(context, listen: false).faculty.email,
        widget.student.email, message);

    socket.emit("message",
        {"message": message, "sender": sourceId, "targetId": targetId});
  }

  void setMessage(String sender, String receiver, String message) {
    Message messageModel = Message(
        sender: sender,
        receiver: receiver,
        message: message,
        time: DateTime.now().toString());
    DB().insertMessage(messageModel);
    debugPrint(messages.toString());
    setState(() {
      messages.add(messageModel);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset("assets/whatsapp_Back.png",
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: AppBar(
              backgroundColor: kPrimaryColor,
              leadingWidth: 70,
              titleSpacing: 0,
              leading: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 24,
                  color: Colors.white,
                ),
              ),
              title: GestureDetector(
                onTap: () {
                  SnackBarGlobal.show("message");
                },
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 27,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(6),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.student.name,
                              style: const TextStyle(
                                  fontSize: 18.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            Text(
                              widget.student.regnum,
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.white),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                    icon: const Icon(
                      Icons.call,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      if (widget.student.phone.isNotEmpty) {
                        try {
                          if (await canLaunchUrl(
                              Uri.parse("tel:${widget.student.phone}"))) {
                            await launchUrl(
                                Uri.parse("tel:${widget.student.phone}"));
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
                    }),
                IconButton(
                    icon: const Icon(Icons.mail, color: Colors.white),
                    onPressed: () async {
                      try {
                        await launchUrl(
                            Uri.parse("mailto:${widget.student.email}"));
                      } catch (e) {
                        debugPrint(e.toString());
                        SnackBarGlobal.show("Try Again later");
                      }
                    }),
                const SizedBox(
                  width: 20,
                )
              ],
            ),
          ),
          body: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                const SizedBox(height: 15),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length + 1,
                    itemBuilder: (context, index) {
                      if (index == messages.length) {
                        return Container(
                          height: 70,
                        );
                      }
                      if (messages[index].sender ==
                          Provider.of<UserProvider>(context, listen: false)
                              .faculty
                              .email) {
                        return OwnMessageCard(
                          message: messages[index].message,
                          time: messages[index].time.substring(10, 16),
                        );
                      } else {
                        return ReplyCard(
                          message: messages[index].message,
                          time: messages[index].time.substring(10, 16),
                        );
                      }
                    },
                  ),
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 86,
                      child: Card(
                        margin: const EdgeInsets.only(
                            left: 2, right: 2, bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TextFormField(
                          controller: _controller,
                          focusNode: focusNode,
                          textAlignVertical: TextAlignVertical.center,
                          keyboardType: TextInputType.multiline,
                          maxLines: 5,
                          minLines: 1,
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              setState(() {
                                sendButton = true;
                              });
                            } else {
                              setState(() {
                                sendButton = false;
                              });
                            }
                          },
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Type a message",
                              hintStyle:
                                  const TextStyle(color: Colors.grey),
                              prefixIcon: const Icon(Icons.keyboard),
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.attach_file),
                                    onPressed: () {
                                      showModalBottomSheet(
                                          backgroundColor:
                                              Colors.transparent,
                                          context: context,
                                          builder: (builder) =>
                                              bottomSheet());
                                    },
                                  ),
                                ],
                              ),
                              contentPadding: const EdgeInsets.only(
                                  top: 10, bottom: 10)),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 8,
                        right: 2,
                        left: 2,
                      ),
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: kPrimaryLight,
                        child: IconButton(
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                          onPressed: () async {
                            if (sendButton) {
                              _scrollController.animateTo(
                                  _scrollController
                                      .position.maxScrollExtent,
                                  duration:
                                      const Duration(milliseconds: 300),
                                  curve: Curves.easeOut);
                              sendMessage(
                                  _controller.text,
                                  Provider.of<UserProvider>(context,
                                          listen: false)
                                      .faculty
                                      .email,
                                  widget.student.email);
                              await DB().getMessage(
                                  widget.student.email,
                                  Provider.of<UserProvider>(context,
                                          listen: false)
                                      .faculty
                                      .email);
                              _controller.clear();
                              setState(() {
                                sendButton = false;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomSheet() {
    return SizedBox(
      height: 278,
      width: MediaQuery.of(context).size.width,
      child: Card(
        margin: const EdgeInsets.all(18.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconCreation(
                      Icons.insert_drive_file, Colors.indigo, "Document"),
                  const SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.camera_alt, Colors.pink, "Camera"),
                  const SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.insert_photo, Colors.purple, "Gallery"),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconCreation(Icons.headset, Colors.orange, "Audio"),
                  const SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.location_pin, Colors.teal, "Location"),
                  const SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.person, Colors.blue, "Contact"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget iconCreation(IconData icons, Color color, String text) {
    return InkWell(
      onTap: () {},
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color,
            child: Icon(
              icons,
              size: 29,
              color: Colors.white,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              // fontWeight: FontWeight.w100,
            ),
          )
        ],
      ),
    );
  }
}
