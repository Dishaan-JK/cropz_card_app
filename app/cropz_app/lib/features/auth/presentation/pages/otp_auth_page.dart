import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone_email_auth/phone_email_auth.dart';

import '../../../../shared/core/config/otp_branding_config.dart';
import '../../../cropz_card/presentation/pages/cropz_card_home_page.dart';
import '../providers/auth_providers.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    if (auth.step == AuthStep.authenticated) {
      return const CropzCardHomePage();
    }
    if (auth.step == AuthStep.loading) {
      return const _AuthLoadingScreen();
    }
    return const OtpAuthPage();
  }
}

class _AuthLoadingScreen extends StatelessWidget {
  const _AuthLoadingScreen();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              scheme.primary.withValues(alpha: 0.14),
              scheme.secondary.withValues(alpha: 0.08),
              Theme.of(context).scaffoldBackgroundColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(strokeWidth: 2.6),
              ),
              SizedBox(height: 14),
              Text(
                'Preparing your workspace...',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OtpAuthPage extends ConsumerStatefulWidget {
  const OtpAuthPage({super.key});

  @override
  ConsumerState<OtpAuthPage> createState() => _OtpAuthPageState();
}

class _OtpAuthPageState extends ConsumerState<OtpAuthPage> {
  final PhoneEmail _phoneEmail = PhoneEmail();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final notifier = ref.read(authControllerProvider.notifier);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              scheme.primary.withValues(alpha: 0.14),
              const Color(0xFFEFF6FF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _AuthHero(),
                    const SizedBox(height: 18),
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 260),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          child: _buildProviderStep(state, notifier),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProviderStep(AuthState state, AuthController notifier) {
    return Column(
      key: const ValueKey('provider_step'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sign in with OTP',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'Secure login with your verified mobile number.',
          style: TextStyle(color: Colors.blueGrey.shade700),
        ),
        const SizedBox(height: 10),
        Text(
          'SMS sender (placeholder): ${OtpBrandingConfig.otpSenderId}',
          style: TextStyle(
            color: Colors.blueGrey.shade700,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (state.errorMessage != null) ...[
          const SizedBox(height: 10),
          _ErrorBanner(message: state.errorMessage!),
        ],
        const SizedBox(height: 16),
        if (!state.isSubmitting)
          Align(
            alignment: Alignment.center,
            child: PhoneLoginButton(
              borderRadius: 16,
              buttonColor: const Color(0xFF0F766E),
              label: 'Continue',
              onSuccess: (String accessToken, String jwtToken) {
                notifier.markLoginInProgress();
                if (accessToken.isEmpty || jwtToken.isEmpty) {
                  notifier.setError('Authentication token was empty.');
                  return;
                }
                PhoneEmail.getUserInfo(
                  accessToken: accessToken,
                  clientId: _phoneEmail.clientId,
                  onSuccess: (userData) {
                    final verifiedPhone = userData.phoneNumber ?? '';
                    if (verifiedPhone.isEmpty) {
                      notifier.setError('Verified phone number was empty.');
                      return;
                    }
                    notifier.completeLogin(
                      accessToken: accessToken,
                      jwtToken: jwtToken,
                      phoneNumber: verifiedPhone,
                      firstName: userData.firstName ?? '',
                      lastName: userData.lastName ?? '',
                    );
                  },
                );
              },
            ),
          )
        else
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.2),
              ),
            ),
          ),
      ],
    );
  }
}

class _AuthHero extends StatelessWidget {
  const _AuthHero();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.shield_moon_outlined, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome to Cropz Card',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'A fast, offline-first card manager for agri-business teams.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFB91C1C)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFFB91C1C)),
            ),
          ),
        ],
      ),
    );
  }
}
