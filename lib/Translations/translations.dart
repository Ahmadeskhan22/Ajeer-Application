// ================================================================
//  translations.dart — AJEER Seeker App
//  English / Arabic — updated to match SQL schema fields
// ================================================================
class Tr {
  static const Map<String, Map<String, String>> _t = {
    // ── App ─────────────────────────────────────────────────
    'appName': {'en': 'AJEER', 'ar': 'أجير'},
    'tagline': {'en': 'Flexible Jobs in Jordan', 'ar': 'وظائف مرنة في الأردن'},
    'switchLang': {'en': 'عربي', 'ar': 'English'},
    'save': {'en': 'Save', 'ar': 'حفظ'},
    'cancel': {'en': 'Cancel', 'ar': 'إلغاء'},
    'loading': {'en': 'Loading…', 'ar': 'جاري التحميل…'},
    'noData': {'en': 'No data found', 'ar': 'لا توجد بيانات'},
    'required': {'en': 'Required', 'ar': 'مطلوب'},

    // ── Nav ─────────────────────────────────────────────────
    'home': {'en': 'Home', 'ar': 'الرئيسية'},
    'browseJobs': {'en': 'Browse Jobs', 'ar': 'تصفح الوظائف'},
    'aiMatcher': {'en': 'AI Match', 'ar': 'التوافق الذكي'},
    'myApplications': {'en': 'Applications', 'ar': 'طلباتي'},
    'myProfile': {'en': 'Profile', 'ar': 'ملفي'},
    'logout': {'en': 'Logout', 'ar': 'خروج'},

    // ── Landing ──────────────────────────────────────────────
    'heroTitle': {
      'en': 'Find Your\nFlexible Job',
      'ar': 'ابحث عن\nوظيفتك المرنة'
    },
    'heroSub': {
      'en': 'Thousands of hourly & part-time jobs across Jordan',
      'ar': 'آلاف الوظائف بالساعة والدوام الجزئي في كل أنحاء الأردن'
    },
    'getStarted': {'en': 'Get Started', 'ar': 'ابدأ الآن'},
    'howItWorks': {'en': 'How It Works', 'ar': 'كيف يعمل'},
    'step1Title': {'en': 'Build Your Profile', 'ar': 'أنشئ ملفك الشخصي'},
    'step1Desc': {
      'en': 'Add your skills, experience & education.',
      'ar': 'أضف مهاراتك وخبراتك وتعليمك.'
    },
    'step2Title': {'en': 'Browse Jobs', 'ar': 'تصفح الوظائف'},
    'step2Desc': {
      'en': 'Search & filter jobs that match your skills.',
      'ar': 'ابحث وصفّح الوظائف التي تناسب مهاراتك.'
    },
    'step3Title': {'en': 'Apply & Work', 'ar': 'قدّم واعمل'},
    'step3Desc': {
      'en': 'One tap to apply. Get hired fast.',
      'ar': 'تقديم بنقرة واحدة. احصل على العمل سريعاً.'
    },
    'whyAjeer': {'en': 'Why AJEER?', 'ar': 'لماذا أجير؟'},
    'feat1Title': {'en': 'AI Matching', 'ar': 'توافق ذكي'},
    'feat1Desc': {
      'en': 'AI finds the best jobs for your skills automatically.',
      'ar': 'الذكاء الاصطناعي يجد أفضل الوظائف لمهاراتك تلقائياً.'
    },
    'feat2Title': {'en': 'Verified Jobs', 'ar': 'وظائف موثّقة'},
    'feat2Desc': {
      'en': 'All listings are verified by our team.',
      'ar': 'جميع الوظائف مراجعة ومعتمدة من فريقنا.'
    },
    'feat3Title': {'en': 'Fast Apply', 'ar': 'تقديم سريع'},
    'feat3Desc': {
      'en': 'Apply to multiple jobs with one profile.',
      'ar': 'قدّم لعدة وظائف بملف شخصي واحد.'
    },
    'feat4Title': {'en': 'Track Status', 'ar': 'تتبع الحالة'},
    'feat4Desc': {
      'en': 'Track all your applications in one place.',
      'ar': 'تابع جميع طلباتك في مكان واحد.'
    },

    // ── Auth ─────────────────────────────────────────────────
    'welcomeBack': {'en': 'Welcome Back!', 'ar': 'مرحباً بعودتك!'},
    'createAccount': {'en': 'Create Account', 'ar': 'إنشاء حساب'},
    'loginBtn': {'en': 'Login', 'ar': 'تسجيل الدخول'},
    'email': {'en': 'Email', 'ar': 'البريد الإلكتروني'},
    'password': {'en': 'Password', 'ar': 'كلمة المرور'},
    'noAccount': {'en': "Don't have an account?", 'ar': 'ليس لديك حساب؟'},
    'haveAccount': {
      'en': 'Already have an account?',
      'ar': 'لديك حساب بالفعل؟'
    },

    // ── Forgot password ──────────────────────────────────────
    'forgotPassword': {'en': 'Forgot Password?', 'ar': 'نسيت كلمة المرور؟'},
    'forgotTitle': {
      'en': 'Reset Your Password',
      'ar': 'إعادة تعيين كلمة المرور'
    },
    'forgotSub': {
      'en': 'Enter your email and we\'ll send you a reset link.',
      'ar': 'أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة التعيين.'
    },
    'sendResetLink': {'en': 'Send Reset Link', 'ar': 'إرسال رابط الإعادة'},
    'sending': {'en': 'Sending…', 'ar': 'جاري الإرسال…'},
    'resetSentTitle': {'en': 'Check Your Email!', 'ar': 'تحقق من بريدك!'},
    'resetSentBody': {
      'en': 'A password reset link has been sent to',
      'ar': 'تم إرسال رابط إعادة التعيين إلى'
    },
    'resetSentNote': {
      'en': 'Check your inbox and spam folder.',
      'ar': 'تحقق من صندوق الوارد ومجلد البريد غير الهام.'
    },
    'backToLogin': {'en': 'Back to Login', 'ar': 'العودة لتسجيل الدخول'},
    'invalidEmail': {
      'en': 'Please enter a valid email',
      'ar': 'أدخل بريدًا إلكترونيًا صحيحًا'
    },

    // ── Profile — SQL seeker_profiles fields ────────────────
    'profileTitle': {'en': 'My Profile', 'ar': 'ملفي الشخصي'},
    'editProfile': {'en': 'Edit', 'ar': 'تعديل'},
    'saveProfile': {'en': 'Save Profile', 'ar': 'حفظ الملف'},
    'profileSaved': {'en': 'Profile saved!', 'ar': 'تم حفظ الملف!'},
    'profileComplete': {'en': 'Profile Complete', 'ar': 'اكتمال الملف'},
    'completeProfile': {
      'en': 'Complete your profile to get better matches.',
      'ar': 'أكمل ملفك الشخصي للحصول على تطابق أفضل.'
    },

    // first_name / last_name
    'fullname': {'en': 'Full Name', 'ar': 'الاسم الكامل'},
    'firstName': {'en': 'First Name', 'ar': 'الاسم الأول'},
    //'lastName': {'en': 'Last Name', 'ar': 'اسم العائلة'},

    // age  TINYINT (16–70)
    'age': {'en': 'Age', 'ar': 'العمر'},
    'ageHint': {'en': '16 – 70', 'ar': '١٦ – ٧٠'},
    'ageError': {
      'en': 'Age must be 16–70',
      'ar': 'العمر يجب أن يكون بين ١٦ و٧٠'
    },

    // city ENUM
    'city': {'en': 'City', 'ar': 'المدينة'},
    'selectCity': {'en': 'Select city', 'ar': 'اختر المدينة'},

    // education ENUM
    'education': {'en': 'Education', 'ar': 'التعليم'},
    'selectEdu': {
      'en': 'Select education level',
      'ar': 'اختر المستوى التعليمي'
    },

    // experience TEXT
    'experience': {'en': 'Experience', 'ar': 'الخبرة'},

    // skills JSON
    'mySkills': {'en': 'My Skills', 'ar': 'مهاراتي'},
    'addSkill': {'en': 'Add skill…', 'ar': 'أضف مهارة…'},

    // ── Job fields — SQL Job table ────────────────────────────
    // Title
    'jobTitle': {'en': 'Job Title', 'ar': 'المسمى الوظيفي'},
    // Location VARCHAR(150)
    'location': {'en': 'Location', 'ar': 'الموقع'},
    // Salary DECIMAL(10,2) NULL
    'salary': {'en': 'Salary', 'ar': 'الراتب'},
    'perMonth': {'en': 'JD/mo', 'ar': 'دينار/شهر'},
    'salaryNA': {'en': 'Salary not specified', 'ar': 'الراتب غير محدد'},
    // Status ENUM
    'statusPending': {'en': 'Pending', 'ar': 'قيد المراجعة'},
    'statusApproved': {'en': 'Approved', 'ar': 'معتمدة'},
    'statusRejected': {'en': 'Rejected', 'ar': 'مرفوضة'},
    // CreatedAt
    'postedOn': {'en': 'Posted', 'ar': 'نُشرت'},

    // ── Browse Jobs ───────────────────────────────────────────
    'searchHint': {
      'en': 'Search jobs, skills…',
      'ar': 'ابحث عن وظائف، مهارات…'
    },
    'allCategories': {'en': 'All', 'ar': 'الكل'},
    'noJobs': {'en': 'No approved jobs found', 'ar': 'لا توجد وظائف معتمدة'},
    'applyNow': {'en': 'Apply Now', 'ar': 'تقدّم الآن'},
    'applied': {'en': 'Applied ✓', 'ar': 'تقدمت ✓'},
    'skills': {'en': 'Skills', 'ar': 'المهارات'},

    // ── Dashboard stats ───────────────────────────────────────
    'activeJobs': {'en': 'Available Jobs', 'ar': 'الوظائف المتاحة'},
    'appliedJobs': {'en': 'Applied', 'ar': 'تقدمت لها'},
    'acceptedJobs': {'en': 'Accepted', 'ar': 'مقبولة'},

    // ── AI Matcher ────────────────────────────────────────────
    'aiTitle': {'en': 'Smart Matching', 'ar': 'التوافق الذكي'},
    'aiSub': {
      'en': 'Smart Matching finds your best job matches instantly',
      'ar': 'خاصية التوافق الذكي يجد أفضل وظائفك في ثوانٍ'
    },
    'runAI': {'en': 'Find My Matches', 'ar': 'ابحث عن تطابقاتي'},
    'analyzing': {'en': 'Analyzing your profile…', 'ar': 'جاري تحليل ملفك…'},
    'topMatches': {'en': 'Your Top Matches', 'ar': 'أفضل تطابقاتك'},
    'matchRate': {'en': 'Match', 'ar': 'تطابق'},
    'excellent': {'en': 'Excellent', 'ar': 'ممتاز'},
    'good': {'en': 'Good', 'ar': 'جيد'},
    'fair': {'en': 'Fair', 'ar': 'متوسط'},
    'low': {'en': 'Low', 'ar': 'منخفض'},
    'needsProfile': {
      'en': 'Add skills to your profile first.',
      'ar': 'أضف مهارات إلى ملفك أولاً.'
    },
    'goToProfile': {'en': 'Go to Profile', 'ar': 'اذهب إلى الملف'},
    'analysed': {'en': 'Analysed', 'ar': 'تم تحليل'},
    'jobs': {'en': 'jobs', 'ar': 'وظيفة'},
    'avgMatch': {'en': 'Avg. match', 'ar': 'متوسط التطابق'},

    // ── My Applications ───────────────────────────────────────
    'appsTitle': {'en': 'My Applications', 'ar': 'طلباتي'},
    'noApps': {'en': 'No applications yet', 'ar': 'لا توجد طلبات بعد'},
    'noAppsSub': {
      'en': 'Browse jobs and start applying!',
      'ar': 'تصفح الوظائف وابدأ التقديم!'
    },
    'appliedOn': {'en': 'Applied', 'ar': 'تقدمت'},
    'statusNew': {'en': 'Under Review', 'ar': 'قيد المراجعة'},
    'statusAccepted': {'en': 'Accepted', 'ar': 'مقبول'},
    'total': {'en': 'Total', 'ar': 'الإجمالي'},
    'pending': {'en': 'Pending', 'ar': 'قيد المراجعة'},
  };

  static String get(String key, String lang) =>
      _t[key]?[lang] ?? _t[key]?['en'] ?? key;
}
