import 'package:flutter/material.dart';

class ListBuahScreen extends StatelessWidget {
  const ListBuahScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> listBuah = [
      {
        "title": "Apple",
        "subttitle": "Buah berwarna merah",
        "color": Colors.red,
        "description": "Buah buah"
      },
      {
        "title": "Banana",
        "subttitle": "Buah berawarna kuning",
        "color": Colors.yellow,
        "description": "Buah buah"
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Buah'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: listBuah.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.of(context).pushNamed('buah-detail-screen',
                  arguments: listBuah[index]['description']);
            },
            child: Card(
              elevation: 4.0,
              child: ListTile(
                leading: const Icon(Icons.food_bank),
                title: Text(listBuah[index]['title']),
                subtitle: Text(listBuah[index]['subttitle']),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          );
        },
      ),
    );
  }
}
