import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:scales/ui/home.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return PlatformApp(
      title: 'Medsenger Scales', // TODO: Give proper title
      home:
          const Home(title: 'Medsenger Scales'), // TODO: Give proper title too
      material: (_, __) =>
          MaterialAppData(theme: ThemeData(primarySwatch: Colors.blue)),
      cupertino: (_, __) => CupertinoAppData(
          theme: const CupertinoThemeData(primaryColor: Colors.blue)),
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
      ],
    );
  }
}
