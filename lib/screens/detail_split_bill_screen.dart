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
              buildBillHeader(
                args['title'],
                args['date'],
                args['members'],
                args['total'],
              ),
              const SizedBox(height: 24),
              buildParticipantsSection(args['members']),
              const SizedBox(height: 16),
              const Divider(thickness: 4, color: Color(0xFFF5F5F5)),
              const SizedBox(height: 16),
              buildSplitResultSection(args['members']),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBillHeader(billTitle, billDate, billMembers, billTotal) {
    // final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'IDR ', decimalDigits: 0);
    // final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Bill detail', style: TextStyle(color: Colors.grey)),
            IconButton(
              icon: const Icon(Icons.share_outlined, color: Colors.grey),
              onPressed: () {
                /* TODO: Implement share functionality */
              },
            ),
          ],
        ),
        Text(
          billTitle,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Bill Date: $billDate',
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        Text(
          billTotal.toString(),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00C853), // Green color
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[800]),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.grey[800]),
                    children: [
                      TextSpan(text: '3 friends are owing you '),
                      TextSpan(
                        text: billTotal.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildParticipantsSection(billMembers) {
    // final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'IDR ', decimalDigits: 0);
    // final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    return Column(
      children: [
        buildCollapsibleHeader('PARTICIPANTS ${billMembers.length}', true),
        if (true)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: billMembers.length,
            itemBuilder: (context, index) {
              return buildParticipantTile(
                billMembers[index]['name'],
                billMembers[index]['total'],
              );
            },
          ),
      ],
    );
  }

  Widget buildCollapsibleHeader(title, isExpanded) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildParticipantTile(participantName, participantTotal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            // backgroundImage: AssetImage(participant.avatarUrl),
            backgroundImage: AssetImage("https://picsum.photos/200"),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                participantName,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const Text(
                'Bill Owner',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              // if (participant.isOwner)
            ],
          ),
          const Spacer(),
          Text(
            participantTotal,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget buildSplitResultSection(billMembers) {
    return Column(
      children: [
        buildCollapsibleHeader('SPLIT RESULT', true),
        if (true)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: billMembers.length,
            itemBuilder: (context, index) {
              return buildSplitResultDetail(
                billMembers[index]['name'],
                billMembers[index]['total'],
              );
            },
          ),
      ],
    );
  }

  Widget buildSplitResultDetail(participantName, participantTotal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                // backgroundImage: AssetImage(participant.avatarUrl),
                backgroundImage: AssetImage('https://picsum.photos/200'),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$participantName's total",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    participantTotal.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // ...participant.items.map(
          //   (item) => Padding(
          //     padding: const EdgeInsets.only(left: 52, top: 8),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: [
          //         Text(item.name, style: const TextStyle(color: Colors.grey)),
          //         Text(
          //           'x${item.quantity}',
          //           style: const TextStyle(color: Colors.grey),
          //         ),
          //         Text(currencyFormat.format(item.price)),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
