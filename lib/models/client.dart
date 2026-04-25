class Client {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final String address;
  final String zone;
  final String collectionDay;
  final String plan;
  final String status;
  final String? paidThrough;
  final String createdAt;

  const Client({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.address,
    required this.zone,
    required this.collectionDay,
    required this.plan,
    required this.status,
    this.paidThrough,
    required this.createdAt,
  });

  factory Client.fromJson(Map<String, dynamic> json) => Client(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String,
        address: json['address'] as String,
        zone: json['zone'] as String,
        collectionDay: json['collection_day'] as String,
        plan: json['plan'] as String,
        status: json['status'] as String,
        paidThrough: json['paid_through'] as String?,
        createdAt: json['created_at'] as String,
      );

  bool get isActive => status == 'active';
  bool get isSuspended => status == 'suspended';
}
