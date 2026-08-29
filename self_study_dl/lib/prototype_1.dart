import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Colors ---
const Color primaryBackground = Color(0xFFF7F8F4);
const Color primaryText = Color(0xFF17211B);
const Color primaryGreen = Color(0xFF2F6B4F);
const Color secondaryGreen = Color(0xFF6F9F7C);
const Color softGreen = Color(0xFFE5F0E8);
const Color warmCream = Color(0xFFF2EBDD);
const Color softBlue = Color(0xFFDCEAF0);
const Color borderColor = Color(0xFFDCE1DC);
const Color darkSectionBackground = Color(0xFF17211B);
const Color warningColor = Color(0xFFD9824B);
const Color dangerColor = Color(0xFFC85C55);

// --- Breakpoints ---
bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 768;
bool isTablet(BuildContext context) => MediaQuery.of(context).size.width >= 768 && MediaQuery.of(context).size.width < 1024;
bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1024;

class NutrixApp extends StatelessWidget {
  const NutrixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nutrix AI',
      theme: ThemeData(
        scaffoldBackgroundColor: primaryBackground,
        textTheme: GoogleFonts.interTextTheme().apply(
          bodyColor: primaryText,
          displayColor: primaryText,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: primaryGreen),
        useMaterial3: true,
      ),
      home: const NutrixHomeScreen(),
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

class NutrixHomeScreen extends StatelessWidget {
  const NutrixHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const NutrixNavbar(),
                const HeroSection(),
                const SizedBox(height: 64),
                const QuickHealthActions(),
                const SizedBox(height: 80),
                const HealthInsights(),
                const SizedBox(height: 80),
                const RecommendationFeed(),
                const SizedBox(height: 80),
                const HealthLensShowcase(),
                const SizedBox(height: 80),
                const AIAssistantSection(),
                const Footer(),
                if (mobile) const SizedBox(height: 80), // Padding for bottom nav
              ],
            ),
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
class NutrixNavbar extends StatelessWidget {
  const NutrixNavbar({super.key});

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
              _navLink('Home', isActive: true),
              _navLink('AI Assistant'),
              _navLink('Health Lens'),
              _navLink('Fitness'),
              _navLink('Dashboard'),
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
          'NUTRIX AI',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18, letterSpacing: -0.5),
        ),
      ],
    );
  }

  Widget _navLink(String text, {bool isActive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
          _bottomNavItem(Icons.home, 'Home', isActive: true),
          _bottomNavItem(Icons.auto_awesome, 'AI'),
          _bottomNavItem(Icons.camera_alt_outlined, 'Health'),
          _bottomNavItem(Icons.directions_run, 'Fitness'),
          _bottomNavItem(Icons.person_outline, 'Profile'),
        ],
      ),
    );
  }

  Widget _bottomNavItem(IconData icon, String label, {bool isActive = false}) {
    return InkWell(
      onTap: () {},
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
                  'NUTRIX AI · PERSONAL HEALTH INTELLIGENCE',
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: primaryGreen, letterSpacing: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your health,\nunderstood.',
                  style: GoogleFonts.inter(fontSize: 40, fontWeight: FontWeight.w700, height: 1.1, letterSpacing: -1),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Nutrix AI turns your food, activity and health data into simple actions you can actually follow.',
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
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthLensScreen()));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('Search Health', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const FeelingHealthyScreen()));
                    },
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: primaryGreen), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text("I'm Feeling Healthy", style: TextStyle(color: primaryGreen, fontWeight: FontWeight.w600)),
                  ),
                )
              ],
            ),
          )
        ],
      );
    }

    return ContentContainer(
      child: SizedBox(
        height: 560,
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
                      'NUTRIX AI · PERSONAL HEALTH INTELLIGENCE',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: primaryGreen, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Your health,\nunderstood.',
                      style: GoogleFonts.inter(fontSize: 56, fontWeight: FontWeight.w800, height: 1.1, letterSpacing: -1.5),
                    ),
                    const SizedBox(height: 24),
                    const SizedBox(
                      width: 480,
                      child: Text(
                        'Nutrix AI turns your food, activity and health data into simple actions you can actually follow.',
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
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthLensScreen()));
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: const Text('Search Health', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const FeelingHealthyScreen()));
                          },
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: primaryGreen), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: const Text("I'm Feeling Healthy", style: TextStyle(color: primaryGreen, fontWeight: FontWeight.w600, fontSize: 16)),
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
                              const Text("Today's Health Score", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
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
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Ask Nutrix about your food, health or fitness...',
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
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: primaryGreen, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.send, color: Colors.white, size: 16),
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
                        _promptChip("Create today's meal plan"),
                        _promptChip("Analyze my food"),
                        _promptChip("Check this ingredient"),
                        _promptChip("Improve my sleep"),
                        _promptChip("Analyze my workout"),
                      ],
                    )
                  ],
                ),
              )
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(color: primaryGreen, borderRadius: BorderRadius.circular(12)),
          child: const Row(
            children: [Icon(Icons.send, color: Colors.white, size: 16), SizedBox(width: 6), Text("Send", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))],
          ),
        ),
      ],
    );
  }

  Widget _promptChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: primaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Text(text, style: const TextStyle(fontSize: 13, color: primaryText)),
    );
  }
}

