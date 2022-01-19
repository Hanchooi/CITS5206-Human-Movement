import 'package:flutter/material.dart';

Widget firstStep() {
  return Text(
    "1: Create account and fill the information required. Click link below",
    style: TextStyle(
        fontSize: 20,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.bold
    ),);
}

Widget secondStep() {
  return Text(
    "2: Please Open Map page, Long press the map and adding locations you frequently access. (Note : Please change setting to 'Allow app to access location all the time'.) Click here",
    style: TextStyle(
        fontSize: 20,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.bold
    ),);
}