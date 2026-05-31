import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../provider/app_provider.dart';
import '../Theme/app_theme.dart';
import '../Translations//translations.dart';
import '../widgets/GradBtn.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  bool _obscure = true, _loading = false;

  // ── Login fields ──────────────────────────────────────────────
  final _loginForm = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPasswordController =
      TextEditingController(); // ✅ الـ Controller الجديد
  // ── Register fields ───────────────────────────────────────────
  final _regForm = GlobalKey<FormState>();
  final _fullnameCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPassCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController(); // كنترولر رقم الهاتف

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    // تنظيف كل الـ controllers لمنع تسريب الذاكرة
    for (final c in [
      _emailCtrl,
      _passCtrl,
      _fullnameCtrl,
      _regEmailCtrl,
      _regPassCtrl,
      _phoneCtrl,
      _confirmPasswordController // ✅ أضفه هنا
    ]) {
      c.dispose();
    }
    _tab.dispose();
    super.dispose();
  }

  // ── Login ─────────────────────────────────────────────────────
  Future<void> _login() async {
    if (!_loginForm.currentState!.validate()) return;
    setState(() => _loading = true);
    final ok = await context
        .read<AppProvider>()
        .login(_emailCtrl.text.trim(), _passCtrl.text.trim());
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) context.go('/browse-jobs');
  }

  // ── Register ──────────────────────────────────────────────────
  Future<void> _register() async {
    if (!_regForm.currentState!.validate()) return;

    // ✅ التحقق من طول كلمة المرور (الباك إند يطلب 8 أحرف على الأقل)
    if (_regPassCtrl.text.trim().length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("كلمة المرور يجب أن تكون 8 أحرف على الأقل",
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final ok = await context.read<AppProvider>().register(
            fullname: _fullnameCtrl.text.trim(),
            email: _regEmailCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
            password: _regPassCtrl.text.trim(),
          );

      if (!mounted) return;
      setState(() => _loading = false);

      if (ok) context.go('/browse-jobs');
    } catch (e) {
      setState(() => _loading = false);
      // ✅ عرض رسالة الخطأ القادمة من السيرفر للمستخدم
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', ''),
              style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ── Forgot Password bottom sheet ──────────────────────────────
  void _showForgotPassword() {
    final lang = context.read<AppProvider>().lang;
    final t = (String k) => Tr.get(k, lang);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ForgotPasswordSheet(t: t, lang: lang),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final lang = prov.lang;
    final t = (String k) => Tr.get(k, lang);

    return Scaffold(
      body: Stack(
        children: [
          // Hero gradient background
          Container(
            height: MediaQuery.of(context).size.height * 0.42,
            decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                // ── Top bar ────────────────────────────────────
                Row(children: [
                  IconButton(
                    onPressed: () => context.go('/landing'),
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white),
                  ),
                  const Spacer(),
                  const Text('AJEER',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900)),
                  const Spacer(),
                  GestureDetector(
                    onTap: prov.toggleLang,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(t('switchLang'),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12)),
                    ),
                  ),
                ]),
                const SizedBox(height: 32),

                // ── Main card ──────────────────────────────────
                Container(
                  decoration: AppTheme.card,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(children: [
                      // Tabs: Login | Register
                      Container(
                        decoration: BoxDecoration(
                            color: AppTheme.bgLight,
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.all(4),
                        child: TabBar(
                          controller: _tab,
                          indicator: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: Colors.white,
                          unselectedLabelColor: AppTheme.textMuted,
                          labelStyle: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14),
                          dividerColor: Colors.transparent,
                          tabs: [
                            Tab(text: t('loginBtn')),
                            Tab(text: t('createAccount')),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Tab views
                      SizedBox(
                        height: _tab.index == 0 ? 300 : 460,
                        child: TabBarView(
                          controller: _tab,
                          children: [
                            // ══ LOGIN FORM ══════════════════════
                            Form(
                              key: _loginForm,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Email
                                    TextFormField(
                                      controller: _emailCtrl,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        labelText: t('email'),
                                        prefixIcon:
                                            const Icon(Icons.email_outlined),
                                      ),
                                      validator: (v) =>
                                          v!.isEmpty ? t('required') : null,
                                    ),
                                    const SizedBox(height: 14),

                                    // Password
                                    TextFormField(
                                      controller: _passCtrl,
                                      obscureText: _obscure,
                                      decoration: InputDecoration(
                                        labelText: t('password'),
                                        prefixIcon: const Icon(
                                            Icons.lock_outline_rounded),
                                        suffixIcon: IconButton(
                                          icon: Icon(_obscure
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined),
                                          onPressed: () => setState(
                                              () => _obscure = !_obscure),
                                        ),
                                      ),
                                      validator: (v) =>
                                          v!.length < 8 ? '8+ chars' : null,
                                    ),

                                    // ── Forgot Password link ────────
                                    Align(
                                      alignment: prov.isAr
                                          ? Alignment.centerLeft
                                          : Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: _showForgotPassword,
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4, vertical: 4),
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text(
                                          t('forgotPassword'),
                                          style: const TextStyle(
                                              color: AppTheme.primary,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    // Login button
                                    _loading
                                        ? const Center(
                                            child: CircularProgressIndicator())
                                        : GradBtn(
                                            label: t('loginBtn'),
                                            icon: Icons.login_rounded,
                                            onPressed: _login),
                                  ]),
                            ),

                            // ══ REGISTER FORM ═══════════════════
                            Form(
                              key: _regForm,
                              child: SingleChildScrollView(
                                child: Column(children: [
                                  // 1. Full Name
                                  TextFormField(
                                    controller: _fullnameCtrl,
                                    maxLength: 50,
                                    decoration: InputDecoration(
                                      labelText: t('fullname'),
                                      prefixIcon: const Icon(
                                          Icons.person_outline_rounded),
                                    ),
                                    validator: (v) =>
                                        v!.isEmpty ? t('required') : null,
                                  ),
                                  const SizedBox(height: 10),

                                  // 2. Email
                                  TextFormField(
                                    controller: _regEmailCtrl,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      labelText: t('email'),
                                      prefixIcon:
                                          const Icon(Icons.email_outlined),
                                    ),
                                    validator: (v) =>
                                        v!.isEmpty ? t('required') : null,
                                  ),
                                  const SizedBox(height: 10),

                                  // 3. Phone (رقم الهاتف بدلاً من تكرار كلمة المرور)
                                  TextFormField(
                                    controller: _phoneCtrl,
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    decoration: const InputDecoration(
                                      labelText:
                                          'رقم الهاتف', // يمكنك وضع t('phone') إذا كانت موجودة في الترجمة
                                      prefixIcon:
                                          Icon(Icons.phone_android_rounded),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty)
                                        return t('required');
                                      if (v.length != 10)
                                        return 'رقم الهاتف يجب أن يكون 10 أرقام';
                                      if (!v.startsWith('07'))
                                        return 'رقم الهاتف يجب أن يبدأ بـ 07';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 10),

                                  // 4. Password (تم إبقاء حقل واحد فقط)
                                  TextFormField(
                                    controller: _regPassCtrl,
                                    obscureText: _obscure,
                                    decoration: InputDecoration(
                                      labelText: t('password'),
                                      prefixIcon: const Icon(
                                          Icons.lock_outline_rounded),
                                      suffixIcon: IconButton(
                                        icon: Icon(_obscure
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined),
                                        onPressed: () => setState(
                                            () => _obscure = !_obscure),
                                      ),
                                    ),
                                    validator: (v) =>
                                        v!.length < 8 ? '8+ chars' : null,
                                  ),

                                  const SizedBox(height: 10),

                                  TextFormField(
                                    controller:
                                        _confirmPasswordController, // ✅ الربط بالكنترولر الجديد
                                    obscureText: _obscure,
                                    decoration: InputDecoration(
                                      labelText:
                                          'تأكيد كلمة المرور', // أو t('confirmPassword')
                                      prefixIcon:
                                          const Icon(Icons.lock_reset_rounded),
                                      suffixIcon: IconButton(
                                        icon: Icon(_obscure
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined),
                                        onPressed: () => setState(
                                            () => _obscure = !_obscure),
                                      ),
                                    ),
                                    // ✅ التحقق الفوري من التطابق
                                    validator: (v) {
                                      if (v == null || v.isEmpty)
                                        return t('required');
                                      if (v != _regPassCtrl.text)
                                        return 'كلمات المرور غير متطابقة';
                                      return null;
                                    },
                                  ),

                                  _loading
                                      ? const Center(
                                          child: CircularProgressIndicator())
                                      : GradBtn(
                                          label: t('createAccount'),
                                          icon: Icons.person_add_rounded,
                                          onPressed: _register),
                                ]),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Switch tab hint
                      Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          Text(
                            _tab.index == 0 ? t('noAccount') : t('haveAccount'),
                            style: const TextStyle(
                                color: AppTheme.textMuted, fontSize: 13),
                          ),
                          TextButton(
                            onPressed: () => setState(
                                () => _tab.animateTo(_tab.index == 0 ? 1 : 0)),
                            child: Text(
                              _tab.index == 0
                                  ? t('createAccount')
                                  : t('loginBtn'),
                              style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ]),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  _ForgotPasswordSheet
// ══════════════════════════════════════════════════════════════════
class _ForgotPasswordSheet extends StatefulWidget {
  final String Function(String) t;
  final String lang;
  const _ForgotPasswordSheet({required this.t, required this.lang});
  @override
  State<_ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<_ForgotPasswordSheet>
    with SingleTickerProviderStateMixin {
  final _form = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _sending = false;
  bool _sent = false;

  late AnimationController _checkCtrl;
  late Animation<double> _checkScale;

  @override
  void initState() {
    super.initState();
    _checkCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _checkScale = CurvedAnimation(parent: _checkCtrl, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _checkCtrl.dispose();
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

      if (!mounted) return;

      if (success) {
        setState(() {
          _sending = false;
          _sent = true;
        });
        _checkCtrl.forward();
      } else {
        setState(() => _sending = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4)),
            ),
            if (!_sent) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.lock_reset_rounded,
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t('forgotTitle'),
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textDark)),
                            const SizedBox(height: 3),
                            Text(t('forgotSub'),
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textMuted,
                                    height: 1.4)),
                          ],
                        ),
                      ),
                    ]),
                    const SizedBox(height: 24),
                    Form(
                      key: _form,
                      child: TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        autofocus: true,
                        decoration: InputDecoration(
                          labelText: t('email'),
                          hintText: 'you@example.com',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                  color: AppTheme.primary, width: 2)),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return t('required');
                          final emailRx =
                              RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');
                          if (!emailRx.hasMatch(v)) return t('invalidEmail');
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    _sending
                        ? Center(
                            child: Column(children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 10),
                            Text(t('sending'),
                                style: const TextStyle(
                                    color: AppTheme.textMuted, fontSize: 13))
                          ]))
                        : GradBtn(
                            label: t('sendResetLink'),
                            icon: Icons.send_rounded,
                            onPressed: _send),
                    const SizedBox(height: 12),
                    Center(
                        child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(t('cancel'),
                                style: const TextStyle(
                                    color: AppTheme.textMuted,
                                    fontWeight: FontWeight.w600)))),
                  ],
                ),
              ),
            ],
            if (_sent) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: Column(children: [
                  ScaleTransition(
                    scale: _checkScale,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                          color: AppTheme.success.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppTheme.success.withOpacity(0.4),
                              width: 2)),
                      child: const Icon(Icons.mark_email_read_rounded,
                          color: AppTheme.success, size: 46),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(t('resetSentTitle'),
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark)),
                  const SizedBox(height: 10),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 14, height: 1.5),
                      children: [
                        TextSpan(text: '${t('resetSentBody')} '),
                        TextSpan(
                            text: _emailCtrl.text.trim(),
                            style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w700)),
                        const TextSpan(text: '.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(t('resetSentNote'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 13)),
                  const SizedBox(height: 28),
                  GradBtn(
                      label: t('backToLogin'),
                      icon: Icons.arrow_back_rounded,
                      onPressed: () => Navigator.pop(context)),
                ]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
