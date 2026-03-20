import 'package:patungan_plus/models/bill.dart';
import 'package:patungan_plus/models/bill_items.dart';
import 'package:patungan_plus/models/participant.dart';
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
      version: 1,
      onCreate: (db, version) async {
        // 1. Transaction Header Table
        await db.execute('''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            created_at TEXT,
            merchant_name TEXT,
            tax_amount REAL,
            total_amount REAL
          )
        ''');

        // 2. Transaction Items Table (Foreign Key to Transactions)
        await db.execute('''
          CREATE TABLE transaction_items(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            transaction_id INTEGER,
            item_name TEXT,
            quantity INTEGER,
            price REAL,
            total_price REAL,
            FOREIGN KEY(transaction_id) REFERENCES transactions(id)
          )
        ''');

        // 3. Items Split Table (Foreign Key to Transaction Items)
        await db.execute('''
          CREATE TABLE item_splits(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            transaction_items_id INTEGER,
            participant_uuid TEXT,
            participant_name TEXT,
            shares INTEGER,
            FOREIGN KEY(transaction_items_id) REFERENCES transaction_items(id)
          )
        ''');
      },
    );
  }

  Future<void> resetDB() async {
    String path = join(await getDatabasesPath(), 'patunganplus.db');
    await deleteDatabase(path);
  }

  // --- COMPLEX INSERT: Transaction + Items ---
  Future<int> insertTransaction(
    BillModel trx,
    List<BillItems> cartItems,
  ) async {
    final db = await database;
    int trxId = 0;

    await db.transaction((txn) async {
      trxId = await txn.insert('transactions', trx.toMap());

      for (var item in cartItems) {
        final trxItem = BillItems(
          transactionId: trxId,
          itemName: item.itemName,
          price: item.price,
          quantity: item.quantity,
          totalPrice: item.totalPrice,
        );
        await txn.insert('transaction_items', trxItem.toMap());
      }
    });

    return trxId;
  }

  // --- COMPLEX FETCH: Header + Items ---
  Future<List<BillModel>> getTransactions({
    int limit = 20,
    int offset = 0,
  }) async {
    final db = await database;
    final List<Map<String, dynamic>> trxMaps = await db.query(
      'transactions',
      limit: limit,
      offset: offset,
      orderBy: "created_at DESC",
    );

    List<BillModel> transactions = [];

    for (var map in trxMaps) {
      final trxId = map['id'];

      final List<Map<String, dynamic>> itemMaps = await db.query(
        'transaction_items',
        where: 'transaction_id = ?',
        whereArgs: [trxId],
        orderBy: 'id ASC',
      );

      final items = List.generate(
        itemMaps.length,
        (i) => BillItems.fromMap(itemMaps[i]),
      );

      transactions.add(BillModel.fromMap(map, items: items));
    }

    return transactions;
  }

  // --- FETCH: Single Transaction by ID ---
  Future<BillModel?> getTransactionById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> trxMaps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (trxMaps.isEmpty) return null;

    final map = trxMaps.first;
    final trxId = map['id'];

    final List<Map<String, dynamic>> itemMaps = await db.query(
      'transaction_items',
      where: 'transaction_id = ?',
      whereArgs: [trxId],
      orderBy: 'id ASC',
    );

    final items = List.generate(
      itemMaps.length,
      (i) => BillItems.fromMap(itemMaps[i]),
    );

    return BillModel.fromMap(map, items: items);
  }

  // --- FETCH: Participants for a specific transaction ---
  Future<List<Participant>> getParticipantsByTransactionId(int trxId) async {
    final db = await database;

    // Get items to map their consistent sequence index
    final List<Map<String, dynamic>> itemMaps = await db.query(
      'transaction_items',
      where: 'transaction_id = ?',
      whereArgs: [trxId],
      orderBy: 'id ASC',
    );

    Map<String, Participant> pMap = {};

    for (int i = 0; i < itemMaps.length; i++) {
      final itemId = itemMaps[i]['id'];

      final List<Map<String, dynamic>> splitMaps = await db.query(
        'item_splits',
        where: 'transaction_items_id = ?',
        whereArgs: [itemId],
      );

      for (var split in splitMaps) {
        String pId = split['participant_uuid'] as String;
        String pName = split['participant_name'] as String;

        if (!pMap.containsKey(pId)) {
          pMap[pId] = Participant(id: pId, name: pName, assignedItems: []);
        }

        // Add index to assigned items to reconstruct the logic
        pMap[pId]!.assignedItems.add(i);
      }
    }

    return pMap.values.toList();
  }

  // --- COMPLEX INSERT: Transaction + Items + Participant Splits ---
  Future<int> insertTransactionWithSplits(
    BillModel trx,
    List<BillItems> items,
    List<Participant> participants,
  ) async {
    final db = await database;
    int trxId = 0;

    await db.transaction((txn) async {
      trxId = await txn.insert('transactions', trx.toMap());

      for (int i = 0; i < items.length; i++) {
        var item = items[i];

        final trxItem = BillItems(
          transactionId: trxId,
          itemName: item.itemName,
          price: item.price,
          quantity: item.quantity,
          totalPrice: item.totalPrice,
        );

        int itemId = await txn.insert('transaction_items', trxItem.toMap());

        // Insert Participant Splits mapped to this specific item index
        for (var participant in participants) {
          if (participant.assignedItems.contains(i)) {
            await txn.insert('item_splits', {
              'transaction_items_id': itemId,
              'participant_uuid': participant.id,
              'participant_name': participant.name,
              'shares': 1,
            });
          }
        }
      }
    });

    return trxId;
  }
}
