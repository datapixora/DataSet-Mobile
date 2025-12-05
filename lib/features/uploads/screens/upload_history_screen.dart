import 'package:flutter/material.dart';
import '../models/upload.dart';
import '../services/upload_service.dart';

class UploadHistoryScreen extends StatefulWidget {
  const UploadHistoryScreen({super.key});

  @override
  State<UploadHistoryScreen> createState() => _UploadHistoryScreenState();
}

class _UploadHistoryScreenState extends State<UploadHistoryScreen> {
  final UploadService _uploadService = UploadService();
  List<Upload> _uploads = [];
  List<Upload> _filteredUploads = [];
  bool _isLoading = true;
  String? _error;
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadUploads();
  }

  Future<void> _loadUploads() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final uploads = await _uploadService.getUserUploads();
      setState(() {
        _uploads = uploads;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    _filteredUploads = _uploads.where((upload) {
      if (_filterStatus == 'all') return true;
      return upload.status == _filterStatus;
    }).toList();
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _filterStatus = filter;
      _applyFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload History'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _onFilterChanged,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Uploads')),
              const PopupMenuItem(value: 'pending', child: Text('Pending')),
              const PopupMenuItem(value: 'approved', child: Text('Approved')),
              const PopupMenuItem(value: 'rejected', child: Text('Rejected')),
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
              onPressed: _loadUploads,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredUploads.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_upload_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _uploads.isEmpty
                  ? 'No uploads yet'
                  : 'No uploads match the filter',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUploads,
      child: Column(
        children: [
          _buildSummaryBar(),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredUploads.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final upload = _filteredUploads[index];
                return _buildUploadCard(upload);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBar() {
    final pendingCount = _uploads.where((u) => u.isPending).length;
    final approvedCount = _uploads.where((u) => u.isApproved).length;
    final rejectedCount = _uploads.where((u) => u.isRejected).length;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Total', _uploads.length.toString(), Colors.blue),
          _buildSummaryItem('Approved', approvedCount.toString(), Colors.green),
          _buildSummaryItem('Pending', pendingCount.toString(), Colors.orange),
          _buildSummaryItem('Rejected', rejectedCount.toString(), Colors.red),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
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

  Widget _buildUploadCard(Upload upload) {
    Color statusColor;
    IconData statusIcon;

    if (upload.isApproved) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (upload.isRejected) {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
    } else {
      statusColor = Colors.orange;
      statusIcon = Icons.pending;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Campaign: ${upload.campaignId}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    upload.status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.image, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  upload.fileKey,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Uploaded: ${_formatDate(upload.createdAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            if (upload.isApproved && upload.approvedAt != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.check, size: 16, color: Colors.green[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Approved: ${_formatDate(upload.approvedAt!)}',
                    style: TextStyle(fontSize: 12, color: Colors.green[600]),
                  ),
                ],
              ),
            ],
            if (upload.isRejected) ...[
              if (upload.rejectedAt != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.error, size: 16, color: Colors.red[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Rejected: ${_formatDate(upload.rejectedAt!)}',
                      style: TextStyle(fontSize: 12, color: Colors.red[600]),
                    ),
                  ],
                ),
              ],
              if (upload.rejectionReason != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.red[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          upload.rejectionReason!,
                          style: TextStyle(fontSize: 12, color: Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
