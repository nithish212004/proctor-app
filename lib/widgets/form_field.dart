import 'package:flutter/material.dart';

class CustomFormField extends StatefulWidget {
  final bool isloading;
  final TextInputType textInputType;
  final String? Function(String?) validator;
  final TextInputAction textInputAction;
  final String label;
  final TextEditingController controller;
  final IconData icon;
  const CustomFormField({super.key, required this.isloading, required this.textInputType, required this.validator, required this.textInputAction, required this.label, required this.controller, required this.icon});

  @override
  State<CustomFormField> createState() => _FormFieldState();
}

class _FormFieldState extends State<CustomFormField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: TextFormField(
          enabled: !widget.isloading,
          textInputAction: widget.textInputAction,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: widget.validator,
          keyboardType: widget.textInputType,
          controller: widget.controller,
          decoration: InputDecoration(
            labelText: widget.label,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            prefixIcon: Icon(widget.icon),
          ),
        ),
      ),
    );
  }
}