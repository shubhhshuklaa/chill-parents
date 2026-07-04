import 'package:chill_parents/Screens/parent_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'parent_register.dart';

class ParentLoginScreen extends StatefulWidget {
  const ParentLoginScreen({super.key});

  @override
  State<ParentLoginScreen> createState() => _ParentLoginScreenState();
}

class _ParentLoginScreenState extends State<ParentLoginScreen> {

  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  Future<void> loginParent() async {

    if (!_formKey.currentState!.validate()) return;

    try {

      setState(() {
        isLoading = true;
      });

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ParentDashboard(),
        ),
      );

    } on FirebaseAuthException catch (e) {

      String message = "Login Failed";

      switch (e.code) {

        case "user-not-found":
          message = "No account found.";
          break;

        case "wrong-password":
          message = "Wrong password.";
          break;

        case "invalid-credential":
          message = "Invalid Email or Password.";
          break;

        case "invalid-email":
          message = "Invalid Email.";
          break;

        default:
          message = e.message ?? "Login Failed";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

    } finally {

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Parent Login"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Form(

          key: _formKey,

          child: Column(

            children: [

              const SizedBox(height: 30),

              const Icon(
                Icons.family_restroom,
                size: 90,
                color: Colors.blue,
              ),

              const SizedBox(height: 20),

              const Text(
                "Welcome Back",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              TextFormField(

                controller: emailController,

                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),

                validator: (value) {

                  if (value == null || value.isEmpty) {
                    return "Enter Email";
                  }

                  if (!value.contains("@")) {
                    return "Enter Valid Email";
                  }

                  return null;

                },

              ),

              const SizedBox(height: 20),

              TextFormField(

                controller: passwordController,

                obscureText: obscurePassword,

                decoration: InputDecoration(

                  labelText: "Password",

                  border: const OutlineInputBorder(),

                  prefixIcon: const Icon(Icons.lock),

                  suffixIcon: IconButton(

                    onPressed: () {

                      setState(() {

                        obscurePassword = !obscurePassword;

                      });

                    },

                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),

                  ),

                ),

                validator: (value) {

                  if (value == null || value.length < 6) {
                    return "Minimum 6 Characters";
                  }

                  return null;

                },

              ),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Forgot Password Coming Soon"),
                      ),
                    );

                  },
                  child: const Text("Forgot Password?"),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(

                width: double.infinity,
                height: 55,

                child: ElevatedButton(

                  onPressed: isLoading
                      ? null
                      : loginParent,

                  child: isLoading
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : const Text(
                    "Login",
                    style: TextStyle(fontSize: 18),
                  ),

                ),

              ),

              const SizedBox(height: 20),

              Row(

                mainAxisAlignment: MainAxisAlignment.center,

                children: [

                  const Text("Don't have an account?"),

                  TextButton(

                    onPressed: () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (_) =>
                          const ParentRegisterScreen(),

                        ),

                      );

                    },

                    child: const Text("Create Account"),

                  )

                ],

              )

            ],

          ),

        ),

      ),

    );

  }

}