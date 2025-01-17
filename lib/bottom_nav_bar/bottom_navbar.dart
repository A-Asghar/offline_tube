import 'package:flutter/material.dart';
import 'package:offline_tube/bottom_nav_bar/bottom_navbar_viewmodel.dart';
import 'package:offline_tube/downloads/playlist_page.dart';
import 'package:offline_tube/home/home_view.dart';
import 'package:offline_tube/search/search_view.dart';
import 'package:stacked/stacked.dart';

class BottomNavbar extends StatelessWidget {
  const BottomNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => BottomNavbarViewmodel(),
      builder: (_, model, __) {
        return Scaffold(
          body: _GetPage(index: model.selectedIndex),
          bottomNavigationBar: BottomNavigationBar(
            iconSize: 16,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey.withOpacity(0.5),
            backgroundColor: Colors.black,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.download),
                label: 'Downloads',
              ),
            ],
            currentIndex: model.selectedIndex,
            onTap: model.onTapItem,
          ),
        );
      },
    );
  }
}

class _GetPage extends StatelessWidget {
  const _GetPage({required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    switch (index) {
      case 0:
        return const HomeView();
      case 1:
        return const SearchView();
      case 2:
        return const DownloadsView();
    }
    return const SizedBox.shrink();
  }
}
