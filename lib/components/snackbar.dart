import 'package:flutter/material.dart';

showSnackBar(context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: const Color.fromARGB(255, 0, 3, 30),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 30,
      content: Text(
        content,
        style: const TextStyle(color: Colors.white),
      )));
}
