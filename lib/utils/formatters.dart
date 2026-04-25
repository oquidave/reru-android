import 'package:intl/intl.dart';

String formatCurrency(int ugx) {
  final formatter = NumberFormat('#,###', 'en_UG');
  return 'UGX ${formatter.format(ugx)}';
}

String formatDate(String isoDate) {
  final date = DateTime.parse(isoDate);
  return DateFormat('d MMM yyyy').format(date);
}

String formatDayOfWeek(String isoDate) {
  final date = DateTime.parse(isoDate);
  return DateFormat('EEEE, d MMM').format(date);
}

String daysUntil(String isoDate) {
  final date = DateTime.parse(isoDate);
  final today = DateTime.now();
  final diff = date.difference(DateTime(today.year, today.month, today.day)).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Tomorrow';
  return 'In $diff days';
}
