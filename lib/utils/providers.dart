import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dashboard_data.dart';
import '../models/collection.dart';
import '../models/invoice.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

// Auth token — set after login, cleared on logout
final authTokenProvider = StateProvider<String?>((ref) => null);

UserService _service(Ref ref) {
  final token = ref.watch(authTokenProvider);
  assert(token != null, 'authTokenProvider must be set before using UserService');
  return UserService.withToken(token!);
}

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  return _service(ref).getDashboard();
});

final collectionsProvider = FutureProvider.family<List<Collection>, String?>(
  (ref, status) async => _service(ref).getCollections(status: status),
);

final invoicesProvider = FutureProvider.family<List<Invoice>, String?>(
  (ref, status) async => _service(ref).getInvoices(status: status),
);

final invoiceDetailProvider = FutureProvider.family<Invoice, String>(
  (ref, id) async => _service(ref).getInvoice(id),
);

// Check stored session on app start
final sessionInitProvider = FutureProvider<bool>((ref) async {
  final token = await AuthService.getValidAccessToken();
  if (token != null) {
    ref.read(authTokenProvider.notifier).state = token;
    return true;
  }
  return false;
});
