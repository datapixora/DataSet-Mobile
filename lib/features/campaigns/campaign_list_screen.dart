import 'package:flutter/material.dart';
import 'models/campaign.dart';
import 'services/campaign_service.dart';
import 'campaign_detail_screen.dart';

class CampaignListScreen extends StatefulWidget {
  const CampaignListScreen({super.key});

  @override
  State<CampaignListScreen> createState() => _CampaignListScreenState();
}

class _CampaignListScreenState extends State<CampaignListScreen> {
  final CampaignService _campaignService = CampaignService();
  List<Campaign> _campaigns = [];
  List<Campaign> _filteredCampaigns = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadCampaigns();
  }

  Future<void> _loadCampaigns() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final campaigns = await _campaignService.getCampaigns();
      setState(() {
        _campaigns = campaigns;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    _filteredCampaigns = _campaigns.where((campaign) {
      final matchesSearch = campaign.title
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          campaign.description.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesFilter = _filterStatus == 'all' ||
          (_filterStatus == 'active' && campaign.isActive) ||
          (_filterStatus == 'expired' && !campaign.isActive);

      return matchesSearch && matchesFilter;
    }).toList();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _filterStatus = filter;
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campaigns'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _onFilterChanged,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Campaigns')),
              const PopupMenuItem(value: 'active', child: Text('Active Only')),
              const PopupMenuItem(value: 'expired', child: Text('Expired')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search campaigns...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
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
              onPressed: _loadCampaigns,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredCampaigns.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'No campaigns found'
                  : 'No campaigns match your search',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCampaigns,
      child: ListView.builder(
        itemCount: _filteredCampaigns.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final campaign = _filteredCampaigns[index];
          return _CampaignCard(
            campaign: campaign,
            onTap: () => _navigateToDetail(campaign),
          );
        },
      ),
    );
  }

  void _navigateToDetail(Campaign campaign) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CampaignDetailScreen(campaignId: campaign.id),
      ),
    );
  }
}

class _CampaignCard extends StatelessWidget {
  final Campaign campaign;
  final VoidCallback onTap;

  const _CampaignCard({
    required this.campaign,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isExpired = !campaign.isActive;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      campaign.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isExpired ? Colors.grey : Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isExpired ? 'Expired' : 'Active',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                campaign.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.category, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    campaign.category,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.photo, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${campaign.uploadCount}/${campaign.photosRequired}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.attach_money, size: 16, color: Colors.green),
                      Text(
                        '${campaign.rewardPerPhoto.toStringAsFixed(2)} per photo',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Deadline: ${_formatDate(campaign.deadline)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isExpired ? Colors.red : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
