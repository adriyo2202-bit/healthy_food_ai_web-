import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'splash_screen.dart';
import 'ingredient_scanner_screen.dart';
import 'diet_planner_screen.dart';

// --- Global Chat State ---
class ChatMessage {
  final String role; // 'user' or 'ai'
  final String text;
  final List<String> uiIndicators;
  final List<String> sources;
  
  ChatMessage({required this.role, required this.text, this.uiIndicators = const [], this.sources = const []});
}

final ValueNotifier<List<ChatMessage>> chatHistoryNotifier = ValueNotifier([
  ChatMessage(
    role: 'ai',
    text: "Based on your layout today, a flexbox container would help you reach your target.",
  )
]);
final ValueNotifier<bool> isTypingNotifier = ValueNotifier(false);

Future<void> sendChatMessage(String text, {TextEditingController? controller}) async {
  if (text.trim().isEmpty) return;
  final userMessage = text.trim();
  controller?.clear();
  
  final currentHistory = List<ChatMessage>.from(chatHistoryNotifier.value);
  currentHistory.add(ChatMessage(role: 'user', text: userMessage));
  chatHistoryNotifier.value = currentHistory;
  isTypingNotifier.value = true;
  
  try {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"query": userMessage, "user_id": "user_A"}),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final aiMessage = ChatMessage(
        role: 'ai',
        text: data['answer'] ?? '',
        uiIndicators: List<String>.from(data['ui_indicators'] ?? []),
        sources: List<String>.from(data['sources'] ?? []),
      );
      final newHistory = List<ChatMessage>.from(chatHistoryNotifier.value);
      newHistory.add(aiMessage);
      chatHistoryNotifier.value = newHistory;
    } else {
      throw Exception("Server error");
    }
  } catch (e) {
    final newHistory = List<ChatMessage>.from(chatHistoryNotifier.value);
    newHistory.add(ChatMessage(role: 'ai', text: "Sorry, I couldn't connect to the backend. Is the FastAPI server running on port 8000?"));
    chatHistoryNotifier.value = newHistory;
  } finally {
    isTypingNotifier.value = false;
  }
}


// --- Colors (Glassmorphism / Dreamy Aesthetic) ---
const Color primaryBackground = Colors.transparent; // Let animation show
const Color primaryText = Color(0xFF1F2937); // Soft dark text for readability
const Color primaryGreen = Color(0xFF8B5CF6); // Restored vibrant purple
const Color secondaryGreen = Color(0xFFC4B5FD); // Restored soft purple accent
const Color softGreen = Color(0x70FFFFFF); // Frosted white for cards
const Color warmCream = Color(0x50FFFFFF); // More transparent white
const Color softBlue = Color(0x60FFFFFF); // Another frosted variation
const Color borderColor = Color(0x40FFFFFF); // Light transparent borders
const Color darkSectionBackground = Color(0x30000000); // Frosted dark
const Color warningColor = Color(0xFFF59E0B);
const Color dangerColor = Color(0xFFEF4444);

// --- Breakpoints ---
bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 768;
bool isTablet(BuildContext context) => MediaQuery.of(context).size.width >= 768 && MediaQuery.of(context).size.width < 1024;
bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1024;

class HealthyFoodApp extends StatelessWidget {
  const HealthyFoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Healthy Food AI',
      theme: ThemeData(
        scaffoldBackgroundColor: primaryBackground,
        textTheme: GoogleFonts.interTextTheme().apply(
          bodyColor: primaryText,
          displayColor: primaryText,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: primaryGreen),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class ContentContainer extends StatelessWidget {
  final Widget child;
  const ContentContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    double horizontalPadding = 20.0;
    if (isDesktop(context)) {
      horizontalPadding = 48.0;
    } else if (isTablet(context)) {
      horizontalPadding = 32.0;
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1320),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: child,
        ),
      ),
    );
  }
}

class HealthyFoodHomeScreen extends StatefulWidget {
  const HealthyFoodHomeScreen({super.key});

  @override
  State<HealthyFoodHomeScreen> createState() => _HealthyFoodHomeScreenState();
}

