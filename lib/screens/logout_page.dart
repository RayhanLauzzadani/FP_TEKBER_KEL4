import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LogoutScreen extends StatefulWidget {
  const LogoutScreen({Key? key}) : super(key: key);

  @override
  _LogoutScreenState createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen> {
  String username = ""; // Untuk menyimpan nama pengguna
  String userInitial = "M"; // Inisial nama pengguna (default)
  bool isFetching = false; // Indikator untuk pengambilan data pengguna

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    isFetching = false; // Pastikan pengambilan data dihentikan
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    try {
      setState(() {
        isFetching = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists && mounted) {
          setState(() {
            username = userDoc['username'] ?? "Guest";
            userInitial = username.isNotEmpty
                ? username[0].toUpperCase()
                : "G"; // Inisial nama
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading user data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isFetching = false; // Selesai mengambil data
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header Profile Section
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, const Color(0xFFB3DFFF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(40),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 80),
            child: Column(
              children: [
                // Avatar dengan inisial nama pengguna
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Text(
                    userInitial,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Nama pengguna
                isFetching
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                const SizedBox(height: 10),
                // Teks "Edit Profile"
                const Text(
                  'Edit your profile',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          // Settings List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildListTile(Icons.notifications, 'Notification'),
                _buildListTile(Icons.language, 'Language'),
                _buildListTile(Icons.lock, 'Security & Privacy'),
                _buildListTile(Icons.help_outline, 'Help'),
                _buildListTile(Icons.info_outline, 'About'),
                _buildListTile(
                  Icons.logout,
                  'Logout',
                  textColor: Colors.red,
                  onTap: () => _showLogoutPopup(context), // Popup logout
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk ListTile
  Widget _buildListTile(IconData icon, String title,
      {Color? textColor, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: Icon(icon, color: textColor ?? Colors.black),
        title: Text(
          title,
          style: TextStyle(
            color: textColor ?? Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
        onTap: onTap, // Fungsi saat ListTile ditekan
      ),
    );
  }

  // Popup Logout
  void _showLogoutPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Logout',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
                _logout(); // Lakukan logout
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi logout
  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigasi kembali ke halaman WelcomePage
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
      }
    } catch (e) {
      print('Logout failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    }
  }
}
