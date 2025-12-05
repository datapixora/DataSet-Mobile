import 'package:flutter/material.dart' hide Badge;
import '../models/gamification.dart';
import '../services/gamification_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final GamificationService _gamificationService = GamificationService();
  List<LeaderboardEntry> _entries = [];
  int _userRank = 0;
  bool _isLoading = true;
  String? _error;
  String _period = 'all'; // all, weekly, monthly

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final entries = await _gamificationService.getLeaderboard(period: _period);
      final userRank = await _gamificationService.getUserRank();

      setState(() {
        _entries = entries;
        _userRank = userRank;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onPeriodChanged(String period) {
    setState(() => _period = period);
    _loadLeaderboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _onPeriodChanged,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Time')),
              const PopupMenuItem(value: 'monthly', child: Text('This Month')),
              const PopupMenuItem(value: 'weekly', child: Text('This Week')),
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
              onPressed: _loadLeaderboard,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLeaderboard,
      child: Column(
        children: [
          if (_userRank > 0) _buildUserRankCard(),
          if (_entries.length >= 3) _buildTopThree(),
          Expanded(child: _buildLeaderboardList()),
        ],
      ),
    );
  }

  Widget _buildUserRankCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        color: Colors.blue[50],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue,
                radius: 24,
                child: Text(
                  '#$_userRank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Rank',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Keep uploading to climb the leaderboard!',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopThree() {
    final top3 = _entries.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (top3.length > 1) _buildPodium(top3[1], 2, Colors.grey, 80),
          if (top3.isNotEmpty) _buildPodium(top3[0], 1, Colors.amber, 100),
          if (top3.length > 2) _buildPodium(top3[2], 3, Colors.brown, 60),
        ],
      ),
    );
  }

  Widget _buildPodium(LeaderboardEntry entry, int rank, Color color, double height) {
    return Column(
      children: [
        CircleAvatar(
          radius: rank == 1 ? 32 : 24,
          backgroundColor: color,
          child: Text(
            entry.userName.isNotEmpty ? entry.userName[0].toUpperCase() : 'U',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          entry.userName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: color, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                rank == 1
                    ? Icons.emoji_events
                    : rank == 2
                        ? Icons.military_tech
                        : Icons.workspace_premium,
                color: color,
                size: 32,
              ),
              const SizedBox(height: 4),
              Text(
                '${entry.totalXP} XP',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardList() {
    final restOfList = _entries.skip(3).toList();

    if (restOfList.isEmpty && _entries.length <= 3) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      itemCount: restOfList.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final entry = restOfList[index];
        return _buildLeaderboardCard(entry);
      },
    );
  }

  Widget _buildLeaderboardCard(LeaderboardEntry entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            '#${entry.rank}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        title: Text(
          entry.userName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          children: [
            Icon(Icons.stars, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text('Level ${entry.level}'),
            const SizedBox(width: 16),
            Icon(Icons.photo, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text('${entry.totalUploads} uploads'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${entry.totalXP}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blue,
              ),
            ),
            const Text(
              'XP',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