class _HealthyFoodHomeScreenState extends State<HealthyFoodHomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);
    return Scaffold(
      backgroundColor: Colors.transparent, // Allow background to show
      body: Stack(
        children: [
          // 1. Base image background
          Positioned.fill(
            child: Image.asset(
              'assets/background_animation.gif', 
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/background_animation.png', 
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
              )
            ),
          ),
          
          // 2. Floating Animated Orbs for extra aesthetic motion
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFC4B5FD).withOpacity(0.1), // Reduced intensity
                boxShadow: const [BoxShadow(color: Color(0xFFC4B5FD), blurRadius: 100, spreadRadius: 30)], // Softer glow
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .move(duration: 8.seconds, begin: const Offset(0, 0), end: const Offset(200, 200))
             .scale(duration: 5.seconds, begin: const Offset(1, 1), end: const Offset(1.5, 1.5)),
          ),
          
          // Scroll-driven Parallax Orb
          AnimatedBuilder(
            animation: _scrollController,
            builder: (context, child) {
              double bottomOffset = -250; // Initially hide 60-70% of the orb
              if (_scrollController.hasClients) {
                double maxScroll = _scrollController.position.maxScrollExtent;
                if (maxScroll > 0) {
                  double progress = (_scrollController.offset / maxScroll).clamp(0.0, 1.0);
                  // Moves up to +50px (fully visible) when scrolled to bottom
                  bottomOffset = -250 + (progress * 300);
                }
              }
              return Positioned(
                bottom: bottomOffset,
                right: -50,
                child: child!,
              );
            },
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8B5CF6).withOpacity(0.05), // Reduced intensity
                boxShadow: const [BoxShadow(color: Color(0xFF8B5CF6), blurRadius: 120, spreadRadius: 40)], // Softer glow
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .move(duration: 10.seconds, begin: const Offset(0, 0), end: const Offset(-150, -100))
             .scale(duration: 6.seconds, begin: const Offset(1, 1), end: const Offset(1.2, 1.2)),
          ),
          
          ListView(
            controller: _scrollController,
            children: [
              const HealthyFoodNavbar(),
              const HeroSection().animate().fade(duration: 500.ms).slideY(begin: 0.1),
              const SizedBox(height: 64),
              const QuickWebActions().animate().fade(duration: 500.ms).slideY(begin: 0.1),
              const SizedBox(height: 80),
              const PerformanceInsights().animate().fade(duration: 500.ms).slideY(begin: 0.1),
              const SizedBox(height: 80),
              const RecommendationFeed().animate().fade(duration: 500.ms).slideY(begin: 0.1),
              const SizedBox(height: 80),
              const WebInspectorShowcase().animate().fade(duration: 500.ms).slideY(begin: 0.1),
              const SizedBox(height: 80),
              const AIAssistantSection().animate().fade(duration: 500.ms).slideY(begin: 0.1),
              const Footer(),
              if (mobile) const SizedBox(height: 80), // Padding for bottom nav
            ],
          ),
          if (mobile)
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: MobileBottomNav(),
            ),
        ],
      ),
    );
  }
}

// --- Navbar ---
class HealthyFoodNavbar extends StatelessWidget {
  const HealthyFoodNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    if (isMobile(context)) {
      return Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLogo(),
            Row(
              children: [
                const Icon(Icons.notifications_none, color: primaryText),
                const SizedBox(width: 16),
                const CircleAvatar(radius: 16, backgroundColor: borderColor, child: Icon(Icons.person, size: 20, color: Colors.grey)),
              ],
            )
          ],
        ),
      );
    }

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLogo(),
          Row(
            children: [
              _navLink(context, 'Home', isActive: true),
              _navLink(context, 'AI Assistant'),
              _navLink(context, 'Web Inspector'),
              _navLink(context, 'Fitness'),
              _navLink(context, 'Dashboard'),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.notifications_none, color: primaryText),
              const SizedBox(width: 20),
              const CircleAvatar(radius: 16, backgroundColor: borderColor, child: Icon(Icons.person, size: 20, color: Colors.grey)),
              const SizedBox(width: 8),
              const Icon(Icons.keyboard_arrow_down, color: primaryText, size: 20),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        const Icon(Icons.eco, color: primaryGreen),
        const SizedBox(width: 8),
        Text(
          'HEALTHY FOOD AI',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18, letterSpacing: -0.5),
        ),
      ],
    );
  }

  Widget _navLink(BuildContext context, String text, {bool isActive = false}) {
    return InkWell(
      onTap: () {
        if (!isActive) Navigator.push(context, animatedRoute(TaskScreen(title: text)));
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? primaryText : primaryText.withOpacity(0.7),
              ),
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 4),
                height: 2,
                width: 24,
                color: primaryGreen,
              )
          ],
        ),
      ),
    );
  }
}

