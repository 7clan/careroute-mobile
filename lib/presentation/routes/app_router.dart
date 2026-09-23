import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/appointments/appointments_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/doctors/doctor_detail_screen.dart';
import '../screens/doctors/doctors_screen.dart';
import '../screens/favorites/favorites_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/shell/home_shell.dart';
import '../screens/splash/splash_screen.dart';
import '../providers/session_providers.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Declarative navigation.
///
/// The router is rebuilt whenever the auth session changes; its `redirect`
/// decides where the user lands:
///
/// * restoring session → splash
/// * signed out → `/login` (auth routes stay reachable)
/// * signed in → `/home` (auth routes redirect away)
final appRouterProvider = Provider<GoRouter>((ref) {
  // Rebuild the router when the session changes (login / logout / expiry).
  ref.watch(sessionProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      final location = state.matchedLocation;
      final isAuthRoute = location == '/login' || location == '/register';

      if (session.isLoading) {
        // Restoring a stored session — hold on the splash route.
        return location == '/' ? null : '/';
      }
      if (session.hasError) {
        // Boot failed (e.g. no network). The splash shows the error + retry.
        return location == '/' ? null : '/';
      }

      final signedIn = session.value != null;
      if (!signedIn) return isAuthRoute ? null : '/login';
      if (isAuthRoute || location == '/') return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/doctors/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            DoctorDetailScreen(doctorId: state.pathParameters['id']!),
      ),
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state, navigationShell) =>
            HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const DoctorsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/saved',
                builder: (context, state) => const FavoritesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/appointments',
                builder: (context, state) => const AppointmentsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
