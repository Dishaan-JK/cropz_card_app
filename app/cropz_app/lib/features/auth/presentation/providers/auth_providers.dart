import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthStep { unauthenticated, loading, authenticated }
enum UserType { dealer, agriSpecialist, companyStaff, farmer }

class AuthState {
  const AuthState({
    this.step = AuthStep.unauthenticated,
    this.phoneNumber = '',
    this.displayName = '',
    this.accessToken = '',
    this.jwtToken = '',
    this.userType,
    this.errorMessage,
    this.isSubmitting = false,
  });

  final AuthStep step;
  final String phoneNumber;
  final String displayName;
  final String accessToken;
  final String jwtToken;
  final UserType? userType;
  final String? errorMessage;
  final bool isSubmitting;

  bool get isAuthenticated => step == AuthStep.authenticated;

  AuthState copyWith({
    AuthStep? step,
    String? phoneNumber,
    String? displayName,
    String? accessToken,
    String? jwtToken,
    UserType? userType,
    String? errorMessage,
    bool? isSubmitting,
    bool clearError = false,
    bool clearUserType = false,
  }) {
    return AuthState(
      step: step ?? this.step,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      accessToken: accessToken ?? this.accessToken,
      jwtToken: jwtToken ?? this.jwtToken,
      userType: clearUserType ? null : userType ?? this.userType,
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
  static const String _authUserTypeKey = 'auth_user_type';

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
      userType: _decodeUserType(prefs.getString(_authUserTypeKey)),
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
      clearUserType: true,
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

  Future<void> setUserType(UserType userType) async {
    state = state.copyWith(userType: userType);
    await _persistState(state);
  }

  Future<void> _persistState(AuthState authState) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authStateStepKey, _encodeStep(authState.step));
    await prefs.setString(_authPhoneKey, authState.phoneNumber);
    await prefs.setString(_authDisplayNameKey, authState.displayName);
    await prefs.setString(_authAccessTokenKey, authState.accessToken);
    await prefs.setString(_authJwtTokenKey, authState.jwtToken);
    await prefs.setString(
      _authUserTypeKey,
      authState.userType == null ? '' : _encodeUserType(authState.userType!),
    );
  }

  Future<void> _clearPersistedState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authStateStepKey);
    await prefs.remove(_authPhoneKey);
    await prefs.remove(_authDisplayNameKey);
    await prefs.remove(_authAccessTokenKey);
    await prefs.remove(_authJwtTokenKey);
    await prefs.remove(_authUserTypeKey);
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

  String _encodeUserType(UserType userType) {
    switch (userType) {
      case UserType.dealer:
        return 'dealer';
      case UserType.agriSpecialist:
        return 'agri_specialist';
      case UserType.companyStaff:
        return 'company_staff';
      case UserType.farmer:
        return 'farmer';
    }
  }

  UserType? _decodeUserType(String? rawValue) {
    switch (rawValue) {
      case 'dealer':
        return UserType.dealer;
      case 'agri_specialist':
        return UserType.agriSpecialist;
      case 'company_staff':
        return UserType.companyStaff;
      case 'farmer':
        return UserType.farmer;
      default:
        return null;
    }
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
