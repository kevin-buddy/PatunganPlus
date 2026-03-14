import 'package:flutter/material.dart';

class BillItem {
  // Controllers to manage the text fields for this specific item
  final TextEditingController nameController = TextEditingController();
  final TextEditingController qtyController = TextEditingController(text: '1');
  final TextEditingController priceController = TextEditingController();
  final TextEditingController discountController = TextEditingController(
    text: '0',
  );
  // A unique key to help Flutter identify this specific widget in the list
  final UniqueKey id = UniqueKey();

  BillItem({
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

  // Helper getters to safely parse numbers from controllers
  double get price => double.tryParse(priceController.text) ?? 0;
  int get quantity => int.tryParse(qtyController.text) ?? 0;
  double get discount => double.tryParse(discountController.text) ?? 0;

  // Calculate the total for this single item
  double get total => (price * quantity) - discount;
}

int cartCounter = 0;
String counterCart = '';
int tabActive = 0;
List<Map<String, dynamic>> activeSplitBill = [
  {
    "id": 1,
    "title": "Grab",
    "date": DateTime.now(),
    "total": 123456,
    "members": [
      {"name": "Budi", "email": "", "total": "123456"},
      {"name": "Hans", "email": "", "total": "123456"},
    ],
  },
];

class InputBillScreen extends StatefulWidget {
  const InputBillScreen({super.key});

  @override
  State<StatefulWidget> createState() => _InputBillScreenState();
}

class _InputBillScreenState extends State<InputBillScreen> {
  int billId = 1;
  double billTotal = 0;
  final TextEditingController _billTitleController = TextEditingController(
    text: "Windy's",
  );
  final TextEditingController _dateController = TextEditingController();

  // Controllers for the summary fields
  final TextEditingController _overallDiscountController =
      TextEditingController(text: '0');
  final TextEditingController _serviceChargeController = TextEditingController(
    text: '0',
  );
  final TextEditingController _taxController = TextEditingController(text: '0');
  final TextEditingController _othersController = TextEditingController(
    text: '0',
  );

  final List<BillItem> _items = [];

  @override
  void initState() {
    super.initState();
    // Set initial date
    // _dateController.text = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    // // Add some initial items to match the screenshot
    // _addInitialItems();

    // // Add listeners to all controllers to recalculate the total on any change
    _overallDiscountController.addListener(_calculateTotal);
    _serviceChargeController.addListener(_calculateTotal);
    _taxController.addListener(_calculateTotal);
    _othersController.addListener(_calculateTotal);
  }

  @override
  void dispose() {
    // Clean up all controllers to prevent memory leaks
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
        // For simplicity, we keep the time as current time when date is picked
        _dateController.text = pickedDate.toString();
      });
    }
  }

  void _addNewItem() {
    setState(() {
      final newItem = BillItem();
      // Add listeners for the new item
      newItem.qtyController.addListener(_calculateTotal);
      newItem.priceController.addListener(_calculateTotal);
      newItem.discountController.addListener(_calculateTotal);
      _items.add(newItem);
    });
    _calculateTotal();
  }

  void _removeItem(UniqueKey id) {
    setState(() {
      // Find the item to remove
      final itemToRemove = _items.firstWhere((item) => item.id == id);
      // Clean up its listeners before removing
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
          'New Bill',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Split Bill',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Make sure to check that all items were read correctly',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // --- Bill Info Section ---
            _buildBillInfoSection(),
            const Divider(height: 32),

            // --- Items List Section ---
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
              hintText: 'Bill Title',
            ),
          ),
        ),
      ],
    );
  }

  Widget _itemInputRow(key, item, onRemove) {
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
                  item.total.toString(),
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz, color: Colors.grey),
                onPressed: onRemove, // Simple action: remove on tap
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
      label: const Text('Add More Item', style: TextStyle(color: Colors.green)),
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
            isDiscount ? Icons.close : Icons.add,
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
            billTotal.toString(),
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
          onPressed: () {
            Navigator.of(
              context,
            ).pushNamed('detail-split-bill', arguments: {'id': billId});
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Next',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
