import 'package:flutter/material.dart';

class DetailMaterialScreen extends StatelessWidget {
  const DetailMaterialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Material'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            Text(args['title']),
            Image.network('https://picsum.photos/400'),
            const Text('Rp. 27.000'),
            Text(args['subttitle']),
            FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Tambah Pembelian'))
          ],
        ),
      ),
    );
  }
}
