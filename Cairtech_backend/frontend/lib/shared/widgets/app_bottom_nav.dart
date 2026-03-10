import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/user_model.dart';

class NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  const NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}

/// Returns nav items based on user role
List<NavItem> getNavItemsForRole(UserModel? user) {
  final items = <NavItem>[
    const NavItem(
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      route: '/home',
    ),
  ];

  // Admin, President, Leader can see BBC Management
  if (user != null && (user.isAdmin || user.isPresident || user.isLeader)) {
    items.add(const NavItem(
      label: 'BBC Management',
      icon: Icons.business_outlined,
      activeIcon: Icons.business,
      route: '/bbc-directory',
    ));
  }

  // Admin and President can see Leaders
  if (user != null && (user.isAdmin || user.isPresident)) {
    items.add(const NavItem(
      label: 'Leaders & Pros',
      icon: Icons.people_outline,
      activeIcon: Icons.people,
      route: '/incharges',
    ));
  }

  // Admin sees admin panel
  if (user != null && user.isAdmin) {
    items.add(const NavItem(
      label: 'Admin',
      icon: Icons.admin_panel_settings_outlined,
      activeIcon: Icons.admin_panel_settings,
      route: '/admin',
    ));
  }

  // Settings for everyone
  items.add(const NavItem(
    label: 'Settings',
    icon: Icons.settings_outlined,
    activeIcon: Icons.settings,
    route: '/settings',
  ));

  return items;
}

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final UserModel? user;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = getNavItemsForRole(user);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = currentIndex == index;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.bottomNavInactive,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.bottomNavInactive,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
