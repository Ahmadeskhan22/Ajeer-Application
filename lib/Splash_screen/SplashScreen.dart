import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '/provider/app_provider.dart';
import '/Theme/app_theme.dart';

//TODO SplashScreen is first screen in app (onbordaring)  it's have  animation
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade, _scale;

  @override
  void initState() {
    super.initState();

    // 1. تشغيل الأنيميشن
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _scale = Tween<double>(begin: 0.6, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _ctrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      debugPrint("Ahmad: Fetching data in background...");
      context.read<AppProvider>().fetchJobs();

      await Future.delayed(const Duration(milliseconds: 2500));

      if (mounted) {
        debugPrint("Ahmad: Attempting to go to /browse-jobs");
        context.go('/browse-jobs');
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
        child: Center(
          //TODO inti  for AnimatedBuilder
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 110, // زدنا الحجم قليلاً للتناسب مع الشعار الجديد
                      height: 110,
                      decoration: BoxDecoration(
                        color:
                            Colors.white.withOpacity(0.15), // خلفية شفافة خفيفة
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
                          width: 50,
                          height: 50,
                          color: AppTheme.primary,
                          colorBlendMode: BlendMode
                              .srcIn, // لضمان صبغ الشعار بالكامل باللون الأبيض
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('AJEER',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2)),
                    const SizedBox(height: 6),
                    Text('أجير',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 22,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: 48,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation(
                            Colors.white.withOpacity(0.8)),
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
}
