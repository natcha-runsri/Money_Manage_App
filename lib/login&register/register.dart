import 'package:flutter/material.dart';
import '../authenticationService.dart';
import '../login&register/login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final username = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  void _showDialog(String message, {bool success = false}) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.error,
                  color: success ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 10),
                Text(
                  success ? "สำเร็จ" : "เกิดข้อผิดพลาด",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Text(message, style: const TextStyle(fontSize: 15)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "ตกลง",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
    );
  }

  // ฟังก์ชันสำหรับการสมัครสมาชิก
  Future<void> _register() async {
    if (email.text.isEmpty || password.text.isEmpty || username.text.isEmpty) {
      _showDialog("กรอกข้อมูลให้ครบ");
      return;
    }

    if (password.text != confirmPassword.text) {
      _showDialog("Password ไม่ตรงกัน");
      return;
    }

    final result = await AuthenticationService().register(
      email.text,
      password.text,
      username.text,
    );

    if (!mounted) return;

    if (result == null) {
      _showDialog("สมัครสมาชิกสำเร็จ", success: true);

      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        Navigator.pop(context); // ปิด dialog
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      });
    } else {
      String message = "สมัครสมาชิกไม่สำเร็จ";

      if (result == "email-already-in-use") {
        message = "อีเมลนี้ถูกใช้งานแล้ว";
      } else if (result == "username-already-in-use") {
        message = "Username นี้ถูกใช้งานแล้ว";
      }

      _showDialog(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 60),

              /// Logo
              Image.asset("images/logo.png", height: 150),

              const SizedBox(height: 20),

              const Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 34, 53, 77),
                ),
              ),
              const SizedBox(height: 6),

              const Text(
                "Create your account to track income and expenses",
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              // Username
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Username",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 80, 42, 81),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _input("Username", Icons.person, username),

              const SizedBox(height: 5),

              // Email
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
              _input("Email", Icons.email, email),
              const SizedBox(height: 5),

              // Password
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
              _input("Password", Icons.lock, password, true),
              const SizedBox(height: 7),

              // Confirm Password
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Confirm Password",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 80, 42, 81),
                  ),
                ),
              ),
              _input(
                "Confirm Password",
                Icons.check_circle,
                confirmPassword,
                true,
              ),
              const SizedBox(height: 30),

              // Sign Up Button
              SizedBox(
                width: 150,
                height: 45,
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 49, 75, 110),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Sign up",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              const Divider(color: Colors.grey, thickness: 1),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(
                      color: Color.fromARGB(255, 49, 75, 110),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "Sign in here",
                      style: TextStyle(
                        color: Color.fromARGB(255, 149, 78, 112),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ส่วนของฟังก์ชันที่สร้างอินพุตฟิลด์ ตกแต่ง
  Widget _input(
    String hint,
    IconData icon,
    TextEditingController controller, [
    bool obscure = false,
  ]) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),

        prefixIcon: Icon(icon, color: const Color.fromARGB(255, 80, 42, 81)),

        filled: true,
        fillColor: Colors.white,

        contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 1),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.2),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xff6B1E3A), width: 2),
        ),
      ),
    );
  }
}
