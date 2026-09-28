import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../../../core/security/secure_storage.dart';

// ── Events ────────────────────────────────────────────────────
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckStatusEvent extends AuthEvent {
  const AuthCheckStatusEvent();
}

class AuthLoginEvent extends AuthEvent {
  final String email;
  final String password;
  const AuthLoginEvent({required this.email, required this.password});
  @override
  List<Object?> get props => [email];
}

class AuthRegisterEvent extends AuthEvent {
  final RegisterParams params;
  const AuthRegisterEvent(this.params);
}

class AuthLogoutEvent extends AuthEvent {
  const AuthLogoutEvent();
}

class AuthChangeLocaleEvent extends AuthEvent {
  final Locale locale;
  const AuthChangeLocaleEvent(this.locale);
  @override
  List<Object?> get props => [locale];
}

// ── States ────────────────────────────────────────────────────
abstract class AuthState extends Equatable {
  final Locale locale;
  const AuthState({this.locale = const Locale('ar')});
  @override
  List<Object?> get props => [locale];
}

class AuthInitial extends AuthState {
  const AuthInitial({super.locale});
}

class AuthLoading extends AuthState {
  const AuthLoading({super.locale});
}

class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated({required this.user, super.locale});
  @override
  List<Object?> get props => [user, locale];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated({super.locale});
}

class AuthError extends AuthState {
  final String message;
  const AuthError({required this.message, super.locale});
  @override
  List<Object?> get props => [message, locale];
}

class AuthRegistered extends AuthState {
  final User user;
  const AuthRegistered({required this.user, super.locale});
}

// ── BLoC ──────────────────────────────────────────────────────
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final SecureStorageService secureStorage;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.secureStorage,
  }) : super(const AuthInitial()) {
    on<AuthCheckStatusEvent>(_onCheck);
    on<AuthLoginEvent>(_onLogin);
    on<AuthRegisterEvent>(_onRegister);
    on<AuthLogoutEvent>(_onLogout);
    on<AuthChangeLocaleEvent>(_onLocale);
  }

  Locale get _locale => state.locale;

  Future<void> _onCheck(
    AuthCheckStatusEvent e,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(locale: _locale));
    final token = await secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      emit(AuthUnauthenticated(locale: _locale));
    } else {
      emit(AuthUnauthenticated(locale: _locale));
    }
  }

  Future<void> _onLogin(
    AuthLoginEvent e,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(locale: _locale));
    final result = await loginUseCase(
      LoginParams(email: e.email, password: e.password),
    );
    result.fold(
      (f) => emit(AuthError(message: f.message, locale: _locale)),
      (user) =>
          emit(AuthAuthenticated(user: user, locale: _locale)),
    );
  }

  Future<void> _onRegister(
    AuthRegisterEvent e,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(locale: _locale));
    final result = await registerUseCase(e.params);
    result.fold(
      (f) => emit(AuthError(message: f.message, locale: _locale)),
      (user) => emit(AuthRegistered(user: user, locale: _locale)),
    );
  }

  Future<void> _onLogout(
    AuthLogoutEvent e,
    Emitter<AuthState> emit,
  ) async {
    await logoutUseCase();
    emit(AuthUnauthenticated(locale: _locale));
  }

  void _onLocale(
    AuthChangeLocaleEvent e,
    Emitter<AuthState> emit,
  ) {
    emit(AuthInitial(locale: e.locale));
  }
}
