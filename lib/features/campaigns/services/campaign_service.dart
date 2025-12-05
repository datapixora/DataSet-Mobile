import 'dart:convert';
import '../../../core/api_client.dart';
import '../models/campaign.dart';

class CampaignService {
  final api = ApiClient.instance;

  Future<List<Campaign>> getCampaigns() async {
    final res = await api.get("/campaigns", auth: true);

    if (res.statusCode != 200) {
      throw Exception('Failed to load campaigns');
    }

    final data = jsonDecode(res.body);
    final List<dynamic> campaignsJson = data['data'] ?? [];

    return campaignsJson.map((json) => Campaign.fromJson(json)).toList();
  }

  Future<Campaign?> getCampaignById(String id) async {
    final res = await api.get("/campaigns/$id", auth: true);

    if (res.statusCode != 200) {
      return null;
    }

    final data = jsonDecode(res.body);
    return Campaign.fromJson(data['data']);
  }
}
