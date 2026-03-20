import 'package:flutter/material.dart';
import 'package:patungan_plus/gradient_widget.dart';
import 'package:patungan_plus/providers/main_controller.dart';
import 'package:patungan_plus/screens/home_screen.dart';
import 'package:patungan_plus/screens/detail_split_bill_screen.dart';
import 'package:patungan_plus/screens/input_bill_screen.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => MainController())],
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text("Hello World")),
          body: const GradientWidget(),
        ),
        initialRoute: 'home-screen',
        routes: {
          'home-screen': (context) => const HomeScreen(),
          'detail-split-bill': (context) => const DetailSplitBillScreen(),
          'input-bill': (context) => const InputBillScreen(),
        },
      ),
    );
  }
}
