import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:scales/util/medsenger_scales.dart';
import 'package:scales/util/shared_preferences.dart';
import 'package:xiaomi_scale/xiaomi_scale.dart';

import '../util/permission.dart';

enum MeasurementPaneStage {
  created,
  measureing,
  measureSuccess,
  sendingToServer,
  sentToServer,
}

class MeasurementPane extends StatefulWidget {
  const MeasurementPane({super.key});

  @override
  State<StatefulWidget> createState() => _MeasurementPaneState();
}

class _MeasurementPaneState extends State<MeasurementPane> {
  StreamSubscription? _measurementSubscription;
  MiScaleMeasurement? _measurement;
  MeasurementPaneStage _stage = MeasurementPaneStage.created;
  final _scale = MiScale.instance;
  late MiScaleGender _userSex;
  late int _userAge;
  late double _userHeight;

  @override
  void initState() {
    startTakingMeasurements();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    stopTakingMeasurements(dispose: true);
  }

  Future<void> startTakingMeasurements() async {
    if (!await checkPermission()) return;
    Store.getUserSex().then((value) {
      if (value != null) {
        _userSex = value;
      } else {
        log('user sex is nil');
      }
    });
    Store.getUserAge().then((value) {
      if (value != null) {
        _userAge = value;
      } else {
        log('user age is nil');
      }
    });
    Store.getUserHeight().then((value) {
      if (value != null) {
        _userHeight = value;
      } else {
        log('user height is nil');
      }
    });
    setState(() {
      _measurementSubscription = _scale.takeMeasurements().listen(
        (measurement) {
          setState(() {
            _stage = MeasurementPaneStage.measureing;
            _measurement = measurement;
            if (measurement.stage == MiScaleMeasurementStage.MEASURED) {
              _stage = MeasurementPaneStage.measureSuccess;
              stopTakingMeasurements();
              log('Measurement received: $measurement weight ${measurement.weight}');
            }
          });
        },
        onError: (e) {
          log('Error while taking measurements: $e');
          stopTakingMeasurements();
        },
        onDone: stopTakingMeasurements,
      );
    });
  }

  void stopTakingMeasurements({dispose = false}) {
    _measurementSubscription?.cancel();
    _measurementSubscription = null;
    if (!dispose) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    switch (_stage) {
      case MeasurementPaneStage.created:
        return _startingMeasurement();
      case MeasurementPaneStage.measureing:
        final measurement = _measurement;
        if (measurement != null) {
          return _buildMeasurementWidget(measurement);
        } else {
          return PlatformText("Измерение...");
        }
      case MeasurementPaneStage.measureSuccess:
        return _measureSuccess();
      case MeasurementPaneStage.sendingToServer:
        return _sendingToServer();
      case MeasurementPaneStage.sentToServer:
        return _sentToServer();
    }
  }

  Widget _sendingToServer() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PlatformCircularProgressIndicator(),
          PlatformText(
            "Отправляем на сервер...",
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Center _sentToServer() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 36.0,
          ),
          Padding(
            padding: const EdgeInsets.all(8),
          ),
          PlatformText('Данные успешно отправлены на сервер'),
          Padding(
            padding: const EdgeInsets.all(8),
          ),
          PlatformElevatedButton(
            child: PlatformText('Измерить заново'),
            onPressed: () {
              _stage = MeasurementPaneStage.created;
              startTakingMeasurements();
            },
          ),
        ],
      ),
    );
  }

  Widget _startingMeasurement() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PlatformCircularProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8),
          ),
          PlatformText(
            "Начинаем измерение...",
            textAlign: TextAlign.center,
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: PlatformText(
              "Пожалуйста, встаньте на весы",
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }

  Widget _measureSuccess() {
    final measurement = _measurement;
    if (measurement != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildMeasurementWidget(measurement),
          Padding(
            padding: const EdgeInsets.all(8),
          ),
          PlatformElevatedButton(
            child: PlatformText("Отправить на сервер"),
            onPressed: () {
              setState(() {
                _stage = MeasurementPaneStage.sendingToServer;
              });
              MedsengerScales.sendMesurementData(
                measurement.weight,
                measurement.getBodyData(_userSex, _userAge, _userHeight),
                measurement.dateTime,
              ).then((_) {
                setState(() {
                  _stage = MeasurementPaneStage.sentToServer;
                });
              }).catchError((e) {
                log('Failed to send measurement data: $e');
              });
            },
          ),
          PlatformTextButton(
            child: PlatformText("Измерить заново"),
            onPressed: () {
              setState(() {
                _stage = MeasurementPaneStage.created;
              });
              startTakingMeasurements();
            },
          ),
        ],
      );
    } else {
      return PlatformText("Ошибка...");
    }
  }

  String _getStageString(MiScaleMeasurementStage stage) {
    switch (stage) {
      case MiScaleMeasurementStage.STABILIZED:
        return "Измерение стабилизировано";
      case MiScaleMeasurementStage.MEASURED:
        return "Измерение завершено";
      case MiScaleMeasurementStage.MEASURING:
        return "Измерение...";
      case MiScaleMeasurementStage.WEIGHT_REMOVED:
        return "Пожалуйста, встаньте на весы";
    }
  }

  Widget _buildMeasurementWidget(MiScaleMeasurement measurement) {
    final extraData = measurement.getBodyData(_userSex, _userAge, _userHeight);
    return Center(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              PlatformText(
                "${measurement.weight.toStringAsFixed(2)} кг",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                textAlign: TextAlign.center,
              ),
              PlatformText(
                _getStageString(measurement.stage),
              ),
              if (extraData != null) ...[
                Container(
                  height: 2,
                  color: Colors.grey,
                ),
                PlatformText(
                  'Процент жира: ${extraData.bodyFat.toStringAsFixed(0)}%',
                ),
                PlatformText(
                  'Костная масса: ${extraData.boneMass.toStringAsFixed(2)} кг',
                ),
                PlatformText(
                  'Мышечная масса: ${extraData.muscleMass.toStringAsFixed(2)} кг',
                ),
                PlatformText(
                  'Процент воды в организме: ${extraData.water.toStringAsFixed(0)}%',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

