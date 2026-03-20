import 'package:flutter/material.dart';
import 'package:patungan_plus/models/bill.dart';
import 'package:patungan_plus/models/bill_items.dart';
import 'package:patungan_plus/providers/main_controller.dart';
import 'package:provider/provider.dart';

class ItemController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController qtyController = TextEditingController(text: '1');
  final TextEditingController priceController = TextEditingController();
  final TextEditingController discountController = TextEditingController(
    text: '0',
  );
  final UniqueKey id = UniqueKey();

  ItemController({
    String name = '',
    int qty = 1,
    double price = 0,
    double discount = 0,
  }) {
    nameController.text = name;
    qtyController.text = qty.toString();
    priceController.text = price > 0 ? price.toStringAsFixed(0) : '';
    discountController.text = discount.toStringAsFixed(0);
  }

  double get price => double.tryParse(priceController.text) ?? 0;
  int get quantity => int.tryParse(qtyController.text) ?? 0;
  double get discount => double.tryParse(discountController.text) ?? 0;
  double get total => (price * quantity) - discount;
}

class InputBillScreen extends StatefulWidget {
  const InputBillScreen({super.key});

  @override
  State<StatefulWidget> createState() => _InputBillScreenState();
}

class _InputBillScreenState extends State<InputBillScreen> {
  double billTotal = 0;
  bool _isInitialized = false; // Flag to prevent re-initializing on rebuilds

  final TextEditingController _billTitleController = TextEditingController(
    text: "New Bill",
  );
  final TextEditingController _dateController = TextEditingController();

  final TextEditingController _overallDiscountController =
      TextEditingController(text: '0');
  final TextEditingController _serviceChargeController = TextEditingController(
    text: '0',
  );
  final TextEditingController _taxController = TextEditingController(text: '0');
  final TextEditingController _othersController = TextEditingController(
    text: '0',
  );

  final List<ItemController> _items = [];

  @override
  void initState() {
    super.initState();
    _dateController.text = DateTime.now().toIso8601String();

    _overallDiscountController.addListener(_calculateTotal);
    _serviceChargeController.addListener(_calculateTotal);
    _taxController.addListener(_calculateTotal);
    _othersController.addListener(_calculateTotal);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Parse arguments from OCR if they exist
    if (!_isInitialized) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args != null) {
        if (args['merchantName'] != null) {
          _billTitleController.text = args['merchantName'];
        }

        // Setup totals
        if (args['tax'] != null && args['tax'] > 0) {
          _taxController.text = (args['tax'] as double).toStringAsFixed(0);
        }
        if (args['serviceCharge'] != null && args['serviceCharge'] > 0) {
          _serviceChargeController.text = (args['serviceCharge'] as double)
              .toStringAsFixed(0);
        }
        if (args['discount'] != null && args['discount'] > 0) {
          _overallDiscountController.text = (args['discount'] as double)
              .toStringAsFixed(0);
        }

        // Setup items list
        if (args['items'] != null) {
          _items.clear();
          final List<Map<String, dynamic>> scannedItems = args['items'];
          for (var itemData in scannedItems) {
            final newItem = ItemController(
              name: itemData['name'] ?? '',
              qty: itemData['qty'] ?? 1,
              price: itemData['price'] ?? 0,
            );
            newItem.qtyController.addListener(_calculateTotal);
            newItem.priceController.addListener(_calculateTotal);
            newItem.discountController.addListener(_calculateTotal);
            _items.add(newItem);
          }
        }
      }
      _isInitialized = true;

