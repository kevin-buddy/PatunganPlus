import 'package:flutter/material.dart';

class BuahDetailScreen extends StatelessWidget {
  const BuahDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail buah'),
      ),
      body: const Column(
        children: [Text('Description')],
      ),
    );
  }
}