class MobileBottomNav extends StatelessWidget {
  const MobileBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: borderColor, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _bottomNavItem(context, Icons.home, 'Home', isActive: true),
          _bottomNavItem(context, Icons.auto_awesome, 'AI'),
          _bottomNavItem(context, Icons.camera_alt_outlined, 'Health'),
          _bottomNavItem(context, Icons.directions_run, 'Fitness'),
          _bottomNavItem(context, Icons.person_outline, 'Profile'),
        ],
      ),
    );
  }

  Widget _bottomNavItem(BuildContext context, IconData icon, String label, {bool isActive = false}) {
    return InkWell(
      onTap: () {
        if (!isActive) Navigator.push(context, animatedRoute(TaskScreen(title: label)));
      },
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isActive ? primaryGreen : Colors.grey, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: isActive ? primaryGreen : Colors.grey, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}

// --- Hero Section ---
class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);

    if (mobile) {
      return Column(
        children: [
          ContentContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  'HEALTHY FOOD AI · PERSONAL HEALTH INTELLIGENCE',
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: primaryGreen, letterSpacing: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your web,\nsimulated.',
                  style: GoogleFonts.inter(fontSize: 40, fontWeight: FontWeight.w700, height: 1.1, letterSpacing: -1),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Healthy Food AI turns your prompts, components and design data into simple actions you can actually follow.',
                  style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                ),
                const SizedBox(height: 24),
                const AIWorkspace(),
                const SizedBox(height: 24),
              ],
            ),
          ),
          SizedBox(
            height: 260,
            width: double.infinity,
            child: Image.asset('assets/images/hero_kitchen_food_1787489673952.jpg', fit: BoxFit.cover),
          ),
          const SizedBox(height: 24),
          ContentContainer(
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const WebInspectorScreen()));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('Generate Site', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const FeelingCreativeScreen()));
                    },
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: primaryGreen), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text("I'm Feeling Creative", style: TextStyle(color: primaryGreen, fontWeight: FontWeight.w600)),
                  ),
                )
              ],
            ),
          )
        ],
      );
    }

    return ContentContainer(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 560),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.only(right: 48.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'HEALTHY FOOD AI · PERSONAL HEALTH INTELLIGENCE',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: primaryGreen, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Your web,\nsimulated.',
                      style: GoogleFonts.inter(fontSize: 56, fontWeight: FontWeight.w800, height: 1.1, letterSpacing: -1.5),
                    ),
                    const SizedBox(height: 24),
                    const SizedBox(
                      width: 480,
                      child: Text(
                        'Healthy Food AI turns your prompts, components and design data into simple actions you can actually follow.',
                        style: TextStyle(fontSize: 18, height: 1.5, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const AIWorkspace(),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const WebInspectorScreen()));
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: const Text('Generate Site', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const FeelingCreativeScreen()));
                          },
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: primaryGreen), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: const Text("I'm Feeling Creative", style: TextStyle(color: primaryGreen, fontWeight: FontWeight.w600, fontSize: 16)),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/hero_kitchen_food_1787489673952.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.center,
                        colors: [primaryBackground, Colors.transparent],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -24,
                    right: 48,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Today's Design Score", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text("82", style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700)),
                                  const Text(" / 100", style: TextStyle(fontSize: 14, color: Colors.grey)),
                                ],
                              ),
                              const Text("Top 15%", style: TextStyle(fontSize: 12, color: primaryGreen, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(width: 24),
                          const SizedBox(
                            width: 48,
                            height: 48,
                            child: CircularProgressIndicator(value: 0.82, backgroundColor: softGreen, color: primaryGreen, strokeWidth: 6),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AIWorkspace extends StatefulWidget {
  const AIWorkspace({super.key});

  @override
  State<AIWorkspace> createState() => _AIWorkspaceState();
}

class _AIWorkspaceState extends State<AIWorkspace> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  final TextEditingController _controller = TextEditingController();

  void _handleSend() {
    if (_controller.text.trim().isEmpty) return;
    
    final text = _controller.text;
    _controller.clear();
    setState(() => _isExpanded = false);
    
    // Navigate to ChatScreen first
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
    
    // Then trigger the API call in the background
    sendChatMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!_isExpanded) {
          setState(() => _isExpanded = true);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: isMobile(context) ? double.infinity : 600,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  const Icon(Icons.eco, color: primaryGreen),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _handleSend(),
                      decoration: const InputDecoration(
                        hintText: 'Ask Healthy Food AI about your components, layout or performance...',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  if (!isMobile(context)) _buildDesktopActions(),
                ],
              ),
            ),
            if (isMobile(context))
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(icon: const Icon(Icons.camera_alt_outlined, size: 20), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.mic_none, size: 20), onPressed: () {}),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: softGreen, borderRadius: BorderRadius.circular(12)),
                      child: const Row(
                        children: [Icon(Icons.auto_awesome, size: 16, color: primaryGreen), SizedBox(width: 4), Text("AI Mode", style: TextStyle(fontSize: 12, color: primaryGreen, fontWeight: FontWeight.w600))],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _handleSend,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: primaryGreen, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.send, color: Colors.white, size: 16),
                      ),
                    )
                  ],
                ),
              ),
            if (_isExpanded)
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Suggested prompts', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _promptChip(context, "Create today's meal plan"),
                        _promptChip(context, "Analyze my food"),
                        _promptChip(context, "Check this ingredient"),
                        _promptChip(context, "Improve my sleep"),
                        _promptChip(context, "Analyze my workout"),
                      ],
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopActions() {
    return Row(
      children: [
        IconButton(icon: const Icon(Icons.mic_none, color: Colors.grey), onPressed: () {}),
        IconButton(icon: const Icon(Icons.camera_alt_outlined, color: Colors.grey), onPressed: () {}),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: softGreen, borderRadius: BorderRadius.circular(12)),
          child: const Row(
            children: [Icon(Icons.auto_awesome, size: 16, color: primaryGreen), SizedBox(width: 4), Text("AI Mode", style: TextStyle(fontSize: 13, color: primaryGreen, fontWeight: FontWeight.w600))],
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _handleSend,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: primaryGreen, borderRadius: BorderRadius.circular(12)),
            child: const Row(
              children: [Icon(Icons.send, color: Colors.white, size: 16), SizedBox(width: 6), Text("Send", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))],
            ),
          ),
        ),
      ],
    );
  }

  Widget _promptChip(BuildContext context, String text) {
    return InkWell(
      onTap: () {
        // Navigate to ChatScreen and trigger the API, just like _handleSend
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
        sendChatMessage(text);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: primaryBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Text(text, style: const TextStyle(fontSize: 13, color: primaryText)),
      ),
    );
  }
}

// --- Quick Health Actions ---
class QuickWebActions extends StatelessWidget {
  const QuickWebActions({super.key});

