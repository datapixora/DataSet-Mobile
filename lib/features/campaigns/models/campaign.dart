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
    // Get tags as category (use first tag if available)
    final tags = json['tags'] as List<dynamic>?;
    final category = tags != null && tags.isNotEmpty ? tags[0].toString() : 'general';

    return Campaign(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: category,
      photosRequired: json['targetQuantity'] ?? 0,
      rewardPerPhoto: double.tryParse(json['basePayout']?.toString() ?? '0') ?? 0.0,
      status: json['status'] ?? 'ACTIVE',
      deadline: json['endsAt'] != null ? DateTime.parse(json['endsAt']) : DateTime.now().add(Duration(days: 365)),
      createdAt: DateTime.parse(json['createdAt']),
      uploadCount: json['totalCollected'] ?? 0,
    );
  }

  bool get isActive => status == 'ACTIVE' && DateTime.now().isBefore(deadline);

  int get remainingPhotos => photosRequired - uploadCount;

  double get totalReward => rewardPerPhoto * photosRequired;
}
