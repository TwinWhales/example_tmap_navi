import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:example_tmap_navi/common/app_routes.dart';
import 'package:example_tmap_navi/models/car_config_model.dart';
import 'package:example_tmap_navi/models/drive_model.dart';

class TmapExampleApp extends StatelessWidget {
  const TmapExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ChangeNotifierProvider로 바꿔야 notifyListeners()가 동작합니다.
        ChangeNotifierProvider(create: (context) => CarConfigModel()),
        ChangeNotifierProvider(create: (context) => DriveModel()),
      ],
      child: MaterialApp.router(
        title: 'Tmap UI SDK Example',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        routerConfig: router(),
      ),
    );
  }
}
