import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibration/vibration.dart';
import 'package:geolocator/geolocator.dart';


class TrackAllChildrenPage extends StatefulWidget {
  const TrackAllChildrenPage({super.key});

  @override
  State<TrackAllChildrenPage> createState() =>
      _TrackAllChildrenPageState();
}
bool notificationShown = false;

class _TrackAllChildrenPageState
    extends State<TrackAllChildrenPage> {

  final String parentId =
      FirebaseAuth.instance.currentUser!.uid;

  GoogleMapController? mapController;

  final Set<Marker> markers = {};
  final Set<Circle> circles = {};
  double radius = 20;
  bool anyChildOut = false;
  bool vibrationDone = false;

  final AudioPlayer player = AudioPlayer();

  final FlutterLocalNotificationsPlugin notificationPlugin =
  FlutterLocalNotificationsPlugin();

  bool isAlarmPlaying = false;

  Position? parentPosition;

  StreamSubscription<QuerySnapshot>? subscription;

  static const CameraPosition initialCamera =
  CameraPosition(
    target: LatLng(26.8467, 80.9462),
    zoom: 14,
  );

  @override
  void initState() {
    super.initState();
    listenAllChildren();
    initNotification();
    getParentLocation();
    loadRadius();

  }

  Future<void> getParentLocation() async {

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) return;

    LocationPermission permission =
    await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((position) {

      setState(() {
        parentPosition = position;
      });

    });

  }

  void showRadiusDialog() {

    final controller = TextEditingController(
      text: radius.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Set Radius (Meter)"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "Example: 20",
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

        final value = double.tryParse(controller.text);

        if (value == null || value <= 0) {
        return;
        }

        final snapshot = await FirebaseFirestore.instance
            .collection("children")
            .where("parentId", isEqualTo: parentId)
            .get();

        final batch = FirebaseFirestore.instance.batch();

        for (var doc in snapshot.docs) {

          final data = doc.data();

          if (data["latitude"] == null || data["longitude"] == null) {
            continue;
          }

          batch.update(doc.reference, {

            "radius": value,

            "safeLat": data["latitude"],

            "safeLng": data["longitude"],

          });
        }

// Sab children ek saath update honge
              await batch.commit();

        setState(() {
        radius = value;
        });

        Navigator.pop(context);
        },
              child: const Text("Save"),
            ),

          ],
        );
      },
    );
  }



  void listenAllChildren() {

    subscription = FirebaseFirestore.instance
        .collection("children")
        .where("parentId", isEqualTo: parentId)
        .snapshots()
        .listen((snapshot) async {

      markers.clear();
      circles.clear();

      anyChildOut = false;

      for (var doc in snapshot.docs) {

        final data = doc.data() as Map<String, dynamic>;

        if (data["latitude"] == null ||
            data["longitude"] == null ||
            data["safeLat"] == null ||
            data["safeLng"] == null ||
            data["radius"] == null) {
          continue;
        }

        final double lat =
        (data["latitude"] as num).toDouble();

        final double lng =
        (data["longitude"] as num).toDouble();

        final double safeLat =
        (data["safeLat"] as num).toDouble();

        final double safeLng =
        (data["safeLng"] as num).toDouble();

        final double childRadius =
        (data["radius"] as num).toDouble();

        final String name =
            data["name"] ?? "Child";

        final double distance =
        Geolocator.distanceBetween(
          safeLat,
          safeLng,
          lat,
          lng,
        );

        if (distance > childRadius) {

          anyChildOut = true;

          if (!notificationShown) {
            notificationShown = true;
            await showAlert(name);
          }

          if (!vibrationDone) {
            vibrationDone = true;
            Vibration.vibrate(duration: 1000);
          }

        }

        markers.add(
          Marker(
            markerId: MarkerId(doc.id),
            position: LatLng(lat, lng),
            icon: distance > childRadius
                ? BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed)
                : BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(
              title: name,
              snippet:
              "${distance.toStringAsFixed(1)} m",
            ),
          ),
        );

        circles.add(
          Circle(
            circleId: CircleId(doc.id),
            center: LatLng(safeLat, safeLng),
            radius: childRadius,
            strokeWidth: 2,
            strokeColor: distance > childRadius
                ? Colors.red
                : Colors.green,
            fillColor: distance > childRadius
                ? Colors.red.withOpacity(0.25)
                : Colors.green.withOpacity(0.25),
          ),
        );
      }

      if (anyChildOut) {
        await playAlarm();
      } else {
        await stopAlarm();
        notificationShown = false;
        vibrationDone = false;
      }

      setState(() {});
    });
  }

  Future<void> loadRadius() async {
    final doc = await FirebaseFirestore.instance
        .collection("parents")
        .doc(parentId)
        .get();

    if (doc.exists) {
      final data = doc.data();

      if (data != null && data["radius"] != null) {
        setState(() {
          radius = (data["radius"] as num).toDouble();
        });
      }
    }
  }


  Future<void> showAlert(String childName) async {

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(

      "child_alert",

      "Child Alert",

      importance: Importance.max,

      priority: Priority.high,

    );

    await notificationPlugin.show(

      1,

      "Child Out of Safe Zone",

      "$childName is out of safe zone.",

      NotificationDetails(
        android: androidDetails,
      ),

    );

  }
  Future<void> playAlarm() async {

    if (isAlarmPlaying) return;

    isAlarmPlaying = true;

    await player.setReleaseMode(
        ReleaseMode.loop);

    await player.play(
      AssetSource("sounds/sound.mp3"),
    );

  }
  Future<void> stopAlarm() async {

    await player.stop();

    isAlarmPlaying = false;

  }

  Future<void> initNotification() async {

    const android = AndroidInitializationSettings(
        '@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: android,
    );

    await notificationPlugin.initialize(settings);

  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Track All Children"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.radio_button_checked),
            onPressed: () {
              showRadiusDialog();
            },
          ),
        ],
      ),

      body: GoogleMap(

        initialCameraPosition: initialCamera,

        myLocationEnabled: true,

        myLocationButtonEnabled: true,

        zoomControlsEnabled: true,

        markers: markers,

        circles: circles,

        onMapCreated: (controller) {
          mapController = controller;
        },

      ),

    );
  }
}