      // Compute total with OCR data
      // use Future.microtask to prevent setState during build phase
      Future.microtask(() => _calculateTotal());
    }
  }

  @override
  void dispose() {
    _billTitleController.dispose();
    _dateController.dispose();
    _overallDiscountController.dispose();
    _serviceChargeController.dispose();
    _taxController.dispose();
    _othersController.dispose();
    for (var item in _items) {
      item.nameController.dispose();
      item.qtyController.dispose();
      item.priceController.dispose();
      item.discountController.dispose();
    }
    super.dispose();
  }

  void _calculateTotal() {
    double itemsTotal = 0;
    for (var item in _items) {
      itemsTotal += item.total;
    }

    final discount = double.tryParse(_overallDiscountController.text) ?? 0;
    final service = double.tryParse(_serviceChargeController.text) ?? 0;
    final tax = double.tryParse(_taxController.text) ?? 0;
    final others = double.tryParse(_othersController.text) ?? 0;

    setState(() {
      billTotal = itemsTotal + service + tax + others - discount;
    });
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _dateController.text = pickedDate.toString();
      });
    }
  }

  void _addNewItem() {
    setState(() {
      final newItem = ItemController();
      newItem.qtyController.addListener(_calculateTotal);
      newItem.priceController.addListener(_calculateTotal);
      newItem.discountController.addListener(_calculateTotal);
      _items.add(newItem);
    });
    _calculateTotal();
  }

  void _removeItem(UniqueKey id) {
    setState(() {
      final itemToRemove = _items.firstWhere((item) => item.id == id);
      itemToRemove.qtyController.removeListener(_calculateTotal);
      itemToRemove.priceController.removeListener(_calculateTotal);
      itemToRemove.discountController.removeListener(_calculateTotal);
      _items.removeWhere((item) => item.id == id);
    });
    _calculateTotal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Edit Bill Details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Verify Scanned Data',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Make sure to check that all items were read correctly from the receipt.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // --- Bill Info Section ---
            _buildBillInfoSection(),
            const Divider(height: 32),

            // --- Items List Section ---
            if (_items.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text(
                  "No items detected. Please add them manually.",
                  style: TextStyle(color: Colors.orange),
                ),
              ),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return _itemInputRow(
                  _items[index].id,
                  _items[index],
                  () => _removeItem(_items[index].id),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildAddItemButton(),
            const Divider(height: 32),

            // // --- Summary Section ---
            _buildSummaryRow(
              'Discount',
              _overallDiscountController,
              isDiscount: true,
            ),
            _buildSummaryRow('Service Charge', _serviceChargeController),
            _buildSummaryRow('Tax', _taxController),
            _buildSummaryRow('Others', _othersController),
            const Divider(height: 32),

            // // --- Grand Total Section ---
            _buildGrandTotalRow(),
          ],
        ),
      ),
      bottomNavigationBar: _buildNavigationBar(),
    );
  }

  Widget _buildBillInfoSection() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextFormField(
            controller: _dateController,
            decoration: const InputDecoration(border: InputBorder.none),
            readOnly: true,
            onTap: _selectDate,
          ),
        ),
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: _billTitleController,
            textAlign: TextAlign.end,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Merchant Name',
            ),
          ),
        ),
      ],
    );
  }

  Widget _itemInputRow(key, ItemController item, onRemove) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 4,
                child: TextFormField(
                  controller: item.nameController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Item Name',
                  ),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  item.total.toStringAsFixed(0),
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: onRemove,
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: item.priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Price',
                  ),
                ),
              ),
              const Text('x'),
              Expanded(
                flex: 1,
                child: TextFormField(
                  controller: item.qtyController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '1',
                  ),
                ),
              ),
              const Text('Discount'),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: item.discountController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.end,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '0',
                    prefixText: '- ',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddItemButton() {
    return TextButton.icon(
      onPressed: _addNewItem,
      icon: const Icon(Icons.add, color: Colors.green),
      label: const Text(
        'Add Missing Item',
        style: TextStyle(color: Colors.green),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    TextEditingController controller, {
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            isDiscount ? Icons.remove : Icons.add,
            color: Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
          SizedBox(
            width: 100,
            child: TextFormField(
              controller: controller,
              textAlign: TextAlign.end,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '0',
                prefixText: isDiscount ? '- ' : '',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrandTotalRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'Rp ${billTotal.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () async {
            // Validate inputs
            if (_items.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please add at least one item')),
              );
              return;
            }

            if (_billTitleController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a merchant name')),
              );
              return;
            }

            try {
              // Convert ItemController list to BillItems list
              final billItems = _items
                  .map(
                    (item) => BillItems(
                      transactionId: 0, // Will be set when finalized
                      itemName: item.nameController.text.trim(),
                      quantity: item.quantity,
                      price: item.price,
                      totalPrice: item.total,
                    ),
                  )
                  .toList();

              final taxAmount = double.tryParse(_taxController.text) ?? 0;
              final dateToSave =
                  DateTime.tryParse(_dateController.text) ?? DateTime.now();

              // Create temporary bill
              final bill = BillModel(
                date: dateToSave,
                merchantName: _billTitleController.text.trim(),
                taxAmount: taxAmount,
                totalAmount: billTotal,
                items: billItems,
              );

              // Store temporarily in controller
              Provider.of<MainController>(
                context,
                listen: false,
              ).setTemporaryBill(bill);

              // Navigate to split screen
              Navigator.of(context).pushNamed('detail-split-bill');
            } catch (e) {
              print(e.toString());
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Review & Split',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
