import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';


class TrackingMapPage extends StatefulWidget {

  final String childId;
  final String childName;

  const TrackingMapPage({
    super.key,
    required this.childId,
    required this.childName,
  });

  @override
  State<TrackingMapPage> createState() => _TrackingMapPageState();
}

class _TrackingMapPageState extends State<TrackingMapPage> {
  final String parentId = FirebaseAuth.instance.currentUser!.uid;


  final AudioPlayer audioPlayer = AudioPlayer();

  Future<void> playBeep() async {
    await audioPlayer.setReleaseMode(ReleaseMode.loop);

    await audioPlayer.play(
      AssetSource("beep.mp3"),
    );
  }

  Future<void> stopBeep() async {
    await audioPlayer.stop();
  }

  GoogleMapController? _mapController;

  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};

  StreamSubscription<DocumentSnapshot>? _subscription;

  static const LatLng _defaultLocation = LatLng(28.6139, 77.2090);

  final TextEditingController radiusController = TextEditingController();

  double currentLat = 0;
  double currentLng = 0;
  double? parentLat;
  double? parentLng;

  double safeRadius = 100;

  double geofenceCenterLat = 0;
  double geofenceCenterLng = 0;

  bool isOutside = false;

  @override
  void initState() {
    super.initState();
    _listenLocation();
    getParentLocation();
    listenChildLocation();
  }

  void listenChildLocation() {
    FirebaseFirestore.instance
        .collection("children")
        .doc(widget.childId)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) return;

      var data = snapshot.data()!;

      double childLat = (data["latitude"] as num).toDouble();
      double childLng = (data["longitude"] as num).toDouble();

      safeRadius = (data["radius"] as num?)?.toDouble() ?? 100;

      geofenceCenterLat =
          (data["centerLat"] as num?)?.toDouble() ?? childLat;

      geofenceCenterLng =
          (data["centerLng"] as num?)?.toDouble() ?? childLng;

      checkDistance(
        childLat,
        childLng,
      );
    });
  }


  void checkDistance(
      double childLat,
      double childLng,
      ) {
    double distance = Geolocator.distanceBetween(
      geofenceCenterLat,
      geofenceCenterLng,
      childLat,
      childLng,
    );

    print("Distance = $distance");
    print("Radius = $safeRadius");

    if (distance > safeRadius) {
      if (!isOutside) {
        isOutside = true;
        playBeep();
      }
    } else {
      if (isOutside) {
        isOutside = false;
        stopBeep();
      }
    }
  }

  void _listenLocation() {
    _subscription = FirebaseFirestore.instance
        .collection("children")
        .doc(widget.childId)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;

      if (!data.containsKey("latitude") ||
          !data.containsKey("longitude")) {
        return;
      }

      final double lat = (data["latitude"] as num).toDouble();
      final double lng = (data["longitude"] as num).toDouble();

      currentLat = lat;
      currentLng = lng;

      final LatLng location = LatLng(lat, lng);

      setState(() {
        _markers.clear();

        _markers.add(
          Marker(
            markerId: const MarkerId("child"),
            position: location,
            infoWindow: InfoWindow(title: widget.childName),
          ),
        );

        // ---------- GEOFENCE CIRCLE ----------

        _circles.clear();

        if (data["geofenceEnabled"] == true &&
            data["centerLat"] != null &&
            data["centerLng"] != null &&
            data["radius"] != null) {

          _circles.add(
            Circle(
              circleId: const CircleId("geofence"),

              center: LatLng(
                (data["centerLat"] as num).toDouble(),
                (data["centerLng"] as num).toDouble(),
              ),

              radius: (data["radius"] as num).toDouble(),

              strokeColor: Colors.red,
              strokeWidth: 3,
              fillColor: Colors.red.withOpacity(0.20),
            ),
          );
        }
      });

      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: location,
            zoom: 17,
          ),
        ),
      );
    });
  }

  void getParentLocation() {

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),

    ).listen((Position position){

      parentLat = position.latitude;
      parentLng = position.longitude;


      FirebaseFirestore.instance
          .collection("parents")
          .doc(parentId)
          .set({

        "latitude": parentLat,
        "longitude": parentLng,

      }, SetOptions(merge:true));


    });

  }

  Future<void> _showRadiusDialog() async {
    radiusController.clear();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Add Geofence"),

          content: TextField(
            controller: radiusController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Radius (Meter)",
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
              onPressed: () async {

                if (radiusController.text.trim().isEmpty) {
                  return;
                }

                double radius =
                double.parse(radiusController.text.trim());

                await FirebaseFirestore.instance
                    .collection("children")
                    .doc(widget.childId)
                    .update({

                  "radius": radius,

                  "centerLat": currentLat,

                  "centerLng": currentLng,

                  "geofenceEnabled": true,

                });

                if (!mounted) return;

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        "Geofence of ${radius.toInt()} meter added"),
                  ),
                );
              },
              child: const Text("SAVE"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    radiusController.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.childName),
        centerTitle: true,

        actions: [

          IconButton(
            onPressed: _showRadiusDialog,
            icon: const Icon(Icons.add_location_alt),
            tooltip: "Add Geofence",
          ),

        ],
      ),

      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: _defaultLocation,
          zoom: 16,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
        markers: _markers,
        circles: _circles,
        onMapCreated: (controller) {
          _mapController = controller;
        },
      ),
    );
  }
}