// --- Quick Health Actions ---
class QuickHealthActions extends StatelessWidget {
  const QuickHealthActions({super.key});

  @override
  Widget build(BuildContext context) {
    return ContentContainer(
      child: Column(
        children: [
          Text("Start with what matters today.", style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          const Text("Choose an action and let Nutrix handle the complexity.", style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 40),
          if (isDesktop(context))
            const Row(
              children: [
                Expanded(child: _ActionCard(title: "Health Lens", desc: "Scan a meal and understand calories, macros and food safety.", cta: "Scan Food →", image: "assets/images/health_lens_food_1787489687935.jpg")),
                SizedBox(width: 24),
                Expanded(child: _ActionCard(title: "AI Meal Creator", desc: "Turn your leftovers into meals that fit your nutrition goals.", cta: "Create a Meal →", image: "assets/images/meal_creator_ingredients_1787489701432.jpg")),
                SizedBox(width: 24),
                Expanded(child: _ActionCard(title: "Fitness Intelligence", desc: "Understand your activity, workouts and daily movement.", cta: "View Fitness →", image: "assets/images/fitness_running_1787489715393.jpg")),
                SizedBox(width: 24),
                Expanded(child: _ActionCard(title: "Ingredient Safety", desc: "Check additives, allergens and food safety before you eat.", cta: "Check Ingredient →", image: "assets/images/ingredient_safety_1787489740080.jpg")),
              ],
            )
          else if (isTablet(context))
            Column(
              children: [
                const Row(
                  children: [
                    Expanded(child: _ActionCard(title: "Health Lens", desc: "Scan a meal and understand calories, macros and food safety.", cta: "Scan Food →", image: "assets/images/health_lens_food_1787489687935.jpg")),
                    SizedBox(width: 24),
                    Expanded(child: _ActionCard(title: "AI Meal Creator", desc: "Turn your leftovers into meals that fit your nutrition goals.", cta: "Create a Meal →", image: "assets/images/meal_creator_ingredients_1787489701432.jpg")),
                  ],
                ),
                const SizedBox(height: 24),
                const Row(
                  children: [
                    Expanded(child: _ActionCard(title: "Fitness Intelligence", desc: "Understand your activity, workouts and daily movement.", cta: "View Fitness →", image: "assets/images/fitness_running_1787489715393.jpg")),
                    SizedBox(width: 24),
                    Expanded(child: _ActionCard(title: "Ingredient Safety", desc: "Check additives, allergens and food safety before you eat.", cta: "Check Ingredient →", image: "assets/images/ingredient_safety_1787489740080.jpg")),
                  ],
                ),
              ],
            )
          else
            Column(
              children: const [
                _ActionCard(title: "Health Lens", desc: "Scan a meal and understand calories, macros and food safety.", cta: "Scan Food →", image: "assets/images/health_lens_food_1787489687935.jpg"),
                SizedBox(height: 16),
                _ActionCard(title: "AI Meal Creator", desc: "Turn your leftovers into meals that fit your nutrition goals.", cta: "Create a Meal →", image: "assets/images/meal_creator_ingredients_1787489701432.jpg"),
                SizedBox(height: 16),
                _ActionCard(title: "Fitness Intelligence", desc: "Understand your activity, workouts and daily movement.", cta: "View Fitness →", image: "assets/images/fitness_running_1787489715393.jpg"),
                SizedBox(height: 16),
                _ActionCard(title: "Ingredient Safety", desc: "Check additives, allergens and food safety before you eat.", cta: "Check Ingredient →", image: "assets/images/ingredient_safety_1787489740080.jpg"),
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
    return MouseRegion(
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
    );
  }
}

// --- Health Insights ---
class HealthInsights extends StatelessWidget {
  const HealthInsights({super.key});

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
            Text("Nutrix combines nutrition, movement and health signals into one simple view.", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16)),
            const SizedBox(height: 48),
            
            if (mobile)
              Column(
                children: [
                  _buildHealthScorePanel(),
                  const SizedBox(height: 24),
                  _buildNutritionPanel(),
                  const SizedBox(height: 24),
                  _buildActivityPanel(),
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
                        _buildNutritionPanel(),
                        const SizedBox(height: 24),
                        _buildActivityPanel(),
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
          const Text("Health Score", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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

  Widget _buildNutritionPanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Nutrition today", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          _progressBar("Protein", "86g", "110g", 0.78, primaryGreen),
          const SizedBox(height: 16),
          _progressBar("Calories", "1,640", "2,100 kcal", 0.78, primaryGreen),
        ],
      ),
    );
  }

  Widget _buildActivityPanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Activity", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
                    Text("7,420", style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 4),
                    const Text("Steps", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text("420", style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 4),
                    const Text("kcal Burned", style: TextStyle(color: Colors.grey)),
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
                  SizedBox(width: 280, child: _RecCard(title: "Protein opportunity", desc: "You're about 24g below your protein target today.", cta: "Show Recipes →", color: softGreen, dotColor: primaryGreen)),
                  SizedBox(width: 16),
                  SizedBox(width: 280, child: _RecCard(title: "Food insight", desc: "Your recent meal was higher in sodium than usual.", cta: "View Details →", color: warmCream, dotColor: warningColor)),
                  SizedBox(width: 16),
                  SizedBox(width: 280, child: _RecCard(title: "Movement goal", desc: "You're 1,500 steps away from today's goal.", cta: "Start Walking →", color: softBlue, dotColor: Colors.blue)),
                ],
              ),
            )
          else
            const Row(
              children: [
                Expanded(child: _RecCard(title: "Protein opportunity", desc: "You're about 24g below your protein target today.", cta: "Show Recipes →", color: softGreen, dotColor: primaryGreen)),
                SizedBox(width: 24),
                Expanded(child: _RecCard(title: "Food insight", desc: "Your recent meal was higher in sodium than usual.", cta: "View Details →", color: warmCream, dotColor: warningColor)),
                SizedBox(width: 24),
                Expanded(child: _RecCard(title: "Movement goal", desc: "You're 1,500 steps away from today's goal.", cta: "Start Walking →", color: softBlue, dotColor: Colors.blue)),
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

// --- Health Lens Showcase ---
class HealthLensShowcase extends StatelessWidget {
  const HealthLensShowcase({super.key});

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
        Text("SEE FOOD DIFFERENTLY", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: primaryGreen, letterSpacing: 0.5)),
        const SizedBox(height: 16),
        Text("Know what's on your plate.", style: GoogleFonts.inter(fontSize: 40, fontWeight: FontWeight.w700, height: 1.1, letterSpacing: -1)),
        const SizedBox(height: 16),
        const Text("Nutrix Vision recognizes food and estimates nutrition while helping you understand potential safety concerns.", style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black87)),
        const SizedBox(height: 32),
        const Row(
          children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Food", style: TextStyle(fontWeight: FontWeight.w600)), Text("Recognition", style: TextStyle(fontSize: 13, color: Colors.grey))])),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Nutrition", style: TextStyle(fontWeight: FontWeight.w600)), Text("Estimation", style: TextStyle(fontSize: 13, color: Colors.grey))])),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Safety", style: TextStyle(fontWeight: FontWeight.w600)), Text("Analysis", style: TextStyle(fontSize: 13, color: Colors.grey))])),
          ],
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Text('Try Health Lens →', style: TextStyle(fontWeight: FontWeight.w600)),
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
        Text("Your health questions, answered.", style: GoogleFonts.inter(fontSize: 40, fontWeight: FontWeight.w700, height: 1.1, color: Colors.white, letterSpacing: -1)),
        const SizedBox(height: 16),
        const Text("From meal planning to fitness advice, Nutrix AI brings your health context into every conversation.", style: TextStyle(fontSize: 16, height: 1.5, color: Colors.white70)),
      ],
    );
  }

  Widget _buildChatPreview(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)]),
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
                  const Text("Nutrix AI", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(radius: 12, backgroundColor: softGreen, child: Icon(Icons.eco, color: primaryGreen, size: 12)),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: softGreen.withOpacity(0.5), borderRadius: const BorderRadius.only(topRight: Radius.circular(16), bottomRight: Radius.circular(16), bottomLeft: Radius.circular(16))),
                  child: const Text("Based on your activity today, a protein-rich dinner would help you reach your target.", style: TextStyle(color: primaryText, height: 1.4)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _chatChip("Show dinner ideas"),
                const SizedBox(width: 8),
                _chatChip("Why protein?"),
                const SizedBox(width: 8),
                _chatChip("Create my meal"),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Open Nutrix AI →', style: TextStyle(fontWeight: FontWeight.w600)),
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
                  const Text("NUTRIX AI", style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.5)),
                  const SizedBox(height: 8),
                  const Text("Personal health intelligence.", style: TextStyle(color: Colors.grey, fontSize: 14)),
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
                            Text("Health Lens", style: TextStyle(height: 2.5, fontWeight: FontWeight.w500)),
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
                  const Text("© NUTRIX AI", style: TextStyle(color: Colors.grey, fontSize: 12)),
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
                        Text("NUTRIX AI", style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.5)),
                        SizedBox(height: 8),
                        Text("Personal health intelligence.", style: TextStyle(color: Colors.grey, fontSize: 14)),
                        SizedBox(height: 48),
                        Text("© NUTRIX AI", style: TextStyle(color: Colors.grey, fontSize: 12)),
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
                        Text("Health Lens", style: TextStyle(height: 2.5, fontWeight: FontWeight.w500)),
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

