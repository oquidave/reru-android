import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dashboard_data.dart';
import '../models/collection.dart';
import '../models/invoice.dart';
import '../services/auth_service.dart';
import '../services/cache_service.dart';
import '../services/user_service.dart';

// Auth token — set after login, cleared on logout
final authTokenProvider = StateProvider<String?>((ref) => null);

UserService _service(Ref ref) {
  final token = ref.watch(authTokenProvider);
  assert(token != null, 'authTokenProvider must be set before using UserService');
  return UserService.withToken(token!);
}

// ── Dashboard ─────────────────────────────────────────────────────

class DashboardNotifier extends AsyncNotifier<DashboardData> {
  @override
  Future<DashboardData> build() async {
    final cached = await CacheService.getDashboard();
    if (cached != null) state = AsyncData(cached);
    try {
      final fresh = await _service(ref).getDashboard();
      await CacheService.saveDashboard(fresh);
      return fresh;
    } catch (_) {
      if (cached != null) return cached;
      rethrow;
    }
  }
}

final dashboardProvider =
    AsyncNotifierProvider<DashboardNotifier, DashboardData>(DashboardNotifier.new);

// ── Collections ───────────────────────────────────────────────────

class CollectionsNotifier extends FamilyAsyncNotifier<List<Collection>, String?> {
  @override
  Future<List<Collection>> build(String? status) async {
    final cached = await CacheService.getCollections(status);
    if (cached != null) state = AsyncData(cached);
    try {
      final fresh = await _service(ref).getCollections(status: status);
      await CacheService.saveCollections(status, fresh);
      return fresh;
    } catch (_) {
      if (cached != null) return cached;
      rethrow;
    }
  }
}

final collectionsProvider = AsyncNotifierProvider.family<CollectionsNotifier, List<Collection>, String?>(
  CollectionsNotifier.new,
);

// ── Invoices ──────────────────────────────────────────────────────

class InvoicesNotifier extends FamilyAsyncNotifier<List<Invoice>, String?> {
  @override
  Future<List<Invoice>> build(String? status) async {
    final cached = await CacheService.getInvoices(status);
    if (cached != null) state = AsyncData(cached);
    try {
      final fresh = await _service(ref).getInvoices(status: status);
      await CacheService.saveInvoices(status, fresh);
      return fresh;
    } catch (_) {
      if (cached != null) return cached;
      rethrow;
    }
  }
}

final invoicesProvider = AsyncNotifierProvider.family<InvoicesNotifier, List<Invoice>, String?>(
  InvoicesNotifier.new,
);

// ── Invoice detail ────────────────────────────────────────────────

class InvoiceDetailNotifier extends FamilyAsyncNotifier<Invoice, String> {
  @override
  Future<Invoice> build(String id) async {
    final cached = await CacheService.getInvoice(id);
    if (cached != null) state = AsyncData(cached);
    try {
      final fresh = await _service(ref).getInvoice(id);
      await CacheService.saveInvoice(fresh);
      return fresh;
    } catch (_) {
      if (cached != null) return cached;
      rethrow;
    }
  }
}

final invoiceDetailProvider = AsyncNotifierProvider.family<InvoiceDetailNotifier, Invoice, String>(
  InvoiceDetailNotifier.new,
);

// ── Session init (no caching needed) ─────────────────────────────

final sessionInitProvider = FutureProvider<bool>((ref) async {
  final token = await AuthService.getValidAccessToken();
  if (token != null) {
    ref.read(authTokenProvider.notifier).state = token;
    return true;
  }
  return false;
});
