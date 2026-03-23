import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const Kit85App());
}

class Kit85App extends StatelessWidget {
  const Kit85App({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Kit85',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme(),
        home: const SplashScreen(),
      );
}