  @override
  Widget build(BuildContext context) {
    return ContentContainer(
      child: Column(
        children: [
          Text("Start with what matters today.", style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          const Text("Choose an action and let Healthy Food AI handle the complexity.", style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 40),
          if (isDesktop(context))
            const Row(
              children: [
                Expanded(child: _ActionCard(title: "Web Inspector", desc: "Scan a component and understand HTML, CSS and accessibility.", cta: "Inspect Element →", image: "assets/images/health_lens_food_1787489687935.jpg")),
                SizedBox(width: 24),
                Expanded(child: _ActionCard(title: "AI Site Creator", desc: "Turn your ideas into websites that fit your design goals.", cta: "Create a Site →", image: "assets/images/meal_creator_ingredients_1787489701432.jpg")),
                SizedBox(width: 24),
                Expanded(child: _ActionCard(title: "AI Diet Planner", desc: "Generate a highly customized, roadmap-style diet and fitness plan.", cta: "Plan Diet →", image: "assets/images/fitness_running_1787489715393.jpg")),
                SizedBox(width: 24),
                Expanded(child: _ActionCard(title: "Component Accessibility", desc: "Check accessibility, SEO and performance before you publish.", cta: "Check Component →", image: "assets/images/ingredient_safety_1787489740080.jpg")),
              ],
            )
          else if (isTablet(context))
            Column(
              children: [
                const Row(
                  children: [
                    Expanded(child: _ActionCard(title: "Web Inspector", desc: "Scan a component and understand HTML, CSS and accessibility.", cta: "Inspect Element →", image: "assets/images/health_lens_food_1787489687935.jpg")),
                    SizedBox(width: 24),
                    Expanded(child: _ActionCard(title: "AI Site Creator", desc: "Turn your ideas into websites that fit your design goals.", cta: "Create a Site →", image: "assets/images/meal_creator_ingredients_1787489701432.jpg")),
                  ],
                ),
                const SizedBox(height: 24),
                const Row(
                  children: [
                    Expanded(child: _ActionCard(title: "AI Diet Planner", desc: "Generate a highly customized, roadmap-style diet and fitness plan.", cta: "Plan Diet →", image: "assets/images/fitness_running_1787489715393.jpg")),
                    SizedBox(width: 24),
                    Expanded(child: _ActionCard(title: "Component Accessibility", desc: "Check accessibility, SEO and performance before you publish.", cta: "Check Component →", image: "assets/images/ingredient_safety_1787489740080.jpg")),
                  ],
                ),
              ],
            )
          else
            Column(
              children: const [
                _ActionCard(title: "Web Inspector", desc: "Scan a component and understand HTML, CSS and accessibility.", cta: "Inspect Element →", image: "assets/images/health_lens_food_1787489687935.jpg"),
                SizedBox(height: 16),
                _ActionCard(title: "AI Site Creator", desc: "Turn your ideas into websites that fit your design goals.", cta: "Create a Site →", image: "assets/images/meal_creator_ingredients_1787489701432.jpg"),
                SizedBox(height: 16),
                _ActionCard(title: "AI Diet Planner", desc: "Generate a highly customized, roadmap-style diet and fitness plan.", cta: "Plan Diet →", image: "assets/images/fitness_running_1787489715393.jpg"),
                SizedBox(height: 16),
                _ActionCard(title: "Component Accessibility", desc: "Check accessibility, SEO and performance before you publish.", cta: "Check Component →", image: "assets/images/ingredient_safety_1787489740080.jpg"),
              ],
            )
        ],
      ),
    );
  }
}

class _ActionCard extends StatefulWidget {
  final String title, desc, cta, image;
  const _ActionCard({required this.title, required this.desc, required this.cta, required this.image});

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.title == 'Web Inspector') {
          Navigator.push(context, animatedRoute(const IngredientScannerScreen()));
        } else if (widget.title == 'AI Diet Planner') {
          Navigator.push(context, animatedRoute(const DietPlannerScreen()));
        } else {
          Navigator.push(context, animatedRoute(TaskScreen(title: widget.title)));
        }
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, _isHovered ? -2 : 0, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _isHovered ? borderColor.withOpacity(0.8) : borderColor),
            boxShadow: _isHovered ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))] : [],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedScale(
                scale: _isHovered ? 1.02 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: Image.asset(widget.image, fit: BoxFit.cover),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(widget.desc, style: const TextStyle(color: Colors.black87, height: 1.4, fontSize: 14)),
                    const SizedBox(height: 24),
                    Text(widget.cta, style: const TextStyle(color: primaryGreen, fontWeight: FontWeight.w600)),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// --- Performance Insights ---
class PerformanceInsights extends StatelessWidget {
  const PerformanceInsights({super.key});

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);

    return Container(
      color: darkSectionBackground,
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: ContentContainer(
        child: Column(
          children: [
            const Text("A clearer picture of your health.", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Text("Healthy Food AI combines nutrition, movement and health signals into one simple view.", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16)),
            const SizedBox(height: 48),
            
            if (mobile)
              Column(
                children: [
                  _buildHealthScorePanel(),
                  const SizedBox(height: 24),
                  _buildPerformancePanel(),
                  const SizedBox(height: 24),
                  _buildTrafficPanel(),
                ],
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 4, child: _buildHealthScorePanel()),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 6,
                    child: Column(
                      children: [
                        _buildPerformancePanel(),
                        const SizedBox(height: 24),
                        _buildTrafficPanel(),
                      ],
                    ),
                  )
                ],
              ),
            
            const SizedBox(height: 48),
            TextButton(
              onPressed: () {},
              child: const Text("View Full Dashboard →", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHealthScorePanel() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Design Score", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 32),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                const SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(value: 0.82, backgroundColor: softGreen, color: secondaryGreen, strokeWidth: 12),
                ),
                Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text("82", style: GoogleFonts.inter(fontSize: 48, fontWeight: FontWeight.w700)),
                        const Text("/100", style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ],
                    ),
                    const Text("Top 15%", style: TextStyle(color: primaryGreen, fontWeight: FontWeight.w600)),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPerformancePanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Performance today", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          _progressBar("LCP", "1.2s", "2.5s", 0.78, primaryGreen),
          const SizedBox(height: 16),
          _progressBar("SEO", "92", "100", 0.78, primaryGreen),
        ],
      ),
    );
  }

  Widget _buildTrafficPanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Traffic", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              Icon(Icons.bar_chart, color: primaryGreen),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text("12,2.4m", style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 4),
                    const Text("Visitors", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text("2.4m", style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 4),
                    const Text("Avg Duration", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _progressBar(String label, String current, String total, double value, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Row(
              children: [
                Text(current, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(" / $total", style: const TextStyle(color: Colors.grey)),
              ],
            )
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: value, backgroundColor: softGreen, color: color, minHeight: 8, borderRadius: BorderRadius.circular(4)),
      ],
    );
  }
}

