import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:patungan_plus/providers/main_controller.dart';
import 'package:patungan_plus/models/bill.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  int tabActive = 0; // 0 for Active, 1 for History
  bool _isProcessingOCR = false;

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Scan Receipt',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.green),
                title: const Text('Take a Picture'),
                onTap: () {
                  Navigator.pop(context);
                  _processReceiptImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _processReceiptImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _processReceiptImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) return;

    setState(() {
      _isProcessingOCR = true;
    });

    try {
      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );

      String extractedText = recognizedText.text;
      await textRecognizer.close();

      // Parse the raw text into receipt data
      Map<String, dynamic> receiptData = _parseReceiptText(extractedText);

      // Clear any temporary bill before creating a new one
      if (mounted) {
        Provider.of<MainController>(
          context,
          listen: false,
        ).clearTemporaryBill();
        Navigator.of(context).pushNamed('input-bill', arguments: receiptData);
      }
    } catch (e) {
      print("OCR Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to read receipt text.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingOCR = false;
        });
      }
    }
  }

  /// A basic heuristic parser to extract receipt data from raw OCR text
  Map<String, dynamic> _parseReceiptText(String text) {
    final lines = text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // Assume the first or second line is the Merchant Name
    String merchantName = lines.isNotEmpty ? lines[0] : "Scanned Bill";
    if (merchantName.toLowerCase().contains('jl') ||
        merchantName.toLowerCase().contains('pt')) {
      // If first line looks like an address/company, check others, but stick to first line as fallback
    }

    List<Map<String, dynamic>> items = [];
    double taxAmount = 0;
    double serviceCharge = 0;
    double discount = 0;
    String? detectedDate;

    // Matches numbers that look like Indonesian prices: 25.000, 25,000, 150000
    final priceRegex = RegExp(
      r'(?:Rp)?\s*(\d{1,3}(?:[.,]\d{3})*(?:[.,]\d+)?)$',
    );
    final dateRegex = RegExp(r'\d{1,2}[-/]\d{1,2}[-/]\d{2,4}');

    for (var line in lines) {
      final lowerLine = line.toLowerCase();

      // Look for dates
      if (detectedDate == null) {
        final dateMatch = dateRegex.firstMatch(line);
        if (dateMatch != null) detectedDate = dateMatch.group(0);
      }

      final match = priceRegex.firstMatch(line);

      if (match != null) {
        // Clean up the price string to parse it to a double
        String priceStr = match
            .group(1)!
            .replaceAll(',', '')
            .replaceAll('.', '');
        double price = double.tryParse(priceStr) ?? 0;

        // The item name is usually whatever comes before the price
        String namePart = line.substring(0, match.start).trim();

        if (lowerLine.contains('total') && !lowerLine.contains('sub')) {
          // Skip total lines for items list
        } else if (lowerLine.contains('tax') ||
            lowerLine.contains('pajak') ||
            lowerLine.contains('pb1') ||
            lowerLine.contains('ppn')) {
          taxAmount = price;
        } else if (lowerLine.contains('service') ||
            lowerLine.contains('layanan')) {
          serviceCharge = price;
        } else if (lowerLine.contains('discount') ||
            lowerLine.contains('diskon')) {
          discount = price;
        } else if (namePart.isNotEmpty && price > 0 && namePart.length > 2) {
          // Assume it's an item if it has a valid name and price
          int qty = 1;
          // Check if it starts with a quantity pattern like "2 x Nasi" or "2 Nasi"
          final qtyRegex = RegExp(r'^(\d+)\s*[xX]?\s+(.*)');
          final qtyMatch = qtyRegex.firstMatch(namePart);

          if (qtyMatch != null) {
            qty = int.tryParse(qtyMatch.group(1)!) ?? 1;
            namePart = qtyMatch.group(2)!.trim();
            // Often receipts show the total row price. If so, single item price is total/qty
            price = price / qty;
          }

          // Filter out random short strings that might be noise
          if (namePart.length > 2) {
            items.add({'name': namePart, 'qty': qty, 'price': price});
          }
        }
      }
    }

    return {
      'merchantName': merchantName,
      'date': detectedDate, // Could be null, input screen will handle it
      'items': items,
      'tax': taxAmount,
      'serviceCharge': serviceCharge,
      'discount': discount,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Split Bill')),
      body: Stack(
        children: [
          Consumer<MainController>(
            builder: (context, controller, child) {
              final transactions = controller.transactions;

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              tabActive = 0;
                            });
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: tabActive == 0
                                ? Colors.grey[200]
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Active',
                            style: TextStyle(color: Color(0xFF007AFF)),
                          ),
                        ),
                      ),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              tabActive = 1;
                            });
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: tabActive == 1
                                ? Colors.grey[200]
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'History',
                            style: TextStyle(color: Color(0xFF007AFF)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      controller.isLoading
                          ? 'LOADING DATA...'
                          : 'YOU HAVE ${transactions.length} SAVED BILLS',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    child: controller.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            padding: const EdgeInsets.all(8.0),
                            itemCount: transactions.length,
                            itemBuilder: (context, index) {
                              return buildBillCard(transactions[index]);
                            },
                          ),
                  ),
                ],
              );
            },
          ),

          // Loading Overlay for OCR
          if (_isProcessingOCR)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.green),
                        SizedBox(height: 16),
                        Text(
                          'Scanning Receipt...',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Ensure there's no temp bill lingering when trying to create a new manual bill
          Provider.of<MainController>(
            context,
            listen: false,
          ).clearTemporaryBill();
          Navigator.of(context).pushNamed('input-bill');
        },
        shape: const CircleBorder(),
        backgroundColor: const Color.fromARGB(255, 71, 216, 78),
        tooltip: 'Manual Input',
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      bottomNavigationBar: _buildNavigationBar(),
    );
  }

  Widget buildBillCard(BillModel bill) {
    String dateStr = "${bill.date.day}/${bill.date.month}/${bill.date.year}";

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.grey, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bill.merchantName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Rp ${bill.totalAmount.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${bill.items.length} items',
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        'detail-split-bill',
                        arguments: {'id': bill.id},
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007AFF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text('See Detail'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.document_scanner),
          onPressed: _showImageSourceDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          label: const Text(
            'Scan Receipt',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
