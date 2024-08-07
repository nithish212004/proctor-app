import 'package:flutter/material.dart';
import 'package:proctor/models/student.dart';
import 'package:proctor/pages/individual_chat_page.dart';

class CustomCard extends StatefulWidget {
  final Student student;
  final bool selected;
  const CustomCard({super.key, required this.student, required this.selected});

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
           minVerticalPadding: 23,
          tileColor: !widget.selected 
              ? Colors.white
              : const Color.fromARGB(255, 154, 210, 255),
          leading: CircleAvatar(
            radius: 27,
            backgroundColor: Colors.grey,
            foregroundColor: const Color.fromRGBO(255, 255, 255, 1),
            child: CircleAvatar(
              radius: MediaQuery.of(context).size.width * 0.09,
              backgroundColor: Colors.grey[300],
              child: !widget.selected 
              ?const Icon(
                      Icons.person,
                      size: 44,
                      color: Colors.white,
                    )
                  : const Icon(
                      Icons.check,
                      size: 32,
                      color: Colors.blue,
                    )
                  
            ),
          ),
          title: Text(
            widget.student.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Row(
            children: [
              Text(
                widget.student.regnum,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          
        ),
      ],
    );
  }
}
