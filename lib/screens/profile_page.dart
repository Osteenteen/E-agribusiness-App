import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

// Note: Ensure you have themeNotifier defined in main.dart if using Dark Mode
// import '../main.dart'; 

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color primaryGreen = Color(0xFF1B5E20);
  static const Color backgroundCream = Color(0xFFFDFDF5);

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      // Background color adapts to Theme (Light/Dark)
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(user?.uid).get(),
        builder: (context, snapshot) {
          String userName = "Farmer";
          String email = user?.email ?? "No email found";

          if (snapshot.hasData && snapshot.data!.exists) {
            var userData = snapshot.data!.data() as Map<String, dynamic>;
            userName = userData['username'] ?? "Farmer";
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // 1. HEADER (Fixed Alignment)
                _buildHeader(context, userName, email),
                
                const SizedBox(height: 30),

                // 2. STATS ROW (Fixed Yellow Bar / Overflow)
                _buildStatsRow(),

                // 3. MENU SECTION
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Account Settings",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      _buildProfileMenu(
                        icon: Icons.person_outline,
                        title: "Edit Profile",
                        onTap: () {},
                      ),
                      _buildProfileMenu(
                        icon: Icons.security,
                        title: "Security & Privacy",
                        onTap: () {},
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        "App Preferences",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      
                      // Optional: Theme Toggle could go here
                      
                      _buildProfileMenu(
                        icon: Icons.help_outline,
                        title: "Help & Support",
                        onTap: () {},
                      ),
                      _buildProfileMenu(
                        icon: Icons.logout,
                        title: "Logout",
                        textColor: Colors.redAccent,
                        iconColor: Colors.redAccent,
                        onTap: () => _handleLogout(context),
                      ),

                      // 4. VERSION INFO
                      const SizedBox(height: 40),
                      _buildVersionInfo(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- UI HELPER METHODS ---

  Widget _buildHeader(BuildContext context, String name, String email) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 240,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: primaryGreen,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
        ),
        // Positioned with left:0 and right:0 centers the children
        Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: Column(
            children: [
              const Text(
                "Profile",
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: const CircleAvatar(
                  radius: 45,
                  backgroundColor: backgroundCream,
                  child: Icon(Icons.person, size: 50, color: primaryGreen),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                name,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                email,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Expanded ensures each card takes exactly 1/3 of the screen width
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('crops').snapshots(),
              builder: (context, snapshot) {
                int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                return _statCard("My Crops", count.toString(), Icons.eco);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('market').snapshots(),
              builder: (context, snapshot) {
                int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                return _statCard("Market", count.toString(), Icons.storefront);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _statCard("Orders", "0", Icons.shopping_bag_outlined),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: primaryGreen, size: 22),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenu({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color textColor = Colors.black87,
    Color iconColor = primaryGreen,
  }) {
    // Adapt text color for Dark Mode
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDark && textColor == Colors.black87 ? Colors.white : textColor, 
            fontWeight: FontWeight.w600, 
            fontSize: 16
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Center(
      child: Column(
        children: [
          Text(
            "v1.0.4 Build 2026",
            style: TextStyle(color: Colors.grey[500], fontSize: 12, letterSpacing: 1.1),
          ),
          const SizedBox(height: 4),
          const Text(
            "E-Agribusiness Project",
            style: TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await AuthService.signOut();
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }
}