class Campaign {
  final String id;
  final String title;
  final String description;
  final String category;
  final int photosRequired;
  final double rewardPerPhoto;
  final String status;
  final DateTime deadline;
  final DateTime createdAt;
  final int uploadCount;

  Campaign({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.photosRequired,
    required this.rewardPerPhoto,
    required this.status,
    required this.deadline,
    required this.createdAt,
    required this.uploadCount,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      photosRequired: json['photosRequired'] ?? 0,
      rewardPerPhoto: (json['rewardPerPhoto'] ?? 0).toDouble(),
      status: json['status'] ?? 'active',
      deadline: DateTime.parse(json['deadline']),
      createdAt: DateTime.parse(json['createdAt']),
      uploadCount: json['_count']?['uploads'] ?? 0,
    );
  }

  bool get isActive => status == 'active' && DateTime.now().isBefore(deadline);

  int get remainingPhotos => photosRequired - uploadCount;

  double get totalReward => rewardPerPhoto * photosRequired;
}
