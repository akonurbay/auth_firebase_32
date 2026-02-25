import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Вход')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (ctx, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (ctx, state) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passCtrl,
                  decoration: const InputDecoration(labelText: 'Пароль'),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                if (state is AuthLoading)
                  const CircularProgressIndicator()
                else ...[
                  ElevatedButton(
                    onPressed: () => context.read<AuthBloc>().add(
                          AuthSignIn(_emailCtrl.text.trim(), _passCtrl.text),
                        ),
                    child: const Text('Войти'),
                  ),
                  const SizedBox(height: 8),
                  // ElevatedButton.icon(
                  //   icon: const Icon(Icons.g_mobiledata),
                  //   label: const Text('Войти через Google'),
                  //   onPressed: () => context.read<AuthBloc>().add(AuthGoogleSignIn()),
                  // ),
                  TextButton(
                    onPressed: () => context.go('/register'),
                    child: const Text('Нет аккаунта? Зарегистрироваться'),
                  ),
                  // TextButton(
                  //   onPressed: () => context.go('/forgot-password'),
                  //   child: const Text('Забыл пароль?'),
                  // ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}