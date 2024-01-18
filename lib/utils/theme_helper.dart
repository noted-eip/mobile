import 'package:flutter/material.dart';

class ThemeHelper {
  static void formatCode(TextEditingController textEditingController) {
    bool allowCommas = false;

    String text = textEditingController.text;
    String formattedText = '';
    bool hasPointOrComma = false;
    int decimalCount = 0;

    for (int i = 0; i < text.length; i++) {
      if ((text[i] == '.' || (allowCommas)) &&
          !hasPointOrComma &&
          decimalCount < 0) {
        formattedText += '.';
        hasPointOrComma = true;
      } else if (RegExp(r'[0-9]').hasMatch(text[i])) {
        if (!hasPointOrComma && formattedText.length < 4) {
          formattedText += text[i];
        } else if (hasPointOrComma && decimalCount < 2) {
          formattedText += text[i];
          decimalCount++;
        }
      }
    }

    double numericValue = double.tryParse(formattedText) ?? 0.0;

    if (numericValue > 9999) {
      formattedText = '9999';
    }

    if (text != formattedText) {
      textEditingController.value = textEditingController.value.copyWith(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
    }
  }

  static InputDecoration codeInputDecoration(
      {String? labelText, String? hintText}) {
    return InputDecoration(
      floatingLabelBehavior: FloatingLabelBehavior.always,
      border: InputBorder.none,
      hintText: hintText,
      labelText: labelText,
      contentPadding: EdgeInsets.zero,
    );
  }

  static InputDecoration textInputDecoration(
      [String lableText = "", String hintText = ""]) {
    return InputDecoration(
      labelText: lableText,
      hintText: hintText,
      fillColor: Colors.white,
      filled: true,
      contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(color: Colors.grey)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: Colors.grey.shade400)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(color: Colors.red)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: const BorderSide(color: Colors.red)),
    );
  }

  static InputDecoration textInputProfile(
      {String labelText = "",
      String hintText = "",
      Widget? prefixIcon,
      Widget? suffixIcon}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.w500,
        height: 0.5,
        fontSize: 24,
      ),
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      floatingLabelBehavior: FloatingLabelBehavior.always,
    );
  }

  static BoxDecoration inputBoxDecorationShaddow() {
    return BoxDecoration(boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 20,
        offset: const Offset(0, 5),
      )
    ]);
  }

  static BoxDecoration buttonBoxDecoration(BuildContext context,
      [String color1 = "", String color2 = ""]) {
    Color c1 = Theme.of(context).colorScheme.primary;
    Color c2 = Theme.of(context).colorScheme.secondary;
    if (color1.isEmpty == false) {
      c1 = Colors.blue;
    }
    if (color2.isEmpty == false) {
      c2 = Colors.pink;
    }

    return BoxDecoration(
      boxShadow: const [
        BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 5.0)
      ],
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: const [0.0, 1.0],
        colors: [
          c1,
          c2,
        ],
      ),
      borderRadius: BorderRadius.circular(30),
    );
  }

  static ButtonStyle buttonStyle() {
    return ButtonStyle(
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      minimumSize: MaterialStateProperty.all(const Size(50, 50)),
      backgroundColor: MaterialStateProperty.all(Colors.transparent),
      shadowColor: MaterialStateProperty.all(Colors.transparent),
    );
  }

  static AlertDialog alartDialog(
      String title, String content, BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.black38)),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            "OK",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class LoginFormStyle {}
