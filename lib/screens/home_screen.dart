import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../providers/connection_provider.dart';
import 'monitor/monitor_screen.dart';
import 'settings/settings_screen.dart';
import 'translation/translation_screen.dart';

/// Root screen with bottom navigation.
/// Order: Collecte (left) | Traduction (center, prominent) | Reglages (right).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1; // Default to Translation (center)

  static final _screens = [
    const MonitorScreen(),
    const TranslationScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final c = HarmonyColors.of(context);
    final conn = context.watch<ConnectionProvider>();

    return _BackgroundContainer(
      gradient: c.backgroundGradient,
      imagePath: c.backgroundImage,
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
        bottomNavigationBar: _buildBottomNav(c),
      ),
    );
  }

  Widget _buildBottomNav(HarmonyColors c) {
    return Container(
      decoration: BoxDecoration(
        color: c.card,
        border: Border(top: BorderSide(color: c.glassBorder, width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: c.primary.withAlpha(8),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 6, left: 24, right: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ── Left: Collecte ──
              _buildSideTab(
                c,
                icon: Icons.monitor_heart_rounded,
                label: 'Collecte',
                index: 0,
              ),

              // ── Center: Traduction (prominent) ──
              _buildCenterTab(c),

              // ── Right: Reglages ──
              _buildSideTab(
                c,
                icon: Icons.tune_rounded,
                label: 'Reglages',
                index: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSideTab(HarmonyColors c,
      {required IconData icon, required String label, required int index}) {
    final active = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: active ? c.primary : c.textHint,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: active ? c.primary : c.textHint,
                fontSize: 11,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterTab(HarmonyColors c) {
    final active = _currentIndex == 1;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 1),
      child: Transform.translate(
        offset: const Offset(0, -12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: active ? c.primaryGradient : null,
                color: active ? null : c.surface,
                border: active
                    ? null
                    : Border.all(color: c.glassBorder, width: 1.5),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: c.primary.withAlpha(80),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: c.textHint.withAlpha(20),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Icon(
                Icons.translate_rounded,
                color: active ? Colors.white : c.textHint,
                size: 28,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Traduction',
              style: TextStyle(
                color: active ? c.primary : c.textHint,
                fontSize: 11,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Container that tries to show a background image; falls back to gradient.
class _BackgroundContainer extends StatelessWidget {
  final LinearGradient gradient;
  final String imagePath;
  final Widget child;

  const _BackgroundContainer({
    required this.gradient,
    required this.imagePath,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient layer (always present as fallback)
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: gradient),
          ),
        ),
        // Image layer (on top of gradient, fades in if present)
        Positioned.fill(
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
        // Content
        Positioned.fill(child: child),
      ],
    );
  }
}
