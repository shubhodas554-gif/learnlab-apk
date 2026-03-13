import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/signup_screen.dart';
import 'features/home/home_screen.dart';
import 'features/home/lesson_screen.dart';
import 'features/home/leaderboard_screen.dart';
import 'features/home/profile_screen.dart';
import 'features/home/quiz_screen.dart';
import 'features/home/subject_screen.dart';
import 'features/home/tutor_screen.dart';
import 'features/splash/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authAsync = ref.watch(authStateProvider);
  final auth = ref.watch(firebaseAuthProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(auth.authStateChanges()),
    redirect: (context, state) {
      if (authAsync.isLoading) return state.location;
      final loggedIn = authAsync.asData?.value != null;
      final loggingIn = state.location == '/login' || state.location == '/signup';
      if (!loggedIn && !loggingIn) return '/login';
      if (loggedIn && (loggingIn || state.location == '/splash')) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
      GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/subjects', builder: (_, __) => const SubjectScreen()),
      GoRoute(path: '/lesson/:id', builder: (_, state) => LessonScreen(lessonId: state.pathParameters['id']!)),
      GoRoute(path: '/quiz/:id', builder: (_, state) => QuizScreen(lessonId: state.pathParameters['id']!)),
      GoRoute(path: '/tutor', builder: (_, __) => const TutorScreen()),
      GoRoute(path: '/leaderboard', builder: (_, __) => const LeaderboardScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    ],
  );
});
