import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import '../../../core/api_client.dart';
import '../models/upload.dart';

class UploadService {
  final api = ApiClient.instance;

  /// Step 1: Initiate upload and get presigned URL
  Future<UploadInitiateResponse> initiateUpload({
    required String campaignId,
    required String filePath,
  }) async {
    final fileName = path.basename(filePath);
    final mimeType = lookupMimeType(filePath) ?? 'image/jpeg';
    final file = File(filePath);
    final fileSize = await file.length();

    final res = await api.post(
      "/uploads/initiate",
      {
        "campaign_id": campaignId,
        "filename": fileName,
        "file_size": fileSize,
        "mime_type": mimeType,
      },
      auth: true,
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to initiate upload: ${res.body}');
    }

    final data = jsonDecode(res.body);
    return UploadInitiateResponse.fromJson(data['data']);
  }

  /// Step 2: Upload file to presigned URL (S3/R2)
  Future<void> uploadToStorage({
    required String uploadUrl,
    required String filePath,
    Function(double)? onProgress,
  }) async {
    final file = File(filePath);
    final fileBytes = await file.readAsBytes();
    final mimeType = lookupMimeType(filePath) ?? 'image/jpeg';

    final request = http.StreamedRequest('PUT', Uri.parse(uploadUrl));
    request.headers['Content-Type'] = mimeType;
    request.headers['Content-Length'] = fileBytes.length.toString();

    final stream = http.ByteStream.fromBytes(fileBytes);
    request.contentLength = fileBytes.length;

    int bytesSent = 0;
    stream.listen(
      (chunk) {
        bytesSent += chunk.length;
        if (onProgress != null) {
          final progress = bytesSent / fileBytes.length;
          onProgress(progress);
        }
      },
    );

    request.sink.add(fileBytes);
    await request.sink.close();

    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Failed to upload file to storage: ${response.statusCode}');
    }
  }

  /// Step 3: Complete upload and register it with backend
  Future<Upload> completeUpload({
    required String campaignId,
    required String fileKey,
    Map<String, dynamic>? metadata,
  }) async {
    final res = await api.post(
      "/uploads/complete",
      {
        "campaign_id": campaignId,
        "file_key": fileKey,
        if (metadata != null) "metadata": metadata,
      },
      auth: true,
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Failed to complete upload: ${res.body}');
    }

    final data = jsonDecode(res.body);
    return Upload.fromJson(data['data']);
  }

  /// Convenience method: Full upload flow
  Future<Upload> uploadPhoto({
    required String campaignId,
    required String filePath,
    Map<String, dynamic>? metadata,
    Function(double)? onProgress,
  }) async {
    // Step 1: Initiate
    final initiateResponse = await initiateUpload(
      campaignId: campaignId,
      filePath: filePath,
    );

    // Step 2: Upload to storage
    await uploadToStorage(
      uploadUrl: initiateResponse.uploadUrl,
      filePath: filePath,
      onProgress: onProgress,
    );

    // Step 3: Complete
    final upload = await completeUpload(
      campaignId: campaignId,
      fileKey: initiateResponse.fileKey,
      metadata: metadata,
    );

    return upload;
  }

  /// Get user's uploads
  Future<List<Upload>> getUserUploads() async {
    final res = await api.get("/uploads/me", auth: true);

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch uploads');
    }

    final data = jsonDecode(res.body);
    final List<dynamic> uploadsJson = data['data'] ?? [];

    return uploadsJson.map((json) => Upload.fromJson(json)).toList();
  }

  /// Get uploads for a specific campaign
  Future<List<Upload>> getCampaignUploads(String campaignId) async {
    final res = await api.get("/uploads?campaignId=$campaignId", auth: true);

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch campaign uploads');
    }

    final data = jsonDecode(res.body);
    final List<dynamic> uploadsJson = data['data'] ?? [];

    return uploadsJson.map((json) => Upload.fromJson(json)).toList();
  }
}
