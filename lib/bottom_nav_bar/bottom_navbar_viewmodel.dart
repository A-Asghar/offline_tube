import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class BottomNavbarViewmodel extends BaseViewModel {
  BottomNavbarViewmodel() {
    pageController = PageController(initialPage: 0);
  }
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;
  set selectedIndex(int value) {
    _selectedIndex = value;
    notifyListeners();
  }

  PageController? pageController;

  void onTapItem(int index) {
    selectedIndex = index;
    pageController!.jumpToPage(index);
  }
}
