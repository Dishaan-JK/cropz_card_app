import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  static const String _authStateStepKey = 'auth_state_step';
  static const String _authPhoneKey = 'auth_phone_number';
  static const String _authDisplayNameKey = 'auth_display_name';
  static const String _authAccessTokenKey = 'auth_access_token';
  static const String _authJwtTokenKey = 'auth_jwt_token';

  bool _isHydrationStarted = false;

  @override
  AuthState build() {
    _hydrateFromDisk();
    return const AuthState();
  }

  Future<void> _hydrateFromDisk() async {
    if (_isHydrationStarted) {
      return;
    }
    _isHydrationStarted = true;
    final prefs = await SharedPreferences.getInstance();
    final stepName = prefs.getString(_authStateStepKey) ?? '';
    final step = _decodeStep(stepName);
    if (step == AuthStep.unauthenticated) {
      return;
    }

    state = state.copyWith(
      step: step,
      phoneNumber: prefs.getString(_authPhoneKey) ?? '',
      displayName: prefs.getString(_authDisplayNameKey) ?? '',
      accessToken: prefs.getString(_authAccessTokenKey) ?? '',
      jwtToken: prefs.getString(_authJwtTokenKey) ?? '',
      isSubmitting: false,
      clearError: true,
    );
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
    _persistState(state);

    Future<void>.delayed(const Duration(milliseconds: 650), () {
      if (state.step != AuthStep.loading || state.jwtToken != jwtToken) {
        return;
      }
      state = state.copyWith(step: AuthStep.authenticated);
      _persistState(state);
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
    _clearPersistedState();
  }

  Future<void> _persistState(AuthState authState) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authStateStepKey, _encodeStep(authState.step));
    await prefs.setString(_authPhoneKey, authState.phoneNumber);
    await prefs.setString(_authDisplayNameKey, authState.displayName);
    await prefs.setString(_authAccessTokenKey, authState.accessToken);
    await prefs.setString(_authJwtTokenKey, authState.jwtToken);
  }

  Future<void> _clearPersistedState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authStateStepKey);
    await prefs.remove(_authPhoneKey);
    await prefs.remove(_authDisplayNameKey);
    await prefs.remove(_authAccessTokenKey);
    await prefs.remove(_authJwtTokenKey);
  }

  String _encodeStep(AuthStep step) {
    switch (step) {
      case AuthStep.unauthenticated:
        return 'unauthenticated';
      case AuthStep.loading:
        return 'loading';
      case AuthStep.authenticated:
        return 'authenticated';
    }
  }

  AuthStep _decodeStep(String value) {
    switch (value) {
      case 'loading':
        return AuthStep.loading;
      case 'authenticated':
        return AuthStep.authenticated;
      default:
        return AuthStep.unauthenticated;
    }
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
