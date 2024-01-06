import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app_material.dart';
import 'app_windows.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

void main() async {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
    WidgetsFlutterBinding.ensureInitialized();
  await Window.initialize();
  await Window.setEffect(
  effect: WindowEffect.mica,
  dark: true,
);

  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      // Use Windows-specific UI
      return const AppWindows();
    } else {
      // Use Material Design UI for other platforms
      return const AppMaterial();
    }
  }
}


