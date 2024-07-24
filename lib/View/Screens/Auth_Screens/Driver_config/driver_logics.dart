import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logitrust_drivers/Container/Repositories/firestore_repo.dart';
import 'package:logitrust_drivers/Container/utils/error_notification.dart';
import 'package:logitrust_drivers/View/Routes/routes.dart';
import 'package:logitrust_drivers/View/Screens/Auth_Screens/Driver_config/driver_providers.dart';

class DriverLogics {
  void sendDataToFirestore(
    BuildContext context,
    ref,
    TextEditingController truckNameController,
    TextEditingController truckPlateNumController,
    String licenceExpiryDate,
    File? frontImageFile,
    File? backImageFile,
  ) async {
    try {
      if (truckNameController.text.isEmpty ||
          truckPlateNumController.text.isEmpty) {
        ErrorNotification().showError(
            context, "Please Enter Truck Name and Truck Plate Number");

        return;
      }
      ref.watch(driverConfigIsLoadingProvider.notifier).update((state) => true);

      ref.watch(globalFirestoreRepoProvider).addDriversDataToFirestore(
          context,
          truckNameController.text.trim(),
          truckPlateNumController.text.trim(),
          ref.watch(driverConfigDropDownProvider)!);

      if (context.mounted) {
        context.goNamed(Routes().navigationScreen);
      }
    } catch (e) {
      ref
          .watch(driverConfigIsLoadingProvider.notifier)
          .update((state) => false);
      ErrorNotification().showError(context, "An Error Occurred $e");
    }
  }
}
