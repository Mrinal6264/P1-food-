import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const FoodieHubApp());
}

class FoodieHubApp extends StatelessWidget {
  const FoodieHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'FoodieHub',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFFE0402B),
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0,
            centerTitle: false,
          ),
          scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
