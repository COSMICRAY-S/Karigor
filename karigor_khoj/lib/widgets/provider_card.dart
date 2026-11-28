import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/provider_model.dart';
import '../services/language_provider.dart';
import '../theme/app_theme.dart';

class ProviderCard extends StatelessWidget {
  final ProviderModel provider;
  final VoidCallback onTap;

  const ProviderCard({super.key, required this.provider, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line),
          boxShadow: AppTheme.softShadow,
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: AppColors.brassGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    provider.initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -1,
                  right: -1,
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: provider.isOnline ? AppColors.success : AppColors.offline,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          provider.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      if (provider.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified, size: 16, color: Colors.blue),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          lang.trCategory(provider.category),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.terracotta,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (provider.isOnline ? AppColors.success : AppColors.offline).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          provider.isOnline ? '🟢 ${lang.t('online')}' : '⚪ ${lang.t('offline')}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: provider.isOnline ? AppColors.success : AppColors.inkSoft,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: AppColors.brassDark),
                      const SizedBox(width: 2),
                      Text(
                        provider.rating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        ' (${provider.reviewCount})',
                        style: const TextStyle(color: AppColors.inkSoft, fontSize: 11.5),
                      ),
                      const Spacer(),
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.inkSoft),
                      const SizedBox(width: 2),
                      Text(
                        '${provider.distance.toStringAsFixed(1)} ${lang.t('km_away')}',
                        style: const TextStyle(color: AppColors.inkSoft, fontSize: 11.5),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.inkSoft),
          ],
        ),
      ),
    );
  }
}
