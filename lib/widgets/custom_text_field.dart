import 'package:flutter/material.dart';
import 'package:messenger/controllers/settings.dart';

Widget createCustomTextField({
  required TextEditingController controller, 
  required String hintLabel,
  void Function()? onEditingComplete,
  bool isObscure = false,
}) {
  final settings = Settings.instance;

  return Container(
    padding: .only(right: 8, left: 8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      border: BoxBorder.all(width: 1, color: settings.innerColor),
    ),
    child: TextField(
      obscureText: isObscure,
      cursorColor: settings.innerColor,
      controller: controller,
      style: TextStyle(
        color: settings.innerColor, 
      ),
      onEditingComplete: onEditingComplete,
      decoration: InputDecoration(
        hintText: hintLabel,
        hintStyle: TextStyle(
          fontFamily: settings.fontFamily, 
          color: settings.middleColor,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
        ),
        floatingLabelBehavior: .never,
        floatingLabelStyle: TextStyle(fontSize: 0)
      ),
    ),
  );
}