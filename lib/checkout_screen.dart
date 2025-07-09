import 'package:flutter/material.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            const Text('Profile'),
            const Text(
                'Jl. M. H Tharmin, Kav 12, Tebet, Jakarta Selatan, 13790'),
            Image.network('https://picsum.photos/300'),
            const Text('Material'),
            const Text('Ringkasan Pembayaran'),
            const Text('Total Pemabayran'),
            const Text('Rp. 37000'),
            FilledButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('success-checkout-screen');
                },
                child: const Text('Buat Pesanan'))
          ],
        ),
      ),
    );
  }
}
