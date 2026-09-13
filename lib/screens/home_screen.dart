import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/update_service.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ReleaseInfo? _latestRelease;
  bool _isCheckingUpdate = false;
  String _selectedNav = 'Dashboard';
  bool _isPlayingMusic = false;

  // Mock sample data for rich UI
  final List<Map<String, dynamic>> _goals = [
    {'title': 'Complete DSA practice', 'done': true},
    {'title': 'Work on web project', 'done': false},
    {'title': 'Revise cloud computing', 'done': false},
    {'title': 'Read 10 pages (book)', 'done': false},
  ];

  final List<Map<String, dynamic>> _recentRooms = [
    {
      'name': 'Cozy Study Room',
      'members': '12 members',
      'tag': 'Quiet',
      'icon': Icons.nightlight_round,
      'color': const Color(0xFF8B5CF6)
    },
    {
      'name': 'Late Night Coders',
      'members': '8 members',
      'tag': 'Dev',
      'icon': Icons.code_rounded,
      'color': const Color(0xFF3B82F6)
    },
    {
      'name': 'Exam Prep Squad',
      'members': '15 members',
      'tag': 'Exam',
      'icon': Icons.menu_book_rounded,
      'color': const Color(0xFF10B981)
    },
    {
      'name': 'Silent Library',
      'members': '6 members',
      'tag': 'Deep',
      'icon': Icons.headset_mic_rounded,
      'color': const Color(0xFFF59E0B)
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthService>().fetchUserProfile();
    });
    _checkForUpdatesSilently();
  }

  Future<void> _checkForUpdatesSilently() async {
    final release = await UpdateService.checkForUpdate();
    if (release != null && mounted) {
      setState(() => _latestRelease = release);
    }
  }

  Future<void> _checkUpdateManually() async {
    setState(() => _isCheckingUpdate = true);
    final release = await UpdateService.checkForUpdate();
    setState(() => _isCheckingUpdate = false);

    if (release != null && mounted) {
      UpdateService.showUpdateDialog(context, release);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You are on the latest version!',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final user = authService.currentUser;
    final profile = authService.userProfile;
    final displayName = profile?.displayName.isNotEmpty == true
        ? profile!.displayName
        : (user?.displayName ?? (user?.email?.split('@').first ?? 'Akash'));
    final userEmail = profile?.email ?? (user?.email ?? 'user@mindflow.app');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------------------------------------------------------
          // 1. LEFT SIDEBAR (Desktop Navigation)
          // ---------------------------------------------------------------
          _buildSidebar(context, authService),

          // ---------------------------------------------------------------
          // 2. MAIN WORKSPACE (Header + Center Grid + Right Panel)
          // ---------------------------------------------------------------
          Expanded(
            child: Column(
              children: [
                // Top Search & User Header
                _buildTopHeader(displayName, userEmail),

                // Main Scrollable Dashboard Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 1050;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Center Content Column
                            Expanded(
                              flex: 7,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildGreetingHero(displayName),
                                  const SizedBox(height: 20),
                                  _buildHeroBannerAndActions(),
                                  const SizedBox(height: 24),
                                  _buildStatsAndRecentRooms(),
                                  const SizedBox(height: 24),
                                  _buildMotivationAndHabitTracker(),
                                ],
                              ),
                            ),

                            // Right Column (Date, Quote, Goals, Music Player)
                            if (isWide) ...[
                              const SizedBox(width: 24),
                              SizedBox(
                                width: 330,
                                child: Column(
                                  children: [
                                    _buildDateCard(),
                                    const SizedBox(height: 16),
                                    _buildAestheticVisualCard(),
                                    const SizedBox(height: 16),
                                    _buildGoalsCard(),
                                    const SizedBox(height: 16),
                                    _buildFocusMusicCard(),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SIDEBAR WIDGET
  // ===========================================================================
  Widget _buildSidebar(BuildContext context, AuthService authService) {
    final navItems = [
      {'title': 'Dashboard', 'icon': Icons.grid_view_rounded},
      {'title': 'Study Room', 'icon': Icons.groups_rounded},
      {'title': 'My Rooms', 'icon': Icons.meeting_room_outlined},
      {'title': 'Find Friends', 'icon': Icons.person_search_rounded},
      {'title': 'Study Timer', 'icon': Icons.timer_outlined},
      {'title': 'Tasks', 'icon': Icons.check_box_outlined},
      {'title': 'Notes', 'icon': Icons.description_outlined},
      {'title': 'Resources', 'icon': Icons.library_books_outlined},
    ];

    final quickAccess = [
      {'title': 'Today', 'icon': Icons.today_rounded},
      {'title': 'Calendar', 'icon': Icons.calendar_month_outlined},
      {'title': 'Habit Tracker', 'icon': Icons.trending_up_rounded},
      {'title': 'Focus Music', 'icon': Icons.music_note_rounded},
    ];

    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand Logo Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/icons/app_icon_1024.png',
                      errorBuilder: (_, __, ___) => const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MindFlow',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'study together, grow together',
                      style: GoogleFonts.caveat(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Main Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                ...navItems.map((item) {
                  final isSelected = _selectedNav == item['title'];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        setState(() => _selectedNav = item['title'] as String);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryDark.withOpacity(0.35) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: isSelected ? Border.all(color: AppColors.primaryDark.withOpacity(0.5)) : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item['icon'] as IconData,
                              size: 19,
                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              item['title'] as String,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  child: Text(
                    'QUICK ACCESS',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: AppColors.textSecondary.withOpacity(0.6),
                    ),
                  ),
                ),

                ...quickAccess.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        child: Row(
                          children: [
                            Icon(item['icon'] as IconData, size: 16, color: AppColors.textSecondary.withOpacity(0.7)),
                            const SizedBox(width: 12),
                            Text(
                              item['title'] as String,
                              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Sidebar Bottom Mini Inspiration Card
          Padding(
            padding: const EdgeInsets.all(14),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text('Daily Spark', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '"A better tomorrow is a focused today."',
                    style: GoogleFonts.caveat(fontSize: 14, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TOP HEADER BAR
  // ===========================================================================
  Widget _buildTopHeader(String displayName, String email) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          // Search Input
          Expanded(
            child: Container(
              height: 40,
              constraints: const BoxConstraints(maxWidth: 460),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search rooms, friends, resources...',
                  hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                  prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.textSecondary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),

          const Spacer(),

          // In-App Updates status
          IconButton(
            tooltip: 'Check Updates',
            icon: _isCheckingUpdate
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                : Icon(_latestRelease != null ? Icons.system_update_rounded : Icons.sync_rounded,
                    color: _latestRelease != null ? AppColors.accent : AppColors.textSecondary, size: 20),
            onPressed: _isCheckingUpdate ? null : _checkUpdateManually,
          ),

          // Notifications
          Stack(
            children: [
              IconButton(
                tooltip: 'Notifications',
                icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textSecondary, size: 22),
                onPressed: () {},
              ),
              Positioned(
                top: 10,
                right: 12,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 8),

          // Profile Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primaryDark,
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : 'A',
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayName,
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    Text(
                      'progress over perfection ♡',
                      style: GoogleFonts.caveat(fontSize: 10, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.textSecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // GREETING HERO SECTION
  // ===========================================================================
  Widget _buildGreetingHero(String displayName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Good evening, $displayName',
                  style: GoogleFonts.outfit(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.auto_awesome, color: AppColors.primary, size: 22),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Same goals, brighter tomorrows ♡',
              style: GoogleFonts.caveat(fontSize: 16, color: AppColors.textSecondary),
            ),
          ],
        ),
        Text(
          '"Discipline looks good on you."',
          style: GoogleFonts.caveat(fontSize: 17, color: AppColors.textSecondary.withOpacity(0.7)),
        ),
      ],
    );
  }

  // ===========================================================================
  // HERO BANNER & QUICK ACTIONS
  // ===========================================================================
  Widget _buildHeroBannerAndActions() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stack = constraints.maxWidth < 700;
        return Flex(
          direction: stack ? Axis.vertical : Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Hero Banner Card
            Expanded(
              flex: stack ? 0 : 6,
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1E1B4B).withOpacity(0.8),
                      const Color(0xFF0F172A).withOpacity(0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  image: const DecorationImage(
                    image: AssetImage('assets/icons/mindflow_transparent.png'),
                    alignment: Alignment.topRight,
                    opacity: 0.12,
                  ),
                ),
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Text(
                        'CURRENT VIBE',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Focus Today',
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, color: AppColors.primary, size: 20),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'A peaceful space to study, together.',
                          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(width: stack ? 0 : 16, height: stack ? 16 : 0),

            // Right Quick Actions Grid
            Expanded(
              flex: stack ? 0 : 5,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    _buildQuickActionItem(
                      icon: Icons.videocam_outlined,
                      title: 'Start a Study Session',
                      subtitle: 'Video, audio, timer & more',
                    ),
                    _buildQuickActionItem(
                      icon: Icons.groups_outlined,
                      title: 'Join a Room',
                      subtitle: 'Connect with other peers',
                    ),
                    _buildQuickActionItem(
                      icon: Icons.add_circle_outline_rounded,
                      title: 'Create a Room',
                      subtitle: 'Your personal study space',
                    ),
                    _buildQuickActionItem(
                      icon: Icons.timer_outlined,
                      title: 'Open Study Timer',
                      subtitle: 'Pomodoro, custom, stopwatch',
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 17),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    Text(subtitle, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // STUDY STATS & RECENT ROOMS
  // ===========================================================================
  Widget _buildStatsAndRecentRooms() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Stats Card
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.bar_chart_rounded, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text('Your Study Stats', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildStatTile(Icons.schedule_rounded, '3h 25m', 'Focus Time', AppColors.primary)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildStatTile(Icons.videocam_rounded, '4', 'Sessions', AppColors.secondary)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildStatTile(Icons.check_circle_rounded, '6', 'Tasks Done', AppColors.success)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildStatTile(Icons.group_work_rounded, '2', 'Study Rooms', AppColors.primaryLight)),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Right Recent Rooms Card
        Expanded(
          flex: 6,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.people_alt_outlined, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text('Recently Joined', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      ],
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 24)),
                      child: Row(
                        children: [
                          Text('View All', style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary)),
                          const SizedBox(width: 2),
                          const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: _recentRooms.map((room) {
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: (room['color'] as Color).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(room['icon'] as IconData, size: 18, color: room['color'] as Color),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              room['name'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Container(width: 5, height: 5, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                                const SizedBox(width: 5),
                                Text(room['members'] as String, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatTile(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(value, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  // ===========================================================================
  // TODAY MOTIVATION & HABIT TRACKER
  // ===========================================================================
  Widget _buildMotivationAndHabitTracker() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Motivation Card
        Expanded(
          flex: 5,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Today's Motivation", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 14),
                Text(
                  '“A focused mind builds a brighter you.”',
                  style: GoogleFonts.caveat(fontSize: 20, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text('— FocusFlow', style: GoogleFonts.caveat(fontSize: 13, color: AppColors.textSecondary)),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Habit Tracker
        Expanded(
          flex: 6,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.track_changes_rounded, size: 17, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text('Habit Tracker', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      ],
                    ),
                    Text('View All', style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildHabitItem(Icons.menu_book_rounded, 'Study', true),
                    _buildHabitItem(Icons.fitness_center_rounded, 'Exercise', false),
                    _buildHabitItem(Icons.water_drop_rounded, 'Hydrate', true),
                    _buildHabitItem(Icons.bedtime_rounded, 'Sleep Early', false),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHabitItem(IconData icon, String label, bool completed) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: completed ? AppColors.primaryDark : AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: completed ? AppColors.primary : AppColors.border),
          ),
          child: Icon(icon, size: 20, color: completed ? Colors.white : AppColors.textSecondary),
        ),
        const SizedBox(height: 6),
        Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }

  // ===========================================================================
  // RIGHT COLUMN WIDGETS
  // ===========================================================================
  Widget _buildDateCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sat, 6 Sep 2026', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Text("Let's make today count.", style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAestheticVisualCard() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E1065), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Stack(
        children: [
          const Positioned(
            right: 8,
            top: 8,
            child: Icon(Icons.nightlight_outlined, color: AppColors.secondary, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Good Students', style: GoogleFonts.caveat(fontSize: 18, color: AppColors.textPrimary)),
              Text('Brighter Futures ♡', style: GoogleFonts.caveat(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Today's Goals", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              InkWell(
                onTap: () {},
                child: Row(
                  children: [
                    const Icon(Icons.add, size: 14, color: AppColors.primary),
                    const SizedBox(width: 2),
                    Text('Add', style: GoogleFonts.inter(fontSize: 11, color: AppColors.primary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._goals.map((g) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    g['done'] as bool ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                    size: 18,
                    color: g['done'] as bool ? AppColors.primary : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      g['title'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: g['done'] as bool ? AppColors.textSecondary : AppColors.textPrimary,
                        decoration: g['done'] as bool ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFocusMusicCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.music_note_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text('Focus Playlist', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ],
              ),
              Text('View All', style: GoogleFonts.inter(fontSize: 11, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.graphic_eq_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Lo-fi Study Beats', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      Text('Chill Beats • Deep Focus', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isPlayingMusic ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                  onPressed: () {
                    setState(() => _isPlayingMusic = !_isPlayingMusic);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
