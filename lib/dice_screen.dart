import 'dart:math';

import 'package:flutter/material.dart';

String urlDice = 'assets/images/1.png';
int rndDice = 6;

class DiceScreen extends StatefulWidget {
  const DiceScreen({super.key});

  @override
  State<StatefulWidget> createState() => _DiceScreenState();
}

class _DiceScreenState extends State<DiceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dice Screen'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            Image.asset(width: 300, height: 300, urlDice),
            const SizedBox(
              height: 5,
            ),
            FilledButton(
                onPressed: () {
                  doRoller();
                },
                child: const Text('Roll'))
          ],
        ),
      ),
    );
  }

  void doRoller() {
    rndDice = Random().nextInt(6) + 1;
    setState(() {
      urlDice = "assets/images/$rndDice.png";
    });
  }
}