// --- Recommendation Feed ---
class RecommendationFeed extends StatelessWidget {
  const RecommendationFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return ContentContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Recommended for you", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text("Small actions that can make today better.", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          if (isMobile(context))
            const SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(width: 280, child: _RecCard(title: "LCP opportunity", desc: "Your meta tags are missing on 2 pages.", cta: "View Pages →", color: softGreen, dotColor: primaryGreen)),
                  SizedBox(width: 16),
                  SizedBox(width: 280, child: _RecCard(title: "Design insight", desc: "Your recent layout has contrast issues.", cta: "View Details →", color: warmCream, dotColor: warningColor)),
                  SizedBox(width: 16),
                  SizedBox(width: 280, child: _RecCard(title: "Performance goal", desc: "You're 0.4s away from your LCP goal.", cta: "Optimize Code →", color: softBlue, dotColor: Colors.blue)),
                ],
              ),
            )
          else
            const Row(
              children: [
                Expanded(child: _RecCard(title: "LCP opportunity", desc: "Your meta tags are missing on 2 pages.", cta: "View Pages →", color: softGreen, dotColor: primaryGreen)),
                SizedBox(width: 24),
                Expanded(child: _RecCard(title: "Design insight", desc: "Your recent layout has contrast issues.", cta: "View Details →", color: warmCream, dotColor: warningColor)),
                SizedBox(width: 24),
                Expanded(child: _RecCard(title: "Performance goal", desc: "You're 0.4s away from your LCP goal.", cta: "Optimize Code →", color: softBlue, dotColor: Colors.blue)),
              ],
            )
        ],
      ),
    );
  }
}

class _RecCard extends StatelessWidget {
  final String title, desc, cta;
  final Color color, dotColor;
  const _RecCard({required this.title, required this.desc, required this.cta, required this.color, required this.dotColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Text(desc, style: const TextStyle(color: Colors.black87, height: 1.4)),
          const SizedBox(height: 16),
          Text(cta, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// --- Web Inspector Showcase ---
class WebInspectorShowcase extends StatelessWidget {
  const WebInspectorShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);
    final imageWidget = ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Image.asset('assets/images/health_lens_showcase_1787489757701.jpg', fit: BoxFit.cover, width: double.infinity, height: mobile ? 300 : 500),
    );

    final textWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("SEE WEB DIFFERENTLY", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: primaryGreen, letterSpacing: 0.5)),
        const SizedBox(height: 16),
        Text("Know what's in your DOM.", style: GoogleFonts.inter(fontSize: 40, fontWeight: FontWeight.w700, height: 1.1, letterSpacing: -1)),
        const SizedBox(height: 16),
        const Text("Healthy Food Vision recognizes food and estimates nutrition while helping you understand potential safety concerns.", style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black87)),
        const SizedBox(height: 32),
        const Row(
          children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Component", style: TextStyle(fontWeight: FontWeight.w600)), Text("Recognition", style: TextStyle(fontSize: 13, color: Colors.grey))])),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Performance", style: TextStyle(fontWeight: FontWeight.w600)), Text("Estimation", style: TextStyle(fontSize: 13, color: Colors.grey))])),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Accessibility", style: TextStyle(fontWeight: FontWeight.w600)), Text("Analysis", style: TextStyle(fontSize: 13, color: Colors.grey))])),
          ],
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Text('Try Web Inspector →', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );

    return ContentContainer(
      child: mobile
          ? Column(children: [imageWidget, const SizedBox(height: 32), textWidget])
          : Row(
              children: [
                Expanded(flex: 5, child: imageWidget),
                const SizedBox(width: 64),
                Expanded(flex: 5, child: textWidget),
              ],
            ),
    );
  }
}

