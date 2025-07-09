import 'package:flutter/material.dart';

int cartCounter = 0;
String counterCart = '';

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
        "title": "Ayam ULU",
        "subttitle": "ayam ulu unggas lestari",
        "color": Colors.red,
        "description": "Buah buah"
      },
      {
        "title": "Bebek CDF",
        "subttitle": "Bebek CDF ciomas duck farm",
        "color": Colors.yellow,
        "description": "Buah buah"
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selamat Datang'),
        leading: const Icon(Icons.supervised_user_circle),
        actions: [
          InkWell(
              onTap: () {
                Navigator.of(context).pushNamed('checkout-screen');
              },
              child: Badge(
                label: Text(counterCart),
                child: const Icon(Icons.shopping_cart),
              )),
          const SizedBox(
            width: 11,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: listMaterial.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.of(context)
                  .pushNamed('detail-material-screen', arguments: {
                'title': listMaterial[index]['title'],
                'subttitle': listMaterial[index]['subttitle'],
              });
              // Navigator.of(context).pushNamed('buah-detail-screen',
              //     arguments: listBuah[index]['description']);
            },
            child: Card(
              elevation: 4.0,
              child: ListTile(
                leading: Image.network('https://picsum.photos/200'),
                title: Text(listMaterial[index]['title']),
                subtitle: Text(listMaterial[index]['subttitle']),
                trailing: FilledButton(
                    onPressed: () {
                      setState(() {
                        cartCounter++;
                        counterCart = cartCounter < 10 ? '$cartCounter' : '9+';
                      });
                    },
                    child: const Text('Tambah')),
              ),
            ),
          );
        },
      ),
    );
  }
}
