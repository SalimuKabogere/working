import 'package:flutter/material.dart';

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
      title: Text('Ride Request'),
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
