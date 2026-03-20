import 'package:flutter/material.dart';
import 'package:patungan_plus/models/bill.dart';
import 'package:patungan_plus/models/bill_items.dart';
import 'package:patungan_plus/models/participant.dart';
import 'package:patungan_plus/services/db_helper.dart';

class MainController extends ChangeNotifier {
  final DBHelper _dbHelper = DBHelper();

  // --- STATE ---
  List<BillModel> _transactions = [];
  BillModel? _temporaryBill; // Holds bill before it's finalized with splits

  bool isLoading = true;

  MainController() {
    fetchTransactions();
  }

  List<BillModel> get transactions => List.unmodifiable(_transactions);
  BillModel? get temporaryBill => _temporaryBill;

  /// Store bill temporarily (not in DB yet)
  void setTemporaryBill(BillModel bill) {
    _temporaryBill = bill;
    notifyListeners();
  }

  /// Get the temporary bill
  BillModel? getTemporaryBill() {
    return _temporaryBill;
  }

  /// Clear the temporary bill
  void clearTemporaryBill() {
    _temporaryBill = null;
    notifyListeners();
  }

  Future<int?> createTransaction(
    String merchantName,
    DateTime billDate,
    double totalAmount,
    double taxAmount,
    List<BillItems> items,
  ) async {
    try {
      if (items.isEmpty) return null;
      final billItems = items
          .map(
            (item) => BillItems(
              transactionId: 0,
              itemName: item.itemName,
              quantity: item.quantity,
              price: item.price,
              totalPrice: item.totalPrice,
            ),
          )
          .toList();

      final trx = BillModel(
        date: billDate,
        merchantName: merchantName,
        taxAmount: taxAmount,
        totalAmount: totalAmount,
        items: billItems,
      );
      try {
        final billId = await _dbHelper.insertTransaction(trx, billItems);

        await fetchTransactions();
        return billId;
      } catch (e) {
        print("Bill Processing Error: $e");
        return null;
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Finalize transaction with participant splits
  Future<int?> finalizeTransaction(
    BillModel bill,
    List<Participant> participants,
  ) async {
    try {
      if (bill.items.isEmpty || participants.isEmpty) return null;

      final billId = await _dbHelper.insertTransactionWithSplits(
        bill,
        bill.items,
        participants,
      );

      await fetchTransactions();
      clearTemporaryBill();
      return billId;
    } catch (e) {
      print("Error finalizing transaction: $e");
      return null;
    }
  }

  Future<void> fetchTransactions({
    DateTimeRange? range,
    bool isRefresh = false,
    int limit = 20,
    int offset = 0,
  }) async {
    if (!isRefresh) {
      isLoading = true;
      notifyListeners();
    }
    try {
      _transactions = await _dbHelper.getTransactions(
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      print("Error fetching transactions: $e");
    } finally {
      if (!isRefresh) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<BillModel?> getTransactionById(int id) async {
    try {
      return await _dbHelper.getTransactionById(id);
    } catch (e) {
      print("Error fetching transaction by id: $e");
      return null;
    }
  }

  Future<List<Participant>> getParticipantsForBill(int billId) async {
    try {
      return await _dbHelper.getParticipantsByTransactionId(billId);
    } catch (e) {
      print("Error fetching participants: $e");
      return [];
    }
  }
}
