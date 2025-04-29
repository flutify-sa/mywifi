import 'package:flutter/material.dart';

class StatusTextField extends StatelessWidget {
  final String text;
  final String label;

  const StatusTextField({
    super.key,
    required this.text,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      controller: TextEditingController(text: text),
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: label,
      ),
    );
  }
}

class HeaderText extends StatelessWidget {
  final String text;

  const HeaderText({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }
}