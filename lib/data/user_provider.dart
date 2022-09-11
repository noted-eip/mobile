import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String token = "";
  String username = "";
  String email = "";
  String id = "";

  void setToken(String token) {
    this.token = token;
    notifyListeners();
  }

  void setID(String id) {
    this.id = id;
    notifyListeners();
  }

  void setUsername(String newUsername) {
    username = newUsername;
    notifyListeners();
  }

  void setEmail(String newEmail) {
    email = newEmail;
    notifyListeners();
  }

  void clearUser() {
    token = "";
    username = "";
    email = "";
    id = "";
  }
}
