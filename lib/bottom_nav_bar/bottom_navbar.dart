import 'package:flutter/material.dart';
import 'package:offline_tube/bottom_nav_bar/bottom_navbar_viewmodel.dart';
import 'package:offline_tube/downloads/downloads_view.dart';
import 'package:offline_tube/home/home_view.dart';
import 'package:offline_tube/main.dart';
import 'package:offline_tube/search/search_view.dart';
import 'package:stacked/stacked.dart';

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({super.key});

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    downloadsService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      downloadsService.pauseAllDownloads();
    } else if (state == AppLifecycleState.resumed) {
      downloadsService.resumeAllDownloads();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => BottomNavbarViewmodel(),
      builder: (_, model, __) {
        return Scaffold(
          body: PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: model.pageController,
            onPageChanged: (index) {
              model.selectedIndex = index;
            },
            children: const [
              _GetPage(index: 0),
              _GetPage(index: 1),
              _GetPage(index: 2),
            ],
          ),
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
        return const HomeView(key: PageStorageKey('HomeView'));
      case 1:
        return const SearchView(key: PageStorageKey('SearchView'));
      case 2:
        return const DownloadsView(key: PageStorageKey('DownloadsView'));
    }
    return const SizedBox.shrink();
  }
}
