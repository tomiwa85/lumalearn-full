import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumalearn/core/theme/app_theme.dart';
import 'package:lumalearn/features/auth/services/auth_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _searchQuery = '';

  // Full list of subjects (Normal code structure, but with all courses)
  final List<Map<String, dynamic>> _subjects = [
    {
      'name': 'Mathematics',
      'progress': 0.75,
      'color': Colors.blueAccent,
      'icon': Icons.calculate_outlined,
    },
    {
      'name': 'Physics',
      'progress': 0.45,
      'color': Colors.purpleAccent,
      'icon': Icons.science_outlined,
    },
    {
      'name': 'Chemistry',
      'progress': 0.30,
      'color': Colors.orangeAccent,
      'icon': Icons.biotech_outlined,
    },
    {
      'name': 'Biology',
      'progress': 0.60,
      'color': Colors.greenAccent,
      'icon': Icons.grass_outlined,
    },
    {
      'name': 'English',
      'progress': 0.50,
      'color': Colors.indigoAccent,
      'icon': Icons.language_outlined,
    },
    {
      'name': 'Economics',
      'progress': 0.40,
      'color': Colors.tealAccent,
      'icon': Icons.trending_up,
    },
    {
      'name': 'Civic Education',
      'progress': 0.25,
      'color': Colors.brown,
      'icon': Icons.gavel_outlined,
    },
    {
      'name': 'Literature',
      'progress': 0.20,
      'color': Colors.redAccent,
      'icon': Icons.book_outlined,
    },
    {
      'name': 'Further Mathematics',
      'progress': 0.10,
      'color': Colors.deepPurpleAccent,
      'icon': Icons.functions,
    },
    {
      'name': 'Geography',
      'progress': 0.35,
      'color': Colors.lightBlueAccent,
      'icon': Icons.public,
    },
    {
      'name': 'Agricultural Science',
      'progress': 0.55,
      'color': Colors.lightGreen,
      'icon': Icons.agriculture_outlined,
    },
    {
      'name': 'IT',
      'progress': 0.80,
      'color': Colors.cyanAccent,
      'icon': Icons.computer_outlined,
    },
  ];

  void _showAppInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceGrey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: AppTheme.neonGreen),
            SizedBox(width: 10),
            Text("About LumaLearn", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "LumaLearn is your AI-powered study companion.",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "• Chat with AI tutors for every subject.\n"
                  "• Track your learning progress.\n"
                  "• Teachers can manage classes and students.\n"
                  "• Save your chat history for revision.",
              style: TextStyle(color: AppTheme.textGrey, height: 1.5),
            ),
            SizedBox(height: 16),
            Text(
              "Version 1.0.0",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: AppTheme.neonGreen)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authServiceProvider).currentUser;
    final userName = user?.userMetadata?['full_name'] ?? 'Student';

    final filteredSubjects = _subjects.where((subject) {
      final name = subject['name'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // --- 1. TOP BAR ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left: Logo + Text
                  Row(
                    children: [
                      Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          image: const DecorationImage(
                            image: AssetImage('assets/icons/icon_lumalearn.png'),
                            fit: BoxFit.contain,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.neonGreen.withOpacity(0.4),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'LumaLearn',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),

                  // Right: Info Icon
                  IconButton(
                    icon: const Icon(Icons.info_outline, color: AppTheme.textGrey),
                    onPressed: _showAppInfoDialog,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // --- 3. SEARCH BAR ---
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceGrey,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Search for subjects...',
                    hintStyle: TextStyle(color: AppTheme.textGrey),
                    prefixIcon: Icon(Icons.search, color: AppTheme.textGrey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // --- 4. SUBJECTS LIST TITLE ---
              const Text(
                'Your Subjects',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // --- 5. SUBJECTS LIST ---
              Expanded(
                child: filteredSubjects.isEmpty
                    ? Center(
                  child: Text(
                    'No subjects found for "$_searchQuery"',
                    style: const TextStyle(color: AppTheme.textGrey),
                  ),
                )
                    : ListView.separated(
                  // *** FIXED HERE: ADDED BOTTOM PADDING ***
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: filteredSubjects.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final subject = filteredSubjects[index];
                    return _SubjectTile(
                      title: subject['name'],
                      progress: subject['progress'],
                      color: subject['color'],
                      icon: subject['icon'],
                      onTap: () {
                        context.push('/subject-history', extra: subject['name']);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubjectTile extends StatelessWidget {
  final String title;
  final double progress;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _SubjectTile({
    required this.title,
    required this.progress,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceGrey,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white10,
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.arrow_forward_ios, color: AppTheme.textGrey, size: 16),
          ],
        ),
      ),
    );
  }
}