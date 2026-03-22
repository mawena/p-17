import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:p17/providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<NavigationPage> _pages = [
    NavigationPage(
      icon: Icons.home,
      label: 'Accueil',
      widget: const _HomePageWidget(),
    ),
    NavigationPage(
      icon: Icons.list,
      label: 'Observations',
      widget: const _ObservationsPageWidget(),
    ),
    NavigationPage(
      icon: Icons.map,
      label: 'Carte',
      widget: const _MapPageWidget(),
    ),
    NavigationPage(
      icon: Icons.person,
      label: 'Profil',
      widget: const _ProfilePageWidget(),
    ),
  ];

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
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/observations/new'),
        tooltip: 'Nouvelle observation',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _HomePageWidget extends StatelessWidget {
  const _HomePageWidget();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.currentUser;

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('Wildlife Census'),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withAlpha(200),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.nature, size: 80, color: Colors.white),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (user != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Profil',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.person),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(user.displayName),
                                      Text(
                                        user.email,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.camera_alt),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '${user.observationCount} observations',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ressources rapides',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 12),
                            _QuickActionButton(
                              icon: Icons.add_circle_outline,
                              label: 'Nouvelle observation',
                              onTap: () => context.go('/observations/new'),
                            ),
                            const SizedBox(height: 8),
                            _QuickActionButton(
                              icon: Icons.list,
                              label: 'Voir toutes les observations',
                              onTap: () => context.go('/observations'),
                            ),
                            const SizedBox(height: 8),
                            _QuickActionButton(
                              icon: Icons.logout,
                              label: 'Déconnexion',
                              onTap: () async {
                                await authProvider.logout();
                                if (context.mounted) {
                                  context.go('/login');
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Veuillez vous connecter'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context.go('/login'),
                            child: const Text('Connexion'),
                          ),
                        ],
                      ),
                    ),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

class _ObservationsPageWidget extends StatelessWidget {
  const _ObservationsPageWidget();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Observations')),
      body: const Center(child: Text('Liste des observations')),
    );
  }
}

class _MapPageWidget extends StatelessWidget {
  const _MapPageWidget();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carte')),
      body: const Center(child: Text('Carte des observations')),
    );
  }
}

class _ProfilePageWidget extends StatelessWidget {
  const _ProfilePageWidget();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: const Center(child: Text('Page de profil')),
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
