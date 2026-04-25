class Invoice {
  final String id;
  final String clientId;
  final String date;
  final String plan;
  final int qty;
  final int unitPrice;
  final int subtotal;
  final int tax;
  final int total;
  final String status;
  final String? paidAt;
  final String? paymentMethod;
  final String? paymentRef;
  final String createdAt;

  const Invoice({
    required this.id,
    required this.clientId,
    required this.date,
    required this.plan,
    required this.qty,
    required this.unitPrice,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.status,
    this.paidAt,
    this.paymentMethod,
    this.paymentRef,
    required this.createdAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
        id: json['id'] as String,
        clientId: json['client_id'] as String,
        date: json['date'] as String,
        plan: json['plan'] as String,
        qty: (json['qty'] as num).toInt(),
        unitPrice: (json['unit_price'] as num).toInt(),
        subtotal: (json['subtotal'] as num).toInt(),
        tax: (json['tax'] as num).toInt(),
        total: (json['total'] as num).toInt(),
        status: json['status'] as String,
        paidAt: json['paid_at'] as String?,
        paymentMethod: json['payment_method'] as String?,
        paymentRef: json['payment_ref'] as String?,
        createdAt: json['created_at'] as String,
      );

  bool get isPaid    => status == 'paid';
  bool get isPending => status == 'pending';
  bool get isOverdue => status == 'overdue';
}
