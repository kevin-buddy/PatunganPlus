import 'package:flutter/material.dart';

class SuccessCheckoutScreen extends StatelessWidget {
  const SuccessCheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informasi'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            const Text('Terima Kasih,'),
            const Text('Pesanan anda akan kami proses selanjutnya.'),
            Image.network(
                'https://static.vecteezy.com/system/resources/thumbnails/011/858/556/small/green-check-mark-icon-with-circle-tick-box-check-list-circle-frame-checkbox-symbol-sign-png.png'),
            InkWell(
              onTap: () {
                Navigator.popUntil(context, ModalRoute.withName('home-screen'));
              },
              child: const Text('Kembali ke Beranda'),
            )
          ],
        ),
      ),
    );
  }
}
