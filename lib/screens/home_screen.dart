import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../providers/connection_provider.dart';
import 'monitor/monitor_screen.dart';
import 'settings/settings_screen.dart';
import 'translation/translation_screen.dart';

/// Root screen with bottom navigation.
/// Order: Traduction (main), Monitor, Parametres.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static final _screens = [
    const TranslationScreen(),
    const MonitorScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final c = HarmonyColors.of(context);
    final conn = context.watch<ConnectionProvider>();

    return Container(
      decoration: BoxDecoration(gradient: c.backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: c.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.sign_language_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'HARMONY',
                style: TextStyle(color: c.textPrimary),
              ),
            ],
          ),
          actions: [
            // ── WiFi connection button (tappable) ──
            GestureDetector(
              onTap: () {
                if (conn.isConnected) {
                  conn.disconnect();
                } else {
                  conn.connect();
                }
              },
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: conn.isConnected
                      ? c.success.withAlpha(25)
                      : c.error.withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: conn.isConnected
                        ? c.success.withAlpha(80)
                        : c.error.withAlpha(80),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      conn.isConnected
                          ? Icons.wifi_rounded
                          : Icons.wifi_off_rounded,
                      color: conn.isConnected ? c.success : c.error,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      conn.isConnected ? 'Connecte' : 'Hors ligne',
                      style: TextStyle(
                        color: conn.isConnected ? c.success : c.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: c.card,
            border: Border(top: BorderSide(color: c.glassBorder)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.translate_rounded,
                    label: 'Traduction',
                    active: _currentIndex == 0,
                    onTap: () => setState(() => _currentIndex = 0),
                  ),
                  _NavItem(
                    icon: Icons.monitor_heart_rounded,
                    label: 'Collecte',
                    active: _currentIndex == 1,
                    onTap: () => setState(() => _currentIndex = 1),
                  ),
                  _NavItem(
                    icon: Icons.tune_rounded,
                    label: 'Reglages',
                    active: _currentIndex == 2,
                    onTap: () => setState(() => _currentIndex = 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = HarmonyColors.of(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: active ? c.primaryGradient : null,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: active ? Colors.white : c.textHint,
              size: 22,
            ),
            if (active) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
