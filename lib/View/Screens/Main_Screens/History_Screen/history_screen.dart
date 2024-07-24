import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logitrust_drivers/View/Screens/Main_Screens/Home_Screen/home_screen.dart';
import 'package:logitrust_drivers/services/firestore_services.dart'; // Import your Firestore service functions

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Future<List<DocumentSnapshot<Map<String, dynamic>>>>? _pendingRequests;

  @override
  void initState() {
    super.initState();
    _fetchPendingRequests();
  }

  Future<void> _fetchPendingRequests() async {
    try {
      var pendingRequests = getPendingRequests();
      if (mounted) {
        setState(() {
          _pendingRequests = pendingRequests;
        });
      }
    } catch (e) {
      print('Error fetching pending requests: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<Map<String, dynamic>?> _getDriverDetails(String name) async {
    try {
      QuerySnapshot<Map<String, dynamic>> driverSnapshot =
          await FirebaseFirestore.instance
              .collection('drivers')
              .where('name', isEqualTo: name)
              .get();

      if (driverSnapshot.docs.isNotEmpty) {
        return driverSnapshot.docs.first.data();
      } else {
        print('Driver not found.');
        return null;
      }
    } catch (e) {
      print('Error fetching driver details: $e');
      return null;
    }
  }

  Future<String?> _getDriverNameForRequest(String requestId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> requestSnapshot =
          await FirebaseFirestore.instance
              .collection('rideRequests')
              .doc(requestId)
              .get();
      return requestSnapshot.data()?['name'];
    } catch (e) {
      print('Error fetching driver name: $e');
      return null;
    }
  }

  Future<void> _acceptRequest(String requestId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> requestSnapshot =
          await FirebaseFirestore.instance
              .collection('rideRequests')
              .doc(requestId)
              .get();

      if (requestSnapshot.exists &&
          requestSnapshot.data()?['status'] == 'pending') {
        await FirebaseFirestore.instance
            .collection('rideRequests')
            .doc(requestId)
            .update({
          'status': 'Accepted',
        });

        String userId = requestSnapshot.data()?['userId'];

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'requestStatus': 'Accepted',
        });

        if (mounted) {
          setState(() {
            _fetchPendingRequests(); // Refresh pending requests list
          });

          // Navigate to HomeScreen after updating Firestore
          String destination = requestSnapshot.data()?['destination'];
          GeoPoint userLocation = requestSnapshot.data()?['userLocation'];
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                destination: destination,
                userLocation: userLocation,
              ),
            ),
          );

          // Show a snackbar to indicate successful acceptance
          // _showSnackBar(
          //     'Request Accepted by ${driverDetails?['name'] ?? 'Unknown Driver'}');
        }
      } else {
        _showSnackBar('Request is not pending or does not exist.');
      }
    } catch (e) {
      print('Error accepting request: $e');
      _showSnackBar('Error accepting request.');
    }
  }

  Future<void> _cancelRequest(String requestId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> requestSnapshot =
          await FirebaseFirestore.instance
              .collection('rideRequests')
              .doc(requestId)
              .get();

      if (requestSnapshot.exists &&
          requestSnapshot.data()?['status'] == 'pending') {
        await FirebaseFirestore.instance
            .collection('rideRequests')
            .doc(requestId)
            .update({
          'status': 'Cancelled',
        });

        String userId = requestSnapshot.data()?['userId'];

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'requestStatus': 'Cancelled',
        });

        if (mounted) {
          setState(() {
            _fetchPendingRequests(); // Refresh pending requests list
          });
          _showSnackBar('Request Cancelled');
        }
      } else {
        _showSnackBar('Request is not pending or does not exist.');
      }
    } catch (e) {
      print('Error cancelling request: $e');
      _showSnackBar('Error cancelling request.');
    }
  }

  @override
  void dispose() {
    // Clean up any subscriptions here
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pending Requests'),
      ),
      body: FutureBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
        future: _pendingRequests,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No pending requests found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var request = snapshot.data![index].data();
                String requestId = snapshot.data![index].id;
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  padding: EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Customer: ${request?['userName']}'),
                      SizedBox(height: 8.0),
                      Text('Destination: ${request?['destination']}'),
                      SizedBox(height: 8.0),
                      Text('user Location: ${request?['userLocation']}'),
                      SizedBox(height: 8.0),
                      Text('Request ID: $requestId'),
                      SizedBox(height: 8.0),
                      Text('Status: ${request?['status']}'),
                      SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () => _acceptRequest(requestId),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue),
                            child: Text('Accept'),
                          ),
                          ElevatedButton(
                            onPressed: () => _cancelRequest(requestId),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            child: Text('Cancel'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
