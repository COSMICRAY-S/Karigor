import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/language_provider.dart';
import '../theme/app_theme.dart';

/// A sleek language switcher switch (English / Bangla) designed for
/// the top-left corner of Login / Sign-in pages as well as in-app bars.
class LanguageSwitchButton extends StatelessWidget {
  final bool isDark;
  final bool showLabel;

  const LanguageSwitchButton({
    super.key,
    this.isDark = false,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();
    final isEn = langProvider.isEnglish;

    final bgColor = isDark
        ? Colors.black.withValues(alpha: 0.28)
        : AppColors.panel;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.22)
        : AppColors.line;
    final activeBg = isDark
        ? AppColors.terracotta
        : AppColors.terracotta;
    final activeText = Colors.white;
    final inactiveText = isDark
        ? Colors.white.withValues(alpha: 0.7)
        : AppColors.inkSoft;

    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Globe Icon
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Icon(
              Icons.language_rounded,
              size: 16,
              color: isDark ? Colors.white.withValues(alpha: 0.85) : AppColors.inkSoft,
            ),
          ),

          // English segment
          _buildSegment(
            context: context,
            label: 'EN',
            isActive: isEn,
            activeBg: activeBg,
            activeTextColor: activeText,
            inactiveTextColor: inactiveText,
            onTap: () => langProvider.setLanguage('en'),
          ),

          const SizedBox(width: 2),

          // Bangla segment
          _buildSegment(
            context: context,
            label: 'বাং',
            isActive: !isEn,
            activeBg: activeBg,
            activeTextColor: activeText,
            inactiveTextColor: inactiveText,
            onTap: () => langProvider.setLanguage('bn'),
          ),
        ],
      ),
    );
  }

  Widget _buildSegment({
    required BuildContext context,
    required String label,
    required bool isActive,
    required Color activeBg,
    required Color activeTextColor,
    required Color inactiveTextColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: activeBg.withValues(alpha: 0.4),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? activeTextColor : inactiveTextColor,
          ),
        ),
      ),
    );
  }
}

/// A full card selector widget for the App Settings screen
class LanguageSettingsCard extends StatelessWidget {
  const LanguageSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();
    final currentLang = langProvider.currentLanguage;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.terracotta.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.translate_rounded, color: AppColors.terracotta, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        langProvider.t('language_section_title'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        langProvider.t('language_section_subtitle'),
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.inkSoft,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.line),

          // English Option
          _buildLanguageOption(
            context: context,
            flag: '🇺🇸',
            title: 'English',
            subtitle: 'Default language',
            isSelected: currentLang == 'en',
            onTap: () {
              langProvider.setLanguage('en');
              _showFeedback(context, 'Language switched to English');
            },
          ),
          const Divider(height: 1, indent: 56, color: AppColors.line),

          // Bangla Option
          _buildLanguageOption(
            context: context,
            flag: '🇧🇩',
            title: 'বাংলা',
            subtitle: 'Bangla language',
            isSelected: currentLang == 'bn',
            onTap: () {
              langProvider.setLanguage('bn');
              _showFeedback(context, 'ভাষা পরিবর্তন করে বাংলা করা হয়েছে');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String flag,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 22)),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.5,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? AppColors.terracotta : AppColors.ink,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft),
      ),
      trailing: isSelected
          ? Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.terracotta,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 14, color: Colors.white),
            )
          : const Icon(Icons.radio_button_off, size: 20, color: AppColors.inkSoft),
      onTap: onTap,
    );
  }

  void _showFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.slate,
      ),
    );
  }
}
