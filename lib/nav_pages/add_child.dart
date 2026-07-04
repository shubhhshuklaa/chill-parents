import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddChildPage extends StatefulWidget {
  const AddChildPage({super.key});

  @override
  State<AddChildPage> createState() => _AddChildPageState();
}

class _AddChildPageState extends State<AddChildPage> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  File? imageFile;

  bool isLoading = false;

  final ImagePicker picker = ImagePicker();

  Future<void> pickImage(ImageSource source) async {
    final XFile? pickedImage =
    await picker.pickImage(source: source, imageQuality: 70);

    if (pickedImage != null) {
      setState(() {
        imageFile = File(pickedImage.path);
      });
    }
  }

  void showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [

              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.camera);
                },
              ),

              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.gallery);
                },
              ),

            ],
          ),
        );
      },
    );
  }


    Future<void> saveChild() async {

      if (!_formKey.currentState!.validate()) return;

      if (imageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please Select Child Photo"),
          ),
        );
        return;
      }

      try {

        setState(() {
          isLoading = true;
        });

        // Check Duplicate Child ID
        DocumentSnapshot childDoc = await FirebaseFirestore.instance
            .collection("children")
            .doc(idController.text.trim())
            .get();

        if (childDoc.exists) {

          setState(() {
            isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Child ID Already Exists"),
            ),
          );

          return;
        }

        // Upload Image


        // Save Firestore
        await FirebaseFirestore.instance
            .collection("children")
            .doc(idController.text.trim())
            .set({

          "name": nameController.text.trim(),
          "childId": idController.text.trim(),
          "password": passwordController.text.trim(),

          "photo": 'null',

          "parentId": FirebaseAuth.instance.currentUser!.uid,

          "latitude": 0.0,
          "longitude": 0.0,

          "lastSeen": FieldValue.serverTimestamp(),

          "createdAt": FieldValue.serverTimestamp(),

        });

        setState(() {
          isLoading = false;
          imageFile = null;
        });

        nameController.clear();
        idController.clear();
        passwordController.clear();
        confirmPasswordController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Child Added Successfully"),
            backgroundColor: Colors.green,
          ),
        );

      } catch (e) {

        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );

      }

    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Child"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(

            children: [

              GestureDetector(
                onTap: showImagePicker,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade300,

                  backgroundImage:
                  imageFile != null ? FileImage(imageFile!) : null,

                  child: imageFile == null
                      ? const Icon(
                    Icons.camera_alt,
                    size: 40,
                    color: Colors.white,
                  )
                      : null,
                ),
              ),

              const SizedBox(height: 30),

              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Child Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Enter Child Name";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: idController,
                decoration: const InputDecoration(
                  labelText: "Child ID",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Enter Child ID";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Enter Password";
                  }

                  if (value.length < 6) {
                    return "Minimum 6 Characters";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Confirm Password",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != passwordController.text) {
                    return "Password Doesn't Match";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(

                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      saveChild();
                    }
                  },

                  child: isLoading
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : const Text(
                    "SAVE CHILD",
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  ),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}