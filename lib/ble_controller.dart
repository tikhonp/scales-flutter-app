import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleController extends ChangeNotifier {
  final genericAccessService = Uuid.parse('1800');
  final genericAttributeService = Uuid.parse('1801');
  final deviceInformationService = Uuid.parse('180a');
  final bodyCompositionService = Uuid.parse('181b');
  final huamiConfigurationService =
      Uuid.parse('00001530-0000-3512-2118-0009af100700');

  final deviceNameCharacteristic = Uuid.parse('2a00');

  final serialNumberStringCharacteristic = Uuid.parse('2a25');
  final softwareRevisionStringCharacteristic = Uuid.parse('2a28');
  final hardwareRevisionStringCharacteristic = Uuid.parse('2a27');

  final ble = FlutterReactiveBle();

  bool _isScanning = false;
  String? _deviceId;
  StreamSubscription<DiscoveredDevice>? _scanSubscription;

  void discover() {
    log('Discovering devices...');

    assert(!_isScanning);

    _scanSubscription = ble.scanForDevices(withServices: [
      genericAccessService,
      genericAttributeService,
      deviceInformationService,
      bodyCompositionService,
      huamiConfigurationService
    ], scanMode: ScanMode.lowLatency).listen((device) {
      if (device.name == '') {
        return;
      }

      log('Found device: ${device.name} (${device.id}) with RSSI ${device.rssi} dBm. ${device.manufacturerData}');

      for (var service in device.serviceData.keys) {
        log('Service data: $service -> ${device.serviceData[service]}');
      }

      log('Manufacturer data: ${String.fromCharCodes(device.manufacturerData)}');

      stopDiscovering();
      connect(device.id);
    }, onError: (Object e) {
      log('Error while scanning: $e');
    });
    _isScanning = true;
  }

  void stopDiscovering() {
    log('Stopping discovery...');
    assert(_isScanning);
    _scanSubscription?.cancel();
    _isScanning = false;
  }

  void connect(String deviceId) {
    log('Connecting to device $deviceId...');

    _deviceId = deviceId;

    ble
        .connectToDevice(
      id: deviceId,
      servicesWithCharacteristicsToDiscover: {
        genericAccessService: [deviceNameCharacteristic],
        genericAttributeService: [],
        deviceInformationService: [
          serialNumberStringCharacteristic,
          softwareRevisionStringCharacteristic,
          hardwareRevisionStringCharacteristic,
        ],
        bodyCompositionService: [],
        huamiConfigurationService: []
      },
      connectionTimeout: const Duration(seconds: 2),
    )
        .listen(
      (connectionState) {
        log('Connection state: ${connectionState.connectionState}');
        if (connectionState.connectionState ==
            DeviceConnectionState.connected) {
          readInformation();
        }
      },
      onError: (Object e) {
        log('Error while connecting: $e');
      },
    );
  }

  void connectAd(String deviceId) {
    log('Connecting to ad device $deviceId...');

    _deviceId = deviceId;

    ble.connectToAdvertisingDevice(
      id: deviceId,
      withServices: [
        genericAccessService,
        genericAttributeService,
        deviceInformationService,
        bodyCompositionService,
        huamiConfigurationService
      ],
      prescanDuration: const Duration(seconds: 5),
      servicesWithCharacteristicsToDiscover: null,
      connectionTimeout: const Duration(seconds: 2),
    );
  }

  void readInformation() async {
    log('Reading information from device...');

    var deviceId = _deviceId;
    if (deviceId == null) {
      log('No device connected');
      return;
    }

    final characteristic = QualifiedCharacteristic(
      serviceId: genericAccessService,
      characteristicId: deviceNameCharacteristic,
      deviceId: deviceId,
    );

    ble.readCharacteristic(characteristic).then((response) {
      log('Read response: $response');
    });
  }
}
