import 'package:stacked/stacked.dart';

class BottomNavbarViewmodel extends BaseViewModel {
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;
  set selectedIndex(int value) {
    _selectedIndex = value;
    notifyListeners();
  }

  void onTapItem(int index) {
    selectedIndex = index;
  }
}
