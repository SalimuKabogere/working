import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logitrust_drivers/Container/Repositories/address_parser_repo.dart';
import 'package:logitrust_drivers/Container/utils/error_notification.dart';
import 'package:logitrust_drivers/View/Screens/Main_Screens/Home_Screen/home_providers.dart';

import '../../../../Container/Repositories/firestore_repo.dart';

class HomeLogics {
  void getDriverLoc(BuildContext context, WidgetRef ref,
      GoogleMapController controller) async {
    try {
      Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(pos.latitude, pos.longitude), zoom: 14)));

      if (context.mounted) {
        await ref.watch(globalAddressParserProvider).humanReadableAddress(
              pos,
              context,
              ref,
            );
      }
    } catch (e) {
      if (context.mounted) {
        ErrorNotification().showError(context, "An Error Occurred $e");
      }
    }
  }

  void getDriverOnline(BuildContext context, WidgetRef ref,
      GoogleMapController controller) async {
    try {
      GeoPoint myLocation = GeoPoint(
          ref.read(homeScreenDriversLocationProvider)!.locationLatitude!,
          ref.read(homeScreenDriversLocationProvider)!.locationLongitude!);

      ref.read(globalFirestoreRepoProvider).setDriverLocationStatus(
            context,
            myLocation,
          );

      Geolocator.getPositionStream().listen((event) {
        GeoPoint newLocation = GeoPoint(event.latitude, event.longitude);
        ref.read(globalFirestoreRepoProvider).setDriverLocationStatus(
              context,
              newLocation,
            );
      });

      LatLng driverPos = LatLng(
          ref.read(homeScreenDriversLocationProvider)!.locationLatitude!,
          ref.read(homeScreenDriversLocationProvider)!.locationLongitude!);

      controller.animateCamera(CameraUpdate.newLatLng(driverPos));

      ref.read(globalFirestoreRepoProvider).setDriverStatus(context, "Idle");
      ref
          .watch(homeScreenIsDriverActiveProvider.notifier)
          .update((state) => true);
    } catch (e) {
      if (context.mounted) {
        ErrorNotification().showError(context, "An Error Occurred $e");
      }
    }
  }

  void getDriverOffline(BuildContext context, WidgetRef ref) async {
    try {
      ref
          .watch(homeScreenIsDriverActiveProvider.notifier)
          .update((state) => false);

      ref.read(globalFirestoreRepoProvider).setDriverStatus(context, "offline");

      ref
          .read(globalFirestoreRepoProvider)
          .setDriverLocationStatus(context, null);

      await Future.delayed(const Duration(seconds: 2));

      SystemChannels.platform.invokeMethod("SystemNavigator.pop");

      if (context.mounted) {
        ErrorNotification().showSuccess(context, "You are now Offline");
      }
    } catch (e) {
      if (context.mounted) {
        ErrorNotification().showError(context, "An Error Occurred $e");
      }
    }
  }

  void listenForRideRequests(BuildContext context, WidgetRef ref) {
    FirebaseFirestore.instance
        .collection('rideRequests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        var rideRequest = snapshot.docs.first;

        String userName = rideRequest['userName'];
        String userLocation = rideRequest['userLocation'];
        String destination = rideRequest['destination'];
        String rideRequestId = rideRequest.id;

        print(
            'Detected new ride request: $userName, $userLocation, $destination');

        Future.delayed(Duration(seconds: 30), () {
          print('Delay elapsed, showing dialog...');
          showRideRequestDialog(
              context, ref, userName, userLocation, destination, rideRequestId);
        });
      }
    });
  }

  void showRideRequestDialog(
      BuildContext context,
      WidgetRef ref,
      String userName,
      String userLocation,
      String destination,
      String rideRequestId) {
    print('Showing ride request dialog...');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('New Ride Request'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('User Name: $userName'),
              Text('User Location: $userLocation'),
              Text('Destination: $destination'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Decline'),
              onPressed: () {
                declineRideRequest(rideRequestId);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Accept'),
              onPressed: () {
                acceptRideRequest(context, ref, rideRequestId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void acceptRideRequest(
      BuildContext context, WidgetRef ref, String rideRequestId) async {
    try {
      await FirebaseFirestore.instance
          .collection('rideRequests')
          .doc(rideRequestId)
          .update({
        'status': 'accepted',
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ride request accepted!')),
        );
      }

      DocumentSnapshot requestDoc = await FirebaseFirestore.instance
          .collection('rideRequests')
          .doc(rideRequestId)
          .get();

      GeoPoint userLocation = requestDoc['userLocation'];
      String destination = requestDoc['destination'];

      ref
          .read(homeScreenProvider.notifier)
          .updateMapWithUserDetails(ref, destination, userLocation);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    }
  }

  void declineRideRequest(String rideRequestId) async {
    try {
      await FirebaseFirestore.instance
          .collection('rideRequests')
          .doc(rideRequestId)
          .update({
        'status': 'declined',
      });

      // The `context` should not be used here as it's not passed into this method
    } catch (e) {
      // The `context` should not be used here as it's not passed into this method
    }
  }
}
