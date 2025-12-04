// lib/features/campaigns/campaign_list_placeholder.dart
import 'package:flutter/material.dart';

class CampaignListPlaceholderScreen extends StatelessWidget {
  const CampaignListPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campaigns'),
      ),
      body: const Center(
        child: Text(
          'Campaign list screen (M2) will be implemented here.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
