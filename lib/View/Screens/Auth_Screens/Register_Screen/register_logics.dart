import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logitrust_drivers/Container/Repositories/auth_repo.dart';
import 'package:logitrust_drivers/Container/utils/error_notification.dart';
import 'package:logitrust_drivers/View/Screens/Auth_Screens/Register_Screen/register_providers.dart';

class RegisterLogics {
  void registerUser(
      BuildContext context,
      WidgetRef ref,
      TextEditingController nameController,
      TextEditingController emailController,
      TextEditingController passwordController) {
    try {
      if (nameController.text.isEmpty ||
          emailController.text.isEmpty ||
          passwordController.text.isEmpty) {
        ErrorNotification()
            .showError(context, "Please Enter Email and Password");

        return;
      }

      ref.watch(registerIsLoadingProvider.notifier).update((state) => true);
      ref.watch(globalAuthRepoProvider).registerUser(
          emailController.text.trim(), passwordController.text.trim(), context);

      ref.watch(registerIsLoadingProvider.notifier).update((state) => false);
    } catch (e) {
      ref.watch(registerIsLoadingProvider.notifier).update((state) => false);
      ErrorNotification().showError(context, "An Error Occurred $e");
    }
  }
}
