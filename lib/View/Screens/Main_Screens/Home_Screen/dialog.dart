import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DialogScreen extends StatefulWidget {
  @override
  _DialogScreenState createState() => _DialogScreenState();
}

class _DialogScreenState extends State<DialogScreen>  {
  StreamSubscription<QuerySnapshot>? rideRequestSubscription;
  Timer? rideRequestTimer;

  @override
  void initState() {
    super.initState();
    _startRideRequestListener();
  }

  @override
  void dispose() {
    rideRequestSubscription?.cancel();
    rideRequestTimer?.cancel();
    super.dispose();
  }

  void _startRideRequestListener() {
    rideRequestSubscription = FirebaseFirestore.instance
        .collection('rideRequests')
        .where('status', isEqualTo: 'Pending')
        .snapshots()
        .listen((querySnapshot) {
      for (var change in querySnapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          var doc = change.doc;
          String requestId = doc.id;
          String userName = doc['userName']; // Replace with actual field name
          String destination = doc['destination']; // Replace with actual field name

          showDialog(
            context: context,
            barrierDismissible: false, // Prevent dismissing dialog by tapping outside
            builder: (BuildContext context) {
              return RideRequestDialog(
                requestId: requestId,
                userName: userName,
                destination: destination,
                onAccept: () {
                  _acceptRequest(requestId);
                  Navigator.of(context).pop(); // Close the dialog
                },
                onDecline: () {
                  _declineRequest(requestId);
                  Navigator.of(context).pop(); // Close the dialog
                },
              );
            },
          );
        }
      }
    });
  }

  void _acceptRequest(String requestId) {
    // Update Firestore to accept the ride request
    FirebaseFirestore.instance
        .collection('rideRequests')
        .doc(requestId)
        .update({
          'status': 'Accepted',
          'acceptedBy': 'Driver Name', // Replace with actual driver's name
        })
        .then((value) => print('Ride request accepted'))
        .catchError((error) => print('Failed to accept ride request: $error'));
  }

  void _declineRequest(String requestId) {
    // Update Firestore to decline the ride request
    FirebaseFirestore.instance
        .collection('rideRequests')
        .doc(requestId)
        .update({'status': 'Declined'})
        .then((value) => print('Ride request declined'))
        .catchError((error) => print('Failed to decline ride request: $error'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Center(
        child: Text('Listening for ride requests...'),
      ),
    );
  }
}

class RideRequestDialog extends StatelessWidget {
  final String requestId;
  final String userName;
  final String destination;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  RideRequestDialog({
    required this.requestId,
    required this.userName,
    required this.destination,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('New Ride Request'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Request ID: $requestId'),
          Text('Customer Name: $userName'),
          Text('Destination: $destination'),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: onAccept,
          child: Text('Accept'),
        ),
        TextButton(
          onPressed: onDecline,
          child: Text('Decline'),
        ),
      ],
    );
  }
}
