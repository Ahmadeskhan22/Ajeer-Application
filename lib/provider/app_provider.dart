import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/SeekerProfile.dart';
import '../models/jobapplication.dart' hide JobStatus;
import '../models/Job.dart';
import '../services/api_service.dart';
import '../models/NotificationModel.dart';

class AppProvider extends ChangeNotifier {
  // ── Language ─────────────────────────────────────────────────
  String _lang = 'en';

  String get lang => _lang;

  bool get isAr => _lang == 'ar';

  Locale get locale => Locale(_lang);

  TextDirection get dir => isAr ? TextDirection.rtl : TextDirection.ltr;

  // ── Auth ──────────────────────────────────────────────────────
  bool _loggedIn = false;

  bool get loggedIn => _loggedIn;

  // ── Loading State ───────────────────────────────────────────
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  //for password
  String? oldPassword;
  String? newPassword;

  // ── Seeker Profile ────────────────────────────────────────────
  SeekerProfile _seeker = SeekerProfile.empty();

  SeekerProfile get seeker => _seeker;

  // ── Jobs ──────────────────────────────────────────────────────
  List<Job> _jobs = [];

  List<Job> get approvedJobs =>
      _jobs; // في الباك إند الـ index يعرض الـ Approved فقط[cite: 6]

  // ── Applications ──────────────────────────────────────────────
  List<JobApplication> _apps = [];

  List<JobApplication> get myApps => _apps;

  int get appliedCount => _apps.length;

  //int get acceptedCount => _apps.where((a) => a.status == 'accepted').length;

  // int get pendingCount => _apps.where((a) => a.status == 'new').length;

  int get acceptedCount =>
      _apps.where((a) => a.status.toLowerCase() == 'accepted').length;

// ✅ السيرفر يرسل 'Pending' وليس 'new'
  int get pendingCount =>
      _apps.where((a) => a.status.toLowerCase() == 'pending').length;

  //-_____Cities
  List<dynamic> _cities = [];

  List<dynamic> get cities => _cities;
  List<dynamic> _skillsCategories = [];

  List<dynamic> get skillsCategories => _skillsCategories;

  // BUG FIX #3: profile_screen called allSkills but the getter didn't exist.
  // Flatten the nested categories → skills list into SkillItem objects.
  List<SkillItem> get allSkills {
    final List<SkillItem> flat = [];
    for (final cat in _skillsCategories) {
      final catName = cat['category_name']?.toString() ?? '';
      final skills = cat['skills'] as List<dynamic>? ?? [];
      for (final s in skills) {
        flat.add(SkillItem(
          id: (s['skill_id'] as num).toInt(),
          name: s['skill_name']?.toString() ?? '',
          category: catName,
        ));
      }
    }
    return flat;
  }

  // ── Init --When run application─────────────────────────
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _lang = prefs.getString('ajeer_lang') ?? 'en';

    final token = prefs.getString('auth_token');
    _loggedIn = token != null && token.isNotEmpty;

    if (_loggedIn) {
      // fetch all data when run app
      await fetchMyProfile();
      await fetchJobs();
      await fetchMyApplications();
      await fetchNotifications();
      await fetchCities();
      await fetchSkills();
    }

