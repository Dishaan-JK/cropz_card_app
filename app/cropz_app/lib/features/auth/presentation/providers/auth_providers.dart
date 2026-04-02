import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthStep { unauthenticated, loading, authenticated }

class AuthState {
  const AuthState({
    this.step = AuthStep.unauthenticated,
    this.phoneNumber = '',
    this.displayName = '',
    this.accessToken = '',
    this.jwtToken = '',
    this.errorMessage,
    this.isSubmitting = false,
  });

  final AuthStep step;
  final String phoneNumber;
  final String displayName;
  final String accessToken;
  final String jwtToken;
  final String? errorMessage;
  final bool isSubmitting;

  bool get isAuthenticated => step == AuthStep.authenticated;

  AuthState copyWith({
    AuthStep? step,
    String? phoneNumber,
    String? displayName,
    String? accessToken,
    String? jwtToken,
    String? errorMessage,
    bool? isSubmitting,
    bool clearError = false,
  }) {
    return AuthState(
      step: step ?? this.step,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      accessToken: accessToken ?? this.accessToken,
      jwtToken: jwtToken ?? this.jwtToken,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState();
  }

  void markLoginInProgress() {
    state = state.copyWith(isSubmitting: true, clearError: true);
  }

  void completeLogin({
    required String accessToken,
    required String jwtToken,
    required String phoneNumber,
    required String firstName,
    required String lastName,
  }) {
    final fullName = [
      firstName.trim(),
      lastName.trim(),
    ].where((value) => value.isNotEmpty).join(' ');

    state = state.copyWith(
      step: AuthStep.loading,
      accessToken: accessToken,
      jwtToken: jwtToken,
      phoneNumber: phoneNumber,
      displayName: fullName,
      isSubmitting: false,
      clearError: true,
    );

    Future<void>.delayed(const Duration(milliseconds: 650), () {
      if (state.step != AuthStep.loading || state.jwtToken != jwtToken) {
        return;
      }
      state = state.copyWith(step: AuthStep.authenticated);
    });
  }

  void setError(String message) {
    state = state.copyWith(isSubmitting: false, errorMessage: message);
  }

  void clearError() {
    if (state.errorMessage == null) {
      return;
    }
    state = state.copyWith(clearError: true);
  }

  void logout() {
    state = const AuthState();
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
