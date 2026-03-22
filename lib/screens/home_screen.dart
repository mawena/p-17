import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:p17/providers/auth_provider.dart';
import 'package:p17/providers/observation_provider.dart';
import 'package:p17/screens/observations/observations_list_screen.dart';
import 'package:p17/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<NavigationPage> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      NavigationPage(
        icon: Icons.list,
        label: 'Observations',
        widget: const ObservationsListScreen(),
      ),
      NavigationPage(
        icon: Icons.person,
        label: 'Profil',
        widget: const ProfileScreen(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex].widget,
      bottomNavigationBar: BottomNavigationBar(
        items: _pages
            .map(
              (page) => BottomNavigationBarItem(
                icon: Icon(page.icon),
                label: page.label,
              ),
            )
            .toList(),
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => context.go('/observations/new'),
              tooltip: 'Nouvelle observation',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class NavigationPage {
  final IconData icon;
  final String label;
  final Widget widget;

  NavigationPage({
    required this.icon,
    required this.label,
    required this.widget,
  });
}
