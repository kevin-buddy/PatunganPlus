import 'package:patungan_plus/models/bill.dart';
import 'package:patungan_plus/models/bill_items.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'patunganplus.db');
    return await openDatabase(
      path,
      version: 1, // Incremented for new tables
      // onUpgrade: (db, oldVersion, newVersion) async {
      //   if (oldVersion < 2) {
      //     await db.execute('''
      //       CREATE TABLE restocks(
      //         id INTEGER PRIMARY KEY AUTOINCREMENT,
      //         created_at TEXT
      //       )
      //     ''');
      //     await db.execute('''
      //       CREATE TABLE restock_items(
      //         id INTEGER PRIMARY KEY AUTOINCREMENT,
      //         restock_id INTEGER,
      //         product_id TEXT,
      //         product_name TEXT,
      //         quantity INTEGER,
      //         FOREIGN KEY(restock_id) REFERENCES restocks(id),
      //         FOREIGN KEY(product_id) REFERENCES products(id)
      //       )
      //     ''');
      //   }
      // },
      onCreate: (db, version) async {
        // 2. Transaction Header Table
        await db.execute('''
          CREATE TABLE transactions(
            id TEXT PRIMARY KEY,
            date TEXT,
            totalAmount REAL
          )
        ''');

        // 3. Transaction Items Table (Foreign Key to Transactions)
        await db.execute('''
          CREATE TABLE transaction_items(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            transaction_id TEXT,
            product_id TEXT,
            product_name TEXT,
            price REAL,
            quantity INTEGER,
            addons_snapshot TEXT,
            FOREIGN KEY(transaction_id) REFERENCES transactions(id)
          )
        ''');
      },
    );
  }

  Future<void> resetDB() async {
    String path = join(await getDatabasesPath(), 'posca.db');
    await deleteDatabase(path);
  }

  // --- COMPLEX INSERT: Transaction + Items ---
  Future<void> insertTransaction(
    BillModel trx,
    List<BillItems> cartItems,
  ) async {
    final db = await database;

    // Use a transaction block to ensure all or nothing
    await db.transaction((txn) async {
      // 1. Insert Header
      await txn.insert('transactions', trx.toMap());

      // 2. Insert Items & Update Stock
      for (var item in cartItems) {
        // Create TransactionItem from CartItem
        final trxItem = BillItems(
          billId: trx.id,
          itemName: item.itemName,
          price: item.price,
          quantity: item.quantity,
          discount: item.discount,
        );

        await txn.insert('transaction_items', trxItem.toMap());
      }
    });
  }

  // --- COMPLEX FETCH: Header + Items ---
  Future<List<BillModel>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;
    String whereClause = '1=1'; // Always true condition to append ANDs
    List<dynamic> args = [];

    if (startDate != null) {
      whereClause += ' AND date >= ?';
      args.add(startDate.toIso8601String());
    }
    if (endDate != null) {
      whereClause += ' AND date <= ?';
      args.add(endDate.toIso8601String());
    }
    // 1. Get all headers
    final List<Map<String, dynamic>> trxMaps = await db.query(
      'transactions',
      where: whereClause,
      whereArgs: args,
      orderBy: "date DESC",
    );

    List<BillModel> transactions = [];

    for (var map in trxMaps) {
      final trxId = map['id'];

      // 2. Get items for this transaction
      final List<Map<String, dynamic>> itemMaps = await db.query(
        'transaction_items',
        where: 'transaction_id = ?',
        whereArgs: [trxId],
      );

      final items = List.generate(
        itemMaps.length,
        (i) => BillItems.fromMap(itemMaps[i]),
      );

      transactions.add(BillModel.fromMap(map, items: items));
    }

    return transactions;
  }
}