// --- AI Assistant Preview ---
class AIAssistantSection extends StatelessWidget {
  const AIAssistantSection({super.key});

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);

    return Container(
      color: primaryGreen, // Dark green background
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: ContentContainer(
        child: mobile
            ? Column(
                children: [
                  _buildTextContent(),
                  const SizedBox(height: 48),
                  _buildChatPreview(context),
                ],
              )
            : Row(
                children: [
                  Expanded(flex: 5, child: Padding(padding: const EdgeInsets.only(right: 48), child: _buildTextContent())),
                  Expanded(flex: 5, child: _buildChatPreview(context)),
                ],
              ),
      ),
    );
  }

  Widget _buildTextContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("AI ASSISTANT PREVIEW", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white70, letterSpacing: 1)),
        const SizedBox(height: 16),
        Text("Your web development questions, answered.", style: GoogleFonts.inter(fontSize: 40, fontWeight: FontWeight.w700, height: 1.1, color: Colors.white, letterSpacing: -1)),
        const SizedBox(height: 16),
        const Text("From layout planning to performance advice, Healthy Food AI brings your design context into every conversation.", style: TextStyle(fontSize: 16, height: 1.5, color: Colors.white70)),
      ],
    );
  }

  Widget _buildChatPreview(BuildContext context) {
    return Container(
      height: 400, // Fixed height for scrollable chat
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 16, backgroundColor: softGreen, child: Icon(Icons.eco, color: primaryGreen, size: 16)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Healthy Food AI", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  Row(
                    children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: secondaryGreen, shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      const Text("Online", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  )
                ],
              )
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ValueListenableBuilder<List<ChatMessage>>(
              valueListenable: chatHistoryNotifier,
              builder: (context, history, child) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: history.length + 1,
                  itemBuilder: (context, index) {
                    if (index == history.length) {
                      // Typing indicator
                      return ValueListenableBuilder<bool>(
                        valueListenable: isTypingNotifier,
                        builder: (context, isTyping, child) {
                          if (!isTyping) return const SizedBox.shrink();
                          return const Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Text("Nutrix AI is thinking...", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                          );
                        }
                      );
                    }
                    final msg = history[index];
                    final isUser = msg.role == 'user';
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: [
                          if (!isUser) const CircleAvatar(radius: 12, backgroundColor: softGreen, child: Icon(Icons.eco, color: primaryGreen, size: 12)),
                          if (!isUser) const SizedBox(width: 12),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isUser ? primaryGreen : softGreen.withOpacity(0.5), 
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                                  bottomRight: isUser ? Radius.zero : const Radius.circular(16)
                                )
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (msg.uiIndicators.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: msg.uiIndicators.map((ui) => Text(ui, style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontStyle: FontStyle.italic))).toList(),
                                      ),
                                    ),
                                  Text(
                                    msg.text, 
                                    style: TextStyle(color: isUser ? Colors.white : primaryText, height: 1.4)
                                  ),
                                  if (msg.sources.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: msg.sources.map((src) => Text(src, style: const TextStyle(fontSize: 11, color: Colors.black54))).toList(),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          if (isUser) const SizedBox(width: 12),
                          if (isUser) const CircleAvatar(radius: 12, backgroundColor: primaryGreen, child: Icon(Icons.person, color: Colors.white, size: 12)),
                        ],
                      ),
                    );
                  },
                );
              }
            ),
          ),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _chatChip("Show layout ideas"),
                const SizedBox(width: 8),
                _chatChip("Why flexbox?"),
                const SizedBox(width: 8),
                _chatChip("Create my layout"),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Open Healthy Food AI →', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          )
        ],
      ),
    );
  }

  Widget _chatChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(border: Border.all(color: borderColor), borderRadius: BorderRadius.circular(16)),
      child: Text(text, style: const TextStyle(fontSize: 12, color: primaryText, fontWeight: FontWeight.w500)),
    );
  }
}

