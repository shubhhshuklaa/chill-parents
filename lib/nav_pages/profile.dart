import 'package:chill_parents/Screens/parent_login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class ParentProfilePage extends StatelessWidget {
  const ParentProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: const Color(0xffF5F8FF),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.blue,
        title: const Text(
          "My Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection("parents")
            .doc(user!.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                "Profile not found",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                //==========================
                // Profile Avatar
                //==========================
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.shade100,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 70,
                    color: Colors.blue,
                  ),
                ),

                const SizedBox(height: 20),
                Text(
                  data["name"] ?? "",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  data["email"] ?? "",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 30),

                profileCard(
                  icon: Icons.person_outline,
                  title: "Full Name",
                  value: data["name"] ?? "",
                ),

                profileCard(
                  icon: Icons.phone_android,
                  title: "Mobile Number",
                  value: data["mobile"] ?? "",
                ),

                profileCard(
                  icon: Icons.email_outlined,
                  title: "Email",
                  value: data["email"] ?? "",
                ),

                profileCard(
                  icon: Icons.verified_user,
                  title: "User ID",
                  value: user.uid,
                ),

                const SizedBox(height: 30),

                //==========================
                // Edit Button
                //==========================
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Edit Profile Coming Soon"),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text(
                      "Edit Profile",
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                //==========================
                // Logout Button
                //==========================
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                      onPressed: () {
                        final TextEditingController passController = TextEditingController();

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Confirm Logout"),
                              content: TextField(
                                controller: passController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: "Enter Password",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Cancel"),
                                ),

                                ElevatedButton(
                                  child: const Text("Verify"),
                                  onPressed: () async {
                                    try {
                                      final user = FirebaseAuth.instance.currentUser;

                                      if (user == null) return;

                                      // Password verify
                                      AuthCredential credential =
                                      EmailAuthProvider.credential(
                                        email: user.email!,
                                        password: passController.text.trim(),
                                      );

                                      await user.reauthenticateWithCredential(credential);

                                      // Dialog Close
                                      Navigator.pop(context);

                                      // Logout
                                      await FirebaseAuth.instance.signOut();

                                      if (!context.mounted) return;

                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const ParentLoginScreen(),
                                        ),
                                            (route) => false,
                                      );
                                    } on FirebaseAuthException catch (e) {
                                      String message = "Verification Failed";

                                      if (e.code == "wrong-password" ||
                                          e.code == "invalid-credential") {
                                        message = "Incorrect Password";
                                      } else if (e.code == "too-many-requests") {
                                        message = "Too many attempts. Try again later.";
                                      }

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(message),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },

                    icon: const Icon(Icons.logout),
                    label: const Text(
                      "Logout",
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget profileCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(
            icon,
            color: Colors.blue,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}