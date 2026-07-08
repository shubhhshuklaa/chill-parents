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
        MaterialPageRoute(builder: (_) => const ParentDashboard()),
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
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
      backgroundColor: const Color(0xffF6F9FF),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              left: -80,
              bottom: -100,
              child: Container(
                width: 280,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(.08),
                  borderRadius: BorderRadius.circular(200),
                ),
              ),
            ),

            Positioned(
              right: -80,
              bottom: -70,
              child: Container(
                width: 300,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(.08),
                  borderRadius: BorderRadius.circular(200),
                ),
              ),
            ),

            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),

              child: Form(
                key: _formKey,

                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,

                          backgroundColor: Colors.white,

                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Color(0xff14213D),
                            ),

                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Parent Login",

                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff14213D),
                      ),
                    ),

                    const SizedBox(height: 30),

                    Container(
                      height: 180,
                      width: 180,

                      decoration: BoxDecoration(
                        shape: BoxShape.circle,

                        color: Colors.white,

                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(.08),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),

                      child: const Center(
                        child: Icon(
                          Icons.family_restroom,
                          color: Colors.blue,
                          size: 110,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      "Welcome Back",

                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff14213D),
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Sign in to continue and keep your child safe.",

                      textAlign: TextAlign.center,

                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),

                    const SizedBox(height: 35),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter Email";
                        }
                        if (!value.contains("@")) {
                          return "Enter Valid Email";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "Email",
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xffEEF4FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.email_outlined,
                            color: Colors.blue,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    TextFormField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return "Minimum 6 Characters";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "Password",
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xffEEF4FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.lock_outline,
                            color: Colors.blue,
                          ),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.blue,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

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
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(
                            colors: [Color(0xff4C9BFF), Color(0xff0057FF)],
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: isLoading ? null : loginParent,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(fontSize: 16),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ParentRegisterScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Create Account",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
