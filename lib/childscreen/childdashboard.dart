import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class ChildDashboard extends StatefulWidget {
  final String childId;


  const ChildDashboard({
    super.key,
    required this.childId,
  });

  @override
  State<ChildDashboard> createState() => _ChildDashboardState();
}

class _ChildDashboardState extends State<ChildDashboard> {
  bool tracking = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Audio Player
  final AudioPlayer _player = AudioPlayer();

  bool _isBeeping = false;

  /// Firestore Listener
  StreamSubscription<DocumentSnapshot>? _sosSubscription;

  /// Location Listener
  StreamSubscription<Position>? _locationSubscription;

  @override
  void initState() {
    super.initState();

    _startTracking();

    _listenSOS();
  }

  //==================================================
  // SOS LISTENER
  //==================================================

  void _listenSOS() {
    _sosSubscription = _firestore
        .collection("children")
        .doc(widget.childId)
        .snapshots()
        .listen((snapshot) async {
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;

      final bool sos = data["sos"] ?? false;

      if (sos) {
        await _startBeep();
      } else {
        await _stopBeep();
      }
    });
  }

  //==================================================
  // START BEEP
  //==================================================

  Future<void> _startBeep() async {
    if (_isBeeping) return;

    _isBeeping = true;

    await _player.stop();

    await _player.setReleaseMode(ReleaseMode.loop);

    await _player.play(
      AssetSource("sound.mp3"),
    );
  }

  //==================================================
  // STOP BEEP
  //==================================================

  Future<void> _stopBeep() async {
    if (!_isBeeping) return;

    _isBeeping = false;

    await _player.stop();
  }

  //==================================================
  // LOCATION TRACKING
  //==================================================

  Future<void> _startTracking() async {
    bool serviceEnabled =
    await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      _showMessage("Please Enable GPS");
      return;
    }

    LocationPermission permission =
    await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      _showMessage("Location Permission Denied");
      return;
    }

    if (permission ==
        LocationPermission.deniedForever) {
      _showMessage(
          "Location permission permanently denied.\nEnable it from Settings.");
      return;
    }

    setState(() {
      tracking = true;
    });

    _startLocationStream();
  }

  void _startLocationStream() {
    _locationSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,

            distanceFilter: 1,
          ),
        ).listen((Position position) async {
          try {
            await _firestore
                .collection("children")
                .doc(widget.childId)
                .update({
              "latitude": position.latitude,
              "longitude": position.longitude,
              "tracking": true,
              "lastSeen": FieldValue.serverTimestamp(),
            });

            DocumentSnapshot snapshot = await _firestore
                .collection("children")
                .doc(widget.childId)
                .get();

            if (!snapshot.exists) return;

            final data = snapshot.data() as Map<String, dynamic>;

            bool geofenceEnabled = data["geofenceEnabled"] ?? false;

            if (geofenceEnabled) {

              double centerLat =
              (data["centerLat"] as num).toDouble();

              double centerLng =
              (data["centerLng"] as num).toDouble();

              double radius =
              (data["radius"] as num).toDouble();

              double distance = Geolocator.distanceBetween(
                position.latitude,
                position.longitude,
                centerLat,
                centerLng,
              );

              if (distance > radius) {
                await _startBeep();
              } else {
                await _stopBeep();
              }
            }

            debugPrint(
                "Location Updated -> ${position.latitude}, ${position.longitude}");
          } catch (e) {
            debugPrint("Firestore Error : $e");
          }
        });
  }

  //==================================================
  // UTILS
  //==================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _logout() async {
    final TextEditingController passwordController =
    TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Logout"),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Enter Password",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              child: const Text("Verify"),
              onPressed: () async {
                try {
                  final doc = await FirebaseFirestore.instance
                      .collection("children")
                      .doc(widget.childId)
                      .get();

                  if (!doc.exists) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Child not found"),
                      ),
                    );
                    return;
                  }

                  final data = doc.data()!;

                  String savedPassword = data["password"] ?? "";

                  if (passwordController.text.trim() != savedPassword) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Incorrect Password"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  Navigator.pop(context);

                  await _locationSubscription?.cancel();
                  await _sosSubscription?.cancel();
                  await _player.stop();

                  if (mounted) {
                    Navigator.pop(context);
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  //==================================================
  // DISPOSE
  //==================================================

  @override
  void dispose() {
    _locationSubscription?.cancel();

    _sosSubscription?.cancel();

    _player.dispose();

    super.dispose();
  }

  //==================================================
  // UI
  //==================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Child Dashboard"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.child_care,
              size: 90,
              color: Colors.blue,
            ),

            const SizedBox(height: 20),

            Text(
              widget.childId,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      tracking
                          ? Icons.location_on
                          : Icons.location_off,
                      size: 55,
                      color: tracking
                          ? Colors.green
                          : Colors.red,
                    ),

                    const SizedBox(height: 15),

                    Text(
                      tracking
                          ? "📡 Live Tracking Started"
                          : "Waiting For Location Permission",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text(
                  "Logout",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}