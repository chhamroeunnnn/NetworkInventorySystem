import 'package:flutter/material.dart';

class SidebarIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const SidebarIcon({
    super.key,
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: active ? Colors.blue : Colors.white60),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.blue : Colors.white60,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Sidebar extends StatelessWidget {
  final String currentPage;
  final VoidCallback onLogout;

  const Sidebar({super.key, required this.currentPage, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      color: const Color(0xFF1F222A),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              const SizedBox(height: 30),
              SidebarIcon(
                icon: Icons.home,
                label: "Home",
                active: currentPage == "Home",
                onTap: () => Navigator.pushNamed(context, '/inventory'),
              ),
              SidebarIcon(
                icon: Icons.apartment,
                label: "Departments",
                active: currentPage == "Departments",
                onTap: () => Navigator.pushNamed(context, '/departments'),
              ),
              SidebarIcon(
                icon: Icons.person,
                label: "Users",
                active: currentPage == "Users",
                onTap: () => Navigator.pushNamed(context, '/users'),
              ),
              SidebarIcon(
                icon: Icons.settings,
                label: "Availability",
                active: currentPage == "Availability",
                onTap: () => Navigator.pushNamed(context, '/add-device'),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: SidebarIcon(
              icon: Icons.logout,
              label: "Logout",
              onTap: onLogout,
            ),
          ),
        ],
      ),
    );
  }
}
