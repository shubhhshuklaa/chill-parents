import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;
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
                "Welcome Back, ${user?.displayName ?? 'User'}",
                style: GoogleFonts.poppins(
                  color: Colors.grey,
                  fontSize: 20,
                ),
              ),


              const SizedBox(height: 25),

              Container(

                width: double.infinity,

                decoration: BoxDecoration(

                  borderRadius: BorderRadius.circular(20),

                ),

                child: Center(
                  child: Image.asset(
                    "assets/images/hhd.jpg", // Apni image ka path
                    fit: BoxFit.contain,
                  ),

                ),


              ),

              const SizedBox(height: 25),

              GridView.count(

                shrinkWrap: true,

                physics: const NeverScrollableScrollPhysics(),

                crossAxisCount: 3,

                crossAxisSpacing: 15,

                mainAxisSpacing: 15,

                childAspectRatio: 0.7,

                children: const [

                  DashboardCard(

                      title: "Children",

                      value: "1",

                      icon: Icons.child_care),

                  DashboardCard(

                      title: "Attendance",

                      value: "95%",

                      icon: Icons.check_circle),

                  DashboardCard(

                      title: "Tracking",

                      value: "ON",

                      icon: Icons.location_on),

                  DashboardCard(

                      title: "Alerts",

                      value: "2",

                      icon: Icons.notifications),

                ],

              ),

              const SizedBox(height: 25),

              Text(

                "Quick Actions",

                style: GoogleFonts.poppins(

                  fontSize: 20,

                  fontWeight: FontWeight.bold,

                ),

              ),

              const SizedBox(height: 15),

              Row(

                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [

                  quick(Icons.location_on, "Track"),

                  quick(Icons.child_care, "Child"),

                  quick(Icons.phone, "SOS"),

                  quick(Icons.person, "Profile"),

                ],

              ),

            ],

          ),
        ),

      ),

    );
  }

  Widget quick(IconData icon,String text){

    return Column(

      children: [

        CircleAvatar(

          radius: 30,

          backgroundColor: Colors.indigo.shade50,

          child: Icon(icon,color: Colors.indigo),

        ),

        const SizedBox(height:8),

        Text(text),

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

          BoxShadow(

            color: Colors.grey.withOpacity(.15),

            blurRadius: 10,

          )

        ],

      ),

      child: Padding(

        padding: const EdgeInsets.all(18),

        child: Column(

          mainAxisAlignment: MainAxisAlignment.spaceEvenly,

          children: [

            CircleAvatar(

              backgroundColor: Colors.indigo.shade100,

              child: Icon(icon,color: Colors.indigo),

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