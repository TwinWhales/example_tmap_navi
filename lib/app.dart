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
        Provider(create: (context) => CarConfigModel()),
        Provider(create: (context) => DriveModel()),
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
