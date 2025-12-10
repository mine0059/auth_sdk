import 'package:flutter/material.dart';

class EmailTextfield extends StatelessWidget {
  const EmailTextfield({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        hintText: "Email",
      ),
    );
  }
}
