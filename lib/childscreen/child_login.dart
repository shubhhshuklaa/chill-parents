import 'package:chill_parents/childscreen/childdashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
  bool obscurePassword = true;

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

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Child ID Not Found")));
        return;
      }

      if (childDoc["password"] != passwordController.text.trim()) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Wrong Password")));
        return;
      }

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text("Login Successful"),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChildDashboard(
            childId: childIdController.text.trim(),
          ),
        ),
      );

    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
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
              //======================
              // Header
              //======================
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

                    const SizedBox(width: 18),

                    const Text(
                      "Child Login",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              //======================
              // Illustration
              //======================
              Container(
                height: 180,
                width: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(.12),
                      blurRadius: 25,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.child_care, size: 95, color: Colors.blue),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Welcome!",
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                "Login to your account and stay connected.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 35),

              //======================
              // Login Card
              //======================
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
                ),

                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Part-2 se continue hoga...
                      //======================
                      // Child ID
                      //======================
                      TextFormField(
                        controller: childIdController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter Child ID";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Enter Child ID",
                          labelText: "Child ID",
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.person_outline,
                              color: Colors.blue,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(color: Colors.blue.shade100),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      //======================
                      // Password
                      //======================
                      TextFormField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter Password";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Enter Password",
                          labelText: "Password",
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.lock_outline,
                              color: Colors.blue,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(color: Colors.blue.shade100),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 35),

                      //======================
                      // Login Button
                      //======================
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: const LinearGradient(
                              colors: [Color(0xff4A90FF), Color(0xff0057FF)],
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
                            onPressed: isLoading ? null : loginChild,
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
                                    "LOGIN",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
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
    childIdController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
