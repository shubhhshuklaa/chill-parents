import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  GoogleMapController? mapController;

  Marker? childMarker;

  StreamSubscription<DocumentSnapshot>? locationStream;

  LatLng initialPosition = const LatLng(28.6139, 77.2090);

  @override
  void initState() {
    super.initState();

    listenChildLocation();
  }

  void listenChildLocation() {

    locationStream = FirebaseFirestore.instance
        .collection("children")
        .doc(widget.childId)
        .snapshots()
        .listen((DocumentSnapshot snapshot) {

      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;

      double lat = (data["latitude"] ?? 0).toDouble();
      double lng = (data["longitude"] ?? 0).toDouble();

      if (lat == 0 && lng == 0) return;

      LatLng newPosition = LatLng(lat, lng);

      childMarker = Marker(
        markerId: const MarkerId("child"),
        position: newPosition,
        infoWindow: InfoWindow(
          title: widget.childName,
        ),
      );

      mapController?.animateCamera(
        CameraUpdate.newLatLng(newPosition),
      );

      setState(() {
        initialPosition = newPosition;
      });

    });

  }

  @override
  void dispose() {
    locationStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(widget.childName),
        centerTitle: true,
      ),

      body: GoogleMap(

        initialCameraPosition: CameraPosition(
          target: initialPosition,
          zoom: 16,
        ),

        markers: childMarker == null
            ? {}
            : {
          childMarker!,
        },

        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,

        onMapCreated: (controller) {
          mapController = controller;
        },

      ),

    );

  }

}