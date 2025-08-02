import 'package:flutter/material.dart';
import 'package:patungan_plus/buah_detail_screen.dart';
import 'package:patungan_plus/checkout_screen.dart';
import 'package:patungan_plus/daftar_user_screen.dart';
import 'package:patungan_plus/detail_material_screen.dart';
import 'package:patungan_plus/dice_screen.dart';
import 'package:patungan_plus/gradient_widget.dart';
import 'package:patungan_plus/list_buah_screen.dart';
import 'package:patungan_plus/login_screen.dart';
import 'package:patungan_plus/otp_screen.dart';
import 'package:patungan_plus/success_checkout_screen.dart';
import 'package:patungan_plus/detail_bill_screen.dart';

import 'package:patungan_plus/home_screen.dart';
import 'package:patungan_plus/detail_split_bill_screen.dart';
import 'package:patungan_plus/input_bill_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Hello World")),
        body: const GradientWidget(),
      ),
      initialRoute: 'home-screen',
      routes: {
        'home-screen': (context) => const HomeScreen(),
        'detail-split-bill': (context) => const DetailSplitBillScreen(),
        'input-bill': (context) => const InputBillScreen(),

        'login-screen': (context) => const LoginScreen(),
        'otp-screen': (context) => const OtpScreen(),
        'detail-material-screen': (context) => const DetailMaterialScreen(),
        'checkout-screen': (context) => const CheckoutScreen(),
        'success-checkout-screen': (context) => const SuccessCheckoutScreen(),
        'dice-screen': (context) => const DiceScreen(),
        'list-buah-screen': (context) => const ListBuahScreen(),
        'buah-detail-screen': (context) => const BuahDetailScreen(),
        'detail-bill-screen': (context) => const DetailBillScreen(),
        DaftarUserScreen.routeName: (context) => const DaftarUserScreen(),
      },
    );
  }
}
