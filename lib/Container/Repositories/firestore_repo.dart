// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logitrust_drivers/Model/driver_info_model.dart';

import '../utils/error_notification.dart';

final globalFirestoreRepoProvider = Provider<AddFirestoreData>((ref) {
  return AddFirestoreData();
});

class AddFirestoreData {
  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void addDriversDataToFirestore(BuildContext context, String truckName,
      String truckPlateNum, String truckType) async {
    try {
      DocumentReference<Map<String, dynamic>> driverRef =
          await db.collection("Drivers").add({
        "name": FirebaseAuth.instance.currentUser!.email!.split("@")[0],
        "email": FirebaseAuth.instance.currentUser!.email,
        "Truck Name": truckName,
        "Truck Plate Num": truckPlateNum,
        "Truck Type": truckType,
        "driverStatus": "Idle", // Optional, if you want to set a default status
        "driverLoc": GeoPoint(0.0, 0.0) // Default location, update later
      });

      print('Driver added with ID: ${driverRef.id}');
    } catch (e) {
      if (context.mounted) {
        ErrorNotification().showError(context, "An Error Occurred $e");
      }
    }
  }

  void getDriverDetails(BuildContext context, String driverId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> data =
          await db.collection("Drivers").doc(driverId).get();

      DriverInfoModel driver = DriverInfoModel(
          driverId, // Use the document ID as the driver ID
          data.data()?["name"],
          data.data()?["email"],
          data.data()?["Truck Name"],
          data.data()?["Truck Plate Num"],
          data.data()?["Truck Type"]);

      print("data is ${driver.truckType}");
    } catch (e) {
      if (context.mounted) {
        ErrorNotification().showError(context, "An Error Occurred $e");
      }
    }
  }

  void setDriverStatus(BuildContext context, String status) async {
    try {
      await db
          .collection("Drivers")
          .doc(auth.currentUser!.email.toString())
          .update({"driverStatus": status});
    } catch (e) {
      if (context.mounted) {
        ErrorNotification().showError(context, "An Error Occurred $e");
      }
    }
  }

  void listenForRideRequests(Function(DocumentSnapshot) onNewRequest) {
    _firestore
        .collection('requests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
      snapshot.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.added) {
          onNewRequest(change.doc);
        }
      });
    });
  }

  Future<void> updateRequestWithDriver(
      BuildContext context, String requestId, String driverId) async {
    try {
      // Fetch driver details
      DocumentSnapshot<Map<String, dynamic>> driverSnapshot =
          await db.collection('Drivers').doc(driverId).get();

      if (driverSnapshot.exists) {
        await db.collection('requests').doc(requestId).update({
          'status': 'Accepted',
          'driverId': driverId,
          'driverName': driverSnapshot.data()?[
              'Truck Name'], // Assuming this is used for the driver's name
          'driverLocation': driverSnapshot.data()?['driverLoc'],
          'driverNumber': driverSnapshot.data()?['email'],
        });

        print('Request updated with driver details.');
      } else {
        print('Driver not found.');
      }
    } catch (e) {
      if (context.mounted) {
        ErrorNotification().showError(context, "An Error Occurred $e");
      }
    }
  }

  void setDriverLocationStatus(BuildContext context, GeoPoint? loc) async {
    try {
      await db
          .collection("Drivers")
          .doc(auth.currentUser!.email.toString())
          .update({"driverLoc": loc});
    } catch (e) {
      if (context.mounted) {
        ErrorNotification().showError(context, "An Error Occurred $e");
      }
    }
  }
}
