// ================================================================
//  Job — maps to CREATE TABLE Job
//
//  SQL columns → Dart fields:
//   JobID            → id          (String, simulated auto-increment)
//   OwnerID          → ownerId     (FK → User)
//   Title            → title       VARCHAR(100)
//   Description      → description TEXT
//   Location         → location    VARCHAR(150)
//   Salary           → salary      DECIMAL(10,2) NULL  → double?
//   Status           → status      ENUM Pending|Approved|Rejected
//   ApprovedBy       → approvedBy  INT NULL (admin FK)
//   ApprovedAt       → approvedAt  DATETIME NULL
//   RejectionReason  → rejectionReason VARCHAR(255) NULL
//   CreatedAt        → createdAt   DATETIME
//   UpdatedAt        → updatedAt   DATETIME
//
//  Extra app field (not in SQL):
//   skills           → List<String>  (for AI matching)
//   category         → String        (for filtering)
//   type             → String        (full-time/part-time/hourly)
// ================================================================
class JobSkill {
  final int skillId;
  final String skillName;
  final String? categoryName;

  JobSkill({
    required this.skillId,
    required this.skillName,
    this.categoryName,
  });

  factory JobSkill.fromJson(Map<String, dynamic> json) {
    return JobSkill(
      skillId: json['skill_id'],
      skillName: json['skill_name'] ?? '',
      categoryName: json['category_name'],
    );
  }
}

class JobShift {
  final int shiftId;
  final String shiftDate;
  final String shiftStart;
  final String shiftEnd;

  JobShift({
    required this.shiftId,
    required this.shiftDate,
    required this.shiftStart,
    required this.shiftEnd,
  });

  factory JobShift.fromJson(Map<String, dynamic> json) {
    return JobShift(
      shiftId: json['shift_id'] ?? 0,
      shiftDate: json['shift_date'] ?? '',
      shiftStart: json['shift_start'] ?? '',
      shiftEnd: json['shift_end'] ?? '',
    );
  }
}

class Job {
  final int jobId;
  final String title;
  final String description;
  final String location;
  final String? salary;
  final String ownerName;
  final List<JobSkill> skills;
  final List<JobShift> shifts;
  final String postedAt;
  final bool applied;

  Job({
    required this.jobId,
    required this.title,
    required this.description,
    required this.location,
    this.salary,
    required this.ownerName,
    required this.skills,
    required this.shifts,
    required this.postedAt,
    required this.applied,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      jobId: json['job_id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      salary: json['salary']?.toString(),
      ownerName: json['owner'] != null
          ? json['owner']['name'] ?? 'غير محدد'
          : 'غير محدد',
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => JobSkill.fromJson(e))
              .toList() ??
          [],
      shifts: (json['shifts'] as List<dynamic>?)
              ?.map((e) => JobShift.fromJson(e))
              .toList() ??
          [],
      postedAt: json['posted_at'] ?? '',
      applied: json['applied'] ?? false,
    );
  }
}
