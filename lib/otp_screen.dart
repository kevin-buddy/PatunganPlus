import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

int timerSeconds = 240;
int minute = 3;
int second = 59;

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<StatefulWidget> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  Timer? _timer;
  int _remainingSeconds;

  _OtpScreenState({int startSeconds = 999}) : _remainingSeconds = startSeconds;

  @override
  initState() {
    _timer = Timer.periodic(const Duration(seconds: 1), ((timer) {
      if (_remainingSeconds <= 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          _remainingSeconds--;
          if (second <= 1) {
            minute--;
            second = 59;
          } else {
            second--;
          }
        });
      }
    }));
    super.initState();
  }

  @override
  dispose() {
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            const Text('OTP'),
            const SizedBox(
              height: 15,
            ),
            SizedBox(
              width: 300,
              child: TextFormField(
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(
                      RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
                ],
                maxLength: 6,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(20.0),
                  hintText: '6 digit kode OTP',
                ),
                onChanged: (value) {
                  if (value.length >= 6) {
                    Navigator.of(context).pushReplacementNamed('home-screen');
                  }
                },
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Text('0$minute:$second'),
            const SizedBox(
              height: 5,
            ),
            FilledButton(
                onPressed: () {
                  doReset();
                },
                child: const Text('Kirim Ulang OTP'))
          ],
        ),
      ),
    );
  }

  void doReset() {
    setState(() {
      minute = 3;
      second = 59;
    });
  }
}
