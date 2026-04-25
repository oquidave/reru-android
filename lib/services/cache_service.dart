import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/collection.dart';
import '../models/dashboard_data.dart';
import '../models/invoice.dart';

class CacheService {
  static const _keyDashboard   = 'cache_dashboard';
  static const _keyCollections = 'cache_collections_';
  static const _keyInvoices    = 'cache_invoices_';
  static const _keyInvoice     = 'cache_invoice_';

  static Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // ── Dashboard ────────────────────────────────────────────────────

  static Future<DashboardData?> getDashboard() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_keyDashboard);
    if (raw == null) return null;
    try {
      return DashboardData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveDashboard(DashboardData data) async {
    final prefs = await _prefs;
    await prefs.setString(_keyDashboard, jsonEncode(data.toJson()));
  }

  // ── Collections ──────────────────────────────────────────────────

  static Future<List<Collection>?> getCollections(String? status) async {
    final prefs = await _prefs;
    final raw = prefs.getString('$_keyCollections${status ?? 'all'}');
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => Collection.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveCollections(String? status, List<Collection> data) async {
    final prefs = await _prefs;
    await prefs.setString(
      '$_keyCollections${status ?? 'all'}',
      jsonEncode(data.map((c) => c.toJson()).toList()),
    );
  }

  // ── Invoices ─────────────────────────────────────────────────────

  static Future<List<Invoice>?> getInvoices(String? status) async {
    final prefs = await _prefs;
    final raw = prefs.getString('$_keyInvoices${status ?? 'all'}');
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => Invoice.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveInvoices(String? status, List<Invoice> data) async {
    final prefs = await _prefs;
    await prefs.setString(
      '$_keyInvoices${status ?? 'all'}',
      jsonEncode(data.map((i) => i.toJson()).toList()),
    );
  }

  // ── Invoice detail ───────────────────────────────────────────────

  static Future<Invoice?> getInvoice(String id) async {
    final prefs = await _prefs;
    final raw = prefs.getString('$_keyInvoice$id');
    if (raw == null) return null;
    try {
      return Invoice.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveInvoice(Invoice data) async {
    final prefs = await _prefs;
    await prefs.setString('$_keyInvoice${data.id}', jsonEncode(data.toJson()));
  }

  // ── Clear all (call on logout) ───────────────────────────────────

  static Future<void> clear() async {
    final prefs = await _prefs;
    final keys = prefs.getKeys().where((k) => k.startsWith('cache_')).toList();
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