// --- Footer ---
class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: ContentContainer(
        child: mobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("HEALTHY FOOD AI", style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.5)),
                  const SizedBox(height: 8),
                  const Text("Web simulation intelligence.", style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 32),
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Home", style: TextStyle(height: 2.5, fontWeight: FontWeight.w500)),
                            Text("AI Assistant", style: TextStyle(height: 2.5, fontWeight: FontWeight.w500)),
                            Text("Web Inspector", style: TextStyle(height: 2.5, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Fitness", style: TextStyle(height: 2.5, fontWeight: FontWeight.w500)),
                            Text("Dashboard", style: TextStyle(height: 2.5, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Privacy", style: TextStyle(height: 2.5, fontWeight: FontWeight.w500)),
                            Text("Settings", style: TextStyle(height: 2.5, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text("© HEALTHY FOOD AI", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              )
            : const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("HEALTHY FOOD AI", style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.5)),
                        SizedBox(height: 8),
                        Text("Web simulation intelligence.", style: TextStyle(color: Colors.grey, fontSize: 14)),
                        SizedBox(height: 48),
                        Text("© HEALTHY FOOD AI", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Home", style: TextStyle(height: 2.5, fontWeight: FontWeight.w500)),
                        Text("AI Assistant", style: TextStyle(height: 2.5, fontWeight: FontWeight.w500)),
                        Text("Web Inspector", style: TextStyle(height: 2.5, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Fitness", style: TextStyle(height: 2.5, fontWeight: FontWeight.w500)),
                        Text("Dashboard", style: TextStyle(height: 2.5, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Privacy", style: TextStyle(height: 2.5, fontWeight: FontWeight.w500)),
                        Text("Settings", style: TextStyle(height: 2.5, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  )
                ],
              ),
      ),
    );
  }
}

// --- Web Inspector Screen ---
class WebInspectorScreen extends StatelessWidget {
  const WebInspectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const HealthyFoodNavbar(),
                const SizedBox(height: 48),
                Text("HEALTHY FOOD VISION", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: primaryGreen, letterSpacing: 0.5)),
                const SizedBox(height: 16),
                Text("What's in your DOM?", style: GoogleFonts.inter(fontSize: 40, fontWeight: FontWeight.w700, letterSpacing: -1)),
                const SizedBox(height: 12),
                const Text("Use your camera to understand your layout, performance and accessibility.", style: TextStyle(fontSize: 16, color: Colors.black87)),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: const Text('Inspect Element', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: primaryGreen), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: const Text('Upload Mockup', style: TextStyle(color: primaryGreen, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                ContentContainer(
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: borderColor)),
                    child: isMobile(context) ? _buildMobileLayout() : _buildDesktopLayout(),
                  ),
                ),
                const SizedBox(height: 48),
                if (!isMobile(context)) _buildTipsSection(),
                const SizedBox(height: 120),
              ],
            ),
          ),
          if (isMobile(context)) const Positioned(bottom: 0, left: 0, right: 0, child: MobileBottomNav()),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 5, child: _buildImageSection()),
          Container(width: 1, color: borderColor),
          Expanded(flex: 5, child: _buildAnalysisSection()),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        SizedBox(height: 300, child: _buildImageSection()),
        Container(height: 1, color: borderColor),
        _buildAnalysisSection(),
      ],
    );
  }

  Widget _buildImageSection() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), bottomLeft: Radius.circular(24)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/biryani_scan_1787490810029.jpg', fit: BoxFit.cover),
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: primaryGreen.withOpacity(0.5), width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Positioned(top: 0, left: 0, right: 0, height: 2, child: Container(color: primaryGreen)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAnalysisSection() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Hero Component", 
                  style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: softGreen, borderRadius: BorderRadius.circular(12)),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: primaryGreen, size: 14),
                    SizedBox(width: 4),
                    Text("94% confidence", style: TextStyle(color: primaryGreen, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 24),
          const Text("Performance", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _nutrientCard("SEO", "640", "kcal", softGreen)),
              const SizedBox(width: 8),
              Expanded(child: _nutrientCard("LCP", "28g", "", softGreen)),
              const SizedBox(width: 8),
              Expanded(child: _nutrientCard("Carbs", "72g", "", warmCream)),
              const SizedBox(width: 8),
              Expanded(child: _nutrientCard("Fat", "24g", "", warmCream)),
            ],
          ),
          const SizedBox(height: 32),
          const Text("Component Accessibility", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: softGreen, borderRadius: BorderRadius.circular(8)),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: primaryGreen, size: 18),
                SizedBox(width: 8),
                Text("No accessibility issues detected", style: TextStyle(color: primaryGreen, fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _safetyItem("Contrast", "Good", warningColor),
          const SizedBox(height: 8),
          _safetyItem("Aria Labels", "All present", primaryGreen),
          const SizedBox(height: 8),
          _safetyItem("Console Errors", "0 detected", primaryGreen),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Text('Save Component', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), side: const BorderSide(color: borderColor)),
                  child: const Text('Inspect Again', style: TextStyle(color: primaryText, fontWeight: FontWeight.w500)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), side: const BorderSide(color: borderColor)),
                  child: const Text('View Details', style: TextStyle(color: primaryText, fontWeight: FontWeight.w500)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _nutrientCard(String label, String value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.local_fire_department, size: 16, color: primaryText.withOpacity(0.5)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              if (unit.isNotEmpty) Text(unit, style: const TextStyle(fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  Widget _safetyItem(String label, String value, Color color) {
    return Row(
      children: [
        Text("$label — ", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }

  Widget _buildTipsSection() {
    return ContentContainer(
      child: Row(
        children: [
          Expanded(child: _tipCard("Blurred mockup", "Scan your camera to understand the layout of your mockup.", "assets/images/health_lens_food_1787489687935.jpg")),
          const SizedBox(width: 16),
          Expanded(child: _tipCard("No components", "No components items recognized, upload a valid mockup.", "assets/images/meal_creator_ingredients_1787489701432.jpg")),
          const SizedBox(width: 16),
          Expanded(child: _tipCard("Low resolution", "Your mockup is too low resolution for food recognition.", "assets/images/ingredient_safety_1787489740080.jpg")),
        ],
      ),
    );
  }

  Widget _tipCard(String title, String desc, String image) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
      child: Row(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset(image, width: 60, height: 60, fit: BoxFit.cover)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// --- Feeling Creative Screen ---
class FeelingCreativeScreen extends StatelessWidget {
  const FeelingCreativeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/feeling_healthy_bg_1787490823270.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const HealthyFoodNavbar(),
                Expanded(
                  child: ContentContainer(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.verified, color: primaryGreen, size: 80),
                        const SizedBox(height: 24),
                        Text(
                          "You're doing great!",
                          style: GoogleFonts.inter(
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Your health score is in the top 15%.\nKeep up the excellent work with your design and performance.",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Return Home', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isMobile(context))
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: MobileBottomNav(),
            ),
        ],
      ),
    );
  }
}

// --- New Chat Screen ---
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  void _handleSend() {
    sendChatMessage(_controller.text, controller: _controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Nutrix AI Assistant', style: TextStyle(color: primaryGreen, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: primaryGreen),
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder<List<ChatMessage>>(
              valueListenable: chatHistoryNotifier,
              builder: (context, history, child) {
                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: history.length + 1,
                  itemBuilder: (context, index) {
                    if (index == history.length) {
                      return ValueListenableBuilder<bool>(
                        valueListenable: isTypingNotifier,
                        builder: (context, isTyping, child) {
                          if (!isTyping) return const SizedBox.shrink();
                          return const Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Text("Nutrix AI is thinking...", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                          );
                        }
                      );
                    }
                    final msg = history[index];
                    final isUser = msg.role == 'user';
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: [
                          if (!isUser) const CircleAvatar(radius: 16, backgroundColor: softGreen, child: Icon(Icons.eco, color: primaryGreen, size: 16)),
                          if (!isUser) const SizedBox(width: 16),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isUser ? primaryGreen : Colors.white, 
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                                  bottomRight: isUser ? Radius.zero : const Radius.circular(16)
                                ),
                                boxShadow: [if (!isUser) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (msg.uiIndicators.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: msg.uiIndicators.map((ui) => Text(ui, style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontStyle: FontStyle.italic))).toList(),
                                      ),
                                    ),
                                  isUser 
                                    ? Text(
                                        msg.text, 
                                        style: const TextStyle(color: Colors.white, height: 1.5, fontSize: 16)
                                      )
                                    : MarkdownBody(
                                        data: msg.text,
                                        styleSheet: MarkdownStyleSheet(
                                          p: const TextStyle(color: primaryText, height: 1.5, fontSize: 16),
                                          h1: const TextStyle(color: primaryText, height: 1.5, fontSize: 24, fontWeight: FontWeight.bold),
                                          h2: const TextStyle(color: primaryText, height: 1.5, fontSize: 22, fontWeight: FontWeight.bold),
                                          h3: const TextStyle(color: primaryText, height: 1.5, fontSize: 20, fontWeight: FontWeight.bold),
                                          listBullet: const TextStyle(color: primaryText, fontSize: 16),
                                          strong: const TextStyle(color: primaryText, fontWeight: FontWeight.bold),
                                          blockquote: const TextStyle(color: primaryGreen, fontStyle: FontStyle.italic, fontSize: 16),
                                          blockquoteDecoration: const BoxDecoration(
                                            border: Border(left: BorderSide(color: primaryGreen, width: 4)),
                                            color: softGreen,
                                          ),
                                        ),
                                      ),
                                  if (msg.sources.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: msg.sources.map((src) => Text(src, style: const TextStyle(fontSize: 12, color: Colors.black54))).toList(),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          if (isUser) const SizedBox(width: 16),
                          if (isUser) const CircleAvatar(radius: 16, backgroundColor: primaryGreen, child: Icon(Icons.person, color: Colors.white, size: 16)),
                        ],
                      ),
                    );
                  },
                );
              }
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: primaryBackground,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: borderColor)
                      ),
                      child: TextField(
                        controller: _controller,
                        onSubmitted: (_) => _handleSend(),
                        decoration: const InputDecoration(
                          hintText: 'Ask a follow up question...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _handleSend,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(color: primaryGreen, shape: BoxShape.circle),
                      child: const Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

// --- Task Screen & Routing ---
Route animatedRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var curve = Curves.easeInOutQuart;
      var tween = Tween(begin: const Offset(0.0, 1.0), end: Offset.zero).chain(CurveTween(curve: curve));
      var fadeTween = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));
      return SlideTransition(
        position: animation.drive(tween),
        child: FadeTransition(
          opacity: animation.drive(fadeTween),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 600),
  );
}

class TaskScreen extends StatelessWidget {
  final String title;
  const TaskScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(title, style: GoogleFonts.inter(color: primaryText, fontWeight: FontWeight.bold)),
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
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/background_animation.png', 
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
              )
            ),
          ),
          // Custom Animated Loader based on title
          _buildCustomLoader(),
        ],
      ),
    );
  }

  Widget _buildCustomLoader() {
    String t = title.toLowerCase();

    if (t.contains('ai') || t.contains('assistant')) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryGreen.withOpacity(0.2),
                boxShadow: [BoxShadow(color: primaryGreen.withOpacity(0.6), blurRadius: 40, spreadRadius: 10)]
              ),
              child: const Icon(Icons.psychology, size: 50, color: Colors.white),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .scale(duration: 1.seconds, begin: const Offset(0.9, 0.9), end: const Offset(1.2, 1.2))
             .shimmer(duration: 2.seconds),
            const SizedBox(height: 32),
            Text(
              'Connecting to AI Core...',
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: primaryText),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).fade(duration: 1.seconds),
          ],
        ),
      );
    } else if (t.contains('inspector') || t.contains('web')) {
      return Center(
        child: Column(
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
              'Analyzing DOM Structure...',
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: primaryText),
            ).animate().slideY(begin: 0.5).fade(),
          ],
        ),
      );
    } else if (t.contains('fitness') || t.contains('health')) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite, size: 80, color: dangerColor)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(duration: 400.ms, begin: const Offset(1, 1), end: const Offset(1.3, 1.3), curve: Curves.elasticOut),
            const SizedBox(height: 32),
            Text(
              'Syncing Biometrics...',
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: primaryText),
            ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1.5.seconds, color: dangerColor),
          ],
        ),
      );
    } else if (t.contains('dashboard') || t.contains('home')) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    valueColor: const AlwaysStoppedAnimation<Color>(primaryGreen),
                    strokeWidth: 8,
                    backgroundColor: primaryGreen.withOpacity(0.2),
                  ),
                ).animate(onPlay: (c) => c.repeat()).rotate(duration: 2.seconds),
                const Icon(Icons.dashboard, size: 40, color: primaryGreen).animate().fade(duration: 1.seconds),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Aggregating Data...',
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: primaryText),
            ).animate().fadeIn(duration: 800.ms),
          ],
        ),
      );
    } else {
      // Generic fallback
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, size: 80, color: primaryGreen).animate().fade().scale(delay: 200.ms),
            const SizedBox(height: 24),
            Text(
              'Loading $title...',
              style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: primaryText),
            ).animate().fade(delay: 400.ms).slideY(begin: 0.2),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: primaryGreen).animate().fade(delay: 600.ms),
          ],
        ),
      );
    }
  }
}
