import 'dart:convert';
import '../../../core/api_client.dart';
import '../models/gamification.dart';

class GamificationService {
  final api = ApiClient.instance;

  /// Get user's current level and XP
  Future<UserLevel> getUserLevel() async {
    final res = await api.get("/gamification/level", auth: true);

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch user level');
    }

    final data = jsonDecode(res.body);
    return UserLevel.fromJson(data['data']);
  }

  /// Get all achievements
  Future<List<Achievement>> getAchievements() async {
    final res = await api.get("/gamification/achievements", auth: true);

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch achievements');
    }

    final data = jsonDecode(res.body);
    final List<dynamic> achievementsJson = data['data'] ?? [];

    return achievementsJson.map((json) => Achievement.fromJson(json)).toList();
  }

  /// Get user's badges
  Future<List<Badge>> getBadges() async {
    final res = await api.get("/gamification/badges", auth: true);

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch badges');
    }

    final data = jsonDecode(res.body);
    final List<dynamic> badgesJson = data['data'] ?? [];

    return badgesJson.map((json) => Badge.fromJson(json)).toList();
  }

  /// Get user's streak information
  Future<Streak> getStreak() async {
    final res = await api.get("/gamification/streak", auth: true);

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch streak');
    }

    final data = jsonDecode(res.body);
    return Streak.fromJson(data['data']);
  }

  /// Get leaderboard
  Future<List<LeaderboardEntry>> getLeaderboard({
    String period = 'all', // all, weekly, monthly
    int limit = 100,
  }) async {
    final res = await api.get(
      "/gamification/leaderboard?period=$period&limit=$limit",
      auth: true,
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch leaderboard');
    }

    final data = jsonDecode(res.body);
    final List<dynamic> entriesJson = data['data'] ?? [];

    return entriesJson.map((json) => LeaderboardEntry.fromJson(json)).toList();
  }

  /// Get user's rank
  Future<int> getUserRank() async {
    final res = await api.get("/gamification/rank", auth: true);

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch user rank');
    }

    final data = jsonDecode(res.body);
    return data['data']['rank'] ?? 0;
  }
}
