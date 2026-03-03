import 'dart:async';
import 'package:firebase_32/presentation/screeens/forgot_password_screen.dart';
import 'package:firebase_32/presentation/screeens/home_screen.dart';
import 'package:firebase_32/presentation/screeens/login_screen.dart';
import 'package:firebase_32/presentation/screeens/notes/note_form_screen.dart';
import 'package:firebase_32/presentation/screeens/notes/notes_screen.dart';
import 'package:firebase_32/presentation/screeens/register_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../models/note_model.dart';

class AppRouter {
  final AuthBloc authBloc;
  AppRouter(this.authBloc);

  late final router = GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final isAuthenticated = authBloc.state is AuthAuthenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password';

      if (!isAuthenticated && !isAuthRoute) return '/login';
      if (isAuthenticated && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login',           builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register',        builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: '/home',            builder: (_, __) => const HomeScreen()),

      // ── Notes ──────────────────────────────────────────────────
      GoRoute(
        path: '/notes',
        builder: (_, state) {
          final uid = state.extra as String;
          return NotesScreen(uid: uid);
        },
      ),
      GoRoute(
        path: '/notes/edit',
        builder: (_, state) {
          final args = state.extra as Map<String, dynamic>;
          return NoteFormScreen(
            uid: args['uid'] as String,
            note: args['note'] as NoteModel?,
          );
        },
      ),
    ],
  );
}

// ─── GoRouter Refresh Stream ───────────────────────────────────────────────
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}