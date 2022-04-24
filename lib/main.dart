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

  // color of the circle
  Color color = Colors.greenAccent;

  // event returned from accelerometer stream
   AccelerometerEvent? event;

  // hold a refernce to these, so that they can be disposed
   Timer? timer;
  StreamSubscription? accel;

  // positions and count
  double top = 125;
   double? left;
  int count = 0;

  // variables for screen size
   double? width;
   double? height;

  setColor(AccelerometerEvent event) {
    // Calculate Left
    double x = ((event.x * 12) + ((width! - 100) / 2));
    // Calculate Top
    double y = event.y * 12 + 125;

    // find the difference from the target position
    var xDiff = x.abs() - ((width! - 100) / 2);
    var yDiff = y.abs() - 125;

    // check if the circle is centered, currently allowing a buffer of 3 to make centering easier
    if (xDiff.abs() < 3 && yDiff.abs() < 3) {
      // set the color and increment count
      setState(() {
        color = Colors.greenAccent;
        count += 1;
      });
    } else {
      // set the color and restart count
      setState(() {
        color = Colors.red;
        count = 0;
      });
    }
  }

  setPosition(AccelerometerEvent event) {
    if (event == null) {
      return;
    }

    // When x = 0 it should be centered horizontally
    // The left positin should equal (width - 100) / 2
    // The greatest absolute value of x is 10, multipling it by 12 allows the left position to move a total of 120 in either direction.
    setState(() {
      left = ((event.x * 12) + ((width! - 100) / 2));
    });

    // When y = 0 it should have a top position matching the target, which we set at 125
    setState(() {
      top = event.y * 12 + 125;
    });
  }


  startTimer() {
    // if the accelerometer subscription hasn't been created, go ahead and create it
    if (accel == null) {
      accel = accelerometerEvents.listen((AccelerometerEvent eve) {
        setState(() {
          event = eve;
        });
      });
    } else {
      // it has already ben created so just resume it
      accel!.resume();
    }

    // Accelerometer events come faster than we need them so a timer is used to only proccess them every 200 milliseconds
    if (timer == null || !timer!.isActive) {
      timer = Timer.periodic(Duration(milliseconds: 200), (_) {
        // if count has increased greater than 3 call pause timer to handle success
        // if (count > 3) {
        //   pauseTimer();
        // } else {
        //   // proccess the current event
        //   setColor(event!);
        //   setPosition(event!);
        // }
      });
    }
  }

  pauseTimer() {
    // stop the timer and pause the accelerometer stream
    timer!.cancel();
    accel!.pause();

    // set the success color and reset the count
    setState(() {
      count = 0;
      color = Colors.green;
    });
  }
    @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    timer!.cancel();
    accel!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
      // get the width and height of the screen
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                          Text('x: ${(event!.x ?? 0).toStringAsFixed(3)}'),
          Text('y: ${(event!.y ?? 0).toStringAsFixed(3)}'),
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
                      Color.fromARGB(255, ((event!.y * 9) + ((width! - 200) / 2)).toInt(), ((event!.x * 9) + ((width! - 50) / 2)).toInt(), 255),
                      Color.fromARGB(255, ((event!.y * 9) + ((height! - 200) / 2)).toInt(), ((event!.x * 9) + ((width! - 50) / 2)).toInt(), 255),
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
