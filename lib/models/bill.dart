import 'bill_items.dart';

class BillModel {
  final String id;
  final DateTime date;
  final List<BillItems> items;
  final double totalAmount;

  BillModel({
    required this.id,
    required this.date,
    this.items = const [],
    required this.totalAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'totalAmount': totalAmount,
    };
  }

  factory BillModel.fromMap(
    Map<String, dynamic> map, {
    List<BillItems> items = const [],
  }) {
    return BillModel(
      id: map['id'].toString(),
      date: DateTime.parse(map['date'] ?? map['created_at']),
      totalAmount: (map['totalAmount'] ?? map['totalamount'] as num).toDouble(),
      items: items,
    );
  }
}
