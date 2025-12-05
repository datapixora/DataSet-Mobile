import 'dart:convert';
import '../../../core/api_client.dart';
import '../models/user.dart';

class UserService {
  final api = ApiClient.instance;

  /// Get current user profile
  Future<User> getCurrentUser() async {
    final res = await api.get("/users/me", auth: true);

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch user profile');
    }

    final data = jsonDecode(res.body);
    return User.fromJson(data['data']);
  }

  /// Get user earnings statistics
  Future<EarningsStats> getEarningsStats() async {
    final res = await api.get("/users/earnings", auth: true);

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch earnings stats');
    }

    final data = jsonDecode(res.body);
    return EarningsStats.fromJson(data['data']);
  }

  /// Get user transactions
  Future<List<Transaction>> getTransactions() async {
    final res = await api.get("/users/transactions", auth: true);

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch transactions');
    }

    final data = jsonDecode(res.body);
    final List<dynamic> transactionsJson = data['data'] ?? [];

    return transactionsJson.map((json) => Transaction.fromJson(json)).toList();
  }

  /// Update user profile
  Future<User> updateProfile({
    String? fullName,
    String? email,
  }) async {
    final body = <String, dynamic>{};
    if (fullName != null) body['fullName'] = fullName;
    if (email != null) body['email'] = email;

    final res = await api.post("/users/me", body, auth: true);

    if (res.statusCode != 200) {
      throw Exception('Failed to update profile');
    }

    final data = jsonDecode(res.body);
    return User.fromJson(data['data']);
  }

  /// Request withdrawal
  Future<Transaction> requestWithdrawal({
    required double amount,
    required String method,
    String? accountDetails,
  }) async {
    final res = await api.post(
      "/users/withdraw",
      {
        "amount": amount,
        "method": method,
        if (accountDetails != null) "accountDetails": accountDetails,
      },
      auth: true,
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Failed to request withdrawal');
    }

    final data = jsonDecode(res.body);
    return Transaction.fromJson(data['data']);
  }
}
