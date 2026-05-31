//  SeekerProfile — maps to CREATE TABLE job_seeker_profiles and users
//
//  SQL columns → Dart fields:
//   id          → id          INT PK AUTO_INCREMENT (from users/profiles)
//   user_id     → userId      INT FK → users(id)
//   name        → fullname    VARCHAR(100) NOT NULL (from users)
//   email       → email       VARCHAR(100) UNIQUE (from users)
//   phone       → phone       VARCHAR(20) NULL (from users)
//   city        → city        VARCHAR(100) NULL (from job_seeker_profiles)
//   experience  → experience  TEXT NULL (from job_seeker_profiles)
//   skills      → skills      JSON  (List<String>) (from job_seeker_profiles)
//   created_at  → createdAt   TIMESTAMP
//   updated_at  → updatedAt   TIMESTAMP

// ── Jordanian cities ────
/*
//avaible date
class AvailabilitySlot {
  String date;
  String time;

  AvailabilitySlot({required this.date, required this.time});

  factory AvailabilitySlot.fromJson(Map<String, dynamic> json) {
    return AvailabilitySlot(
      date: json['available_date'] ?? '',
      time: json['available_time'] ?? '',
    );
  }
  Map<String, dynamic> toJson() => {
        'available_date': date,
        'available_time': time,
      };
}

class SeekerProfile {
  String id;
  String userId;
  // ── Data from 'users' table ──
  String fullname;
  String email;
  String? phone; //nullable string
  List<AvailabilitySlot> availabilitySlots; //avaible date
  // ── Data from 'job_seeker_profiles' table ──
  String? city; //
  String? experience;
  List<String> skills;
  String? profileImage; //image profile
  // ── Timestamps ──
  String createdAt;
  String updatedAt;

  SeekerProfile({
    required this.id,
    required this.userId,
    required this.fullname,
    required this.email,
    this.phone,
    this.city,
    this.profileImage, //new
    this.experience,
    required this.skills,
    required this.createdAt,
    required this.updatedAt,
    required this.availabilitySlots, //new
  });

  /// Full display name
  String get fullName => fullname.trim();

  /// Profile completeness 0.0–1.0
  double get completeness {
    int filled = 0;
    if (fullname.isNotEmpty) filled++;
    if (email.isNotEmpty) filled++;
    if (phone != null && phone!.isNotEmpty) filled++;
    if (city != null && city!.isNotEmpty) filled++;
    if (experience != null && experience!.isNotEmpty) filled++;
    if (skills.isNotEmpty) filled++;
    return filled / 6; // 6 main fields to fill
  }

  factory SeekerProfile.empty() {
    final now = DateTime.now().toIso8601String();
    return SeekerProfile(
      id: 'sp_1',
      userId: 'u_1',
      fullname: '',
      email: '',
      phone: '',
      city: null, // عمان default
      experience: null,
      skills: [],
      availabilitySlots: [], //new
      createdAt: now,
      updatedAt: now,
    );
  }

  factory SeekerProfile.fromJson(Map<String, dynamic> j) {
    final now = DateTime.now().toIso8601String();
    return SeekerProfile(
      id: j['id']?.toString() ?? 'sp_1',
      userId: j['user_id']?.toString() ?? 'u_1',
      fullname:
          j['name'] ?? j['fullname'] ?? '', // Handle both keys just in case
      email: j['email'] ?? '',
      phone: j['phone']?.toString() ?? '',
      city: j['city'] ?? null,
      profileImage: j['profile_image'] ?? j['avatar'], //image new
      experience: j['experience'],
      skills: List<String>.from(j['skills'] ?? []),
      availabilitySlots: (j['availability_slots'] as List<dynamic>?)
              ?.map((e) => AvailabilitySlot.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: j['created_at'] ?? now,
      updatedAt: j['updated_at'] ?? now,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'name': fullname,
        'email': email,
        'phone': phone,
        'city': city,
        'experience': experience,
        'skills': skills,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'profile_image': profileImage,
        'availability_slots': availabilitySlots.map((e) => e.toJson()).toList(),
      };
}
*/

// ─────────────────────────────────────────────────────────────────────────────
//  SeekerProfile — maps to job_seeker_profiles + users tables
// ─────────────────────────────────────────────────────────────────────────────

// ── BUG FIX #1 ──────────────────────────────────────────────────────────────
// Removed hardcoded kJordanCities constant.
// Cities now come from the API (AppProvider.cities) so this list was causing
// the dropdown to always fall back to "عمان" even when the server returned a
// different city name or spelling.
// ────────────────────────────────────────────────────────────────────────────

// ── SkillItem ────────────────────────────────────────────────────────────────
// BUG FIX #2: Skills were stored as plain strings (names only).
// The backend syncUserSkills() expects integer IDs, not names.
// SkillItem carries both id + name so we can display the name and send the id.
class SkillItem {
  final int id;
  final String name;
  final String category;

  const SkillItem({
    required this.id,
    required this.name,
    this.category = '',
    String? categoryIcon,
  });

  factory SkillItem.fromJson(Map<String, dynamic> json) => SkillItem(
        // API returns 'skill_id' and 'skill_name' (ProfileController / DataController)
        id: ((json['skill_id'] ?? json['id']) as num).toInt(),
        name: (json['skill_name'] ?? json['name'])?.toString() ?? '',
        category: (json['category_name'] ?? json['category'])?.toString() ?? '',
      );

  @override
  bool operator ==(Object other) => other is SkillItem && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => name;
}

