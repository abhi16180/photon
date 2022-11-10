import 'package:flutter/material.dart';

showSnackBar(context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.blueGrey.shade900,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 30,
      content: Text(
        content,
        style: const TextStyle(
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    ),
  );
}
