import 'bill_items.dart';

class BillModel {
  final int? id;
  final DateTime date;
  final String merchantName;
  final double taxAmount;
  final List<BillItems> items;
  final double totalAmount;

  BillModel({
    this.id,
    required this.date,
    required this.merchantName,
    required this.taxAmount,
    this.items = const [],
    required this.totalAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'created_at': date.toIso8601String(),
      'merchant_name': merchantName,
      'tax_amount': taxAmount,
      'total_amount': totalAmount,
    };
  }

  factory BillModel.fromMap(
    Map<String, dynamic> map, {
    List<BillItems> items = const [],
  }) {
    return BillModel(
      id: map['id'],
      date: DateTime.parse(map['created_at']),
      merchantName: map['merchant_name'] as String,
      taxAmount: (map['tax_amount'] as num).toDouble(),
      totalAmount: (map['total_amount'] as num).toDouble(),
      items: items,
    );
  }
}
