import 'dart:convert';

class Message{
  String sender;
  String receiver;
  String message;
  String time;
  Message({required this.message, required this.sender, required this.time, required this.receiver});

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'sender': sender,
      'time': time,
    };
  }

      factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
        message: map['message'],
        sender: map['sender'],
        time: map['time'],
        receiver: map['receiver']);
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) => Message.fromMap(json.decode(source));

}