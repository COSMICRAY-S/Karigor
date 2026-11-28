import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/language_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/language_switch_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final lang = context.watch<LanguageProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: AppColors.clayBg,
      appBar: AppBar(
        title: Text(lang.t('settings_title')),
        backgroundColor: AppColors.panel,
        foregroundColor: AppColors.ink,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 14),
            child: Center(
              child: LanguageSwitchButton(isDark: false),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── SECTION 1: LANGUAGE SWITCH & PREFERENCES ───
            _buildSectionHeader(
              icon: Icons.language_rounded,
              title: lang.t('language_section_title'),
            ),
            const SizedBox(height: 10),
            const LanguageSettingsCard(),

            const SizedBox(height: 12),
            // User state indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.sageBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.slateLight.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_circle_outlined, size: 18, color: AppColors.slate),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      user != null
                          ? '${lang.t('saved_for_user')}: ${user.name} (${user.role.toUpperCase()})'
                          : lang.t('guest_user'),
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.slateDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.terracotta,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      lang.isEnglish ? 'EN' : 'বাং',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ─── SECTION 2: GENERAL NOTIFICATIONS ───
            _buildSectionHeader(
              icon: Icons.tune_rounded,
              title: lang.t('general_section_title'),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.panel,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.line),
                boxShadow: AppTheme.softShadow,
              ),
              child: SwitchListTile(
                value: _notificationsEnabled,
                activeColor: AppColors.terracotta,
                title: Text(
                  lang.t('push_notifications'),
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: AppColors.ink),
                ),
                subtitle: Text(
                  lang.t('push_notifications_sub'),
                  style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft),
                ),
                secondary: const Icon(Icons.notifications_active_outlined, color: AppColors.brassDark),
                onChanged: (val) => setState(() => _notificationsEnabled = val),
              ),
            ),

            const SizedBox(height: 28),

            // ─── SECTION 3: ACCOUNT INFO ───
            _buildSectionHeader(
              icon: Icons.person_outline_rounded,
              title: lang.t('account_section_title'),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.panel,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.line),
                boxShadow: AppTheme.softShadow,
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.badge_outlined, color: AppColors.slate),
                    title: Text(
                      user?.name ?? 'Guest User',
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: AppColors.ink),
                    ),
                    subtitle: Text(
                      user?.phone ?? user?.email ?? 'No contact information',
                      style: const TextStyle(fontSize: 12, color: AppColors.inkSoft),
                    ),
                  ),
                  if (user != null) ...[
                    const Divider(height: 1, indent: 56, color: AppColors.line),
                    ListTile(
                      leading: const Icon(Icons.work_outline, color: AppColors.terracotta),
                      title: Text(
                        '${lang.t('user_role')}: ${user.role.toUpperCase()}',
                        style: const TextStyle(fontSize: 13.5, color: AppColors.ink),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ─── SECTION 4: ABOUT APP ───
            _buildSectionHeader(
              icon: Icons.info_outline_rounded,
              title: lang.t('about_section_title'),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.panel,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.line),
                boxShadow: AppTheme.softShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: AppColors.brassGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: const Text('🛠️', style: TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lang.t('about_app_name'),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.ink,
                              ),
                            ),
                            Text(
                              lang.t('app_version'),
                              style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    lang.t('app_desc'),
                    style: const TextStyle(fontSize: 12.5, height: 1.4, color: AppColors.inkSoft),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Logout Button (if logged in)
            if (user != null)
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.logout),
                label: Text(lang.t('logout')),
                onPressed: () async {
                  await auth.logout();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, '/role-select', (r) => false);
                  }
                },
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.inkSoft),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.inkSoft,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
