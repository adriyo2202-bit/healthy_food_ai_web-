import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Widget _buildStatCard(String title, String value, String change, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
        border: Border.all(color: color.withOpacity(0.1), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: change.startsWith('+') ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(change, style: TextStyle(
                  color: change.startsWith('+') ? Colors.green.shade700 : Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                )),
              ),
            ],
          ),
          const Spacer(),
          Text(value, style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B))),
          const SizedBox(height: 4),
          Text(title, style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Overview", style: GoogleFonts.inter(color: const Color(0xFF1E293B), fontWeight: FontWeight.w800, fontSize: 24)),
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Good Morning, Alex 👋", style: GoogleFonts.inter(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
            const SizedBox(height: 32),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : (MediaQuery.of(context).size.width > 500 ? 2 : 1),
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard("Daily Calories", "1,840", "+12%", Icons.local_fire_department, Colors.orange),
                _buildStatCard("Protein Intake", "120g", "+5%", Icons.fitness_center, Colors.blue),
                _buildStatCard("Water Consumed", "2.1L", "-2%", Icons.water_drop, Colors.cyan),
                _buildStatCard("Sleep Score", "85", "+8%", Icons.nights_stay, Colors.deepPurple),
              ],
            ),
            const SizedBox(height: 40),
            Text("Recent AI Insights", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF2E8B57), Color(0xFF20B2AA)]),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: const Color(0xFF2E8B57).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Optimal Time for Carbs", style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text("Based on your recent workout patterns, consuming complex carbohydrates between 2 PM and 4 PM will maximize your energy levels.", style: GoogleFonts.inter(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FitnessScreen extends StatelessWidget {
  const FitnessScreen({super.key});

  Widget _buildActivityRing(String label, double percentage, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                value: percentage,
                strokeWidth: 12,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Text("${(percentage * 100).toInt()}%", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 20, color: const Color(0xFF1E293B))),
          ],
        ),
        const SizedBox(height: 16),
        Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
      ],
    );
  }

  Widget _buildWorkoutTile(String title, String duration, String calories, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF1E293B))),
                const SizedBox(height: 4),
                Text(duration, style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 13)),
              ],
            ),
          ),
          Text(calories, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 16, color: color)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Fitness Intelligence", style: GoogleFonts.inter(color: const Color(0xFF1E293B), fontWeight: FontWeight.w800, fontSize: 24)),
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 12))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActivityRing("Move", 0.75, Colors.pink),
                  _buildActivityRing("Exercise", 0.60, Colors.greenAccent.shade700),
                  _buildActivityRing("Stand", 0.90, Colors.blueAccent),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Recent Workouts", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                TextButton(onPressed: () {}, child: const Text("See All")),
              ],
            ),
            const SizedBox(height: 16),
            _buildWorkoutTile("Morning Run", "45 mins • Outdoor", "420 kcal", Icons.directions_run, Colors.orange),
            _buildWorkoutTile("HIIT Session", "30 mins • Indoor", "350 kcal", Icons.bolt, Colors.redAccent),
            _buildWorkoutTile("Yoga Flow", "60 mins • Recovery", "180 kcal", Icons.self_improvement, Colors.teal),
          ],
        ),
      ),
    );
  }
}

class MealsScreen extends StatelessWidget {
  const MealsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Diet Planner")),
      body: Center(
        child: Text("Your generated diet plans and nutrition macros will appear here.",
          style: GoogleFonts.inter(fontSize: 20), textAlign: TextAlign.center),
      ),
    );
  }
}


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _profileImageBytes;
  String _userName = "Adriyo Gayen";
  String _userEmail = "testuser@example.com";

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _profileImageBytes = bytes;
      });
    }
  }

  void _editName() {
    TextEditingController controller = TextEditingController(text: _userName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Edit Name", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Enter your name",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E8B57),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              setState(() {
                _userName = controller.text;
              });
              Navigator.pop(context);
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF2E8B57).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF2E8B57)),
        ),
        title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16)),
        subtitle: Text(subtitle, style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 13)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section with gradient
            Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2E8B57), Color(0xFF20B2AA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                ),
                
                // Profile Picture Avatar
                Positioned(
                  bottom: -60,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 5),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, spreadRadius: 5)],
                        ),
                        child: CircleAvatar(
                          radius: 65,
                          backgroundColor: Colors.white,
                          backgroundImage: _profileImageBytes != null ? MemoryImage(_profileImageBytes!) : null,
                          child: _profileImageBytes == null ? const Icon(Icons.person, size: 60, color: Colors.grey) : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E8B57),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 80),
            
            // Name and Email
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 24),
                Text(_userName, style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B))),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.grey),
                  onPressed: _editName,
                ),
              ],
            ),
            Text(_userEmail, style: GoogleFonts.inter(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
            
            const SizedBox(height: 30),
            
            // Options List
            _buildProfileOption(Icons.restaurant_menu, "Dietary Preferences", "Vegan, Gluten-Free, Keto..."),
            _buildProfileOption(Icons.fitness_center, "Activity Level", "Highly Active, 5 days/week"),
            _buildProfileOption(Icons.monitor_weight_outlined, "Health Goals", "Maintain weight, build muscle"),
            _buildProfileOption(Icons.security, "Privacy & Security", "Manage data and app permissions"),
            
            const SizedBox(height: 30),
            
            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red.shade700,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.logout),
                label: Text("Sign Out", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                onPressed: () {
                  // Simulate logout
                  Navigator.of(context).pushReplacementNamed("/"); 
                },
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
