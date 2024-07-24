import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logitrust_drivers/View/Screens/Auth_Screens/Register_Screen/register_logics.dart';
import 'package:logitrust_drivers/View/Screens/Auth_Screens/Register_Screen/register_providers.dart';
import '../../../Components/all_components.dart';
import '../../../Routes/routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: InkWell(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 40.0, bottom: 20.0),
                    child: Text(
                      "Logitrust",
                      style: TextStyle(
                        fontFamily: "bold",
                        fontSize: 28,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: Text(
                      "Register",
                      style: TextStyle(
                        fontFamily: "bold",
                        fontSize: 24,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Form(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Components().returnTextField(
                            nameController,
                            context,
                            false,
                            "Enter Name",
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Components().returnTextField(
                              emailController,
                              context,
                              false,
                              "Enter Email",
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Components().returnTextField(
                              passwordController,
                              context,
                              true,
                              "Enter Password",
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Consumer(
                              builder: (context, ref, child) {
                                return InkWell(
                                  onTap: ref.watch(registerIsLoadingProvider)
                                      ? null
                                      : () => RegisterLogics().registerUser(
                                          context,
                                          ref,
                                          nameController,
                                          emailController,
                                          passwordController),
                                  child: Components().mainButton(
                                    size,
                                    ref.watch(registerIsLoadingProvider)
                                        ? "Loading ..."
                                        : "Register",
                                    context,
                                    ref.watch(registerIsLoadingProvider)
                                        ? Colors.grey
                                        : Colors.blue,
                                  ),
                                );
                              },
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              context.goNamed(Routes().login);
                            },
                            child: const Text(
                              "Login.",
                              style: TextStyle(
                                fontFamily: "bold",
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
