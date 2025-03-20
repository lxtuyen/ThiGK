import 'package:flutter/material.dart';
import 'package:giua_ky/controller/auth_controller.dart';
import 'package:giua_ky/presentation/screens/login/login.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController passwordController =
      TextEditingController(); // Controller để lưu giá trị mật khẩu
  final TextEditingController emailController =
      TextEditingController(); // Controller để lưu giá trị email
  final TextEditingController fullnameController =
      TextEditingController(); // Controller để lưu giá trị full name
  final TextEditingController confirmPasswordController =
      TextEditingController(); // Controller để lưu giá trị nhập lại mật khẩu

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final String email = emailController.text.trim();
      final String password = passwordController.text.trim();

      final authController = AuthController();
      await authController.signUp(
        context,
        fullnameController.text,
        email,
        password,
      );
    }
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required.";
    }
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegExp.hasMatch(value)) {
      return 'Invalid email address.';
    }
    return null;
  }

   static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    // Check for minimum password length
    if (value.length < 6) {
      return 'Password must be at least 6 characters long.';
    }
    // Check for at least one digit
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one digit.';
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20), // Khoảng cách xung quanh
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Căn giữa nội dung
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 30),
              const Text(
                'Đăng ký',
                style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 50),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    // Full name
                    TextFormField(
                      controller: fullnameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ),
                        ),
                        filled: true,
                        fillColor: Color(0xFFF1F4FF),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nhập đầy đủ thông tin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Email
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ),
                        ),
                        filled: true,
                        fillColor: Color(0xFFF1F4FF),
                      ),
                      validator: (value) {
                        return validateEmail(value);
                      },
                    ),
                    const SizedBox(height: 20),
                    // Password
                    TextFormField(
                      controller:
                      passwordController, // Gán controller cho password feild
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ),
                        ),
                        filled: true,
                        fillColor: Color(0xFFF1F4FF),
                      ),
                      obscureText: true, // Ẩn mật khẩu
                      validator: (value) {
                        return validatePassword(value);
                      },
                    ),
                    const SizedBox(height: 20),
                    // Confirm password
                    TextFormField(
                      controller: confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Confirm password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ),
                        ), // Ẩn mật khẩu
                        filled: true,
                        fillColor: Color(0xFFF1F4FF),
                      ),
                      obscureText: true, // Ẩn mật khẩu
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nhập đầy đủ thông tin';
                        } else if (value != passwordController.text) {
                          return 'Mật khẩu không khớp';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {
                  _submit();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F41BB), // Màu nền
                  foregroundColor: Colors.white, // Màu chữ
                  padding: const EdgeInsets.symmetric(
                    horizontal: 135,
                    vertical: 20,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Đăng ký'),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Đã có tài khoản? ',
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  TextButton(
                    onPressed: () {
                      // Chuyển hướng đến trang đăng nhập
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: const Text(
                      'Đăng nhập',
                      style: TextStyle(color: Color(0xFF1F41BB), fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    passwordController.dispose();
    emailController.dispose();
    fullnameController.dispose();
    super.dispose();
  }
}