    notifyListeners();
  }

  // ── Language ──────────────────────────────────────────────────
  Future<void> toggleLang() async {
    _lang = _lang == 'en' ? 'ar' : 'en';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ajeer_lang', _lang);
    notifyListeners();
  }

  // ── Auth (ربط تسجيل الدخول مع API) ──────────────────────────
  Future<bool> login(String email, String password) async {
    try {
      await ApiService.login(email, password);
      _loggedIn = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('ajeer_logged_in', true);

      // Fetch all data needed for the app after login
      await Future.wait([
        fetchMyProfile(),
        fetchJobs(),
        fetchMyApplications(),
        fetchNotifications(),
        fetchCities(),
        fetchSkills(),
      ]);

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Login error: $e");
      return false;
    }
  }

  Future<bool> register({
    required String fullname,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      await ApiService.register(fullname, email, phone, password);
      _loggedIn = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('ajeer_logged_in', true);

      // Fetch all data needed after registration
      await Future.wait([
        fetchMyProfile(),
        fetchJobs(),
        fetchCities(),
        fetchSkills(),
      ]);

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Register error: $e");
      rethrow; // preserve original exception type for UI
    }
  }

  Future<void> logout() async {
    try {
      await ApiService.logout();
    } catch (e) {
      debugPrint("Logout from server failed, clearing local data anyway.");
    }

    // Clear ALL cached state so no stale data survives to next login
    _loggedIn = false;
    _seeker = SeekerProfile.empty();
    _jobs = [];
    _apps = [];
    _notifications = [];
    _unreadNotificationsCount = 0;
    _cachedMatches = [];
    _cities = [];
    _skillsCategories = [];

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.setBool('ajeer_logged_in', false);

    notifyListeners();
  }

  // ── Profile (ربط البروفايل مع API) ──────────────────────────

  Future<void> fetchMyProfile() async {
    _isLoading = true;
    notifyListeners();
    // Change password

    try {
      final data = await ApiService.getProfile(); // ✅ طلب البيانات الحقيقية
      _seeker = SeekerProfile.fromJson(data);
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveProfileData(
    SeekerProfile updatedProfile,
    // ignore: avoid_unused_parameters — kept for call-site compatibility
    dynamic _newImage, {
    String? oldPassword,
    String? newPassword,
  }) async {
    try {
      // 1. Update basic info (name, phone)
      await ApiService.updateProfile({
        'name': updatedProfile.fullname,
        'phone': updatedProfile.phone,
      });

      // 2. Change password if both fields provided
      if (oldPassword != null &&
          newPassword != null &&
          oldPassword.isNotEmpty &&
          newPassword.isNotEmpty) {
        await ApiService.changePassword(
          currentPassword: oldPassword,
          newPassword: newPassword,
        );
      }

      // 3. Update city
      if (updatedProfile.city != null && updatedProfile.city!.isNotEmpty) {
        await ApiService.updateCity(updatedProfile.city!);
      }

      // 4. Sync skills by ID
      if (updatedProfile.skills.isNotEmpty) {
        await ApiService.syncUserSkills(updatedProfile.skillIds);
      }

      // 5. Sync availability slots:
      final existingIds =
          _seeker.availabilitySlots.map((s) => s.id).whereType<int>().toSet();
      final updatedIds = updatedProfile.availabilitySlots
          .map((s) => s.id)
          .whereType<int>()
          .toSet();

      // Delete removed slots
      for (final id in existingIds.difference(updatedIds)) {
        await ApiService.deleteAvailability(id);
      }

      // Add new slots (those without an id from the server)
      for (final slot in updatedProfile.availabilitySlots) {
        if (slot.id == null) {
          // : تنظيف البيانات قبل إرسالها للسيرفر
          String backendDate = _formatDateForBackend(slot.date);
          String backendTime = _formatTimeForBackend(slot.time);

          await ApiService.addAvailability(backendDate, backendTime);
        }
      }

      // 6. Re-fetch to sync server state
      await fetchMyProfile();
    } catch (e) {
      debugPrint("Error saving profile: $e");
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // ─────────────────────────────────────────────────────────────────

  // تمن DD/MM/YYYY إلى YYYY-MM-DD
  String _formatDateForBackend(String date) {
    if (!date.contains('/')) return date;
    try {
      List<String> parts = date.split('/');
      return "${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}";
    } catch (e) {
      return date;
    }
  }

  // تحويل الوقت من نظام 12 ساعة (AM/PM) إلى نظام 24 ساعة (HH:mm)
  String _formatTimeForBackend(String time) {
    String t = time.toUpperCase().trim();
    if (!t.contains('AM') && !t.contains('PM')) return t;

    try {
      bool isPM = t.contains('PM');
      String cleanTime = t.replaceAll('AM', '').replaceAll('PM', '').trim();
      List<String> parts = cleanTime.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      if (isPM && hour < 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;

      return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return time;
    }
  }

  // ── Applications (ما زالت تستخدم البيانات الوهمية مؤقتاً) ──
  bool hasApplied(int jobId) => _apps.any((a) => a.jobId == jobId);

  Future<bool> applyToJob(int jobId, {String? message}) async {
    try {
      // إرسال طلب التقديم للسيرفر (يرجع 201 في حال النجاح)
      final success = await ApiService.applyToJob(jobId, message);

      if (success) {
        // تحديث قائمة "طلباتي" فوراً لتعكس التغيير في الواجهة
        await fetchMyApplications();
        // إعادة جلب الوظائف لتحديث حالة "Applied" في القائمة الرئيسية
        await fetchJobs();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Apply error: $e");
      return false;
    }
  }

  Future<void> fetchJobs({String? search}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.getJobs(search: search);

      // ✅ 1. اطبع البيانات الخام اللي واصلة من السيرفر
      debugPrint("Raw Response: $response");

      // ✅ 2. تأكد من وجود مفتاح 'data' وأن قيمته قائمة (List)
      if (response['data'] != null) {
        final List<dynamic> jobsData = response['data'];
        _jobs = jobsData.map((j) => Job.fromJson(j)).toList();
        debugPrint("Jobs mapped successfully: ${_jobs.length} jobs");
      }
    } catch (e) {
      // ✅ 3. اطبع الخطأ كامل مع مكان حدوثه (StackTrace)
      debugPrint("Error fetching jobs: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
      // ✅ 4. نصيحة: إذا كنت في شاشة Splash، لازم تنادي أمر الانتقال هون
      // حتى لو فشل التحميل، عشان المستخدم ما يضل معلق.
    }
  }

  Future<void> fetchMyApplications() async {
    try {
      final data = await ApiService.getMyApplications();
      _apps = data.map((a) => JobApplication.fromJson(a)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching apps: $e");
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      // طلب الإرسال من السيرفر
      return await ApiService.forgotPassword(email);
    } catch (e) {
      // إعادة رمي الخطأ ليتم التقاطه في الـ Catch الموجود في شاشة الدخول
      rethrow;
    }
  }

  // دالة إلغاء الطلب وتحديث القائمة
  Future<bool> cancelApplication(int applicationId) async {
    try {
      final success = await ApiService.cancelApplication(applicationId);
      if (success) {
        // تحديث القائمة المحلية فوراً لتعكس أن الطلب أصبح "Canceled"[cite: 3]
        await fetchMyApplications();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error canceling application: $e");
      return false;
    }
  }

  // ── Notifications ───────────────────────────────────────────
  List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications => _notifications;

  int _unreadNotificationsCount = 0;

  int get unreadNotificationsCount => _unreadNotificationsCount;

  // دالة جلب الإشعارات
  Future<void> fetchNotifications() async {
    try {
      final response = await ApiService.getNotifications();

      // تحويل البيانات من السيرفر لقائمة من الـ Models[cite: 7]
      final List<dynamic> data = response['data'];
      _notifications = data.map((n) => NotificationModel.fromJson(n)).toList();

      // أخذ عدد الإشعارات الغير مقروءة من الـ Meta[cite: 7]
      _unreadNotificationsCount = response['meta']['unread_count'] ?? 0;

      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
    }
  }

  // دالة قراءة إشعار واحد
  Future<void> markNotificationAsRead(int id) async {
    try {
      final success = await ApiService.markNotificationAsRead(id);
      if (success) {
        // تحديث الحالة محلياً بدون ما نرجع نطلب من السيرفر (عشان السرعة)
        final index = _notifications.indexWhere((n) => n.id == id);
        if (index != -1 && !_notifications[index].isRead) {
          _notifications[index].isRead = true;
          _unreadNotificationsCount = (_unreadNotificationsCount > 0)
              ? _unreadNotificationsCount - 1
              : 0;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("Error marking notification: $e");
    }
  }

  // دالة قراءة الكل دفعة واحدة
  Future<void> markAllNotificationsAsRead() async {
    try {
      final success = await ApiService.markAllNotificationsAsRead();
      if (success) {
        for (var n in _notifications) {
          n.isRead = true;
        }
        _unreadNotificationsCount = 0;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error marking all notifications: $e");
    }
  }

  // دالة حذف إشعار واحد — مستخدمة في notifications_screen عند السحب
  Future<void> deleteNotification(int id) async {
    // Optimistic local removal for instant UI response
    _notifications.removeWhere((n) => n?.id == id);
    if (_unreadNotificationsCount > 0) {
      // Adjust unread count if the deleted notification was unread
      _unreadNotificationsCount = _notifications.where((n) => !n.isRead).length;
    }
    notifyListeners();

    // Persist deletion on server
    try {
      await ApiService.deleteNotification(id);
    } catch (e) {
      debugPrint("Error deleting notification: $e");
      // Re-fetch to restore correct state if server call failed
      await fetchNotifications();
    }
  }

// to feitch cities
  Future<void> fetchCities() async {
    try {
      _cities = await ApiService.getCities();
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching cities: $e");
    }
  }

  // دالة إضافة وقت التوفر وتحديث الواجهة
  Future<bool> addAvailability(String date, String time) async {
    try {
      final ok = await ApiService.addAvailability(date, time);
      if (ok) {
        // إعادة جلب البروفايل لضمان الحصول على الـ ID الخاص بالوقت الجديد من السيرفر[cite: 8]
        await fetchMyProfile();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Availability Error: $e");
      return false;
    }
  }

  // دالة حذف وقت التوفر
  Future<void> removeAvailability(int id) async {
    try {
      final ok = await ApiService.deleteAvailability(id);
      if (ok) {
        // BUG FIX #6: was comparing slot.date (a date string) against id (int).
        // Must compare slot.id (the availability_id from the server).
        _seeker = _seeker.copyWith(
          availabilitySlots:
              _seeker.availabilitySlots.where((slot) => slot.id != id).toList(),
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Delete Availability Error: $e");
    }
  }

  // ── Smart  Matching ───────────────────────────────────────────────
  // BUG FIX #5: Old calcMatch() cast List<SkillItem> to List<String> at runtime
  // (CastError), and ignored the backend MatchingService entirely.
  // Now getTopMatches() calls the real /jobs/match endpoint which scores by
  // skills + city + availability. Falls back to local scoring only if the
  // network call fails.
  List<Map<String, dynamic>> _cachedMatches = [];

  List<Map<String, dynamic>> get cachedMatches => _cachedMatches;

  // Alias used by my_applications_screen and other UI screens.
  // Returns the same cached list from the last fetchTopMatches() call.
  List<Map<String, dynamic>> get matchedJobs => _cachedMatches;

  Future<List<Map<String, dynamic>>> fetchTopMatches() async {
    try {
      final response = await ApiService.getMatchedJobs();
      // Safe cast: filter only Map elements to avoid runtime CastError
      _cachedMatches = response.whereType<Map<String, dynamic>>().toList();
      notifyListeners();
      return _cachedMatches;
    } catch (e) {
      debugPrint("Match fetch failed, using local fallback: $e");
      return _localTopMatches();
    }
  }

  // Local fallback — correctly uses skill names via .skillNames
  // داخل ملف app_provider.dart
  List<Map<String, dynamic>> _localTopMatches({int top = 5}) {
    final seekerSkills = _seeker.skillNames;
    final results = approvedJobs.map((job) {
      final jobSkills = job.skills.map((s) => s.skillName).toList();
      int score = 20;
      if (jobSkills.isNotEmpty && seekerSkills.isNotEmpty) {
        final matched = jobSkills.where((s) => seekerSkills.contains(s)).length;
        final direct = (matched / jobSkills.length) * 100;
        score = direct.round().clamp(0, 100);
      }
      // ✅ التعديل هنا: نرجع الخريطة بنفس شكل السيرفر عشان الشاشة ما تضرب
      return {
        'job': {
          'job_id': job.jobId,
          'title': job.title,
          'location': job.location,
          'salary': job.salary,
          'skills': job.skills.map((s) => {'skill_name': s.skillName}).toList(),
        },
        'score': score
      };
    }).toList()
      ..sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
    return results.take(top).toList();
  }

  // Keep old name as a sync alias so existing UI code doesn't break
  List<Map<String, dynamic>> getTopMatches({int top = 5}) =>
      _cachedMatches.isNotEmpty
          ? _cachedMatches.take(top).toList()
          : _localTopMatches(top: top);

  Future<void> fetchSkills() async {
    try {
      _skillsCategories = await ApiService.getSkills();
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching skills: $e");
    }
  }
}
