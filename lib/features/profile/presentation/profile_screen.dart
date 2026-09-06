import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/device_id_service.dart';
import 'bloc/profile_bloc.dart';
import 'bloc/profile_event.dart';
import 'bloc/profile_state.dart';
import '../domain/entities/user_profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: context.read<DeviceIdService>().getDeviceId(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return BlocProvider(
          create: (context) => ProfileBloc(
            repository: context.read(),
            deviceId: snapshot.data!,
          )..add(LoadProfile()),
          child: const ProfileView(),
        );
      },
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ProfileLoaded) {
              return _buildProfileContent(context, state.profile);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, UserProfile profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildProfileHeader(profile),
          const SizedBox(height: 24),
          _buildStatsCard(profile),
          const SizedBox(height: 24),
          _buildSettingsList(context, profile),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile profile) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
              ),
              child: const CircleAvatar(
                radius: 55,
                backgroundColor: AppColors.lightBlue,
                child: Icon(Icons.person, size: 60, color: AppColors.primaryBlue),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          profile.name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
        ),
        const SizedBox(height: 4),
        Text(
          profile.email,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            profile.badge,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(UserProfile profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('${profile.totalQuizzes}', 'Total Quizzes', AppColors.primaryBlue),
          Container(width: 1, height: 50, color: Colors.grey.shade200),
          _buildStatItem('${profile.accuracy.toInt()}%', 'Accuracy', AppColors.turquoise),
          Container(width: 1, height: 50, color: Colors.grey.shade200),
          _buildStatItem('${profile.streakDays} Days', 'Streak', AppColors.orange),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
      ],
    );
  }

  Widget _buildSettingsList(BuildContext context, UserProfile profile) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsItem(
            icon: Icons.subscriptions,
            title: 'My Subscriptions',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Active',
                  style: TextStyle(
                      color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 12)),
            ),
          ),
          _buildSettingsItem(
            icon: Icons.settings,
            title: 'Settings',
            trailing: const Icon(Icons.chevron_right, color: AppColors.grey),
          ),
          _buildDarkModeItem(context, profile.isDarkMode),
          _buildSettingsItem(
            icon: Icons.help_outline,
            title: 'Help Center',
            trailing: const Icon(Icons.chevron_right, color: AppColors.grey),
          ),
          _buildSettingsItem(
            icon: Icons.logout,
            title: 'Logout',
            iconColor: AppColors.error,
            titleColor: AppColors.error,
            trailing: const Icon(Icons.chevron_right, color: AppColors.error),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required Widget trailing,
    Color? iconColor,
    Color? titleColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (iconColor ?? AppColors.primaryBlue).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor ?? AppColors.primaryBlue, size: 22),
        ),
        title: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.w600, color: titleColor ?? AppColors.primaryNavy)),
        trailing: trailing,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDarkModeItem(BuildContext context, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryNavy.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.dark_mode, color: AppColors.primaryNavy, size: 22),
        ),
        title: const Text('Dark Mode',
            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryNavy)),
        trailing: Switch(
          value: isDarkMode,
          onChanged: (_) => context.read<ProfileBloc>().add(ToggleDarkMode()),
          activeThumbColor: AppColors.primaryBlue,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
