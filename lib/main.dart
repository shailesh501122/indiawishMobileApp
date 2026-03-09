import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';
import 'providers/marketplace_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/user_provider.dart';
import 'providers/config_provider.dart';
import 'providers/discovery_provider.dart';
import 'providers/services_provider.dart';
import 'providers/search_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_screens_wrapper.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await NotificationService().init();
  } catch (e) {
    debugPrint('Notification init error: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MarketplaceProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ConfigProvider()),
        ChangeNotifierProvider(create: (_) => DiscoveryProvider()),
        ChangeNotifierProvider(create: (_) => ServicesProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const IndiaWishApp(),
    ),
  );
}

class IndiaWishApp extends StatelessWidget {
  const IndiaWishApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IndiaWish',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const MainScreensWrapper(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}
