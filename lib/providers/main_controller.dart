import 'package:flutter/material.dart';
import 'package:patungan_plus/models/bill.dart';
import 'package:patungan_plus/services/db_helper.dart';

class MainController extends ChangeNotifier {
  // final ApiService _apiService = ApiService();
  final DBHelper _dbHelper = DBHelper();

  // --- STATE ---
  List<BillModel> _transactions = [];

  bool isLoading = true;

  MainController() {
    fetchTransactions();
  }
  List<BillModel> get transactions => List.unmodifiable(_transactions);
  // NEW: Dedicated method for fetching transactions with filters
  Future<void> fetchTransactions({
    DateTimeRange? range,
    bool isRefresh = false,
  }) async {
    // Only update loading if called directly (not from refreshData which handles its own loading)
    if (!isRefresh) {
      isLoading = true;
      // notifyListeners();
    }
    try {
      DateTime? start = range?.start;
      DateTime? end = range?.end;

      // Ensure end date covers the full day
      if (end != null) {
        end = DateTime(end.year, end.month, end.day, 23, 59, 59);
      }

      _transactions = await _dbHelper.getTransactions(
        startDate: start,
        endDate: end,
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
}
