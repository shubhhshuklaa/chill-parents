import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'parent_login.dart';

class ParentRegisterScreen extends StatefulWidget {
  const ParentRegisterScreen({super.key});

  @override
  State<ParentRegisterScreen> createState() => _ParentRegisterScreenState();
}

class _ParentRegisterScreenState extends State<ParentRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  Future<void> registerParent() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() {
        isLoading = true;
      });

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      await userCredential.user!.updateDisplayName(nameController.text.trim());

      await userCredential.user!.reload();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registration Successful"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ParentLoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String message = e.message ?? "Registration Failed";

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
      backgroundColor: const Color(0xffF5F8FF),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),

              //=====================
              // Header
              //=====================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(18),

                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,

                            blurRadius: 10,

                            offset: Offset(0, 4),
                          ),
                        ],
                      ),

                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },

                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.blue,
                        ),
                      ),
                    ),

                    const SizedBox(width: 20),

                    const Text(
                      "Parent Register",

                      style: TextStyle(
                        fontSize: 24,

                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              //=====================
              // Illustration
              //=====================
              Container(
                height: 190,

                width: 190,

                decoration: BoxDecoration(
                  color: Colors.white,

                  shape: BoxShape.circle,

                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(.15),

                      blurRadius: 25,
                    ),
                  ],
                ),

                child: const Center(
                  child: Icon(
                    Icons.family_restroom,

                    color: Colors.blue,

                    size: 95,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              //=====================
              // Register Card
              //=====================
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),

                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(30),

                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 20),
                  ],
                ),

                child: Form(
                  key: _formKey,

                  child: Column(
                    children: [
                      //=========================
                      // Full Name
                      //=========================
                      TextFormField(
                        controller: nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter Full Name";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Enter your full name",
                          labelText: "Full Name",
                          prefixIcon: const Icon(
                            Icons.person_outline,
                            color: Colors.blue,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      //=========================
                      // Mobile Number
                      //=========================
                      TextFormField(
                        controller: mobileController,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.length != 10) {
                            return "Enter Valid Mobile Number";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Enter your mobile number",
                          labelText: "Mobile Number",
                          prefixIcon: const Icon(
                            Icons.phone_android,
                            color: Colors.blue,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      //=========================
                      // Email
                      //=========================
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || !value.contains("@")) {
                            return "Enter Valid Email";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Enter your email",
                          labelText: "Email",
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: Colors.blue,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      //=========================
                      // Password
                      //=========================
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
                          hintText: "Enter your password",
                          labelText: "Password",
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Colors.blue,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      //=========================
                      // Create Account Button
                      //=========================
                      Container(
                        width: double.infinity,
                        height: 58,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(
                            colors: [Color(0xff4A90FF), Color(0xff005CFF)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(.35),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: isLoading ? null : registerParent,
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
                                  "Create Account",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ParentLoginScreen(),
                            ),
                          );
                        },
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                            children: [
                              TextSpan(text: "Already have an account? "),
                              TextSpan(
                                text: "Login",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
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

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
