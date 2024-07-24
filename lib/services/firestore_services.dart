import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';


Future<List<DocumentSnapshot<Map<String, dynamic>>>>
    getPendingRequests() async {
  try {
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('rideRequests')
        .where('status', isEqualTo: 'pending')
        .get();

    return snapshot.docs;
  } catch (e) {
    print('Error fetching pending requests: $e');
    throw e; // Rethrow the error to handle it in the UI or debug console
  }
}


void acceptRideRequest(
    String rideRequestId, String driverId, String driverName) {
  FirebaseFirestore.instance
      .collection('rideRequests')
      .doc(rideRequestId)
      .update({
    'status': 'accepted',
    'driverId': driverId,
    'driverName': driverName,
  });
}

class FirestoreRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to listen for new ride requests
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

  // Method to update request status
  Future<void> updateRequestStatus(String requestId, String status) async {
    await _firestore.collection('requests').doc(requestId).update({
      'status': status,
    });
  }

  // Method to set driver's location status
  Future<void> setDriverLocationStatus(
      BuildContext context, GeoPoint? location) async {
    try {
      // Example implementation to update driver's location status in Firestore
      String driverId = ""; // Get driver ID or use user ID
      await _firestore.collection('drivers').doc(driverId).update({
        'location': location,
      });
    } catch (e) {
      throw Exception("Failed to update driver location: $e");
    }
  }

  // Method to set driver's status
  Future<void> setDriverStatus(BuildContext context, String status) async {
    try {
      // Example implementation to update driver's status in Firestore
      String driverId = ""; // Get driver ID or use user ID
      await _firestore.collection('drivers').doc(driverId).update({
        'status': status,
      });
    } catch (e) {
      throw Exception("Failed to update driver status: $e");
    }
  }
}

