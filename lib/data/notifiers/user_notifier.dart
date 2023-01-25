import 'package:flutter/material.dart';

class UserNotifier extends ChangeNotifier {
  String _token = "";
  String get token => _token;

  String _name = "";
  String get name => _name;

  String _email = "";
  String get email => _email;

  String _id = "";
  String get id => _id;

  void setToken(String token) {
    _token = token;
    notifyListeners();
  }

  void setID(String id) {
    _id = id;
    notifyListeners();
  }

  void setName(String newName) {
    _name = newName;
    notifyListeners();
  }

  void setEmail(String newEmail) {
    _email = newEmail;
    notifyListeners();
  }
}
