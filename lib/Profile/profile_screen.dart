import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../Theme/app_theme.dart';
import '../Translations/translations.dart';
import '../Widgets/GradBtn.dart';
import '../Widgets/Seeker_BottomNavi.dart';
import '../models/SeekerProfile.dart';
import '../provider/app_provider.dart';
import '../services/api_service.dart';
import '../widgets/StatCard.dart';
import '../widgets/AvailabilityWidget.dart'; // ✅ تم تفعيل الاستدعاء

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _editing = false, _saving = false;
  final _formKey = GlobalKey<FormState>();

  List<AvailabilitySlot> _availabilitySlots = []; // ✅ متغير حفظ الأوقات

  late TextEditingController _fullnameCtrl;
  late TextEditingController _expCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  late List<SkillItem> _skills;
  File? _selectedImage;

  String? _selectedCity;
  @override
  void initState() {
    super.initState();
    _load(context.read<AppProvider>().seeker);

    // Fix 1: cities were never fetched → dropdown always empty
    // Fix 2: skills were never fetched → allSkills always returns []
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<AppProvider>();
      if (prov.cities.isEmpty) prov.fetchCities();
      if (prov.skillsCategories.isEmpty) prov.fetchSkills();
    });
  }

  void _load(SeekerProfile p) {
    _fullnameCtrl = TextEditingController(text: p.fullname);
    _expCtrl = TextEditingController(text: p.experience ?? '');
    _emailCtrl = TextEditingController(text: p.email);
    _phoneCtrl = TextEditingController(text: p.phone ?? '');
    _skills = List.from(p.skills);
    _selectedImage = null;
    _oldPassCtrl.clear();
    _newPassCtrl.clear();
    _confirmPassCtrl.clear();
    _availabilitySlots =
        List.from(p.availabilitySlots); // ✅ تحميل الأوقات من الداتا بيس
    _selectedCity = p.city;
  }

  @override
  void dispose() {
    _fullnameCtrl.dispose();
    _expCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _showSkillSelector(Function t) {
    // Use skillsCategories (grouped) instead of flat allSkills,
    // so the UI matches the backend DataController response exactly:
    // [{category_id, category_name, icon, skills:[{skill_id, skill_name}]}]
    final categories = context.read<AppProvider>().skillsCategories;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.92,
          builder: (_, scrollCtrl) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4)),
              ),
              Text(
                t('addSkill') ?? 'Add Skill',
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              const Divider(height: 18),
              Expanded(
                child: categories.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        controller: scrollCtrl,
                        itemCount: categories.length,
                        itemBuilder: (_, ci) {
                          final cat = categories[ci];
                          final catName =
                              cat['category_name']?.toString() ?? '';
                          final catSkills =
                              (cat['skills'] as List<dynamic>? ?? []);

                          // Filter out skills already added
                          final available = catSkills.where((s) {
                            final id = (s['skill_id'] as num?)?.toInt() ?? 0;
                            return !_skills.any((added) => added.id == id);
                          }).toList();

                          if (available.isEmpty) return const SizedBox.shrink();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category header
                              Padding(
                                padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
                                child: Text(
                                  catName,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.primary,
                                      letterSpacing: 0.5),
                                ),
                              ),
                              // Skills in this category
                              ...available.map((s) {
                                final id =
                                    (s['skill_id'] as num?)?.toInt() ?? 0;
                                final name = s['skill_name']?.toString() ?? '';
                                return ListTile(
                                  dense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 0),
                                  leading: const Icon(Icons.add_circle_outline,
                                      color: AppTheme.primary, size: 20),
                                  title: Text(name,
                                      style: const TextStyle(fontSize: 14)),
                                  subtitle: Text(catName,
                                      style: const TextStyle(fontSize: 11)),
                                  onTap: () {
                                    setState(() {
                                      _skills.add(SkillItem(
                                          id: id,
                                          name: name,
                                          category: catName));
                                    });
                                    Navigator.pop(ctx);
                                  },
                                );
                              }),
                            ],
                          );
                        },
                      ),
              ),
            ]),
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_newPassCtrl.text.isNotEmpty &&
        _newPassCtrl.text != _confirmPassCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords do not match!")));
      return;
    }

    setState(() => _saving = true);
    final prov = context.read<AppProvider>();

    // تجهيز الكائن بالبيانات الجديدة من الـ TextFields
    SeekerProfile updatedProfile = SeekerProfile(
      id: prov.seeker.id,
      userId: prov.seeker.userId,
      fullname: _fullnameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      city: _selectedCity, // المتغير الذي ربطناه بالـ Dropdown
      email: prov.seeker.email,
      skills: _skills,
      availabilitySlots: _availabilitySlots,
      createdAt: prov.seeker.createdAt,
      updatedAt: DateTime.now().toIso8601String(),
    );

    try {
      await prov.saveProfileData(
        updatedProfile,
        _selectedImage,
        oldPassword: _oldPassCtrl.text.trim(),
        newPassword: _newPassCtrl.text.trim(),
      );
      await ApiService.syncUserSkills(
        _skills.map((e) => e.id).toList(),
      );

      if (!mounted) return;
      setState(() {
        _saving = false;
        _editing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("تم حفظ الملف بنجاح!"), backgroundColor: Colors.green));
    } catch (e) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("حدث خطأ أثناء الحفظ!"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final lang = prov.lang;
    final t = (String k) => Tr.get(k, lang);
    final p = prov.seeker;
    final pct = (p.completeness * 100).round();
    debugPrint("Ahmad: Cities Count = ${prov.cities.length}");
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(t('profileTitle')),
        actions: [
          IconButton(
              icon: const Icon(Icons.translate_rounded),
              onPressed: prov.toggleLang),
          TextButton(
            onPressed: _saving
                ? null
                : () => setState(() {
                      if (_editing) _load(prov.seeker);
                      _editing = !_editing;
                    }),
            child: Text(
              _editing ? t('cancel') : t('editProfile'),
              style: TextStyle(
                  color: _editing ? AppTheme.danger : AppTheme.primary,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            // ── Profile hero card ─────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(20)),
              child: Column(children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!) as ImageProvider
                          : (p.profileImage != null &&
                                  p.profileImage!.isNotEmpty)
                              ? NetworkImage(p.profileImage!) as ImageProvider
                              : null,
                      child: _selectedImage == null &&
                              (p.profileImage == null ||
                                  p.profileImage!.isEmpty)
                          ? Text(
                              p.fullname.isNotEmpty
                                  ? p.fullname[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white),
                            )
                          : null,
                    ),
                    /*if (_editing)
                      GestureDetector(
                        onTap: _pickImage,
                        child: const CircleAvatar(
                          radius: 16,
                          backgroundColor: AppTheme.secondary,
                          child: Icon(Icons.camera_alt,
                              size: 16, color: Colors.white),
                        ),
                      ),

                     */
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  p.fullname.isEmpty ? t('profileTitle') : p.fullname,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800),
                ),
                if (p.email.isNotEmpty)
                  Text(p.email,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8), fontSize: 13)),
                const SizedBox(height: 12),
                _buildCompletenessBar(pct, p.completeness, t),
              ]),
            ),
            const SizedBox(height: 16),

            _buildStatsRow(prov, t),
            const SizedBox(height: 16),

            // ══ SECTION: Basic Info ══════════════════════════
            _Card(title: t('profileTitle'), children: [
              _textField(
                  ctrl: _fullnameCtrl,
                  label: t('user name'),
                  icon: Icons.person_outline_rounded,
                  required: true),
              _textField(
                ctrl: _phoneCtrl,
                label: t('phone'),
                icon: Icons.phone_android_rounded,
                keyboard: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                required: true,
              ),
            ]),

            _Card(
              title: t('city') ?? 'City',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: prov.cities.isEmpty
                          // Cities still loading — show a placeholder
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : DropdownButtonFormField<String>(
                              // Guard: if the saved city isn't in the loaded list
                              // (e.g. name mismatch), fall back to null so Flutter
                              // doesn't throw "value not in items" assertion.
                              value: prov.cities.any((c) =>
                                      c['name'].toString() == _selectedCity)
                                  ? _selectedCity
                                  : null,
                              decoration: const InputDecoration(
                                labelText: 'المدينة',
                                prefixIcon: Icon(Icons.location_on),
                              ),
                              items: prov.cities.map((city) {
                                final name = city['name'].toString();
                                return DropdownMenuItem<String>(
                                    value: name, child: Text(name));
                              }).toList(),
                              onChanged: _editing
                                  ? (val) => setState(() => _selectedCity = val)
                                  : null,
                            ),
                    ),
                  ],
                ),
              ],
            ),

            // ══ SECTION: Experience ══════════════════════════
            _Card(title: t('experience'), children: [
              _textField(
                  ctrl: _expCtrl,
                  label: t('experience'),
                  icon: Icons.work_history_rounded,
                  maxLines: 4),
            ]),

            // ══ SECTION: Skills ══════════════════════════════
            _buildSkillsSection(t),

            // ✅ ══ SECTION: My Availability ═══════════════════
            if (_editing)
              _Card(title: 'My Availability', children: [
                AvailabilityWidget(
                  onSlotsUpdated: (slots) {
                    setState(() {
                      _availabilitySlots = slots;
                    });
                  },
                  initialSlots: _availabilitySlots, // ✅ هذا هو التعديل السحري!
                ),
              ]),

            // ✅ عرض الأوقات كـ Read-only إذا لم نكن في وضع التعديل
            if (!_editing && _availabilitySlots.isNotEmpty)
              _Card(title: 'My Availability', children: [
                ..._availabilitySlots
                    .map((slot) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time,
                                  color: AppTheme.primary, size: 18),
                              const SizedBox(width: 10),
                              Text('${slot.date} at ${slot.time}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: AppTheme.primary)),
                            ],
                          ),
                        ))
                    .toList()
              ]),

            // ══ SECTION: Change Password ═════════════════════
            if (_editing)
              _Card(title: t('changePassword') ?? 'Change Password', children: [
                _textField(
                    ctrl: _oldPassCtrl,
                    label: t('currentPassword') ?? 'Current Password',
                    icon: Icons.lock_outline,
                    obscureText: true),
                _textField(
                    ctrl: _newPassCtrl,
                    label: t('newPassword') ?? 'New Password',
                    icon: Icons.lock_outline,
                    obscureText: true),
                _textField(
                    ctrl: _confirmPassCtrl,
                    label: t('confirmPassword') ?? 'Confirm Password',
                    icon: Icons.lock_outline,
                    obscureText: true),
              ]),

            if (_editing) ...[
              const SizedBox(height: 8),
              _saving
                  ? const Center(child: CircularProgressIndicator())
                  : GradBtn(
                      label: t('saveProfile'),
                      icon: Icons.save_rounded,
                      onPressed: _save),
            ],

            _buildLogoutBtn(prov, t),
            const SizedBox(height: 80),
          ]),
        ),
      ),
      bottomNavigationBar: const SeekerBottomNav(index: 4),
    );
  }

  Widget _buildCompletenessBar(int pct, double value, Function t) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(t('profileComplete'),
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12)),
          Text('$pct%',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation(
                pct >= 80 ? AppTheme.secondary : Colors.orangeAccent),
          ),
        ),
      ]);

  Widget _buildStatsRow(prov, t) => Row(children: [
        StatCard(
            value: '${prov.appliedCount}',
            label: t('appliedJobs'),
            icon: Icons.send_rounded,
            color: AppTheme.primary),
        const SizedBox(width: 10),
        StatCard(
            value: '${prov.pendingCount}',
            label: t('pending'),
            icon: Icons.hourglass_empty_rounded,
            color: AppTheme.warning),
        const SizedBox(width: 10),
        StatCard(
            value: '${prov.acceptedCount}',
            label: t('acceptedJobs'),
            icon: Icons.check_circle_rounded,
            color: AppTheme.success),
      ]);

  Widget _buildLogoutBtn(prov, t) => Padding(
        padding: const EdgeInsets.only(top: 16),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              await prov.logout();
              if (context.mounted) context.go('/landing');
            },
            style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.danger,
                side: const BorderSide(color: AppTheme.danger)),
            icon: const Icon(Icons.logout_rounded),
            label: Text(t('logout')),
          ),
        ),
      );

  Widget _buildSkillsSection(Function t) => _Card(
        title: t('mySkills'),
        children: [
          if (_editing) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showSkillSelector(t),
                icon: const Icon(Icons.add_rounded),
                label: Text(t('addSkill') ?? 'Select Skill'),
              ),
            ),
            const SizedBox(height: 16),
          ],
          _skills.isEmpty
              ? Text(
                  t('noData'),
                  style: const TextStyle(color: AppTheme.textMuted),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _skills.map((skill) {
                    return Chip(
                      label: Text(skill.name),
                      onDeleted: _editing
                          ? () {
                              setState(() {
                                _skills.remove(skill);
                              });
                            }
                          : null,
                      backgroundColor: AppTheme.primary.withOpacity(0.08),
                      deleteIconColor: AppTheme.danger,
                      labelStyle: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    );
                  }).toList(),
                ),
        ],
      );
  // ✅ تم إزالة الخطأ المطبعي (Widget _) من هنا

  Widget _textField({
    required TextEditingController ctrl,
    required String label,
    required IconData icon,
    TextInputType? keyboard,
    int maxLines = 1,
    int? maxLength,
    bool required = false,
    bool obscureText = false,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        enabled: _editing,
        maxLines: maxLines,
        keyboardType: keyboard,
        obscureText: obscureText,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          fillColor: _editing ? Colors.grey.shade50 : Colors.white,
        ),
        validator: (v) => required && v!.isEmpty
            ? Tr.get('required', context.read<AppProvider>().lang)
            : null,
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Card({required this.title, required this.children});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.card,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppTheme.primary)),
          const Divider(height: 18),
          ...children,
        ]),
      );
}
