class BillItems {
  final int? id; // Auto-increment ID
  final int transactionId;
  final String itemName; // Snapshot name
  final int quantity;
  final double price; // Snapshot price
  final double totalPrice;

  BillItems({
    this.id,
    required this.transactionId,
    required this.itemName,
    required this.quantity,
    required this.price,
    required this.totalPrice,
  });

  // Convert for DB Insertion
  Map<String, dynamic> toMap() {
    return {
      'transaction_id': transactionId,
      'item_name': itemName,
      'quantity': quantity,
      'price': price,
      'total_price': totalPrice,
    };
  }

  factory BillItems.fromMap(Map<String, dynamic> map) {
    return BillItems(
      id: map['id'] as int?,
      transactionId: map['transaction_id'] as int,
      itemName: map['item_name'] as String,
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'] as int,
      totalPrice: (map['total_price'] as num).toDouble(),
    );
  }
}
