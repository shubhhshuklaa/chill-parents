import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:chill_parents/screens/Login_role_page.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}
class _SplashScreenState
    extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 10),
          () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
            const RoleSelectionScreen(),
          ),
        );
      },
    );
  }

  Widget buildTriangle(
      Alignment alignment,
      Color color,
      bool isTop,
      bool isLeft,
      ) {
    return Align(
      alignment: alignment,
      child: SlideInUp(
        duration:
        const Duration(milliseconds: 1200),

        child: Transform.rotate(
          angle: 0.8,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: color,
              borderRadius:
              BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Center(
        child:Scaffold(
          backgroundColor: const Color(0xFF031B4E),
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.bottomRight,
                    radius: 0.0,
                    colors: [
                      Color(0xFF082C85),
                      Color(0xFFF3F5F8),

                    ],
                  ),
                ),
              ),

              // Top Left
              Positioned(
                top: -60,
                left: -60,
                child: ZoomIn(
                  duration: const Duration(seconds: 1),
                  child: Transform.rotate(
                    angle: 0.8,
                    child: Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.4),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Top Right
              Positioned(
                top: -60,
                right: -60,
                child: ZoomIn(
                  delay: const Duration(milliseconds: 300),
                  duration: const Duration(seconds: 1),
                  child: Transform.rotate(
                    angle: 0.8,
                    child: Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        color: const Color(0xFF081F63),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: const Color(0xFF4D6DFF),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Left
              Positioned(
                bottom: -60,
                left: -60,
                child: ZoomIn(
                  delay: const Duration(milliseconds: 400),
                  duration: const Duration(seconds: 1),
                  child: Transform.rotate(
                    angle: 0.8,
                    child: Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        color: const Color(0xFF081F63),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: const Color(0xFF4D6DFF),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Bottom Right
              Positioned(
                bottom: -60,
                right: -60,
                child: ZoomIn(
                  delay: const Duration(milliseconds: 900),
                  duration: const Duration(seconds: 1),
                  child: Transform.rotate(
                    angle: 0.8,
                    child: Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.4),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FadeInDown(
                        duration: const Duration(seconds: 2),
                        child: Container(
                          height: 140,
                          width: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFFF2F15),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFEEF0F4)
                                    .withOpacity(0.5),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: Lottie.asset(
                            'assets/Lock.json',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      BounceInDown(
                        duration:
                        const Duration(milliseconds: 800),
                        child: const Text(
                          "Empowering Teachers,",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      BounceInLeft(
                        delay:
                        const Duration(milliseconds: 800),
                        duration:
                        const Duration(milliseconds: 800),
                        child: const Text(
                          " Inspiring Futures.",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      BounceInRight(
                        delay:
                        const Duration(milliseconds: 1600),
                        duration:
                        const Duration(milliseconds: 800),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 60,
                              height: 2,
                              color: Colors.black,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Welcome To",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 60,
                              height: 2,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),

                      BounceInUp(
                        delay:
                        const Duration(milliseconds: 2400),
                        duration:
                        const Duration(milliseconds: 800),
                        child: const Text(
                          "Teacher's Dashboard",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF070707),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      FadeInDown(
                        duration: const Duration(seconds: 2),
                        child: SizedBox(
                          height: 150,
                          width: 150,
                          child: Lottie.asset(
                            'assets/red.json',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
    );
  }
}