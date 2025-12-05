import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import 'earnings_screen.dart';
import 'settings_screen.dart';
import '../../uploads/screens/upload_history_screen.dart';
import '../../auth/login_screen.dart';
import '../../gamification/models/gamification.dart';
import '../../gamification/services/gamification_service.dart';
import '../../gamification/screens/achievements_screen.dart';
import '../../gamification/screens/leaderboard_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final GamificationService _gamificationService = GamificationService();
  User? _user;
  UserLevel? _userLevel;
  Streak? _streak;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = await _userService.getCurrentUser();

      // Try to load gamification data, but don't fail if unavailable
      UserLevel? level;
      Streak? streak;

      try {
        level = await _gamificationService.getUserLevel();
        streak = await _gamificationService.getStreak();
      } catch (e) {
        // Gamification features may not be available yet
      }

      setState(() {
        _user = user;
        _userLevel = level;
        _streak = streak;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null || _user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: ${_error ?? "User not found"}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProfile,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProfile,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildStatsCards(),
          const SizedBox(height: 24),
          _buildMenuItems(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final user = _user!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Text(
                user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                style: const TextStyle(fontSize: 36, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.fullName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: user.isAdmin ? Colors.purple : Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user.role.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Member since ${_formatDate(user.createdAt)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            if (_userLevel != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('Level', style: TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        '${_userLevel!.level}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        _userLevel!.title,
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  if (_streak != null)
                    Column(
                      children: [
                        const Text('Streak', style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              _streak!.isActive ? Icons.local_fire_department : Icons.local_fire_department_outlined,
                              color: _streak!.isActive ? Colors.orange : Colors.grey,
                              size: 24,
                            ),
                            Text(
                              '${_streak!.currentStreak}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _streak!.isActive ? Colors.orange : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'days',
                          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_userLevel!.currentXP} / ${_userLevel!.xpForNextLevel} XP',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Next: Lvl ${_userLevel!.level + 1}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _userLevel!.progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.blue,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    final user = _user!;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Earnings',
            '\$${user.totalEarnings.toStringAsFixed(2)}',
            Icons.attach_money,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Pending',
            '\$${user.pendingEarnings.toStringAsFixed(2)}',
            Icons.pending,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItems() {
    final user = _user!;

    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.account_balance_wallet,
          title: 'Earnings & Transactions',
          subtitle: 'View your earnings and transaction history',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EarningsScreen()),
            );
          },
        ),
        _buildMenuItem(
          icon: Icons.history,
          title: 'Upload History',
          subtitle: '${user.totalUploads} total uploads',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UploadHistoryScreen()),
            );
          },
        ),
        _buildMenuItem(
          icon: Icons.emoji_events,
          title: 'Achievements',
          subtitle: 'View your achievements and badges',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AchievementsScreen()),
            );
          },
        ),
        _buildMenuItem(
          icon: Icons.leaderboard,
          title: 'Leaderboard',
          subtitle: 'See how you rank against others',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
            );
          },
        ),
        _buildMenuItem(
          icon: Icons.bar_chart,
          title: 'Statistics',
          subtitle: '${user.approvalRate.toStringAsFixed(1)}% approval rate',
          onTap: () {
            _showStatsDialog();
          },
        ),
        _buildMenuItem(
          icon: Icons.settings,
          title: 'Settings',
          subtitle: 'Manage your account settings',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showStatsDialog() {
    final user = _user!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your Statistics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow('Total Uploads', user.totalUploads.toString()),
            _buildStatRow('Approved', user.approvedUploads.toString(), Colors.green),
            _buildStatRow('Pending', user.pendingUploads.toString(), Colors.orange),
            _buildStatRow('Rejected', user.rejectedUploads.toString(), Colors.red),
            const Divider(),
            _buildStatRow(
              'Approval Rate',
              '${user.approvalRate.toStringAsFixed(1)}%',
              Colors.blue,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, [Color? color]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
