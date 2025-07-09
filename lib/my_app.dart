import 'package:flutter/material.dart';
import 'package:my_dice/buah_detail_screen.dart';
import 'package:my_dice/checkout_screen.dart';
import 'package:my_dice/daftar_user_screen.dart';
import 'package:my_dice/detail_material_screen.dart';
import 'package:my_dice/dice_screen.dart';
import 'package:my_dice/gradient_widget.dart';
import 'package:my_dice/home_screen.dart';
import 'package:my_dice/list_buah_screen.dart';
import 'package:my_dice/login_screen.dart';
import 'package:my_dice/otp_screen.dart';
import 'package:my_dice/success_checkout_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Hello World"),
        ),
        body: const GradientWidget(),
      ),
      initialRoute: 'login-screen',
      routes: {
        'login-screen': (context) => const LoginScreen(),
        'otp-screen': (context) => const OtpScreen(),
        'home-screen': (context) => const HomeScreen(),
        'detail-material-screen': (context) => const DetailMaterialScreen(),
        'checkout-screen': (context) => const CheckoutScreen(),
        'success-checkout-screen': (context) => const SuccessCheckoutScreen(),
        'dice-screen': (context) => const DiceScreen(),
        'list-buah-screen': (context) => const ListBuahScreen(),
        'buah-detail-screen': (context) => const BuahDetailScreen(),
        DaftarUserScreen.routeName: (context) => const DaftarUserScreen(),
      },
    );
  }
}
