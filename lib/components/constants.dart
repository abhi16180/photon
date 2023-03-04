import 'package:flutter/material.dart';

const BoxDecoration appBarGradient = BoxDecoration(
  gradient: LinearGradient(
    colors: [
      Colors.blueAccent,
      Colors.lightBlueAccent,
      // Colors.lightBlueAccent.shade200,
    ],
  ),
);

const InputDecoration inputDecoration = InputDecoration(
  border: UnderlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(15),
    ),
  ),
  focusedBorder: UnderlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(15),
    ),
  ),
  enabledBorder: UnderlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(15),
    ),
  ),
);
