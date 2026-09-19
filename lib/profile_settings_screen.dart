import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'auth_service.dart';
import 'login_screen.dart';
import 'profile_service.dart';

const Color primaryGreen = Color(0xFF0D9488); // Teal 600
const Color softGreen = Color(0xFFF0FDF4); // Green 50
const Color primaryText = Color(0xFF1E293B); // Slate 800
const Color secondaryText = Color(0xFF64748B); // Slate 500
const Color borderColor = Color(0xFFE2E8F0); // Slate 200

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final String joinDate = "Joined September 2026";

  @override
  void initState() {
    super.initState();
    profileService.addListener(_onProfileChanged);
  }

  @override
  void dispose() {
    profileService.removeListener(_onProfileChanged);
    super.dispose();
  }

  void _onProfileChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _editValue(String title, String currentValue, Future<void> Function(String) onSave) async {
    final controller = TextEditingController(text: currentValue);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("Edit $title", style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: primaryText, fontSize: 18)),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryGreen, width: 2)),
              hintText: "Enter $title",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: GoogleFonts.inter(color: secondaryText, fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () {
                onSave(controller.text);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text("Save", style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: primaryText),
        title: Text(
          "Profile & Settings",
          style: GoogleFonts.inter(
            color: primaryText,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: borderColor, height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Profile Header Section
            _buildProfileHeader().animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Health & Diet Preferences
                  _buildSectionHeader("Health & Diet"),
                  _buildSettingsCard([
                    _buildSettingsTile(
                      icon: Icons.favorite_border_rounded,
                      iconColor: Colors.pink,
                      title: "Dietary Preferences",
                      subtitle: profileService.dietaryPreferences,
                      onTap: () => _editValue("Dietary Preferences", profileService.dietaryPreferences, profileService.updateDietaryPreferences),
                    ),
                    _buildDivider(),
                    _buildSettingsTile(
                      icon: Icons.warning_amber_rounded,
                      iconColor: Colors.orange,
                      title: "Allergies",
                      subtitle: profileService.allergies,
                      onTap: () => _editValue("Allergies", profileService.allergies, profileService.updateAllergies),
                    ),
                    _buildDivider(),
                    _buildSettingsTile(
                      icon: Icons.flag_outlined,
                      iconColor: Colors.blue,
                      title: "Health Goals",
                      subtitle: profileService.healthGoals,
                      onTap: () => _editValue("Health Goals", profileService.healthGoals, profileService.updateHealthGoals),
                    ),
                  ]).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                  
                  const SizedBox(height: 24),
                  
                  // 3. App Settings
                  _buildSectionHeader("App Settings"),
                  _buildSettingsCard([
                    _buildSwitchTile(
                      icon: Icons.notifications_none_rounded,
                      iconColor: Colors.indigo,
                      title: "Push Notifications",
                      value: profileService.notificationsEnabled,
                      onChanged: (val) => profileService.updateNotifications(val),
                    ),
                    _buildDivider(),
                    _buildSwitchTile(
                      icon: Icons.dark_mode_outlined,
                      iconColor: Colors.deepPurple,
                      title: "Dark Mode",
                      value: profileService.darkModeEnabled,
                      onChanged: (val) => profileService.updateDarkMode(val),
                    ),
                    _buildDivider(),
                    _buildSwitchTile(
                      icon: Icons.fingerprint_rounded,
                      iconColor: Colors.teal,
                      title: "Biometric Login",
                      value: profileService.biometricsEnabled,
                      onChanged: (val) => profileService.updateBiometrics(val),
                    ),
                  ]).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

                  const SizedBox(height: 24),

                  // 4. Account & Support
                  _buildSectionHeader("Account"),
                  _buildSettingsCard([
                    _buildSettingsTile(
                      icon: Icons.person_outline_rounded,
                      iconColor: Colors.grey.shade700,
                      title: "Personal Information",
                      onTap: () => _editValue("Email Address", profileService.userEmail, profileService.updateEmail),
                    ),
                    _buildDivider(),
                    _buildSettingsTile(
                      icon: Icons.security_rounded,
                      iconColor: Colors.grey.shade700,
                      title: "Data Privacy",
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildSettingsTile(
                      icon: Icons.help_outline_rounded,
                      iconColor: Colors.grey.shade700,
                      title: "Help & Support",
                      onTap: () {},
                    ),
                  ]).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                  
                  const SizedBox(height: 32),
                  
                  // 5. Logout Button
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: () => _handleLogout(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.logout_rounded),
                      label: Text(
                        "Log Out",
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms).scale(),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      padding: const EdgeInsets.only(top: 32.0, bottom: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Elegant Avatar
          GestureDetector(
            onTap: () {
              // Simulating photo update for demo
              _editValue("Profile Photo URL", profileService.profilePhotoUrl, profileService.updateProfilePhoto);
            },
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE0E7FF), Color(0xFFF3E8FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 8))
                    ],
                    image: profileService.profilePhotoUrl.isNotEmpty 
                        ? DecorationImage(image: NetworkImage(profileService.profilePhotoUrl), fit: BoxFit.cover) 
                        : null,
                  ),
                  child: profileService.profilePhotoUrl.isEmpty ? Center(
                    child: Text(
                      profileService.userName.isNotEmpty ? profileService.userName.substring(0, 1).toUpperCase() : "?",
                      style: GoogleFonts.inter(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        color: primaryGreen,
                      ),
                    ),
                  ) : null,
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: primaryGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => _editValue("Name", profileService.userName, profileService.updateName),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  profileService.userName,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: primaryText,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.edit_rounded, size: 16, color: secondaryText),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profileService.userEmail,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: secondaryText,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: softGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              joinDate,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: primaryGreen,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 12.0, top: 8.0),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: secondaryText,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: primaryText,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: secondaryText,
                        ),
                      ),
                    ]
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1), size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: primaryText,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: primaryGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      width: double.infinity,
      color: borderColor,
      margin: const EdgeInsets.only(left: 60),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    await authService.signOut();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
        (route) => false,
      );
    }
  }
}
