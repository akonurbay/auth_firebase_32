import 'package:firebase_32/bloc/auth/auth_event.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'bloc/auth/auth_bloc.dart';
import 'core/router/app_router.dart';
import 'data/repositories/auth_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = AuthRepository();
    return BlocProvider(
      create: (_) => AuthBloc(authRepository: authRepo)..add(AuthStarted()),
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            title: 'HW_32',
            routerConfig: AppRouter(context.read<AuthBloc>()).router,
          );
        },
      ),
    );
  }
}