import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ReleaseAsset {
  final String name;
  final String downloadUrl;
  final int size;

  ReleaseAsset({
    required this.name,
    required this.downloadUrl,
    required this.size,
  });
}

class ReleaseInfo {
  final String tagName;
  final String releaseName;
  final String body;
  final String htmlUrl;
  final List<ReleaseAsset> assets;

  ReleaseInfo({
    required this.tagName,
    required this.releaseName,
    required this.body,
    required this.htmlUrl,
    required this.assets,
  });

  String? get apkDownloadUrl {
    final asset = assets.where((a) => a.name.endsWith('.apk')).firstOrNull;
    return asset?.downloadUrl;
  }

  String? get aabDownloadUrl {
    final asset = assets.where((a) => a.name.endsWith('.aab')).firstOrNull;
    return asset?.downloadUrl;
  }
}

class UpdateService {
  static const String repoOwner = 'AkashKumar-Behera';
  static const String repoName = 'StudyTogather';

  // Check for updates against GitHub Releases API
  static Future<ReleaseInfo?> checkForUpdate() async {
    try {
      final url = Uri.parse('https://api.github.com/repos/$repoOwner/$repoName/releases/latest');
      final response = await http.get(
        url,
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final tagName = (data['tag_name'] as String? ?? '').replaceFirst('v', '');
        final packageInfo = await PackageInfo.fromPlatform();
        final currentVersion = packageInfo.version;

        if (_isNewerVersion(currentVersion, tagName)) {
          final rawAssets = (data['assets'] as List<dynamic>? ?? []);
          final assets = rawAssets.map((a) {
            return ReleaseAsset(
              name: a['name'] as String? ?? '',
              downloadUrl: a['browser_download_url'] as String? ?? '',
              size: a['size'] as int? ?? 0,
            );
          }).toList();

          return ReleaseInfo(
            tagName: data['tag_name'] as String? ?? '',
            releaseName: data['name'] as String? ?? 'New Update Available',
            body: data['body'] as String? ?? '',
            htmlUrl: data['html_url'] as String? ?? '',
            assets: assets,
          );
        }
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
    }
    return null;
  }

  static bool _isNewerVersion(String current, String latest) {
    if (latest.isEmpty) return false;
    try {
      final cParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final lParts = latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      for (int i = 0; i < 3; i++) {
        final c = i < cParts.length ? cParts[i] : 0;
        final l = i < lParts.length ? lParts[i] : 0;
        if (l > c) return true;
        if (l < c) return false;
      }
    } catch (_) {}
    return false;
  }

  // Show modern in-app update dialog
  static void showUpdateDialog(BuildContext context, ReleaseInfo release) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.system_update_rounded, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Update Available',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Version ${release.tagName} is now ready for download!',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              if (release.body.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    release.body,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                'Direct download links:',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              if (release.apkDownloadUrl != null)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.android_rounded, color: AppColors.success),
                  title: Text('Download Android APK', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13)),
                  trailing: const Icon(Icons.download_rounded, color: AppColors.primary, size: 20),
                  onTap: () async {
                    final uri = Uri.parse(release.apkDownloadUrl!);
                    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
                  },
                ),
              if (release.aabDownloadUrl != null)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.inventory_2_outlined, color: AppColors.accent),
                  title: Text('Download App Bundle (AAB)', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13)),
                  trailing: const Icon(Icons.download_rounded, color: AppColors.primary, size: 20),
                  onTap: () async {
                    final uri = Uri.parse(release.aabDownloadUrl!);
                    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
                  },
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Later', style: GoogleFonts.inter(color: AppColors.textSecondary)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.open_in_browser_rounded, size: 18),
              label: Text('View Release', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              onPressed: () async {
                final uri = Uri.parse(release.htmlUrl);
                if (await canLaunchUrl(uri)) {
                  launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
          ],
        );
      },
    );
  }
}
