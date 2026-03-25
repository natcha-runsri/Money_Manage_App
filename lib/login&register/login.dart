// loginpage.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 👈 เพิ่มบรรทัดนี้
import '../authenticationService.dart';
import '../login&register/register.dart';
import '../buttom_navigation/homepage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }
  //เช็คว่าใส่ข้อมูลครบไหม ถ้าครบแล้วจะทำการเข้าสู่ระบบ ถ้าไม่ครบจะแสดงข้อความแจ้งเตือน
  Future<void> _doLogin() async {
    final email = _email.text.trim();
    final pass = _password.text;

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรอก Email และ Password ให้ครบ')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final ok = await AuthenticationService().login(email, pass);
      if (!mounted) return;

      if (ok) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('logged_in', true);
        await prefs.setString('email', email);

        showAutoPopup("เข้าสู่ระบบสำเร็จ", success: true);

        Future.delayed(const Duration(seconds: 3), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        });
      } else {
        showAutoPopup('อีเมลหรือรหัสผ่านไม่ถูกต้อง', success: false);
      }
    } catch (e) {
      if (!mounted) return;
      showAutoPopup('เข้าสู่ระบบล้มเหลว: $e', success: false);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 100),

              // Logo
              Image.asset("images/logo.png", height: 200),
              const SizedBox(height: 60),

              // Email Label
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Email",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 80, 42, 81),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Email Field
              TextField(
                controller: _email,
                decoration: InputDecoration(
                  hintText: "user@example.com",
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.email),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 255, 255, 255),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.grey,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              //Password Label
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Password",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 80, 42, 81),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Password Field
              TextField(
                controller: _password,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Ex. 12bndf56",
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.lock),
                  filled: true,
                  fillColor: Color.fromARGB(255, 255, 255, 255),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.grey,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 80),

              //Login Button
              SizedBox(
                width: 150,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _doLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 49, 75, 110),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child:
                      _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 30),

              // Divider
              Row(
                children: const [
                  Expanded(
                    child: Divider(
                      color: Color.fromARGB(255, 171, 181, 196),
                      thickness: 1,
                      indent: 5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Create Account
              InkWell(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  );
                },
                child: const Text(
                  "Create an Account",
                  style: TextStyle(
                    color: Color.fromARGB(255, 149, 78, 112),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

 //pop up แจ้งเตือนอัตโนมัติ
  void showAutoPopup(String message, {bool success = true}) {
    Color color = success ? Colors.green : Colors.red;
    IconData icon = success ? Icons.check_circle : Icons.error;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }
}
