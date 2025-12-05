import 'package:flutter/material.dart' hide Badge;
import '../models/gamification.dart';
import '../services/gamification_service.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final GamificationService _gamificationService = GamificationService();
  List<Achievement> _achievements = [];
  List<Badge> _badges = [];
  bool _isLoading = true;
  String? _error;
  String _filter = 'all'; // all, unlocked, locked

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final achievements = await _gamificationService.getAchievements();
      final badges = await _gamificationService.getBadges();

      setState(() {
        _achievements = achievements;
        _badges = badges;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Achievement> get _filteredAchievements {
    if (_filter == 'unlocked') {
      return _achievements.where((a) => a.isUnlocked).toList();
    } else if (_filter == 'locked') {
      return _achievements.where((a) => !a.isUnlocked).toList();
    }
    return _achievements;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => setState(() => _filter = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All')),
              const PopupMenuItem(value: 'unlocked', child: Text('Unlocked')),
              const PopupMenuItem(value: 'locked', child: Text('Locked')),
            ],
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

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAchievements,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAchievements,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSummaryCard(),
          const SizedBox(height: 16),
          if (_badges.isNotEmpty) ...[
            _buildBadgesSection(),
            const SizedBox(height: 24),
          ],
          _buildAchievementsSection(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final unlockedCount = _achievements.where((a) => a.isUnlocked).length;
    final totalXP = _achievements
        .where((a) => a.isUnlocked)
        .fold(0, (sum, a) => sum + a.xpReward);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Unlocked', '$unlockedCount/${_achievements.length}', Icons.emoji_events, Colors.amber),
                _buildStat('Total XP', totalXP.toString(), Icons.stars, Colors.blue),
                _buildStat('Badges', _badges.length.toString(), Icons.badge, Colors.purple),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _achievements.isEmpty ? 0 : unlockedCount / _achievements.length,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
              color: Colors.amber,
            ),
            const SizedBox(height: 8),
            Text(
              '${(_achievements.isEmpty ? 0 : (unlockedCount / _achievements.length * 100)).toStringAsFixed(1)}% Complete',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon, Color color) {
    return Column(
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
        ),
      ],
    );
  }

  Widget _buildBadgesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Badges',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _badges.length,
            itemBuilder: (context, index) {
              final badge = _badges[index];
              return _buildBadgeCard(badge);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeCard(Badge badge) {
    Color badgeColor;
    switch (badge.rarity) {
      case 'legendary':
        badgeColor = Colors.deepOrange;
        break;
      case 'epic':
        badgeColor = Colors.purple;
        break;
      case 'rare':
        badgeColor = Colors.blue;
        break;
      default:
        badgeColor = Colors.grey;
    }

    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        color: badgeColor.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.badge, size: 32, color: badgeColor),
              const SizedBox(height: 4),
              Text(
                badge.name,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _filter == 'all'
              ? 'All Achievements'
              : _filter == 'unlocked'
                  ? 'Unlocked Achievements'
                  : 'Locked Achievements',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (_filteredAchievements.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.emoji_events_outlined, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      'No achievements found',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ..._filteredAchievements.map((achievement) => _buildAchievementCard(achievement)),
      ],
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    final isUnlocked = achievement.isUnlocked;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          isUnlocked ? Icons.emoji_events : Icons.lock,
          size: 32,
          color: isUnlocked ? Colors.amber : Colors.grey,
        ),
        title: Text(
          achievement.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isUnlocked ? null : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(achievement.description),
            const SizedBox(height: 8),
            if (achievement.hasProgress && !isUnlocked) ...[
              LinearProgressIndicator(
                value: achievement.progressPercentage,
                minHeight: 6,
                backgroundColor: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 4),
              Text(
                '${achievement.progress}/${achievement.target}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
            if (isUnlocked && achievement.unlockedAt != null) ...[
              Text(
                'Unlocked: ${_formatDate(achievement.unlockedAt!)}',
                style: TextStyle(fontSize: 12, color: Colors.green[700]),
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.stars, color: Colors.blue, size: 20),
            const SizedBox(height: 4),
            Text(
              '+${achievement.xpReward}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
