import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/asset_hub_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/geo_map_screen.dart';
import 'screens/dna_analyzer_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase not initialized: $e");
  }
  runApp(const DigitalAssetProtectionApp());
}

class DigitalAssetProtectionApp extends StatelessWidget {
  const DigitalAssetProtectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Asset Protection',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    DashboardScreen(),
    const AssetHubScreen(),
    const AnalyticsScreen(),
    const GeoMapScreen(),
    const DnaAnalyzerScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      body: Row(
        children: [
          if (isDesktop)
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                border: const Border(right: BorderSide(color: Colors.white10)),
              ),
              child: NavigationRail(
                backgroundColor: Colors.transparent,
                selectedIndex: _selectedIndex,
                onDestinationSelected: (int index) {
                  setState(() => _selectedIndex = index);
                },
                labelType: NavigationRailLabelType.all,
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                        ),
                        child: const Icon(LucideIcons.shieldCheck, color: AppTheme.primary, size: 28),
                      ),
                      const SizedBox(height: 8),
                      const Text('DAP', style: TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    ],
                  ),
                ),
                selectedIconTheme: const IconThemeData(color: AppTheme.primary),
                unselectedIconTheme: const IconThemeData(color: Colors.white38),
                selectedLabelTextStyle: const TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.bold),
                unselectedLabelTextStyle: const TextStyle(color: Colors.white38, fontSize: 10),
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(LucideIcons.layoutDashboard),
                    label: Text('Threats'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(LucideIcons.uploadCloud),
                    label: Text('Assets'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(LucideIcons.activity),
                    label: Text('Analytics'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(LucideIcons.globe),
                    label: Text('GeoMap'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(LucideIcons.dna),
                    label: Text('DNA'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.background,
                    AppTheme.background.withBlue(20),
                  ],
                ),
              ),
              child: _screens[_selectedIndex],
            ),
          ),
        ],
      ),
      bottomNavigationBar: !isDesktop
          ? BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              backgroundColor: AppTheme.surface,
              selectedItemColor: AppTheme.primary,
              unselectedItemColor: Colors.white54,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(icon: Icon(LucideIcons.layoutDashboard), label: 'Threats'),
                BottomNavigationBarItem(icon: Icon(LucideIcons.uploadCloud), label: 'Assets'),
                BottomNavigationBarItem(icon: Icon(LucideIcons.activity), label: 'Analytics'),
                BottomNavigationBarItem(icon: Icon(LucideIcons.globe), label: 'GeoMap'),
                BottomNavigationBarItem(icon: Icon(LucideIcons.dna), label: 'DNA'),
              ],
            )
          : null,
    );
  }
}
