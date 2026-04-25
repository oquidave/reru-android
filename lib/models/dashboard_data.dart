import 'client.dart';
import 'collection.dart';
import 'invoice.dart';

class DashboardData {
  final Client client;
  final Collection? nextCollection;
  final List<Collection> recentCollections;
  final Invoice? pendingInvoice;
  final int overdueInvoiceCount;

  const DashboardData({
    required this.client,
    this.nextCollection,
    required this.recentCollections,
    this.pendingInvoice,
    required this.overdueInvoiceCount,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) => DashboardData(
        client: Client.fromJson(json['client'] as Map<String, dynamic>),
        nextCollection: json['next_collection'] != null
            ? Collection.fromJson(json['next_collection'] as Map<String, dynamic>)
            : null,
        recentCollections: (json['recent_collections'] as List<dynamic>)
            .map((e) => Collection.fromJson(e as Map<String, dynamic>))
            .toList(),
        pendingInvoice: json['pending_invoice'] != null
            ? Invoice.fromJson(json['pending_invoice'] as Map<String, dynamic>)
            : null,
        overdueInvoiceCount: (json['overdue_invoice_count'] as num).toInt(),
      );
}
