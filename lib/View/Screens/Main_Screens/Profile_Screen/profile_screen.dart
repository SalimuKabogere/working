import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logitrust_drivers/Model/driver_info_model.dart';
import 'package:logitrust_drivers/View/Screens/Main_Screens/Profile_Screen/edit_profile.dart';

final globalFirestoreRepoProvider = Provider<AddFirestoreData>((ref) {
  return AddFirestoreData();
});

class AddFirestoreData {
  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  Future<DriverInfoModel?> getDriverDetails() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> data = await db
          .collection("Drivers")
          .doc(auth.currentUser!.email.toString())
          .get();

      if (data.exists) {
        return DriverInfoModel(
            auth.currentUser!.uid,
            data.data()?["name"] ?? 'N/A',
            data.data()?["email"] ?? 'N/A',
            data.data()?["Truck Name"] ?? 'N/A',
            data.data()?["Truck Plate Num"] ?? 'N/A',
            data.data()?["Truck Type"] ?? 'N/A');
      }
    } catch (e) {
      print("An Error Occurred while fetching data: $e");
    }
    return null;
  }
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestoreRepo = ref.watch(globalFirestoreRepoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Profile'),
        backgroundColor: Colors.blueAccent,
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<DriverInfoModel?>(
        future: firestoreRepo.getDriverDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("An error occurred"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("No data available"));
          } else {
            final driver = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  const Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('images/avatar.png'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    driver.name,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    driver.email,
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const ListTile(
                    leading: Icon(
                      Icons.badge,
                      color: Colors.blueAccent,
                    ),
                    title: Text(
                      'License Number',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    subtitle: Text(
                      '12345678',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                  const ListTile(
                    leading: Icon(
                      Icons.calendar_today,
                      color: Colors.blueAccent,
                    ),
                    title: Text(
                      'License Expiry Date',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    subtitle: Text(
                      '2024-12-31',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.directions_car,
                        color: Colors.blueAccent),
                    title: const Text(
                      'Vehicle Make and Model',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    subtitle: Text(
                      driver.truckName,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.confirmation_number,
                        color: Colors.blueAccent),
                    title: const Text(
                      'License Plate Number',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    subtitle: Text(
                      driver.truckPlateNum,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
                  const ListTile(
                    leading: Icon(Icons.star, color: Colors.blueAccent),
                    title: Text(
                      'Rating',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    subtitle: Text(
                      '4.8',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.history, color: Colors.blueAccent),
                    title: const Text(
                      'Trip History',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    subtitle: const Text(
                      'View recent trips',
                      style: TextStyle(color: Colors.black54),
                    ),
                    onTap: () {
                      // Navigate to trip history page
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.edit, color: Colors.blueAccent),
                    title: const Text(
                      'Edit Profile',
                      style: TextStyle(color: Colors.black),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditProfileScreen(
                                    driverInfo: driver,
                                  )));
                      // Navigate to edit profile page
                    },
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
