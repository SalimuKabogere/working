import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logitrust_drivers/View/Components/all_components.dart';
import 'package:logitrust_drivers/View/Screens/Auth_Screens/Driver_config/driver_logics.dart';
import 'package:logitrust_drivers/View/Screens/Auth_Screens/Driver_config/driver_providers.dart';

class DriverConfigsScreen extends StatefulWidget {
  const DriverConfigsScreen({super.key});

  @override
  State<DriverConfigsScreen> createState() => _DriverConfigsScreenState();
}

class _DriverConfigsScreenState extends State<DriverConfigsScreen> {
  final TextEditingController truckNameController = TextEditingController();
  final TextEditingController truckPlateNumController = TextEditingController();
  final TextEditingController licenceExpiryController = TextEditingController();
  File? _frontImageFile;
  File? _backImageFile;

  Future<void> _pickImage(ImageSource source, bool isFront) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (isFront) {
          _frontImageFile = File(pickedFile.path);
        } else {
          _backImageFile = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        licenceExpiryController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Column(
              children: [
                Text(
                  "Driver Config",
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(fontFamily: "bold", fontSize: 20),
                ),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 20.0, left: 20, right: 20),
                    child: Consumer(
                      builder: (context, ref, child) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Components().returnTextField(truckNameController,
                                context, false, "Please Enter Truck Name"),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Components().returnTextField(
                                  truckPlateNumController,
                                  context,
                                  false,
                                  "Please Enter Truck Plate Number"),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: SizedBox(
                                width: size.width * 0.7,
                                child: DropdownButton(
                                  value:
                                      ref.watch(driverConfigDropDownProvider),
                                  onChanged: (val) {
                                    ref
                                        .watch(driverConfigDropDownProvider
                                            .notifier)
                                        .update((state) => val);
                                  },
                                  dropdownColor: Colors.black45,
                                  isExpanded: true,
                                  underline: Container(),
                                  hint: Text(
                                    "Select Truck",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                            fontFamily: "medium", fontSize: 14),
                                  ),
                                  items: [
                                    DropdownMenuItem(
                                        value: "Big Truck",
                                        child: Text(
                                          "Big Truck",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                  fontFamily: "medium",
                                                  fontSize: 14),
                                        )),
                                    DropdownMenuItem(
                                        value: "Medium Truck",
                                        child: Text(
                                          "Medium Truck",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                  fontFamily: "medium",
                                                  fontSize: 14),
                                        )),
                                    DropdownMenuItem(
                                        value: "Small Truck",
                                        child: Text(
                                          "Small Truck",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                  fontFamily: "medium",
                                                  fontSize: 14),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: TextField(
                                controller: licenceExpiryController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  hintText: "Select Licence Expiry Date",
                                  border: OutlineInputBorder(),
                                ),
                                onTap: () => _selectDate(context),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  GestureDetector(
                                    onTap: () =>
                                        _pickImage(ImageSource.gallery, true),
                                    child: _frontImageFile == null
                                        ? Container(
                                            width: size.width * 0.3,
                                            height: size.width * 0.3,
                                            color: Colors.grey.withOpacity(0.3),
                                            child: Center(
                                              child: Text(
                                                "Front Truck Image",
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          )
                                        : Image.file(
                                            _frontImageFile!,
                                            width: size.width * 0.3,
                                            height: size.width * 0.3,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                  GestureDetector(
                                    onTap: () =>
                                        _pickImage(ImageSource.gallery, false),
                                    child: _backImageFile == null
                                        ? Container(
                                            width: size.width * 0.3,
                                            height: size.width * 0.3,
                                            color: Colors.grey.withOpacity(0.3),
                                            child: Center(
                                              child: Text(
                                                "Back Truck Image",
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          )
                                        : Image.file(
                                            _backImageFile!,
                                            width: size.width * 0.3,
                                            height: size.width * 0.3,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 30.0),
                              child: Consumer(
                                builder: (context, ref, child) {
                                  return InkWell(
                                    onTap: ref.watch(
                                            driverConfigIsLoadingProvider)
                                        ? null
                                        : () =>
                                            DriverLogics().sendDataToFirestore(
                                              context,
                                              ref,
                                              truckNameController,
                                              truckPlateNumController,
                                              licenceExpiryController.text,
                                              _frontImageFile,
                                              _backImageFile,
                                            ),
                                    child: Components().mainButton(
                                      size,
                                      ref.watch(driverConfigIsLoadingProvider)
                                          ? "Loading ..."
                                          : "Submit Data",
                                      context,
                                      ref.watch(driverConfigIsLoadingProvider)
                                          ? Colors.grey
                                          : Colors.blue,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
