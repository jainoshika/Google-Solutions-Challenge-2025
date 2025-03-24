import 'package:flutter/material.dart';
import 'login_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryOrange = Color(0xFFFF5722);
    const Color darkBackground = Color(0xFFFFFFFF);
    const Color surfaceColor = Color(0xFFe4dfd3);
    const Color lightGrey = Color(0xFF262b21);

    return Scaffold(
      backgroundColor: darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      height: 44,
                      width: 8,
                      decoration: BoxDecoration(
                        color: primaryOrange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Text(
                      "REGISTER",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                const Padding(
                  padding: EdgeInsets.only(left: 23),
                  child: Text(
                    "Create your athlete profile",
                    style: TextStyle(fontSize: 16, color: lightGrey),
                  ),
                ),

                const SizedBox(height: 60),

                // Form fields
                _buildTextField(
                  label: "Full Name",
                  icon: Icons.person_outline,
                  surfaceColor: surfaceColor,
                  lightGrey: lightGrey,
                  primaryOrange: primaryOrange,
                ),

                const SizedBox(height: 20),

                _buildTextField(
                  label: "Email",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  surfaceColor: surfaceColor,
                  lightGrey: lightGrey,
                  primaryOrange: primaryOrange,
                ),

                const SizedBox(height: 20),

                _buildTextField(
                  label: "Password",
                  icon: Icons.lock_outline,
                  isPassword: true,
                  surfaceColor: surfaceColor,
                  lightGrey: lightGrey,
                  primaryOrange: primaryOrange,
                ),

                const SizedBox(height: 20),

                _buildTextField(
                  label: "Confirm Password",
                  icon: Icons.lock_outline,
                  isPassword: true,
                  surfaceColor: surfaceColor,
                  lightGrey: lightGrey,
                  primaryOrange: primaryOrange,
                ),

                const SizedBox(height: 50),

                // Button
                Container(
                  width: double.infinity,
                  height: 58,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      colors: [
                        primaryOrange,
                        Color(0xFFFF7043),
                        Color(0xFFFF8A65),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryOrange.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                        spreadRadius: -4,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      splashColor: Colors.white.withOpacity(0.2),
                      highlightColor: Colors.white.withOpacity(0.1),
                      onTap: () {
                        // TODO: Implement Sign Up Logic
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "CREATE ACCOUNT",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already a member? ",
                      style: TextStyle(color: lightGrey),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Sign In",
                        style: TextStyle(
                          color: primaryOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required Color surfaceColor,
    required Color lightGrey,
    required Color primaryOrange,
    TextInputType? keyboardType,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        obscureText: isPassword,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: lightGrey.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: surfaceColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: primaryOrange,
              width: 2,
            ), // Removed const here
          ),
          prefixIcon: Icon(
            icon,
            color: primaryOrange,
          ), // The Icon constructor doesn't need const removal as it's not using const
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}
