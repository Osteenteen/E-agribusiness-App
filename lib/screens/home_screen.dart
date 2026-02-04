import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'profile_page.dart'; // Ensure this import exists
import 'market_dashboard.dart';
import 'crop_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color primaryGreen = Color(0xFF1B5E20);
  static const Color backgroundCream = Color(0xFFFDFDF5);

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser();

    return Scaffold(
      backgroundColor: backgroundCream,
      appBar: AppBar(
        title: const Text("E-Agribusiness", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryGreen,
        elevation: 0,
      ),
      drawer: _buildDrawer(context, user),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(user?.uid).get(),
                builder: (context, snapshot) {
                  String name = "Farmer";
                  if (snapshot.hasData && snapshot.data!.exists) {
                    name = snapshot.data!['username'] ?? "Farmer";
                  }
                  return Text(
                    "Welcome Back, $name!",
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: primaryGreen),
                  );
                },
              ),
              const Text(
                "What are we doing today?",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              
              const SizedBox(height: 30),

              // --- DASHBOARD GRID ---
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _buildDashboardCard(
                    context,
                    "My Crops",
                    Icons.eco_outlined,
                    Colors.green,
                    () => Navigator.pushNamed(context, '/crops'),
                  ),
                  _buildDashboardCard(
                    context,
                    "Market",
                    Icons.shopping_cart_outlined,
                    Colors.orange,
                    () => Navigator.pushNamed(context, '/market'),
                  ),
                  _buildDashboardCard(
                    context,
                    "Weather",
                    Icons.wb_sunny_outlined,
                    Colors.blue,
                    () => Navigator.pushNamed(context, '/weather'),
                  ),
                  _buildDashboardCard(
                    context,
                    "Profile",
                    Icons.person_outline,
                    Colors.brown,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage())),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for the Grid Cards
  Widget _buildDashboardCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 45, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, User? user) {
    return Drawer(
      child: Container(
        color: const Color(0xFFFDFDF5), // Matches your backgroundCream
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Dynamic Header fetching user data from Firestore
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(user?.uid).get(),
              builder: (context, snapshot) {
                String name = "Loading...";
                String email = user?.email ?? "No email found";

                if (snapshot.hasData && snapshot.data!.exists) {
                  var userData = snapshot.data!.data() as Map<String, dynamic>;
                  name = userData['username'] ?? "Farmer";
                }

                return UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(color: primaryGreen),
                  currentAccountPicture: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: primaryGreen, size: 35),
                  ),
                  accountName: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  accountEmail: Text(email),
                );
              },
            ),

            // Navigation Menu
            _drawerTile(Icons.dashboard_outlined, "Dashboard", () {
              Navigator.pop(context); // Just closes the drawer
            }),

            

            _drawerTile(Icons.eco_outlined, "My Crops", () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CropsScreen()),
              );
            }),

            _drawerTile(Icons.shopping_basket_outlined, "Market", () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MarketDashboard()),
              );
            }),

            _drawerTile(Icons.person_outline, "Profile", () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            }),

            const Divider(), // Visual separator for the logout action

            _drawerTile(Icons.logout, "Logout", () async {
              await AuthService.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            }, iconColor: Colors.redAccent),
          ],
        ),
      ),
    );
  }

  // Helper method for consistent Drawer Tiles
  Widget _drawerTile(IconData icon, String title, VoidCallback onTap, {Color? iconColor}) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? primaryGreen),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
      ),
      onTap: onTap,
    );
  }
}