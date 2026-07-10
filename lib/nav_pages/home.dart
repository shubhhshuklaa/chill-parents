import 'dart:async';

import 'package:chill_parents/nav_pages/tracking_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = FirebaseAuth.instance.currentUser;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  StreamSubscription<Position>? parentLocationStream;

  bool tracking = false;

  @override
  void initState() {
    super.initState();

    startParentTracking();
  }

  Future<void> startParentTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    setState(() {
      tracking = true;
    });

    parentLocationStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 5,
          ),
        ).listen((Position position) async {
          if (user == null) return;

          await firestore.collection("parents").doc(user!.uid).set({
            "uid": user!.uid,
            "parentName": user!.displayName ?? user!.email ?? "Parent",
            "latitude": position.latitude,
            "longitude": position.longitude,
            "tracking": true,
            "updatedAt": FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          debugPrint("Parent : ${position.latitude}, ${position.longitude}");
        });
  }

  @override
  void dispose() {
    parentLocationStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F8FC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Good Morning 👋",
                style: GoogleFonts.poppins(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Welcome Back, ${user?.displayName ?? user?.email ?? "Parent"}",
                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 20),
              ),

              const SizedBox(height: 25),

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Image.asset(
                    "assets/images/hhd.jpg",
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.2,
                children: [
                  DashboardCard(
                    title: "Tracking",
                    value: tracking ? "LIVE" : "OFF",
                    icon: Icons.location_on,
                  ),

                  const DashboardCard(
                    title: "Children",
                    value: "1",
                    icon: Icons.child_care,
                  ),

                  const DashboardCard(
                    title: "Alerts",
                    value: "0",
                    icon: Icons.notifications,
                  ),

                  DashboardCard(
                    title: "Parent",
                    value: tracking ? "ONLINE" : "OFFLINE",
                    icon: Icons.person_pin_circle,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Text(
                "Quick Actions",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TrackingMapPage(
                            childId: "CHILD_UID",
                            childName: "My Child",
                          ),
                        ),
                      );
                    },
                    child: quick(Icons.location_on, "Track"),
                  ),

                  quick(Icons.child_care, "Child"),

                  quick(Icons.phone, "SOS"),

                  quick(Icons.person, "Profile"),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget quick(IconData icon, String text) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.indigo.shade50,
          child: Icon(icon, color: Colors.indigo),
        ),

        const SizedBox(height: 8),

        Text(text, style: GoogleFonts.poppins()),
      ],
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(.15), blurRadius: 10),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CircleAvatar(
              backgroundColor: Colors.indigo.shade100,
              child: Icon(icon, color: Colors.indigo),
            ),

            Text(
              value,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),

            Text(title),
          ],
        ),
      ),
    );
  }
}
