import 'package:flutter/material.dart';

List<Map<String, dynamic>> detailSplitBill = [
  {
    "id": 1,
    "title": "Mala Jia",
    "date": DateTime.now(),
    "total": 123456,
    "members": [
      {"name": "Budi", "email": "", "phone": "08123456789"},
      {"name": "Hans", "email": "", "phone": "08123456789"},
    ],
    "items": [
      {"name": "Hot Pot", "qty": 2, "amount": 123000},
      {"name": "Minum", "qty": 2, "amount": 456},
    ],
  },
];

class DetailSplitBillScreen extends StatelessWidget {
  const DetailSplitBillScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{})
            as Map;
    return Scaffold(
      appBar: AppBar(title: const Text('Split Bill')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // buildBillHeader(bill: bill),
              const SizedBox(height: 24),
              // _ParticipantsSection(participants: bill.participants),
              const SizedBox(height: 16),
              const Divider(thickness: 4, color: Color(0xFFF5F5F5)),
              const SizedBox(height: 16),
              // _SplitResultSection(participants: bill.participants),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBillHeader(
    billTitle,
    billdate,
    billMembers,
    billTotal,
    billItems,
  ) {
    // final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'IDR ', decimalDigits: 0);
    // final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    return Card(
      elevation: 1,
      // shadowColor: Colors.black12,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.grey, width: 0.5),
      ),
      // color: Colors.black,
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
                      billTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      billdate.toString(),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                // --- Participant Avatars (dummy representation) ---
                Row(
                  children: List.generate(
                    billMembers.length.clamp(0, 3), // Show max 3 avatars
                    (index) => const Padding(
                      padding: EdgeInsets.only(left: 4.0),
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.brown, // Placeholder color
                        child: Icon(
                          Icons.person,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              billTotal.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${billItems.length} items - ${billMembers.length} persons',
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {},
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
}
