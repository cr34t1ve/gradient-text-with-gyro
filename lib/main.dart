import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GradientText(),
    );
  }
}

class GradientText extends StatefulWidget {
  const GradientText({Key? key}) : super(key: key);

  @override
  State<GradientText> createState() => _GradientTextState();
}

class _GradientTextState extends State<GradientText> {
  int xValue = 0;
  int yValue = 0;

  // event returned from accelerometer stream
  AccelerometerEvent? event;

  // hold a refernce to these, so that they can be disposed
  StreamSubscription? accel;

  int rangeMapping(
      int input, int inputStart, int inputEnd, int outputStart, int outputEnd) {
    int output = (outputStart +
            ((outputEnd - outputStart) / (inputEnd - inputStart)) *
                (input - inputStart))
        .toInt();
    return output;
  }

  startEvent() async{
    // if the accelerometer subscription hasn't been created, go ahead and create it
    if (accel == null) {
      accel = await accelerometerEvents.listen((AccelerometerEvent eve) {
        setState(() {
          event = eve;
          xValue = rangeMapping(event!.x.toInt(), -10, 10, 0, 255);
          yValue = rangeMapping(event!.y.toInt(), -10, 10, 0, 255);
        });
      });
    } else {
      // it has already ben created so just resume it
      accel!.resume();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startEvent();
  }

  @override
  void dispose() {
    accel!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('x: ${(event!.x).toStringAsFixed(3)}'),
                Text('y: ${(event!.y).toStringAsFixed(3)}'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Container(
              child: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromARGB(255, xValue, 239, 255),
                      Color.fromARGB(255, yValue, 97, 255)
                    ]).createShader(
                  Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                ),
                child: Text(
                  "That's what you get with Sofua Desmond",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 40),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