// --- Health Lens Screen ---
class HealthLensScreen extends StatelessWidget {
  const HealthLensScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const NutrixNavbar(),
                const SizedBox(height: 48),
                Text("NUTRIX VISION", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: primaryGreen, letterSpacing: 0.5)),
                const SizedBox(height: 16),
                Text("What's on your plate?", style: GoogleFonts.inter(fontSize: 40, fontWeight: FontWeight.w700, letterSpacing: -1)),
                const SizedBox(height: 12),
                const Text("Use your camera to understand your meal, nutrition and food safety.", style: TextStyle(fontSize: 16, color: Colors.black87)),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: const Text('Scan Food', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: primaryGreen), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: const Text('Upload Image', style: TextStyle(color: primaryGreen, fontWeight: FontWeight.w600)),
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
                  "Chicken Biryani", 
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
          const Text("Nutrition", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _nutrientCard("Calories", "640", "kcal", softGreen)),
              const SizedBox(width: 8),
              Expanded(child: _nutrientCard("Protein", "28g", "", softGreen)),
              const SizedBox(width: 8),
              Expanded(child: _nutrientCard("Carbs", "72g", "", warmCream)),
              const SizedBox(width: 8),
              Expanded(child: _nutrientCard("Fat", "24g", "", warmCream)),
            ],
          ),
          const SizedBox(height: 32),
          const Text("Food Safety", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: softGreen, borderRadius: BorderRadius.circular(8)),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: primaryGreen, size: 18),
                SizedBox(width: 8),
                Text("No major concerns detected", style: TextStyle(color: primaryGreen, fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _safetyItem("Sodium", "Moderate", warningColor),
          const SizedBox(height: 8),
          _safetyItem("Allergens", "None detected", primaryGreen),
          const SizedBox(height: 8),
          _safetyItem("Additives", "2 detected", primaryGreen),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Text('Log to Diary', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), side: const BorderSide(color: borderColor)),
                  child: const Text('Scan Again', style: TextStyle(color: primaryText, fontWeight: FontWeight.w500)),
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
          Expanded(child: _tipCard("Blurred image", "Scan your camera to understand nutrition of your image.", "assets/images/health_lens_food_1787489687935.jpg")),
          const SizedBox(width: 16),
          Expanded(child: _tipCard("No food", "No food items recognized, point camera to food.", "assets/images/meal_creator_ingredients_1787489701432.jpg")),
          const SizedBox(width: 16),
          Expanded(child: _tipCard("Poor lighting", "Your environment is too dark for food recognition.", "assets/images/ingredient_safety_1787489740080.jpg")),
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

// --- Feeling Healthy Screen ---
class FeelingHealthyScreen extends StatelessWidget {
  const FeelingHealthyScreen({super.key});

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
                const NutrixNavbar(),
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
                          "Your health score is in the top 15%.\nKeep up the excellent work with your nutrition and movement.",
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

