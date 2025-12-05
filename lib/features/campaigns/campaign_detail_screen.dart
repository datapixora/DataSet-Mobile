import 'package:flutter/material.dart';
import 'models/campaign.dart';
import 'services/campaign_service.dart';

class CampaignDetailScreen extends StatefulWidget {
  final String campaignId;

  const CampaignDetailScreen({
    super.key,
    required this.campaignId,
  });

  @override
  State<CampaignDetailScreen> createState() => _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends State<CampaignDetailScreen> {
  final CampaignService _campaignService = CampaignService();
  Campaign? _campaign;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCampaign();
  }

  Future<void> _loadCampaign() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final campaign = await _campaignService.getCampaignById(widget.campaignId);
      setState(() {
        _campaign = campaign;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campaign Details'),
      ),
      body: _buildBody(),
      bottomNavigationBar: _campaign != null && _campaign!.isActive
          ? _buildUploadButton()
          : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null || _campaign == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: ${_error ?? "Campaign not found"}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCampaign,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildInfoSection(),
          const SizedBox(height: 24),
          _buildDescription(),
          const SizedBox(height: 24),
          _buildProgressSection(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final campaign = _campaign!;
    final isExpired = !campaign.isActive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                campaign.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: isExpired ? Colors.grey : Colors.green,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                isExpired ? 'Expired' : 'Active',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.category, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              campaign.category,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    final campaign = _campaign!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(
              Icons.attach_money,
              'Reward per Photo',
              '\$${campaign.rewardPerPhoto.toStringAsFixed(2)}',
              Colors.green,
            ),
            const Divider(),
            _buildInfoRow(
              Icons.photo_library,
              'Total Photos Required',
              campaign.photosRequired.toString(),
              Colors.blue,
            ),
            const Divider(),
            _buildInfoRow(
              Icons.monetization_on,
              'Total Campaign Reward',
              '\$${campaign.totalReward.toStringAsFixed(2)}',
              Colors.orange,
            ),
            const Divider(),
            _buildInfoRow(
              Icons.calendar_today,
              'Deadline',
              _formatDate(campaign.deadline),
              campaign.isActive ? Colors.grey : Colors.red,
            ),
            const Divider(),
            _buildInfoRow(
              Icons.schedule,
              'Created',
              _formatDate(campaign.createdAt),
              Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _campaign!.description,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection() {
    final campaign = _campaign!;
    final progress = campaign.uploadCount / campaign.photosRequired;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Progress',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: progress,
          minHeight: 10,
          backgroundColor: Colors.grey[300],
          borderRadius: BorderRadius.circular(5),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${campaign.uploadCount} uploaded',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            Text(
              '${campaign.remainingPhotos} remaining',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUploadButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton.icon(
          onPressed: _handleUpload,
          icon: const Icon(Icons.camera_alt),
          label: const Text('Upload Photos'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }

  void _handleUpload() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo upload feature will be implemented in the next milestone'),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
