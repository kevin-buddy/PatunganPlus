import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

int cartCounter = 0;
String counterCart = '';
int tabActive = 0;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> listMaterial = [
      {
        "title": "Mala Jia",
        "subttitle": "mala jia PTC",
        "color": Colors.red,
        "description": "Buah buah",
        "date": DateTime.now(),
        "total": 10000,
        "id": 1,
        "members": [
          {"name": "Budi", "email": "", "phone": "08123456789"},
        ],
      },
      {
        "title": "Santong",
        "subttitle": "santong PTC",
        "color": Colors.yellow,
        "description": "Buah buah",
        "date": DateTime.now(),
        "total": 10000,
        "id": 1,
        "members": [
          {"name": "Budi", "email": "", "phone": "08123456789"},
        ],
      },
    ];

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
                  onPressed: () => setState(() => tabActive = 0),
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
                  onPressed: () => setState(() => tabActive = 1),
                  style: TextButton.styleFrom(
                    backgroundColor: tabActive == 1
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
                return Card(
                  elevation: 4.0,
                  child: ListTile(
                    leading: Image.network('https://picsum.photos/200'),
                    title: Text(listMaterial[index]['title']),
                    subtitle: Text(listMaterial[index]['subttitle']),
                    trailing: FilledButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          'detail-bill-screen',
                          arguments: {
                            'title': listMaterial[index]['title'],
                            'subttitle': listMaterial[index]['subttitle'],
                          },
                        );
                      },
                      child: const Text('See Detail'),
                    ),
                  ),
                );
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
}
