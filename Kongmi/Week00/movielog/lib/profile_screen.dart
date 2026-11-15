import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';
import 'widgets/common_app_bar.dart';
import 'widgets/stat_item.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const List<Map<String, String>> statsData = [
    {'label': '본 영화', 'value': '342'},
    {'label': '평점', 'value': '4.2'},
    {'label': '즐겨찾기', 'value': '58'},
  ];

  static const List<String> genreData = ['드라마', 'SF', '애니메이션'];

  @override
  Widget build(BuildContext context) {
    const String profileImagePath = 'assets/images/profile/profile.png';
    final bool hasProfileImage = profileImagePath.isNotEmpty;

    return Scaffold(
      appBar: const CommonAppBar(title: '내 프로필'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            if (hasProfileImage)
              const CircleAvatar(
                radius: 48,
                backgroundImage: AssetImage(profileImagePath),
              )
            else
              const CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.violet,
                child: Icon(Icons.person, size: 48, color: AppColors.white),
              ),
            const SizedBox(height: 16),
            const Text('무비러버', style: AppTextStyles.titleLarge),
            const SizedBox(height: 8),
            const Text(
              '매주 주말엔 영화관으로 출근하는 프로 관람객. 좋은 영화를 보고 기록하는 것을 좋아합니다.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: () {},
              icon: SvgPicture.asset(
                'assets/icons/movie.svg',
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(
                  AppColors.violet,
                  BlendMode.srcIn,
                ),
              ),
              label: const Text(
                '프로필 수정',
                style: TextStyle(color: AppColors.violet),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.violet),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: statsData.map((stat) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: StatItem(
                      label: stat['label']!,
                      value: stat['value']!,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text('선호하는 장르', style: AppTextStyles.titleMedium),
            ),
            const SizedBox(height: 12),
            Row(
              children: genreData.map((genre) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Chip(
                    label: Text(genre),
                    backgroundColor: AppColors.violet.withValues(alpha: 0.1),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
