import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'dart:async';
import 'login&register/login.dart';
import 'buttom_navigation/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false,
  );

  final prefs = await SharedPreferences.getInstance();
  bool loggedIn = prefs.getBool('logged_in') ?? false;

  runApp(MyApp(loggedIn));
}

class MyApp extends StatelessWidget {
  final bool loggedIn;
  const MyApp(this.loggedIn, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: loggedIn ? const HomePage() : const OnboardingCarousel(),
    );
  }
}

class OnboardingCarousel extends StatefulWidget {
  const OnboardingCarousel({super.key});

  @override
  State<OnboardingCarousel> createState() => _OnboardingCarouselState();
}

// หน้าแรกที่แสดงเมื่อเปิดแอปครั้งแรก
class _OnboardingCarouselState extends State<OnboardingCarousel> {
  final PageController _controller = PageController();
  int _index = 0;
  Timer? _timer;

  final List<_OnboardData> pages = [
    _OnboardData(
      image: "images/banner1.png",
      title: "Welcome to Pocket Money",
      desc: "เราจะช่วยคุณจัดระเบียบการเงิน เพิ่มความสะดวกสบายและเข้าใจที่มาที่ไปของเงินคุณได้ง่ายๆ",
    ),
    _OnboardData(
      image: "images/banner2.png",
      title: "Comfortable",
      desc: "พวกเราใช้ง่าย สามารถเพิ่ม แก้ไข ลบ ข้อมูลได้ไม่ยุ่งยาก",
    ),
    _OnboardData(
      image: "images/banner3.png",
      title: "Summary",
      desc: "เราจะช่วยสรุปข้อมูล พฤติกรรมการใช้จ่ายของคุณ",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      final nextPage = _controller.page!.toInt() + 1;
      _controller.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            /// ส่วนกลางจอ
            Expanded(
              child: Column(
                children: [
                  const Spacer(),
                  /// PAGE VIEW
                  SizedBox(
                    height: 350,
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: pages.length,
                      onPageChanged: (i) {
                        setState(() {
                          _index = i;
                        });
                      },
                      itemBuilder: (context, i) {
                        final page = pages[i];
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              page.image,
                              height: 220,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 20),

                            Text(
                              page.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff3B4E6B),
                              ),
                            ),
                            const SizedBox(height: 8),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                              ),
                              child: Text(
                                page.desc,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // DOTS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(pages.length, (i) {
                      bool active = i == _index;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: active ? 12 : 8,
                        height: active ? 12 : 8,
                        decoration: BoxDecoration(
                          color:
                              active
                                  ? const Color(0xff591D3A)
                                  : Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 80),

                  // LOGIN BUTTON
                  SizedBox(
                    width: 180,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 49, 75, 110),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardData {
  final String image;
  final String title;
  final String desc;

  _OnboardData({required this.image, required this.title, required this.desc});
}
