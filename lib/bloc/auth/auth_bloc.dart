import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<AuthSignIn>(_onSignIn);
    on<AuthSignUp>(_onSignUp);
    on<AuthSignOut>(_onSignOut);
    on<AuthGoogleSignIn>(_onGoogleSignIn);
    on<AuthResetPassword>(_onResetPassword);
  }

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    await emit.forEach(
      authRepository.authStateChanges,
      onData: (User? user) =>
          user != null ? AuthAuthenticated(user) : AuthUnauthenticated(),
    );
  }

  Future<void> _onSignIn(AuthSignIn event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.signIn(email: event.email, password: event.password);
    } on FirebaseAuthException catch (e) {
      emit(AuthError(authRepository.getErrorMessage(e.code)));
    }
  }

  Future<void> _onSignUp(AuthSignUp event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.signUp(email: event.email, password: event.password);
    } on FirebaseAuthException catch (e) {
      emit(AuthError(authRepository.getErrorMessage(e.code)));
    }
  }

  Future<void> _onSignOut(AuthSignOut event, Emitter<AuthState> emit) async {
    await authRepository.signOut();
  }

  Future<void> _onGoogleSignIn(AuthGoogleSignIn event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.signInWithGoogle();
    } on FirebaseAuthException catch (e) {
      emit(AuthError(authRepository.getErrorMessage(e.code)));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onResetPassword(AuthResetPassword event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.resetPassword(event.email);
      emit(AuthPasswordResetSent());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(authRepository.getErrorMessage(e.code)));
    }
  }
}