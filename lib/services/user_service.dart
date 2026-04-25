import '../models/collection.dart';
import '../models/dashboard_data.dart';
import '../models/invoice.dart';
import 'api_client.dart';

class UserService {
  final ApiClient _client;

  const UserService(String accessToken)
      : _client = const ApiClient(),
        assert(accessToken.length > 0);

  UserService._(this._client);

  factory UserService.withToken(String accessToken) =>
      UserService._(ApiClient(accessToken: accessToken));

  Future<DashboardData> getDashboard() async {
    final data = await _client.get('/api/user/dashboard');
    return DashboardData.fromJson(data);
  }

  Future<List<Collection>> getCollections({
    String? status,
    int limit = 50,
    int offset = 0,
  }) async {
    final params = {
      if (status != null) 'status': status,
      'limit': '$limit',
      'offset': '$offset',
    };
    final query = Uri(queryParameters: params).query;
    final data = await _client.get('/api/user/collections?$query');
    final list = data['data'] as List<dynamic>;
    return list.map((e) => Collection.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Collection>> getUpcomingCollections({int limit = 3}) async {
    final data = await _client.get('/api/user/collections/upcoming?limit=$limit');
    final list = data as List<dynamic>;
    return list.map((e) => Collection.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Invoice>> getInvoices({String? status}) async {
    final query = status != null ? '?status=$status' : '';
    final data = await _client.get('/api/user/invoices$query');
    final list = data as List<dynamic>;
    return list.map((e) => Invoice.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Invoice> getInvoice(String id) async {
    final data = await _client.get('/api/user/invoices/$id');
    return Invoice.fromJson(data);
  }
}
