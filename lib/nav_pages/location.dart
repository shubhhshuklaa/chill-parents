import 'package:chill_parents/nav_pages/tracking_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LiveTrackingPage extends StatelessWidget {
  const LiveTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String parentId = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Tracking"),
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("children")
            .where("parentId", isEqualTo: parentId)
            .snapshots(),

        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No Child Registered",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {

              final child = snapshot.data!.docs[index];

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 12),

                child: ListTile(

                  leading: CircleAvatar(
                    radius: 28,

                    backgroundImage:
                    child["photo"] != null &&
                        child["photo"].toString().isNotEmpty
                        ? NetworkImage(child["photo"])
                        : null,

                    child: child["photo"] == null ||
                        child["photo"].toString().isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),

                  title: Text(
                    child["name"],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Text(
                    "ID : ${child["childId"]}",
                  ),

                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),

                  onTap: () {

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TrackingMapPage(
                          childId: child["childId"],
                          childName: child["name"],
                        ),
                      ),
                    );

                  },

                ),
              );
            },
          );
        },
      ),
    );
  }
}