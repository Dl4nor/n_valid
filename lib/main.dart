import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'app_widget.dart';

main() {
  runApp(DevicePreview(
          enabled: true,
          builder: (context) => const AppWidget(),
        ));
}
  