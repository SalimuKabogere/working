import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logitrust_drivers/View/Components/all_components.dart';
import 'package:logitrust_drivers/View/Routes/routes.dart';
import 'package:logitrust_drivers/View/Screens/Auth_Screens/Login_Screen/login_logics.dart';
import 'package:logitrust_drivers/View/Screens/Auth_Screens/Login_Screen/login_providers.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: SafeArea(
        child: InkWell(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: Stack(
              children: [
                Container(
                  width: size.width,
                  height: size.height,
                  color: Colors.white,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: Text(
                        "Logitrust",
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(
                                fontFamily: "bold",
                                fontSize: 24,
                                color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Text(
                        "Login",
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontFamily: "bold",
                            fontSize: 20,
                            color: Colors.black),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 20),
                        child: Form(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Components().returnTextField(emailController,
                                  context, false, "Enter Email"),
                              const SizedBox(height: 20),
                              Components().returnTextField(passwordController,
                                  context, true, "Enter Password"),
                              const SizedBox(height: 20),
                              Consumer(builder: (context, ref, child) {
                                return InkWell(
                                  onTap: ref.watch(loginIsLoadingProvider)
                                      ? null
                                      : () => LoginLogics().loginUser(
                                          context,
                                          ref,
                                          emailController,
                                          passwordController),
                                  child: Components().mainButton(
                                      size,
                                      ref.watch(loginIsLoadingProvider)
                                          ? "Loading ..."
                                          : "Login",
                                      context,
                                      ref.watch(loginIsLoadingProvider)
                                          ? Colors.grey
                                          : Colors.blue),
                                );
                              }),
                              TextButton(
                                onPressed: () {
                                  context.goNamed(Routes().register);
                                },
                                child: Text(
                                  "Don't have an account? Sign Up.",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                          fontFamily: "bold",
                                          fontSize: 15,
                                          color: Colors.red),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
