import 'dart:async';
import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:scales/ui/measurement_pane.dart';
import 'package:scales/ui/medsenger_colors.dart';
import 'package:scales/util/shared_preferences.dart';
import 'package:xiaomi_scale/xiaomi_scale.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.title});

  final String title;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linksSubscription;
  StreamSubscription<BluetoothAdapterState>? _bluetoothStateSubscription;

  // state
  bool _agentTokenExists = false;
  bool _isBluetoothOn = false;

  @override
  void initState() {
    _initDeepLinks();
    _initCheckBluetooth();
    Store.getAgentToken().then((value) {
      setState(() {
        _agentTokenExists = value != null;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _linksSubscription?.cancel();
    _bluetoothStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initCheckBluetooth() async {
    _bluetoothStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      setState(() {
        _isBluetoothOn = state == BluetoothAdapterState.on;
      });
    });
  }

  Future<void> _initDeepLinks() async {
    _linksSubscription = _appLinks.uriLinkStream.listen((link) {
      link.queryParameters.forEach((key, value) {
        switch (key) {
          case 'agent_token':
            Store.setAgentToken(value).then((_) => {
                  setState(() {
                    _agentTokenExists = true;
                  })
                });
            break;
          case 'user_sex':
            if (value == 'male') {
              Store.setUserSex(MiScaleGender.MALE);
            } else if (value == 'female') {
              Store.setUserSex(MiScaleGender.FEMALE);
            } else {
              log('Invalid user_sex value: $value');
            }
            break;
          case 'user_age':
            Store.setUserAge(int.parse(value));
            break;
          case 'user_height':
            Store.setUserHeight(double.parse(value));
            break;
          default:
            log('Received query parameter: $key -> $value');
        }
      });
      log('Received link: $link');
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Builder(builder: (context) {
          if (_agentTokenExists) {
            if (_isBluetoothOn) {
              return MeasurementPane();
            } else {
              return noBluetooth();
            }
          } else {
            return noAgentToken();
          }
        }),
      ),
    );
  }

  Widget noBluetooth() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bluetooth,
            color: MedsengerColors.blue,
            size: 36.0,
          ),
          PlatformText(
            "Для того, чтобы синхронизированные данные отправлялись врачу, пожалуйста, включите Bluetooth.",
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget noAgentToken() {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.monitor_weight,
            color: MedsengerColors.blue,
            size: 36.0,
          ),
          PlatformText(
            "Для того, чтобы синхронизированные данные отправлялись врачу, пожалуйста, перейдите в приложение Medsenger и в чате с врачом нажмите \"подключить устройство\".",
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

