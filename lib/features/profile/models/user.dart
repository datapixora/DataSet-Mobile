class User {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final DateTime createdAt;
  final double totalEarnings;
  final double pendingEarnings;
  final int totalUploads;
  final int approvedUploads;
  final int pendingUploads;
  final int rejectedUploads;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.createdAt,
    this.totalEarnings = 0.0,
    this.pendingEarnings = 0.0,
    this.totalUploads = 0,
    this.approvedUploads = 0,
    this.pendingUploads = 0,
    this.rejectedUploads = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      role: json['role'] ?? 'user',
      createdAt: DateTime.parse(json['createdAt']),
      totalEarnings: double.tryParse(json['totalEarned']?.toString() ?? '0') ?? 0.0,
      pendingEarnings: double.tryParse(json['currentBalance']?.toString() ?? '0') ?? 0.0,
      totalUploads: json['totalUploads'] ?? 0,
      approvedUploads: json['approvedUploads'] ?? 0,
      pendingUploads: json['pendingUploads'] ?? 0,
      rejectedUploads: json['rejectedUploads'] ?? 0,
    );
  }

  double get approvalRate {
    if (totalUploads == 0) return 0.0;
    return (approvedUploads / totalUploads) * 100;
  }

  bool get isAdmin => role == 'admin';
}

class Transaction {
  final String id;
  final String userId;
  final String type;
  final double amount;
  final String status;
  final String? description;
  final String? campaignId;
  final String? uploadId;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.status,
    this.description,
    this.campaignId,
    this.uploadId,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      type: json['type'] ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      status: json['status'] ?? 'pending',
      description: json['description'],
      campaignId: json['campaignId'],
      uploadId: json['uploadId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isEarning => type == 'earning';
  bool get isWithdrawal => type == 'withdrawal';
}

class EarningsStats {
  final double totalEarnings;
  final double pendingEarnings;
  final double availableBalance;
  final int totalUploads;
  final int approvedUploads;
  final int pendingUploads;
  final int rejectedUploads;
  final List<Transaction> recentTransactions;

  EarningsStats({
    required this.totalEarnings,
    required this.pendingEarnings,
    required this.availableBalance,
    required this.totalUploads,
    required this.approvedUploads,
    required this.pendingUploads,
    required this.rejectedUploads,
    this.recentTransactions = const [],
  });

  factory EarningsStats.fromJson(Map<String, dynamic> json) {
    final transactionsJson = json['recentTransactions'] as List<dynamic>? ?? [];
    final transactions = transactionsJson
        .map((t) => Transaction.fromJson(t))
        .toList();

    return EarningsStats(
      totalEarnings: double.tryParse(json['totalEarned']?.toString() ?? '0') ?? 0.0,
      pendingEarnings: double.tryParse(json['pendingEarnings']?.toString() ?? '0') ?? 0.0,
      availableBalance: double.tryParse(json['currentBalance']?.toString() ?? '0') ?? 0.0,
      totalUploads: json['totalUploads'] ?? 0,
      approvedUploads: json['approvedUploads'] ?? 0,
      pendingUploads: json['pendingUploads'] ?? 0,
      rejectedUploads: json['rejectedUploads'] ?? 0,
      recentTransactions: transactions,
    );
  }

  double get approvalRate {
    if (totalUploads == 0) return 0.0;
    return (approvedUploads / totalUploads) * 100;
  }
}
