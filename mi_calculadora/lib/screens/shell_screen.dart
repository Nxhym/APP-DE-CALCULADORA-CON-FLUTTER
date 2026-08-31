import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShellScreen extends ConsumerWidget {
  final Widget child;

  const ShellScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Usamos MediaQuery directamente para decidir el shell
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora Flutter'),
      ),
      body: Row(
        children: [
          // Rail de navegación para pantallas grandes (opcional)
          if (!isMobile)
            NavigationRail(
              selectedIndex: _calculateSelectedIndex(context),
              onDestinationSelected: (int index) => _onItemTapped(index, context),
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.calculate), label: Text('Calc')),
                NavigationRailDestination(icon: Icon(Icons.history), label: Text('Historial')),
              ],
            ),
          if (!isMobile) const VerticalDivider(thickness: 1, width: 1),
          // El contenido principal
          Expanded(child: child),
        ],
      ),
      // Barra de navegación inferior (Solo si ES móvil)
      bottomNavigationBar: isMobile
          ? NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (int index) => _onItemTapped(index, context),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.calculate), label: 'Calc'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Historial'),
        ],
      )
          : null,
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/history')) return 1;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/history');
        break;
    }
  }
}