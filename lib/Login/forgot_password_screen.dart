import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Theme/app_theme.dart';
import '../Translations/translations.dart';
import '../provider/app_provider.dart';
import '../services/api_service.dart';

// ═══════════════════════════════════════════════════════════════════════════
// SCREEN 1 — ForgotPasswordScreen
// User enters email → backend sends a reset link via Laravel Password::sendResetLink
// ═══════════════════════════════════════════════════════════════════════════
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  // FIX: was a global TextEditingController — never disposed, shared across
  // widget rebuilds. Now properly owned and disposed by this State.
  final _emailCtrl = TextEditingController();
  bool _sending = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _sending = true);

    try {
      final success = await context
          .read<AppProvider>()
          .forgotPassword(_emailCtrl.text.trim());

      // FIX: mounted guard — widget may have been unmounted during the async call
      if (!mounted) return;

      if (success) {
        setState(() {
          _sending = false;
          _sent = true;
        });
      } else {
        setState(() => _sending = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // Strip "Exception: " prefix that Dart adds automatically
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<AppProvider>().lang;
    final t = (String k) => Tr.get(k, lang);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          t('forgotPassword') ?? 'Forgot Password',
          style: const TextStyle(
              color: AppTheme.primary, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: _sent
              ? _SuccessView(email: _emailCtrl.text.trim(), t: t)
              : _FormView(
                  form: _form,
                  emailCtrl: _emailCtrl,
                  sending: _sending,
                  onSubmit: _send,
                  t: t,
                ),
        ),
      ),
    );
  }
}

// ── Form view (step 1) ─────────────────────────────────────────────────────
class _FormView extends StatelessWidget {
  final GlobalKey<FormState> form;
  final TextEditingController emailCtrl;
  final bool sending;
  final VoidCallback onSubmit;
  final String? Function(String) t;

  const _FormView({
    required this.form,
    required this.emailCtrl,
    required this.sending,
    required this.onSubmit,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_reset_rounded,
                  size: 40, color: AppTheme.primary),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            t('forgotPassword') ?? 'Forgot your password?',
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary),
          ),
          const SizedBox(height: 8),
          Text(
            t('forgotPasswordSub') ??
                'Enter your registered email and we\'ll send you a password reset link.',
            style: const TextStyle(
                fontSize: 14, color: AppTheme.textMuted, height: 1.5),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Please enter your email';
              }
              if (!v.contains('@') || !v.contains('.')) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: sending ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: sending
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  : Text(
                      t('sendResetLink') ?? 'Send Reset Link',
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Success view (shown after link sent) ───────────────────────────────────
class _SuccessView extends StatelessWidget {
  final String email;
  final String? Function(String) t;
  const _SuccessView({required this.email, required this.t});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        Container(
          width: 88,
          height: 88,
          decoration: const BoxDecoration(
              color: Color(0xFFE6F7EE), shape: BoxShape.circle),
          child: const Icon(Icons.mark_email_read_rounded,
              size: 44, color: Color(0xFF1B8A4B)),
        ),
        const SizedBox(height: 24),
        const Text(
          'Check your inbox!',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.primary),
        ),
        const SizedBox(height: 12),
        Text(
          'We sent a password reset link to\n$email\n\n'
          'Open the link in that email to choose a new password.',
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 14, color: AppTheme.textMuted, height: 1.6),
        ),
        const SizedBox(height: 36),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.primary),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Back to Login',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SCREEN 2 — ResetPasswordScreen
// FIX: VerifyCodeScreen was referenced but never defined anywhere in the
// codebase.  Laravel's default password reset uses a signed URL (no OTP
// code to verify in the app). This screen is the correct replacement:
// it collects new password + confirmation and calls ApiService.resetPassword.
// Navigate to it from a deep-link handler passing the email + token that
// Laravel appends to the reset URL.
// ═══════════════════════════════════════════════════════════════════════════
class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String token;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.token,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _saving = false;
  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      await ApiService.resetPassword(
        email: widget.email,
        code: widget.token,
        newPassword: _passCtrl.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset successfully! Please log in.'),
          backgroundColor: Color(0xFF1B8A4B),
        ),
      );
      // Pop back to login (first route)
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Set New Password',
          style:
              TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_outline_rounded,
                        size: 40, color: AppTheme.primary),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Create a new password',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your new password must be at least 8 characters.',
                  style: TextStyle(
                      fontSize: 14, color: AppTheme.textMuted, height: 1.5),
                ),
                const SizedBox(height: 32),

                // New password
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure1,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure1
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () => setState(() => _obscure1 = !_obscure1),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Enter a new password';
                    }
                    if (v.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm password
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: _obscure2,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure2
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () => setState(() => _obscure2 = !_obscure2),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (v != _passCtrl.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text(
                            'Reset Password',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
