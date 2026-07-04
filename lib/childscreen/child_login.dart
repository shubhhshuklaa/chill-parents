import 'package:chill_parents/childscreen/childdashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChildLoginPage extends StatefulWidget {
  const ChildLoginPage({super.key});

  @override
  State<ChildLoginPage> createState() => _ChildLoginPageState();
}

class _ChildLoginPageState extends State<ChildLoginPage> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController childIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> loginChild() async {

    if (!_formKey.currentState!.validate()) return;

    try {

      setState(() {
        isLoading = true;
      });

      DocumentSnapshot childDoc = await FirebaseFirestore.instance
          .collection("children")
          .doc(childIdController.text.trim())
          .get();

      if (!childDoc.exists) {

        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Child ID Not Found"),
          ),
        );

        return;
      }

      if (childDoc["password"] != passwordController.text.trim()) {

        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Wrong Password"),
          ),
        );

        return;
      }

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login Successful"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChildDashboard(

          ),
        ),
      );

    } catch (e) {

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );

    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Child Login"),
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Form(

          key: _formKey,

          child: Column(

            children: [

              const SizedBox(height: 40),

              TextFormField(

                controller: childIdController,

                decoration: const InputDecoration(

                  labelText: "Child ID",

                  border: OutlineInputBorder(),

                ),

                validator: (value) {

                  if (value == null || value.isEmpty) {

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

                  if (value == null || value.isEmpty) {

                    return "Enter Password";

                  }

                  return null;

                },

              ),

              const SizedBox(height: 30),

              SizedBox(

                width: double.infinity,

                height: 55,

                child: ElevatedButton(

                  onPressed: loginChild,

                  child: isLoading
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : const Text(
                    "LOGIN",
                    style: TextStyle(fontSize: 18),
                  ),

                ),

              ),

            ],

          ),

        ),

      ),

    );

  }
  

}