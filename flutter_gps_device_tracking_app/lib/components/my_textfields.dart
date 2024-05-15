import 'package:flutter/material.dart';

TextFormField textFormEmail({required var mode, required var controller}) {
  return TextFormField(
    autovalidateMode: mode,
    decoration: const InputDecoration(
      hintText: "Email",
    ),
    keyboardType: TextInputType.emailAddress,
    textInputAction: TextInputAction.next,
    controller: controller,
    validator: (value) {
      if (validateEmail(value.toString())) {
      } else {
        mode = AutovalidateMode.onUserInteraction;
        return "Please enter correct email type";
      }
      return null;
    },
  );
}

TextFormField textFormPassword({
  required var mode,
  required var controller,
}) {
  return TextFormField(
    decoration: const InputDecoration(
      hintText: "Password",
    ),
    obscureText: true,
    textInputAction: TextInputAction.done,
    controller: controller,
    validator: (value) {
      if (value!.length <= 5) {
        mode = AutovalidateMode.onUserInteraction;
        return "Please Write Password at least 6 characters.";
      }
      return null;
    },
  );
}

TextFormField textFormFieldDefault(
    {required var mode,
    required var controller,
    String errorText = "Please Fill this area",
    String? hint,
    required TextInputAction action}) {
  return TextFormField(
    autovalidateMode: mode,
    decoration: InputDecoration(
      hintText: hint,
    ),
    textInputAction: action,
    controller: controller,
    validator: (value) {
      if (value!.isEmpty) {
        mode = AutovalidateMode.onUserInteraction;
        return errorText;
      } else {}
      return null;
    },
  );
}

bool validateEmail(String value) {
  Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = RegExp(pattern.toString());
  return (!regex.hasMatch(value)) ? false : true;
}
