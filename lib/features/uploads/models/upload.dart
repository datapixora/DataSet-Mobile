class Upload {
  final String id;
  final String campaignId;
  final String userId;
  final String fileKey;
  final String status;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final String? rejectionReason;
  final Map<String, dynamic>? metadata;

  Upload({
    required this.id,
    required this.campaignId,
    required this.userId,
    required this.fileKey,
    required this.status,
    required this.createdAt,
    this.approvedAt,
    this.rejectedAt,
    this.rejectionReason,
    this.metadata,
  });

  factory Upload.fromJson(Map<String, dynamic> json) {
    return Upload(
      id: json['id'] ?? '',
      campaignId: json['campaignId'] ?? '',
      userId: json['userId'] ?? '',
      fileKey: json['fileKey'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['createdAt']),
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'])
          : null,
      rejectedAt: json['rejectedAt'] != null
          ? DateTime.parse(json['rejectedAt'])
          : null,
      rejectionReason: json['rejectionReason'],
      metadata: json['metadata'],
    );
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
}

class UploadInitiateResponse {
  final String uploadUrl;
  final String fileKey;

  UploadInitiateResponse({
    required this.uploadUrl,
    required this.fileKey,
  });

  factory UploadInitiateResponse.fromJson(Map<String, dynamic> json) {
    return UploadInitiateResponse(
      uploadUrl: json['uploadUrl'] ?? '',
      fileKey: json['fileKey'] ?? '',
    );
  }
}
