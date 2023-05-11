import 'package:flutter/material.dart';
import 'package:noted_mobile/components/common/custom_drawer.dart';
import 'package:noted_mobile/components/common/new_custom_drawer.dart';

class MainScreenNotifier extends ChangeNotifier {
  MyMenuItem _item = MyMenuItems.home;

  MyMenuItem get item => _item;

  void setItem(MyMenuItem newItem) {
    _item = newItem;
    notifyListeners();
  }
}
