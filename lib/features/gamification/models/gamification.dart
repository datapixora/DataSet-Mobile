class UserLevel {
  final int level;
  final String title;
  final int currentXP;
  final int xpForNextLevel;
  final int totalXP;

  UserLevel({
    required this.level,
    required this.title,
    required this.currentXP,
    required this.xpForNextLevel,
    required this.totalXP,
  });

  factory UserLevel.fromJson(Map<String, dynamic> json) {
    return UserLevel(
      level: json['level'] ?? 1,
      title: json['title'] ?? 'Beginner',
      currentXP: json['currentXP'] ?? 0,
      xpForNextLevel: json['xpForNextLevel'] ?? 100,
      totalXP: json['totalXP'] ?? 0,
    );
  }

  double get progress {
    if (xpForNextLevel == 0) return 1.0;
    return currentXP / xpForNextLevel;
  }

  static String getLevelTitle(int level) {
    if (level < 5) return 'Beginner';
    if (level < 10) return 'Novice';
    if (level < 20) return 'Contributor';
    if (level < 35) return 'Expert';
    if (level < 50) return 'Master';
    if (level < 75) return 'Champion';
    if (level < 100) return 'Legend';
    return 'Mythic';
  }
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int xpReward;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int? progress;
  final int? target;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.xpReward,
    required this.isUnlocked,
    this.unlockedAt,
    this.progress,
    this.target,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? 'trophy',
      xpReward: json['xpReward'] ?? 0,
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'])
          : null,
      progress: json['progress'],
      target: json['target'],
    );
  }

  double get progressPercentage {
    if (target == null || progress == null || target == 0) return 0.0;
    return (progress! / target!).clamp(0.0, 1.0);
  }

  bool get hasProgress => progress != null && target != null;
}

class Badge {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String rarity;
  final DateTime earnedAt;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.rarity,
    required this.earnedAt,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? 'badge',
      rarity: json['rarity'] ?? 'common',
      earnedAt: DateTime.parse(json['earnedAt']),
    );
  }

  bool get isRare => rarity == 'rare' || rarity == 'epic' || rarity == 'legendary';
}

class Streak {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastUploadDate;
  final bool isActive;

  Streak({
    required this.currentStreak,
    required this.longestStreak,
    this.lastUploadDate,
    required this.isActive,
  });

  factory Streak.fromJson(Map<String, dynamic> json) {
    return Streak(
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      lastUploadDate: json['lastUploadDate'] != null
          ? DateTime.parse(json['lastUploadDate'])
          : null,
      isActive: json['isActive'] ?? false,
    );
  }
}

class LeaderboardEntry {
  final String userId;
  final String userName;
  final int rank;
  final int totalXP;
  final int level;
  final int totalUploads;
  final double totalEarnings;

  LeaderboardEntry({
    required this.userId,
    required this.userName,
    required this.rank,
    required this.totalXP,
    required this.level,
    required this.totalUploads,
    required this.totalEarnings,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'Anonymous',
      rank: json['rank'] ?? 0,
      totalXP: json['totalXP'] ?? 0,
      level: json['level'] ?? 1,
      totalUploads: json['totalUploads'] ?? 0,
      totalEarnings: (json['totalEarnings'] ?? 0).toDouble(),
    );
  }

  bool get isTopThree => rank <= 3;
}