// ── AvailabilitySlot ─────────────────────────────────────────────────────────
class AvailabilitySlot {
  // BUG FIX #3: id was missing entirely.
  // Without it, AppProvider.removeAvailability() had to compare slot.date == id
  // which is obviously wrong (date string vs integer).
  // Now the id returned by the server is preserved so deletion works correctly.
  final int? id;
  final String date;
  final String time;

  const AvailabilitySlot({
    this.id,
    required this.date,
    required this.time,
  });

  factory AvailabilitySlot.fromJson(Map<String, dynamic> json) =>
      AvailabilitySlot(
        // API returns 'availability_id', not 'id'
        id: (json['availability_id'] ?? json['id']) != null
            ? ((json['availability_id'] ?? json['id']) as num).toInt()
            : null,
        date: json['available_date']?.toString() ?? '',
        time: json['available_time']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'available_date': date,
        'available_time': time,
      };
}

// ── SeekerProfile ─────────────────────────────────────────────────────────────
class SeekerProfile {
  final String id;
  final String userId;
  final String fullname;
  final String email;
  final String? phone;
  final String? city;
  final String? experience;
  final String? profileImage;

  // BUG FIX #2 (cont): skills now stores SkillItem objects (id + name) so we
  // can both display the name and send the correct id to the backend.
  final List<SkillItem> skills;

  final List<AvailabilitySlot> availabilitySlots;
  final String createdAt;
  final String updatedAt;

  const SeekerProfile({
    required this.id,
    required this.userId,
    required this.fullname,
    required this.email,
    this.phone,
    this.city,
    this.experience,
    this.profileImage,
    required this.skills,
    required this.availabilitySlots,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convenience: skill names for display / matching
  List<String> get skillNames => skills.map((s) => s.name).toList();

  /// Convenience: skill ids for syncing with backend
  List<int> get skillIds => skills.map((s) => s.id).toList();

  /// Profile completeness 0.0–1.0
  double get completeness {
    int filled = 0;
    if (fullname.isNotEmpty) filled++;
    if (email.isNotEmpty) filled++;
    if (phone != null && phone!.isNotEmpty) filled++;
    if (city != null && city!.isNotEmpty) filled++;
    if (experience != null && experience!.isNotEmpty) filled++;
    if (skills.isNotEmpty) filled++;
    return filled / 6;
  }

  factory SeekerProfile.empty() {
    final now = DateTime.now().toIso8601String();
    return SeekerProfile(
      id: '0',
      userId: '0',
      fullname: '',
      email: '',
      phone: '',
      city: null,
      experience: null,
      profileImage: null,
      skills: const [],
      availabilitySlots: const [],
      createdAt: now,
      updatedAt: now,
    );
  }

  factory SeekerProfile.fromJson(Map<String, dynamic> j) {
    final now = DateTime.now().toIso8601String();

    // BUG FIX #2 (cont): The API may return skills as:
    //   a) List of objects: [{"id":1,"name":"PHP"}, ...]   ← most likely
    //   b) List of strings: ["PHP", "Laravel"]             ← simple case
    //   c) List of IDs:     [1, 2, 3]                      ← unlikely but safe
    // The old code did List<String>.from(...) which broke for case (a).
    final rawSkills = j['skills'] as List<dynamic>? ?? [];
    final parsedSkills = rawSkills
        .map<SkillItem>((s) {
          if (s is Map<String, dynamic>) return SkillItem.fromJson(s);
          // Fallback when skill is just a name string (no id available → id = 0)
          return SkillItem(id: 0, name: s.toString());
        })
        .where((s) => s.name.isNotEmpty)
        .toList();

    return SeekerProfile(
      id: j['id']?.toString() ?? '0',
      userId: j['user_id']?.toString() ?? '0',
      fullname: j['name'] ?? j['fullname'] ?? '',
      email: j['email'] ?? '',
      phone: j['phone']?.toString(),
      city: j['city']?.toString(),
      experience: j['experience']?.toString(),
      // API returns 'profile_picture' (ProfileController); fall back to legacy keys
      profileImage: j['profile_picture']?.toString() ??
          j['profile_image']?.toString() ??
          j['avatar']?.toString(),
      skills: parsedSkills,
      // API returns 'availabilities' (ProfileController.show), not 'availability_slots'
      availabilitySlots:
          ((j['availabilities'] ?? j['availability_slots']) as List<dynamic>? ??
                  [])
              .map((e) => AvailabilitySlot.fromJson(e as Map<String, dynamic>))
              .toList(),
      createdAt: j['created_at']?.toString() ?? now,
      updatedAt: j['updated_at']?.toString() ?? now,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'name': fullname,
        'email': email,
        'phone': phone,
        'city': city,
        'experience': experience,
        'profile_image': profileImage,
        // Send skill ids when serializing for the API
        'skill_ids': skillIds,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'availability_slots': availabilitySlots.map((e) => e.toJson()).toList(),
      };

  /// Creates a copy with optional overrides (immutable pattern)
  SeekerProfile copyWith({
    String? id,
    String? userId,
    String? fullname,
    String? email,
    String? phone,
    String? city,
    String? experience,
    String? profileImage,
    List<SkillItem>? skills,
    List<AvailabilitySlot>? availabilitySlots,
    String? createdAt,
    String? updatedAt,
  }) =>
      SeekerProfile(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        fullname: fullname ?? this.fullname,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        city: city ?? this.city,
        experience: experience ?? this.experience,
        profileImage: profileImage ?? this.profileImage,
        skills: skills ?? this.skills,
        availabilitySlots: availabilitySlots ?? this.availabilitySlots,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
