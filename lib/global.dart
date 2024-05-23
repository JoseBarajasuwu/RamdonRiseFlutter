import 'package:flutter/services.dart';

class Url {
  // static const String url = "http://127.0.0.1:8000/api";
  static const String url =
      "https://ramdonriselaravel-production.up.railway.app/api";
  // static const String url = "";
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
