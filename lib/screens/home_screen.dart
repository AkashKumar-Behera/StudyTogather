import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
      setState(() {
        _latestRelease = release;
      });
      // Show auto-popup when an update is found
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          UpdateService.showUpdateDialog(context, release);
        }
      });
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
        : (user?.displayName ?? (user?.email?.split('@').first ?? 'Friend'));
    final photoUrl = profile?.photoUrl ?? user?.photoURL;
    final userEmail = profile?.email ?? (user?.email ?? '');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/icons/app_icon_1024.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'MindFlow',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          // In-App update check button
          IconButton(
            tooltip: 'Check for Updates',
            icon: _isCheckingUpdate
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  )
                : Icon(
                    _latestRelease != null ? Icons.system_update_rounded : Icons.sync_rounded,
                    color: _latestRelease != null ? AppColors.accent : AppColors.textSecondary,
                  ),
            onPressed: _isCheckingUpdate ? null : _checkUpdateManually,
          ),
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  title: Text(
                    'Sign Out',
                    style: GoogleFonts.outfit(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                  ),
                  content: Text(
                    'Are you sure you want to log out?',
                    style: GoogleFonts.inter(color: AppColors.textSecondary),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textSecondary)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text('Logout', style: GoogleFonts.inter()),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await authService.signOut();
              }
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // In-App Update Banner if update is available
                if (_latestRelease != null) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary.withOpacity(0.2), AppColors.accent.withOpacity(0.1)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.new_releases_rounded, color: AppColors.accent, size: 28),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Update ${_latestRelease!.tagName} available',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'New features and bug fixes ready for download.',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () => UpdateService.showUpdateDialog(context, _latestRelease!),
                          child: const Text('Download'),
                        ),
                      ],
                    ),
                  ),
                ],

                // Animated glowing avatar / Profile Picture
                Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: photoUrl == null
                        ? const LinearGradient(
                            colors: [AppColors.primary, AppColors.accent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    border: Border.all(color: AppColors.primary, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 28,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: photoUrl != null && photoUrl.isNotEmpty
                        ? Image.network(
                            photoUrl,
                            fit: BoxFit.cover,
                            width: 104,
                            height: 104,
                            errorBuilder: (context, error, stackTrace) => Center(
                              child: Text(
                                displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                                style: GoogleFonts.outfit(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                              style: GoogleFonts.outfit(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 32),

                // Welcome message
                Text(
                  'Welcome, $displayName!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),

                // User details pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        userEmail.isNotEmpty ? userEmail : 'Logged In',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Platforms & Downloads Section Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.cloud_download_rounded, color: AppColors.primary, size: 22),
                          const SizedBox(width: 10),
                          Text(
                            'App Downloads & Platforms',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Download the latest binaries for Android and access other platform versions from GitHub Releases.',
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.android_rounded, color: AppColors.success, size: 18),
                            label: const Text('Download APK'),
                            onPressed: () => _safeLaunchUrl(
                              context,
                              _latestRelease?.apkDownloadUrl ??
                                  'https://github.com/AkashKumar-Behera/StudyTogather/releases/latest',
                            ),
                          ),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.inventory_2_outlined, color: AppColors.accent, size: 18),
                            label: const Text('App Bundle (AAB)'),
                            onPressed: () => _safeLaunchUrl(
                              context,
                              _latestRelease?.aabDownloadUrl ??
                                  'https://github.com/AkashKumar-Behera/StudyTogather/releases/latest',
                            ),
                          ),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.open_in_browser_rounded, color: AppColors.secondary, size: 18),
                            label: const Text('All Releases'),
                            onPressed: () => _safeLaunchUrl(
                              context,
                              'https://github.com/AkashKumar-Behera/StudyTogather/releases',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Web Hosting & Status info
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.language_rounded, color: AppColors.accent, size: 24),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Firebase Web Hosting Active',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Web builds automatically deploy to Firebase Hosting on release tags.',
                              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _safeLaunchUrl(BuildContext context, String urlString) async {
    try {
      final uri = Uri.parse(urlString);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint('Failed to launch URL: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open browser: $urlString'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
