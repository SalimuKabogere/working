import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logitrust_drivers/Model/driver_info_model.dart';

class EditProfileScreen extends StatefulWidget {
  final DriverInfoModel driverInfo;
  const EditProfileScreen({required this.driverInfo, Key? key})
      : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController truckNameController = TextEditingController();
  final TextEditingController truckPlateNumController = TextEditingController();
  final TextEditingController licenseExpiryController = TextEditingController();
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.driverInfo.name;
    emailController.text = widget.driverInfo.email;
    truckNameController.text = widget.driverInfo.truckName;
    truckPlateNumController.text = widget.driverInfo.truckPlateNum;
    // Assuming this field exists in DriverInfoModel
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImageToFirebase() async {
    if (_profileImage == null) return '';

    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference =
        FirebaseStorage.instance.ref().child('profile_images/$fileName');
    UploadTask uploadTask = reference.putFile(_profileImage!);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _updateProfile() async {
    String profileImageUrl = await _uploadImageToFirebase();
    FirebaseFirestore db = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;

    db.collection("Drivers").doc(auth.currentUser!.email).update({
      'name': nameController.text,
      'email': emailController.text,
      'Truck Name': truckNameController.text,
      'Truck Plate Num': truckPlateNumController.text,
      'License Expiry Date': licenseExpiryController.text,
      if (profileImageUrl.isNotEmpty) 'profileImage': profileImageUrl,
    }).then((_) {
      print('Profile updated successfully!');
      Navigator.pop(context);
    }).catchError((error) {
      print('Failed to update profile: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    _profileImage != null ? FileImage(_profileImage!) : null,
                child: _profileImage == null
                    ? const Icon(Icons.camera_alt, size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: truckNameController,
              decoration: const InputDecoration(labelText: 'Truck Name'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: truckPlateNumController,
              decoration:
                  const InputDecoration(labelText: 'Truck Plate Number'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: licenseExpiryController,
              decoration:
                  const InputDecoration(labelText: 'License Expiry Date'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              child: const Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
