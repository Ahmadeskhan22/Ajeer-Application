import 'package:ajeer/Notifications/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'Ai_matching/MatcherScreen.dart';
import 'Browse_Job/browse_jobs_screen.dart';
import 'Login/forgot_password_screen.dart'
    show ForgotPasswordScreen, ResetPasswordScreen;
import 'Login/login_screen.dart';
import 'Profile/profile_screen.dart';
import 'Splash_screen/SplashScreen.dart';
import 'Theme/app_theme.dart';
import 'landing/landing_screen.dart';
import 'applications/my_applications_screen.dart';
import 'provider/app_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  final provider = AppProvider();
  await provider.init();

  runApp(
    ChangeNotifierProvider.value(value: provider, child: const AjeerApp()),
  );
}

class AjeerApp extends StatefulWidget {
  const AjeerApp({super.key});

  @override
  State<AjeerApp> createState() => _AjeerAppState();
}

class _AjeerAppState extends State<AjeerApp> {
  late GoRouter _router;

  @override
  void initState() {
    super.initState();
    final prov = context.read<AppProvider>();

    _router = GoRouter(
      initialLocation: '/splash',
      refreshListenable: prov,
      redirect: (ctx, state) {
        final loggedIn = prov.loggedIn;
        final going = state.matchedLocation;

        // ── BUG FIX #2: '/browse-jobs' was in the allowed list, letting
        // unauthenticated users reach a protected screen.
        // Only truly public routes (splash, landing, login) are allowed here.
        const allowed = [
          '/splash',
          '/landing',
          '/login',
          '/forgot-password',
          '/reset-password'
        ];
        final isAllowed = allowed.contains(going);

        if (!loggedIn && !isAllowed) return '/landing';
        if (loggedIn && (going == '/login' || going == '/landing')) {
          return '/browse-jobs';
        }

        return null;
      },
      routes: [
        GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
        GoRoute(path: '/landing', builder: (_, __) => const LandingScreen()),
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(
            path: '/browse-jobs', builder: (_, __) => const BrowseJobsScreen()),
        GoRoute(path: '/ai-matcher', builder: (_, __) => const MatcherScreen()),
        GoRoute(
            path: '/applications',
            builder: (_, __) => const ApplicationsScreen()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        GoRoute(
            path: '/forgot-password',
            builder: (_, __) => const ForgotPasswordScreen()),
        GoRoute(
            path: '/reset-password',
            builder: (ctx, state) => ResetPasswordScreen(
                  email: state.uri.queryParameters['email'] ?? '',
                  token: state.uri.queryParameters['token'] ?? '',
                )),
        GoRoute(
            path: '/notifications',
            builder: (_, __) => const NotificationsScreen()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final textDir = context.select<AppProvider, TextDirection>((p) => p.dir);
    final locale = context.select<AppProvider, Locale>((p) => p.locale);
    final isAr = context.select<AppProvider, bool>((p) => p.isAr);

    return Directionality(
      textDirection: textDir,
      child: MaterialApp.router(
        title: 'AJEER - أجير',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme(arabic: isAr),
        routerConfig: _router,
        locale: locale,
      ),
    );
  }
}
