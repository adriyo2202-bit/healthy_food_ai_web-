import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui' as ui;
import 'prototype_web_sim.dart';

class DietPlannerScreen extends StatefulWidget {
  const DietPlannerScreen({super.key});

  @override
  State<DietPlannerScreen> createState() => _DietPlannerScreenState();
}

class _DietPlannerScreenState extends State<DietPlannerScreen> {
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  
  String _goal = "Just be fit";
  String _dietType = "Veg";
  
  bool _isLoading = false;
  Map<String, dynamic>? _resultJson;
  String? _errorMessage;

  Future<void> _generatePlan() async {
    final age = int.tryParse(_ageController.text);
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);
    
    if (age == null || height == null || weight == null) {
      setState(() => _errorMessage = "Please enter valid numbers for Age, Height, and Weight.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _resultJson = null;
    });

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/diet-plan'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "age": age,
          "height": height,
          "weight": weight,
          "goal": _goal,
          "diet_type": _dietType
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _resultJson = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to generate plan: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Connection error: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text("AI Diet Coach", style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: primaryText)),
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryGreen),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE0E7FF), Color(0xFFF3E8FF), Color(0xFFE0F2FE)],
              ),
            ),
          ),
          
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile(context) ? 16.0 : MediaQuery.of(context).size.width * 0.2,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader().animate().fadeIn().slideY(begin: 0.1),
                const SizedBox(height: 24),
                
                if (_resultJson == null)
                  _buildFormCard().animate().fadeIn(delay: 200.ms).slideY(begin: 0.1)
                else
                  _buildResultsDashboard().animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                
                const SizedBox(height: 32),
                
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Text(_errorMessage!, style: GoogleFonts.inter(color: Colors.red.shade700)),
                  ).animate().fadeIn(),
                  
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildTextField("Age", _ageController, TextInputType.number, Icons.person_outline),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField("Height (cm)", _heightController, TextInputType.number, Icons.height),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField("Weight (kg)", _weightController, TextInputType.number, Icons.monitor_weight_outlined),
              const SizedBox(height: 24),
              
              Text("Primary Goal", style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: primaryText)),
              const SizedBox(height: 8),
              _buildSegmentedControl(["Just be fit", "Body building"], _goal, (v) => setState(() => _goal = v)),
              const SizedBox(height: 24),
              
              Text("Diet Preference", style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: primaryText)),
              const SizedBox(height: 8),
              _buildSegmentedControl(["Veg", "Non-Veg"], _dietType, (v) => setState(() => _dietType = v)),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _generatePlan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text("Generate My Roadmap", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsDashboard() {
    final data = _resultJson!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Action Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Your Action Plan", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: primaryText)),
            TextButton.icon(
              onPressed: () => setState(() => _resultJson = null),
              icon: const Icon(Icons.refresh, color: primaryGreen),
              label: Text("Recalculate", style: GoogleFonts.inter(color: primaryGreen, fontWeight: FontWeight.w600)),
            )
          ],
        ),
        const SizedBox(height: 16),

        // Hero Metrics
        Row(
          children: [
            Expanded(child: _buildMetricCard("BMI Verdict", data["bmi_verdict"] ?? "", Icons.monitor_heart, const Color(0xFF6366F1))),
            const SizedBox(width: 16),
            Expanded(child: _buildMetricCard("Goal Alignment", data["goal_alignment"] ?? "", Icons.track_changes, primaryGreen)),
          ],
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
        
        const SizedBox(height: 24),

        // Timeline
        _buildTimelineCard(data["daily_roadmap"] ?? {}).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

        const SizedBox(height: 24),

        // Dos and Donts
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildListCard("Mandatory Fuel", data["mandatory_fuel"] ?? [], Icons.check_circle, primaryGreen).animate().fadeIn(delay: 600.ms).slideX(begin: -0.1)),
            const SizedBox(width: 16),
            Expanded(child: _buildListCard("Strictly Forbidden", data["strictly_forbidden"] ?? [], Icons.cancel, Colors.red).animate().fadeIn(delay: 800.ms).slideX(begin: 0.1)),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: primaryText)),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(Map<String, dynamic> roadmap) {
    final meals = ["breakfast", "lunch", "snack", "dinner"];
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.restaurant_menu, color: primaryText, size: 24),
              const SizedBox(width: 12),
              Text("Daily Roadmap", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: primaryText)),
            ],
          ),
          const SizedBox(height: 24),
          ...meals.map((meal) => _buildTimelineItem(
            meal.toUpperCase(), 
            roadmap[meal] ?? "Not specified", 
            meal == meals.last
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String desc, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 16, height: 16,
                decoration: BoxDecoration(shape: BoxShape.circle, color: primaryGreen, border: Border.all(color: Colors.white, width: 3)),
              ),
              if (!isLast)
                Expanded(child: Container(width: 2, color: primaryGreen.withOpacity(0.3))),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: primaryGreen)),
                  const SizedBox(height: 4),
                  Text(desc, style: GoogleFonts.inter(fontSize: 15, color: primaryText, height: 1.5)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildListCard(String title, List<dynamic> items, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: primaryText))),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 6, height: 6,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(item.toString(), style: GoogleFonts.inter(fontSize: 14, color: primaryText.withOpacity(0.8)))),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Icon(Icons.auto_awesome, size: 48, color: primaryGreen),
        const SizedBox(height: 16),
        Text("Personal AI Coach", style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: primaryText)),
        const SizedBox(height: 8),
        Text(
          "Enter your details to generate a highly customized, roadmap-style diet and fitness plan in seconds.",
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 15, color: primaryText.withOpacity(0.7)),
        )
      ],
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, TextInputType type, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: type,
        style: GoogleFonts.inter(color: primaryText),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: primaryGreen, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSegmentedControl(List<String> options, String currentValue, Function(String) onChanged) {
    return Row(
      children: options.map((opt) {
        final isSelected = opt == currentValue;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(opt),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: opt == options.last ? 0 : 12),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? primaryGreen : Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? primaryGreen : Colors.transparent),
              ),
              child: Center(
                child: Text(
                  opt,
                  style: GoogleFonts.inter(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : primaryText.withOpacity(0.7),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
