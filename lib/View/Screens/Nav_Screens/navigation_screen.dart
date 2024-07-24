import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logitrust_drivers/View/Screens/Main_Screens/History_Screen/history_screen.dart';
import 'package:logitrust_drivers/View/Screens/Main_Screens/Home_Screen/home_screen.dart';
import 'package:logitrust_drivers/View/Screens/Main_Screens/Payment_Screen/payment_screen.dart';
import 'package:logitrust_drivers/View/Screens/Main_Screens/Profile_Screen/profile_screen.dart';
import 'package:logitrust_drivers/View/Screens/Nav_Screens/navigation_providers.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {

  // These should be set with actual data when creating the NavigationScreen widget
  final String destination = "Destination Example";
  final GeoPoint userLocation = GeoPoint(0.0, 0.0);

  List<Widget> get screens => [
        HomeScreen(destination: destination, userLocation: userLocation),
        const PaymentScreen(),
        HistoryScreen(),
        const ProfileScreen(),
      ];

  


  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Logout"),
          content: Text("Are you sure you want to logout?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Logout"),
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
            ),
          ],
        );
      },
    );
  }

  void _logout() {
    print("User logged out");
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return Scaffold(
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text("Rlexandra"),
                  accountEmail: Text("rlexandra@gmail.com"),
                  currentAccountPicture: CircleAvatar(
                    child: ClipOval(
                      child: Image.network(
                        'https://via.placeholder.com/150',
                        fit: BoxFit.cover,
                        width: 90,
                        height: 90,
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.home_outlined, color: Colors.blueAccent),
                  title: Text('Home'),
                  onTap: () {
                    ref
                        .watch(navigationStateProvider.notifier)
                        .update((state) => 0);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.payment, color: Colors.blueAccent),
                  title: Text('Payments'),
                  onTap: () {
                    ref
                        .watch(navigationStateProvider.notifier)
                        .update((state) => 1);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.history, color: Colors.blueAccent),
                  title: Text('Notifications'),
                  onTap: () {
                    ref
                        .watch(navigationStateProvider.notifier)
                        .update((state) => 2);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading:
                      Icon(Icons.person_2_outlined, color: Colors.blueAccent),
                  title: Text('Profile'),
                  onTap: () {
                    ref
                        .watch(navigationStateProvider.notifier)
                        .update((state) => 3);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings, color: Colors.blueAccent),
                  title:
                      Text('Settings', style: TextStyle(color: Colors.black)),
                  onTap: () {
                    // Navigate to settings page
                  },
                ),
                ListTile(
                  leading: Icon(Icons.help, color: Colors.blueAccent),
                  title: Text('Support', style: TextStyle(color: Colors.black)),
                  onTap: () {
                    // Navigate to support page
                  },
                ),
                ListTile(
                  leading: Icon(Icons.exit_to_app, color: Colors.blueAccent),
                  title: Text('Log Out'),
                  onTap: () {
                    Navigator.pop(context); // Close the drawer
                    _showLogoutDialog(
                        context); // Show the logout confirmation dialog
                  },
                ),
              ],
            ),
          ),
          body: screens[ref.watch(navigationStateProvider)],
        );
      },
    );
  }
}
