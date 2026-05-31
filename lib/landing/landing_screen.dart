import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../provider/app_provider.dart';
import '../Theme/app_theme.dart';
import '../Translations//translations.dart';
import '../Widgets/GradBtn.dart';
import '../Widgets/LangFb.dart';

//TODO interodution screen to show  Key features for appliaction "AJEER"
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final lang = prov.lang;
    final t = (String k) => Tr.get(k, lang);

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _HeroSection(t: t, prov: prov),
                _HowItWorksSection(t: t),
                _FeaturesSection(t: t),
                _CtaSection(t: t),
                const SizedBox(height: 40),
              ],
            ),
          ),
          LangFb(),
        ],
      ),
    );
  }
}

// ── Hero ──────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  final String Function(String) t;
  final AppProvider prov;
  const _HeroSection({required this.t, required this.prov});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 56),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(
                        color: Colors.white24, width: 1.5), // إطار نحيف
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10))
                    ],
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/bug.png', // تأكد من تسمية الملف بهذا الاسم في مجلد assets
                      width: 25,
                      height: 25,
                      color: AppTheme.primary,
                      colorBlendMode: BlendMode
                          .srcIn, // لضمان صبغ الشعار بالكامل باللون الأبيض
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text('AJEER',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1)),
              ]),
              TextButton(
                //TODO    after  enter this button go to login screen
                onPressed: () => context.go('/login'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white.withOpacity(0.15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(t('loginBtn'),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 52),

          // Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: AppTheme.primary.withOpacity(0.5)),
            ),
            child: Text(t('tagline'),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 16),

          // Hero title
          Text(t('heroTitle'),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  height: 1.2)),
          const SizedBox(height: 14),
          Text(t('heroSub'),
              style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 15,
                  height: 1.5)),
          const SizedBox(height: 36),

          // CTA
          GradBtn(
            label: t('getStarted'),
            icon: Icons.arrow_forward_rounded,
            onPressed: () => context.go('/login'),
          ),
          const SizedBox(height: 44),

          // Stats row
          Row(children: [
            _StatBox('10+', 'Jobs', Colors.blue.shade300),
            const SizedBox(width: 10),
            _StatBox('10+', 'Seekers', Colors.green.shade300),
            const SizedBox(width: 10),
            _StatBox('98%', 'Satisfaction', Colors.purple.shade300),
          ]),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatBox(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Text(value,
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.w900, fontSize: 20)),
              const SizedBox(height: 2),
              Text(label,
                  style: const TextStyle(color: Colors.white60, fontSize: 11)),
            ],
          ),
        ),
      );
}

// ── How it works ──────────────────────────────────────────────
class _HowItWorksSection extends StatelessWidget {
  final String Function(String) t;
  const _HowItWorksSection({required this.t});

  @override
  Widget build(BuildContext context) {
    final steps = [
      (
        Icons.manage_accounts_rounded,
        '1',
        'step1Title',
        'step1Desc',
        AppTheme.primary
      ),
      (
        Icons.search_rounded,
        '2',
        'step2Title',
        'step2Desc',
        AppTheme.secondary
      ),
      (Icons.send_rounded, '3', 'step3Title', 'step3Desc', AppTheme.accent),
    ];

    return Container(
      color: AppTheme.bgLight,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
      child: Column(
        children: [
          Text(t('howItWorks'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark)),
          const SizedBox(height: 28),
          ...steps.map((s) {
            final (icon, num, titleKey, descKey, color) = s;
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: AppTheme.card,
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(icon, color: color, size: 26),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                                color: color, shape: BoxShape.circle),
                            child: Center(
                                child: Text(num,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900))),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t(titleKey),
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppTheme.textDark)),
                        const SizedBox(height: 3),
                        Text(t(descKey),
                            style: const TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 12,
                                height: 1.4)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Features ──────────────────────────────────────────────────
class _FeaturesSection extends StatelessWidget {
  final String Function(String) t;
  const _FeaturesSection({required this.t});

  @override
  Widget build(BuildContext context) {
    final feats = [
      (Icons.auto_awesome_rounded, AppTheme.accent, 'feat1Title', 'feat1Desc'),
      (Icons.verified_rounded, AppTheme.success, 'feat2Title', 'feat2Desc'),
      (Icons.flash_on_rounded, AppTheme.primary, 'feat3Title', 'feat3Desc'),
      (
        Icons.track_changes_rounded,
        AppTheme.warning,
        'feat4Title',
        'feat4Desc'
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        children: [
          Text(t('whyAjeer'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark)),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.0,
            children: feats.map((f) {
              final (icon, color, titleKey, descKey) = f;
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.card,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12)),
                      child: Icon(icon, color: color, size: 22),
                    ),
                    const SizedBox(height: 12),
                    Text(t(titleKey),
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            color: AppTheme.textDark)),
                    const SizedBox(height: 5),
                    Text(t(descKey),
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                            height: 1.4)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── CTA ───────────────────────────────────────────────────────
//TODO TO KEEP FORWORD AND  GO LOGIN SECREEN
class _CtaSection extends StatelessWidget {
  final String Function(String) t;
  const _CtaSection({required this.t});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              const Icon(Icons.rocket_launch_rounded,
                  color: Colors.white, size: 44),
              const SizedBox(height: 14),
              Text(t('createAccount'),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(t('heroSub'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.8), fontSize: 13)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primary),
                child: Text(t('getStarted'),
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      );
}
