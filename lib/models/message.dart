import 'dart:convert';

class Message {
  final String title;
  final String message;
  final String time;

  Message({required this.title, required this.message, required this.time});


  Map<String, dynamic> toMap() {
    return {
      'title': title, 
      'message': message,
      'time': time
    };
  }

      factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
        title: map['title'],
        message: map['message'],
        time: map['time']
    );
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) => Message.fromMap(json.decode(source));
}