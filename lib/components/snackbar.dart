import 'package:flutter/material.dart';

showSnackBar(context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: const Color.fromARGB(
          205, 117, 255, 122),
      content: Text(
        content,
        style: const TextStyle(
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    ),
  );
}
