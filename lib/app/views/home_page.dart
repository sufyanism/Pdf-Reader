import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/pdf_controller.dart';
import '../routes/app_routes.dart';
import '../core/responsive.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final controller = Get.put(PdfController());

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning ☀";
    if (hour < 17) return "Good Afternoon 🌤";
    return "Good Evening 🌙";
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final width = Responsive.contentWidth(context);

    return Scaffold(
      backgroundColor: const Color(0xff0B1220),
      body: Stack(
        children: [

          /// Background glow
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(.12),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SizedBox(
                width: width,
                child: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 18 : 40,
                    vertical: 24,
                  ),
                  children: [

                    /// ===== HERO =====
                    _HeroSection(
                      greeting: getGreeting(),
                    ),

                    const SizedBox(height: 30),

                    /// ===== PROGRESS CARD =====
                    _ProgressCard(),

                    const SizedBox(height: 30),

                    /// ===== QUICK ACTIONS =====
                    const Text(
                      "Quick Access",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 18),

                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _ActionCard(
                          icon: Icons.menu_book_rounded,
                          title: "Continue Reading",
                          subtitle: "Page ${controller.currentPage.value}",
                          color: Colors.blue,
                          onTap: () => Get.toNamed(Routes.reader),
                        ),
                        _ActionCard(
                          icon: Icons.bookmarks_rounded,
                          title: "Bookmarks",
                          subtitle: "${controller.bookmarks.length} saved",
                          color: Colors.orange,
                          onTap: controller.showBookmarksDialog,
                        ),
                        _ActionCard(
                          icon: Icons.settings_rounded,
                          title: "Reader Settings",
                          subtitle: "Themes & Fonts",
                          color: Colors.purple,
                          onTap: controller.showReaderSettings,
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    /// ===== STATS SECTION =====
                    _StatsSection(),

                    const SizedBox(height: 40),

                    /// ===== START BUTTON =====
                    _StartReadingCard(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// HERO SECTION
////////////////////////////////////////////////////////////
class _HeroSection extends StatelessWidget {
  final String greeting;
  const _HeroSection({required this.greeting});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff2563EB), Color(0xff1E3A8A)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 25,
            offset: Offset(0, 12),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Pdf Reader",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Your peaceful digital reading space.",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// PROGRESS CARD
////////////////////////////////////////////////////////////
class _ProgressCard extends StatelessWidget {
  final controller = Get.find<PdfController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xff111827),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Reading Progress",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: controller.progress,
            backgroundColor: Colors.white10,
            color: Colors.blue,
          ),
          const SizedBox(height: 10),
          Text(
            "${controller.percentage} completed",
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ));
  }
}

////////////////////////////////////////////////////////////
/// ACTION CARD
////////////////////////////////////////////////////////////
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Ink(
        width: 260,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xff111827),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withOpacity(.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// STATS SECTION
////////////////////////////////////////////////////////////
class _StatsSection extends StatelessWidget {
  final controller = Get.find<PdfController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _StatCard(
          title: "Streak",
          value: "${controller.readingStreak.value} 🔥",
        ),
        _StatCard(
          title: "Time",
          value: controller.formattedTotalTime,
        ),
        _StatCard(
          title: "Bookmarks",
          value: "${controller.bookmarks.length}",
        ),
      ],
    ));
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xff111827),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(title,
                style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// START READING CARD
////////////////////////////////////////////////////////////
class _StartReadingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff1E293B), Color(0xff0F172A)],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        children: [
          const Icon(Icons.auto_stories,
              color: Colors.blue, size: 46),
          const SizedBox(height: 14),
          const Text(
            "Start Reading",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () =>
                  Get.toNamed(Routes.reader),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text("Open Reader"),
            ),
          ),
        ],
      ),
    );
  }
}