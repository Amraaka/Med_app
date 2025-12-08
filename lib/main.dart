import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'services.dart';
import 'widgets.dart';
import 'pages/auth/login_page.dart';
import 'pages/auth/singup_page.dart';
import 'pages/auth/intro_page.dart';
import 'services/auth_service.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PatientService()..loadPatients()),
        ChangeNotifierProvider(
          create: (_) => PrescriptionService()..loadPrescriptions(),
        ),
        ChangeNotifierProvider(
          create: (_) => DoctorProfileService()..loadProfile(),
        ),
      ],
      child: MaterialApp(
        title: 'Med App',
        debugShowCheckedModeBanner: false,
        theme: _buildAppTheme(),
        home: const AuthGate(),
        routes: {
          '/intro': (context) => const IntroPage(),
          '/login': (context) => LoginPage(),
          '/signup': (context) => SignupPage(),
          '/home': (context) => const MainScreen(),
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const HomePage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void switchToProfile() {
    setState(() => _selectedIndex = 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.02, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: KeyedSubtree(
          key: ValueKey<int>(_selectedIndex),
          child: _pages[_selectedIndex],
        ),
      ),
      extendBody: true,
      bottomNavigationBar: AppBottomNav(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

ThemeData _buildAppTheme() {
  const baseBackground = Color(0xFFE0F5F4);
  const accent = Color(0xFF00B8A9);

  final scheme = ColorScheme.fromSeed(
    seedColor: accent,
    brightness: Brightness.light,
  ).copyWith(primary: accent, secondary: accent, surface: baseBackground);

  return ThemeData(
    useMaterial3: true,
    fontFamily: 'NotoSans',
    colorScheme: scheme,
    scaffoldBackgroundColor: baseBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: _SlideFadeTransitionsBuilder(),
        TargetPlatform.iOS: _SlideFadeTransitionsBuilder(),
        TargetPlatform.macOS: _SlideFadeTransitionsBuilder(),
        TargetPlatform.linux: _SlideFadeTransitionsBuilder(),
        TargetPlatform.windows: _SlideFadeTransitionsBuilder(),
        TargetPlatform.fuchsia: _SlideFadeTransitionsBuilder(),
      },
    ),
  );
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: authService.value.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const MainScreen();
        }
        return const IntroPage();
      },
    );
  }
}

class _SlideFadeTransitionsBuilder extends PageTransitionsBuilder {
  const _SlideFadeTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.06, 0.0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
