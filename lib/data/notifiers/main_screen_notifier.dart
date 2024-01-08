import 'package:flutter/material.dart';
import 'package:noted_mobile/components/common/new_custom_drawer.dart';

class MainScreenNotifier extends ChangeNotifier {
  MyMenuItem _item = MyMenuItems.home;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  MyMenuItem get item => _item;
  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;

  void setItem(MyMenuItem newItem) {
    _item = newItem;
    notifyListeners();
  }
}
