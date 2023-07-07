import 'package:board/util/widget.dart';
import 'package:flutter/material.dart';
import 'package:position_sensors/position_sensors.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math' as math;

class SensorValue {
  double x;
  double y;
  double z;

  SensorValue({
    required this.x,
    required this.y,
    required this.z,
  });

  factory SensorValue.zero() => SensorValue(x: 0, y: 0, z: 0);
}

class SensorPage extends StatefulWidget {
  const SensorPage({super.key});

  @override
  State<SensorPage> createState() => _SensorPageState();
}

class SensorNotifier extends ValueNotifier<SensorValue> {
  SensorNotifier(super.value);

  factory SensorNotifier.zero() =>
      SensorNotifier(SensorValue(x: 0, y: 0, z: 0));
}

class _SensorPageState extends State<SensorPage> {
  final SensorNotifier _userAccelerometerNotifier = SensorNotifier.zero();
  final SensorNotifier _accelerometerNotifier = SensorNotifier.zero();
  final SensorNotifier _gyroscopeNotifier = SensorNotifier.zero();
  final SensorNotifier _magnetometerNotifier = SensorNotifier.zero();
  final SensorNotifier _rotateNotifier = SensorNotifier.zero();
  @override
  void initState() {
    super.initState();
    setOnlyPortraitScreen();
    userAccelerometerEvents.listen(
      (UserAccelerometerEvent event) {
        _userAccelerometerNotifier.value =
            SensorValue(x: event.x, y: event.y, z: event.z);
      },
      onError: showErrorDialog('user accelerometer'),
      cancelOnError: true,
    );
    accelerometerEvents.listen(
      (AccelerometerEvent event) {
        _accelerometerNotifier.value =
            SensorValue(x: event.x, y: event.y, z: event.z);
      },
      onError: showErrorDialog('accelerometer'),
      cancelOnError: true,
    );
    gyroscopeEvents.listen(
      (GyroscopeEvent event) {
        _gyroscopeNotifier.value =
            SensorValue(x: event.x, y: event.y, z: event.z);
      },
      onError: showErrorDialog('gyroscope'),
      cancelOnError: true,
    );
    magnetometerEvents.listen(
      (MagnetometerEvent event) {
        _magnetometerNotifier.value =
            SensorValue(x: event.x, y: event.y, z: event.z);
      },
      onError: showErrorDialog('magnetometer'),
      cancelOnError: true,
    );
    PositionSensors.rotationEvents.listen((event) {
      _rotateNotifier.value =   SensorValue(x: event.x, y: event.y, z: event.z);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _userAccelerometerNotifier.dispose();
    _accelerometerNotifier.dispose();
    _gyroscopeNotifier.dispose();
    _magnetometerNotifier.dispose();
  }

  ValueNotifier<Matrix4> matrixNotifier = ValueNotifier(Matrix4.identity());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Stack(
            children: <Widget>[
              //text(_userAccelerometerNotifier),
              //padding16,
              //text(_accelerometerNotifier),
              //padding16,
              // Positioned(
              //   top: 0,
              //   right: 0,
              //   child: Transform.rotate(
              //     alignment: Alignment.center,
              //     angle: math.pi / 2,
              //     child: SizedBox(
              //       width: 120,
              //       height: 120,
              //       child: text(_gyroscopeNotifier),
              //     ),
              //   ),
              // ),
              Positioned(
                child: gyroscopeWidgetX(),
              ),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: AnimatedBuilder(
                          animation: _rotateNotifier,
                          builder: (ctx, child) {
                            return Transform.rotate(
                              angle: _rotateNotifier.value.x,
                              child: Center(
                                child: Container(
                                  height: 3,
                                  color: Colors.blue,
                                ),
                              ),
                            );
                          }),
                    ),
                    padding16,
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: AnimatedBuilder(
                          animation: _rotateNotifier,
                          builder: (ctx, child) {
                            return Transform.rotate(
                              angle: _rotateNotifier.value.y,
                              child: Center(
                                child: Container(
                                  height: 3,
                                  color: Colors.blue,
                                ),
                              ),
                            );
                          }),
                    ),
                    padding16,
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: AnimatedBuilder(
                          animation: _rotateNotifier,
                          builder: (ctx, child) {
                            return Transform.rotate(
                              angle: _rotateNotifier.value.z,
                              child: Center(
                                child: Container(
                                  height: 3,
                                  color: Colors.blue,
                                ),
                              ),
                            );
                          }),
                    )
                  ],
                ),
              )
              //padding16,
              //text(_magnetometerNotifier),
            ],
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget get padding16 =>
      const Padding(padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8));

  Widget text(SensorNotifier listenable) {
    return ValueListenableBuilder(
        valueListenable: listenable,
        builder: (context, value, child) {
          String s = sensorValToString(listenable);
          return Text(
            s,
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 8),
          );
        });
  }

  Function showErrorDialog(String sensorName) {
    return (e) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Sensor Not Found"),
              content: Text("Your device doesn't support $sensorName sensor"),
            );
          });
    };
  }

  String sensorValToString(SensorNotifier notifier) {
    final buffer = StringBuffer();
    final value = notifier.value;
    buffer.write('x: ${value.x}');
    buffer.write('\ny: ${value.y}');
    buffer.write('\nz: ${value.z}');
    return buffer.toString();
  }

  Widget gyroscopeWidgetX() {
    return Container(
      width: 60,
      height: 160,
      color: Colors.grey,
      child: Stack(
        children: [
          AnimatedBuilder(
              animation: _gyroscopeNotifier,
              builder: (ctx, child) {
                return Transform.translate(
                  offset: Offset(0, 0),
                  child: Center(
                    child: Container(
                      width: 50,
                      height: 50,
                      color: Colors.blue,
                    ),
                  ),
                );
              })
        ],
      ),
    );
  }
}
