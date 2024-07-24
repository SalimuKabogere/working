import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logitrust_drivers/Model/direction_model.dart';

final homeScreenDriversLocationProvider = StateProvider<Direction?>((ref) {
  return null;
});

final homeScreenMainPolylinesProvider = StateProvider<Set<Polyline>>((ref) {
  return {};
});

final homeScreenMainMarkersProvider = StateProvider<Set<Marker>>((ref) {
  return {};
});

final homeScreenMainCirclesProvider = StateProvider<Set<Circle>>((ref) {
  return {};
});

final homeScreenIsDriverActiveProvider = StateProvider<bool>((ref) {
  return false;
});

// New provider for GoogleMapController
final googleMapControllerProvider = StateProvider<GoogleMapController?>((ref) {
  return null;
});

class HomeScreenNotifier extends StateNotifier<GoogleMapController?> {
  HomeScreenNotifier() : super(null);

  void setController(GoogleMapController controller) {
    state = controller;
  }

  void updateMapWithUserDetails(
      WidgetRef ref, String destination, GeoPoint userLocation) {
    final controller = state;
    if (controller != null) {
      controller.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(userLocation.latitude, userLocation.longitude),
        14,
      ));

      final markers = ref.read(homeScreenMainMarkersProvider);
      markers.clear();
      markers.add(
        Marker(
          markerId: MarkerId('userLocationMarker'),
          position: LatLng(userLocation.latitude, userLocation.longitude),
          infoWindow: InfoWindow(
            title: 'User Location',
            snippet: 'Destination: $destination',
          ),
        ),
      );

      ref.read(homeScreenMainMarkersProvider.notifier).state = markers;
    }
  }
}

final homeScreenProvider =
    StateNotifierProvider<HomeScreenNotifier, GoogleMapController?>((ref) {
  return HomeScreenNotifier();
});
