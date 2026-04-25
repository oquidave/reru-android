class Collection {
  final String id;
  final String clientId;
  final String scheduledDate;
  final String status;
  final int? bagsCollected;
  final String? notes;
  final String? completedAt;
  final String createdAt;

  const Collection({
    required this.id,
    required this.clientId,
    required this.scheduledDate,
    required this.status,
    this.bagsCollected,
    this.notes,
    this.completedAt,
    required this.createdAt,
  });

  factory Collection.fromJson(Map<String, dynamic> json) => Collection(
        id: json['id'] as String,
        clientId: json['client_id'] as String,
        scheduledDate: json['scheduled_date'] as String,
        status: json['status'] as String,
        bagsCollected: json['bags_collected'] as int?,
        notes: json['notes'] as String?,
        completedAt: json['completed_at'] as String?,
        createdAt: json['created_at'] as String,
      );

  bool get isScheduled  => status == 'scheduled';
  bool get isCompleted  => status == 'completed';
  bool get isMissed     => status == 'missed';

  DateTime get scheduledDateTime => DateTime.parse(scheduledDate);
}
