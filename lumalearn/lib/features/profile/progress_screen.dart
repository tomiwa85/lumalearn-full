import 'package:flutter/material.dart';
import 'package:lumalearn/core/theme/app_theme.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      appBar: AppBar(
        title: const Text('Your Growth'),
        backgroundColor: Colors.transparent,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TOP STATS ROW
            Row(
              children: [
                _StatCard(
                  label: "Day Streak",
                  value: "7",
                  icon: Icons.local_fire_department,
                  color: Colors.orangeAccent,
                ),
                const SizedBox(width: 16),
                _StatCard(
                  label: "Questions",
                  value: "42",
                  icon: Icons.check_circle_outline,
                  color: AppTheme.neonGreen,
                ),
              ],
            ),

            const SizedBox(height: 30),

            // 2. ACTIVITY HEATMAP
            const Text(
              "Activity Map",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceGrey,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                children: [
                  // This builds a 7-day x 5-week grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7, // 7 Days a week
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: 28, // 4 weeks of data
                    itemBuilder: (context, index) {
                      // Fake data logic for demo: Color random blocks green
                      final opacity = (index % 3 == 0 || index % 5 == 0) ? 1.0 : 0.1;
                      return Container(
                        decoration: BoxDecoration(
                          color: AppTheme.neonGreen.withOpacity(opacity * 0.8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text("Less", style: TextStyle(fontSize: 10, color: Colors.grey)),
                      SizedBox(width: 4),
                      Icon(Icons.square_rounded, size: 12, color: Colors.white10),
                      SizedBox(width: 4),
                      Icon(Icons.square_rounded, size: 12, color: AppTheme.neonGreen),
                      SizedBox(width: 4),
                      Text("More", style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 3. MASTERY BY SUBJECT
            const Text(
              "Topic Mastery",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),

            const _MasteryRow(
                subject: "Physics",
                percentage: 0.75,
                color: Colors.blueAccent
            ),
            const _MasteryRow(
                subject: "Mathematics",
                percentage: 0.60,
                color: Colors.tealAccent
            ),
            const _MasteryRow(
                subject: "Chemistry",
                percentage: 0.45,
                color: Colors.greenAccent
            ),
            const _MasteryRow(
                subject: "Biology",
                percentage: 0.30,
                color: Colors.pinkAccent
            ),
          ],
        ),
      ),
    );
  }
}

// --- HELPER WIDGETS ---

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceGrey,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: AppTheme.textGrey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _MasteryRow extends StatelessWidget {
  final String subject;
  final double percentage;
  final Color color;

  const _MasteryRow({
    required this.subject,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(subject, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
              Text("${(percentage * 100).toInt()}%", style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.white10,
              color: color,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}