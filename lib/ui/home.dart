import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../ble_controller.dart';
import 'measurement_pane.dart';
import 'raw_data_pane.dart';
import 'scanning_pane.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.title});

  final String title;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final bleController = BleController();

  var _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: const [
            MeasurementPane(),
            ScanningPane(),
            RawDataPane(),
          ],
        ),
      ),
      bottomNavBar: PlatformNavBar(
        currentIndex: _currentIndex,
        itemChanged: _bottomTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            label: 'Measurements',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Scanning',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Raw Data',
          ),
        ],
      ),
    );
  }

  void _bottomTapped(int index) => setState(() => _currentIndex = index);
}

