import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui' as ui;
import 'prototype_web_sim.dart'; // For colors and navigation

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isHoveringBtn = false;
  bool _isHoveringGoogle = false;

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1200));
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HealthyFoodHomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Reusing the animated background aesthetic from the main app
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Fallback if no bg
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image (if used in main app) or a nice subtle gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE0E7FF),
                  Color(0xFFF3E8FF),
                  Color(0xFFE0F2FE),
                ],
              ),
            ),
          ),
          
          // Floating ambient orbs (CSS aesthetic)
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryGreen.withOpacity(0.2),
              ),
            ).animate(onPlay: (controller) => controller.repeat()).move(
              duration: 10.seconds,
              begin: const Offset(0, 0),
              end: const Offset(50, 50),
              curve: Curves.easeInOutSine,
            ).then().move(
              duration: 10.seconds,
              begin: const Offset(50, 50),
              end: const Offset(0, 0),
              curve: Curves.easeInOutSine,
            ),
          ),
          
          Positioned(
            bottom: -150,
            right: -50,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent.withOpacity(0.15),
              ),
            ).animate(onPlay: (controller) => controller.repeat()).move(
              duration: 12.seconds,
              begin: const Offset(0, 0),
              end: const Offset(-80, -40),
              curve: Curves.easeInOutSine,
            ).then().move(
              duration: 12.seconds,
              begin: const Offset(-80, -40),
              end: const Offset(0, 0),
              curve: Curves.easeInOutSine,
            ),
          ),

          // Main Glassmorphic Login Card
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                child: Container(
                  width: isMobile(context) ? MediaQuery.of(context).size.width * 0.9 : 450,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.6),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 30,
                        spreadRadius: 0,
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo/Title
                      const Icon(Icons.health_and_safety_rounded, size: 56, color: primaryGreen)
                          .animate()
                          .scale(duration: 600.ms, curve: Curves.easeOutBack),
                      const SizedBox(height: 16),
                      Text(
                        'Welcome Back',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: primaryText,
                          letterSpacing: -0.5,
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                      const SizedBox(height: 8),
                      Text(
                        'Enter your details to access Healthy Food AI.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: primaryText.withOpacity(0.7),
                        ),
                      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                      const SizedBox(height: 40),

                      // Email Field
                      _buildGlassTextField(
                        controller: _emailController,
                        hint: 'Email Address',
                        icon: Icons.email_outlined,
                        delay: 400.ms,
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      _buildGlassTextField(
                        controller: _passwordController,
                        hint: 'Password',
                        icon: Icons.lock_outline_rounded,
                        isPassword: true,
                        delay: 500.ms,
                      ),
                      
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            foregroundColor: primaryGreen,
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            'Forgot Password?',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 600.ms),
                      const SizedBox(height: 30),

                      // Login Button
                      MouseRegion(
                        onEnter: (_) => setState(() => _isHoveringBtn = true),
                        onExit: (_) => setState(() => _isHoveringBtn = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          transform: Matrix4.identity()..scale(_isHoveringBtn && !_isLoading ? 1.02 : 1.0),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: _isHoveringBtn ? 10 : 0,
                              shadowColor: primaryGreen.withOpacity(0.5),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : Text(
                                    'Sign In',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2),

                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(child: Divider(color: primaryText.withOpacity(0.1))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: primaryText.withOpacity(0.5),
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: primaryText.withOpacity(0.1))),
                        ],
                      ).animate().fadeIn(delay: 800.ms),
                      const SizedBox(height: 24),

                      // Google Auth Button (Mock)
                      MouseRegion(
                        onEnter: (_) => setState(() => _isHoveringGoogle = true),
                        onExit: (_) => setState(() => _isHoveringGoogle = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          transform: Matrix4.identity()..scale(_isHoveringGoogle ? 1.02 : 1.0),
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.g_mobiledata_rounded, size: 28, color: primaryText),
                            label: Text(
                              'Continue with Google',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: primaryText,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              backgroundColor: Colors.white.withOpacity(0.5),
                              side: BorderSide(color: Colors.white.withOpacity(0.8), width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.2),
                      
                      const SizedBox(height: 16),
                      // Skip Button
                      Center(
                        child: TextButton(
                          onPressed: _isLoading ? null : _handleLogin, // Same mock logic to navigate
                          style: TextButton.styleFrom(
                            foregroundColor: primaryText.withOpacity(0.6),
                          ),
                          child: Text(
                            'Skip for now',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 1000.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    required Duration delay,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.8), width: 1),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: GoogleFonts.inter(color: primaryText, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: primaryText.withOpacity(0.5), fontSize: 15),
          prefixIcon: Icon(icon, color: primaryGreen.withOpacity(0.7), size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
      ),
    ).animate().fadeIn(delay: delay).slideY(begin: 0.2);
  }
}
