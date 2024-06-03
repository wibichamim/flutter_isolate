import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

Future<double> complexTask1() async {
  var total = 0.0;
  for (var i = 0; i < 1000000000; i++) {
    total += i;
  }
  return total;
}

complexTask2(SendPort sendPort) {
  var total = 0.0;
  for (var i = 0; i < 1000000000; i++) {
    total += i;
  }
  sendPort.send(total);
}

double complexTask3() {
  var total = 0.0;
  for (var i = 0; i < 1000000000; i++) {
    total += i;
  }
  return total;
}

class _HomePageState extends State<HomePage> {
  double result = 0;
  var overlayController = OverlayPortalController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Image.asset('assets/gifs/bouncing-ball.gif'),
              //Blocking UI task
              ElevatedButton(
                onPressed: () async {
                  var total = await complexTask1();
                  debugPrint('Result 1: $total');
                  setState(() {
                    result = total;
                  });
                },
                child: const Text('Task 1'),
              ),
              //Isolate
              ElevatedButton(
                onPressed: () async {
                  final receivePort = ReceivePort();
                  await Isolate.spawn(complexTask2, receivePort.sendPort);
                  receivePort.listen((total) {
                    debugPrint('Result 2: $total');
                    setState(() {
                      result = total;
                    });
                  });
                },
                child: const Text('Task 2'),
              ),
              ElevatedButton(
                onPressed: () async {
                  double total = await Isolate.run(() => complexTask3());
                  debugPrint('Result 3: $total');
                  setState(() {
                    result = total;
                  });
                },
                child: const Text('Task 3'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    result = 0.0;
                  });
                },
                child: const Text('Reset'),
              ),
              ElevatedButton(
                onPressed: overlayController.toggle,
                child: OverlayPortal(
                  controller: overlayController,
                  overlayChildBuilder: (context) {
                    return Positioned(
                      right: 20,
                      top: 315,
                      child: Column(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              var total = await complexTask1();
                              debugPrint('Result 1: $total');
                              setState(() {
                                result = total;
                              });
                            },
                            child: const Text('Task 1'),
                          ),
                          //Isolate
                          ElevatedButton(
                            onPressed: () async {
                              final receivePort = ReceivePort();
                              await Isolate.spawn(
                                  complexTask2, receivePort.sendPort);
                              receivePort.listen((total) {
                                debugPrint('Result 2: $total');
                                setState(() {
                                  result = total;
                                });
                              });
                            },
                            child: const Text('Task 2'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              double total =
                                  await Isolate.run(() => complexTask3());
                              debugPrint('Result 3: $total');
                              setState(() {
                                result = total;
                              });
                            },
                            child: const Text('Task 3'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Show/Hide Tooltip'),
                ),
              ),
              const Gap(20),
              const Text(
                'Result : ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              Text(
                result.toString(),
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
