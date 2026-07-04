import 'package:chill_parents/nav_pages/add_child.dart';
import 'package:flutter/material.dart';
import 'package:chill_parents/nav_pages/children_page.dart';
import 'package:chill_parents/nav_pages/home.dart';
import 'package:chill_parents/nav_pages/location.dart';
import 'package:chill_parents/nav_pages/profile.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {

  int currentIndex = 0;

  final pages = const [
    HomePage(),
    LiveTrackingPage(),
    ChildrenPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: pages[currentIndex],

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddChildPage(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Child",style: TextStyle(color: Colors.white),),
      ),

      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: NavigationBar(

        height: 75,

        selectedIndex: currentIndex,

        onDestinationSelected: (index){

          setState(() {

            currentIndex=index;

          });

        },

        destinations: const [

          NavigationDestination(

              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: "Home"),

          NavigationDestination(

              icon: Icon(Icons.location_on_outlined),
              selectedIcon: Icon(Icons.location_on),
              label: "Tracking"),

          NavigationDestination(

              icon: Icon(Icons.child_care_outlined),
              selectedIcon: Icon(Icons.child_care),
              label: "Children"),

          NavigationDestination(

              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: "Profile"),

        ],
      ),

    );
  }
}