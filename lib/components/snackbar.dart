import 'package:flutter/material.dart';

showSnackBar(context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(content)));
}
