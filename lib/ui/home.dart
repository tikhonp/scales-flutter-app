import 'dart:async';
import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:scales/ui/measurement_pane.dart';
import 'package:scales/util/shared_preferences.dart';
import 'package:xiaomi_scale/xiaomi_scale.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.title});

  final String title;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linksSubscription;

  // state
  bool _agentTokenExists = false;

  @override
  void initState() {
    _initDeepLinks();
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
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();
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
            return MeasurementPane();
          } else {
            return noAgentToken();
          }
        }),
      ),
    );
  }

  Column noAgentToken() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.beach_access,
          color: Colors.blue,
          size: 36.0,
        ),
        PlatformText(
          "Пожалуйста, зайдите в приложение Medsenger и подключите весы",
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

