class BillItems {
  final int? id; // Auto-increment ID
  final String billId;
  final String itemName; // Snapshot name
  final int quantity;
  final double price; // Snapshot price
  final double discount;

  BillItems({
    this.id,
    required this.billId,
    required this.itemName,
    required this.quantity,
    required this.price,
    required this.discount,
  });

  // Convert for DB Insertion
  Map<String, dynamic> toMap() {
    return {
      'bill_id': billId,
      'item_name': itemName,
      'quantity': quantity,
      'price': price,
      'discount': discount,
    };
  }

  factory BillItems.fromMap(Map<String, dynamic> map) {
    return BillItems(
      id: map['id'] as int?,
      billId: map['bill_id'].toString(),
      itemName: map['item_name'] as String,
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'] as int,
      discount: (map['discount'] as num).toDouble(),
    );
  }
}
