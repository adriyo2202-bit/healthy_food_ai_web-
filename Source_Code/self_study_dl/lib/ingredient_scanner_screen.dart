import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'prototype_web_sim.dart'; // To get colors like primaryGreen, primaryBackground

class IngredientScannerScreen extends StatefulWidget {
  const IngredientScannerScreen({super.key});

  @override
  State<IngredientScannerScreen> createState() => _IngredientScannerScreenState();
}

class _IngredientScannerScreenState extends State<IngredientScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  bool _isLoading = false;
  Map<String, dynamic>? _analysisResult;
  String? _errorMessage;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
          _analysisResult = null;
          _errorMessage = null;
        });
        _analyzeImage(pickedFile);
      }
    } catch (e) {
      setState(() => _errorMessage = "Error picking image: $e");
    }
  }

  Future<void> _analyzeImage(XFile file) async {
    setState(() => _isLoading = true);
    
    try {
      var request = http.MultipartRequest('POST', Uri.parse('http://127.0.0.1:8000/analyze-label'));
      
      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: file.name));
      } else {
        request.files.add(await http.MultipartFile.fromPath('file', file.path));
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        setState(() {
          _analysisResult = json.decode(responseData);
          _isLoading = false;
        });
      } else {
        var errorData = await response.stream.bytesToString();
        setState(() {
          _errorMessage = "Server error: ${response.statusCode} - $errorData";
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

  Widget _buildScannerAnimation() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 16,
              height: 60,
              decoration: BoxDecoration(
                color: secondaryGreen,
                borderRadius: BorderRadius.circular(8),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .scaleY(duration: 600.ms, delay: (index * 200).ms, begin: 0.2, end: 1.5)
             .tint(color: primaryGreen, duration: 600.ms);
          }),
        ),
        const SizedBox(height: 32),
        Text(
          'Scanning Ingredients...',
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: primaryText),
        ).animate().slideY(begin: 0.5).fade(),
        const SizedBox(height: 8),
        Text(
          'Analyzing OCR and safety data',
          style: TextStyle(color: Colors.grey.shade600),
        ).animate().fade(delay: 400.ms),
      ],
    );
  }

  Widget _buildResultView() {
    if (_analysisResult == null) return const SizedBox.shrink();

    final score = _analysisResult!['overall_safety_score'] ?? 0;
    Color scoreColor = score >= 80 ? const Color(0xFF2E8B57) : (score >= 50 ? Colors.orange : dangerColor);
    
    final ingredients = _analysisResult!['ingredients'] as List<dynamic>? ?? [];
    final safeIngredients = ingredients.where((i) {
      final verdict = (i['safety_verdict'] ?? '').toString().toLowerCase().trim();
      return verdict == 'safe';
    }).toList();
    final unsafeIngredients = ingredients.where((i) {
      final verdict = (i['safety_verdict'] ?? '').toString().toLowerCase().trim();
      return verdict != 'safe';
    }).toList();
    final warnings = _analysisResult!['warnings_detected'] as List<dynamic>? ?? [];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, spreadRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Safety Score", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: primaryText)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: scoreColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text("$score / 100", style: TextStyle(color: scoreColor, fontWeight: FontWeight.bold, fontSize: 18)),
              )
            ],
          ),
          const SizedBox(height: 24),
          if (warnings.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.withOpacity(0.3))),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(child: Text(warnings.join("; "), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600))),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          if (unsafeIngredients.isNotEmpty) ...[
            Text("Requires Attention", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)),
            const SizedBox(height: 12),
            ...unsafeIngredients.map((i) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(((i['safety_verdict'] ?? '').toString().toLowerCase().trim()) == 'unsafe' ? Icons.cancel : Icons.info_outline, color: ((i['safety_verdict'] ?? '').toString().toLowerCase().trim()) == 'unsafe' ? Colors.red : Colors.orange, size: 16),
                      const SizedBox(width: 8),
                      Text(i['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const Spacer(),
                      Text(i['eu_status'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                  if (i['long_term_risk'] == true && i['long_term_risk_detail'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(i['long_term_risk_detail'], style: const TextStyle(fontSize: 13, color: Colors.red)),
                    )
                ],
              ),
            )),
            const SizedBox(height: 24),
          ],
          
          if (safeIngredients.isNotEmpty) ...[
            Text("Safe Ingredients", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF2E8B57))),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: safeIngredients.map((i) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.withOpacity(0.2)),
                ),
              )).toList(),
            ),
            const SizedBox(height: 24),
          ],

          if (_analysisResult!['summary_bn_en'] != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryGreen.withOpacity(0.05), const Color(0xFF8B5CF6).withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF8B5CF6).withOpacity(0.1), blurRadius: 20, spreadRadius: -5)
                ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Color(0xFF8B5CF6)),
                      const SizedBox(width: 10),
                      Text("AI Verdict", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF8B5CF6))),
                    ]
                  ),
                  const SizedBox(height: 16),
                  MarkdownBody(
                    data: _analysisResult!['summary_bn_en'],
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(fontSize: 15, height: 1.6, color: primaryText),
                      strong: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8B5CF6)),
                    ),
                  ),
                ],
              ),
            ).animate().shimmer(duration: 2000.ms, color: Colors.white24).slideY(begin: 0.2),
        ],
      ).animate().fade(duration: 800.ms).slideY(begin: 0.1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Ingredient Scanner', style: GoogleFonts.inter(color: primaryText, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryText),
      ),
      body: Stack(
        children: [
          // Background matches home
          Positioned.fill(
            child: Image.asset(
              'assets/background_animation.gif', 
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE2F0FF), Color(0xFFFFE0E2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                )
              )
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_imageFile == null) ...[
                    const SizedBox(height: 60),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.document_scanner, size: 80, color: primaryGreen),
                            const SizedBox(height: 24),
                            Text("Scan a Nutrition Label", style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Text("Capture or upload a photo of a food label to instantly analyze its safety.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                            const SizedBox(height: 40),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => _pickImage(ImageSource.camera),
                                  icon: const Icon(Icons.camera_alt),
                                  label: const Text("Camera"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryGreen,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                OutlinedButton.icon(
                                  onPressed: () => _pickImage(ImageSource.gallery),
                                  icon: const Icon(Icons.photo_library),
                                  label: const Text("Gallery"),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: primaryGreen,
                                    side: const BorderSide(color: primaryGreen),
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
                    )
                  ] else ...[
                    // Show Image Thumbnail
                    Center(
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 32),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
                          image: DecorationImage(
                            image: kIsWeb ? NetworkImage(_imageFile!.path) as ImageProvider : FileImage(File(_imageFile!.path)),
                            fit: BoxFit.cover,
                          )
                        ),
                      ).animate().fade(),
                    ),
                    
                    if (_isLoading)
                      _buildScannerAnimation()
                    else if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(16)),
                        child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                      )
                    else
                      _buildResultView(),
                      
                    if (!_isLoading) ...[
                      const SizedBox(height: 32),
                      Center(
                        child: TextButton.icon(
                          onPressed: () => setState(() { _imageFile = null; _analysisResult = null; _errorMessage = null; }),
                          icon: const Icon(Icons.refresh),
                          label: const Text("Scan Another"),
                          style: TextButton.styleFrom(foregroundColor: primaryText),
                        ),
                      )
                    ]
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
