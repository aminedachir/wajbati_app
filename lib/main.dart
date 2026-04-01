import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'models/providers.dart';
import 'models/home_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/restaurant/restaurant_screen.dart';
import 'screens/restaurant/all_restaurants_screen.dart';
import 'utils/theme_utils.dart';
import 'models/models.dart';
import 'utils/app_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await AppInitializer.initialize();
    debugPrint("✅ Appwrite Connected Successfully");
  } catch (e) {
    debugPrint("❌ Appwrite Connection Failed: $e");
  }

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const WajbatiApp());
}

class WajbatiApp extends StatelessWidget {
  const WajbatiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
      ],
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return MaterialApp(
            title: 'وجبتي',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeNotifier.currentTheme,
            home: const SplashScreen(),
            onGenerateRoute: (settings) {
              if (settings.name == '/restaurant') {
                final restaurant = settings.arguments as Restaurant;
                return MaterialPageRoute(
                  builder: (context) =>
                      RestaurantScreen(restaurant: restaurant),
                );
              }
              if (settings.name == '/all-restaurants') {
                // Get restaurants from HomeProvider instead of sampleRestaurants
                return MaterialPageRoute(
                  builder: (context) => AllRestaurantsScreen(
                    initialRestaurants:
                        context.read<HomeProvider>().restaurants,
                  ),
                );
              }
              return null;
            },
            routes: {
              '/login': (context) => const LoginScreen(),
              '/signup': (context) => const SignupScreen(),
              '/home': (context) => const HomeScreen(),
              '/cart': (context) => const CartScreen(),
            },
          );
        },
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.isLoggedIn) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}
