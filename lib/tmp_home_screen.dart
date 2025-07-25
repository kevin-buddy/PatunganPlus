import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

int cartCounter = 0;
String counterCart = '';
int tabActive = 0;
List<Map<String, dynamic>> historySplitBil = [
  {
    "id": 1,
    "title": "Mala Jia",
    "date": DateTime.now(),
    "total": 10000,
    "members": [
      {"name": "Budi", "email": "", "phone": "08123456789"},
      {"name": "Hans", "email": "", "phone": "08123456789"},
    ],
  },
  {
    "id": 2,
    "title": "santong PTC",
    "date": DateTime.now(),
    "total": 10000,
    "members": [
      {"name": "Budi", "email": "", "phone": "08123456789"},
      {"name": "Hans", "email": "", "phone": "08123456789"},
    ],
  },
];
List<Map<String, dynamic>> activeSplitBill = [
  {
    "id": 1,
    "title": "Grab",
    "date": DateTime.now(),
    "total": 123456,
    "members": [
      {"name": "Budi", "email": "", "phone": "08123456789"},
      {"name": "Hans", "email": "", "phone": "08123456789"},
    ],
  },
];
List<Map<String, dynamic>> listMaterial = activeSplitBill;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Split Bill'),
        leading: const Icon(Icons.supervised_user_circle),
        actions: [
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed('checkout-screen');
            },
            child: Badge(
              label: Text(counterCart),
              child: const Icon(Icons.shopping_cart),
            ),
          ),
          const SizedBox(width: 11),
        ],
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      listMaterial = activeSplitBill;
                      tabActive = 0;
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: tabActive == 0
                        ? Colors.grey
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
                      listMaterial = historySplitBil;
                      tabActive = 1;
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: tabActive == 1
                        ? Colors.grey
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
              'YOU HAVE 14 ACTIVE BILLS',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: listMaterial.length,
              itemBuilder: (context, index) {
                return buildBillCard(
                  listMaterial[index]['title'],
                  listMaterial[index]['date'],
                  listMaterial[index]['members'],
                  listMaterial[index]['total'],
                  listMaterial[index]['members'],
                );
                // return Card(
                //   elevation: 4.0,
                //   child: ListTile(
                //     leading: Image.network('https://picsum.photos/200'),
                //     title: Text(listMaterial[index]['title']),
                //     subtitle: Text(listMaterial[index]['total'].toString()),
                //     trailing: FilledButton(
                //       onPressed: () {
                //         Navigator.of(context).pushNamed(
                //           'detail-bill-screen',
                //           arguments: {
                //             'title': listMaterial[index]['title'],
                //             'subttitle': listMaterial[index]['subttitle'],
                //           },
                //         );
                //       },
                //       child: const Text('See Detail'),
                //     ),
                //   ),
                // );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        shape: CircleBorder(),
        backgroundColor: const Color.fromARGB(255, 71, 216, 78),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget buildBillCard(billTitle, billdate, billMembers, billTotal, billItems) {
    return Card(
      elevation: 1,
      shadowColor: Colors.black12,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
