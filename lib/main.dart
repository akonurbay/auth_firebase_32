import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/auth/auth_event.dart';
import 'bloc/notes/notes_bloc.dart';
import 'core/router/app_router.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/notes_repository.dart';

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
    final notesRepo = NotesRepository();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => authRepo),
        RepositoryProvider(create: (_) => notesRepo),
      ],
      child: Builder(
        builder: (context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => AuthBloc(authRepository: authRepo)..add(AuthStarted()),
              ),
              BlocProvider(
                create: (_) => NotesBloc(notesRepository: notesRepo),
              ),
            ],
            child: Builder(
              builder: (context) {
                return MaterialApp.router(
                  title: 'HW_33',
                  debugShowCheckedModeBanner: false,
                  theme: ThemeData(
                    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                    useMaterial3: true,
                  ),
                  routerConfig: AppRouter(context.read<AuthBloc>()).router,
                );
              },
            ),
          );
        },
      ),
    );
  }
}