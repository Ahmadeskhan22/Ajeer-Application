// lib/models/jobapplication.dart
//
// Matches ApplicationController.php index() response shape exactly:
// {
//   application_id, status, message, applied_at,
//   job: { job_id, title, location, salary, owner_name,
//          skills: [{skill_id, skill_name}],
//          shifts:  [{shift_date, shift_start, shift_end}] }
// }

// API statuses (PascalCase from backend):
// 'Pending' | 'Accepted' | 'Rejected' | 'Canceled'
enum JobStatus { pending, accepted, rejected, canceled, unknown }

class JobApplication {
  final int applicationId;
  final String status; // raw string from API e.g. 'Pending', 'Accepted'
  final String? message;
  final String? appliedAt;

  // ── Flattened job fields for easy access in UI ──
  final int jobId;
  final String jobTitle;
  final String? location;
  final String? salary;
  final String? ownerName;
  final List<String> skills; // skill_name strings
  final List<Map<String, String>>
      shifts; // {shift_date, shift_start, shift_end}

  const JobApplication({
    required this.applicationId,
    required this.status,
    this.message,
    this.appliedAt,
    required this.jobId,
    required this.jobTitle,
    this.location,
    this.salary,
    this.ownerName,
    required this.skills,
    required this.shifts,
  });

  /// Typed enum for logic (e.g. showing cancel button only on Pending)
  JobStatus get jobStatus {
    switch (status) {
      case 'Pending':
        return JobStatus.pending;
      case 'Accepted':
        return JobStatus.accepted;
      case 'Rejected':
        return JobStatus.rejected;
      case 'Canceled':
        return JobStatus.canceled;
      default:
        return JobStatus.unknown;
    }
  }

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    final job = json['job'] as Map<String, dynamic>? ?? {};

    // Skills → list of name strings
    final rawSkills = job['skills'] as List<dynamic>? ?? [];
    final skillNames = rawSkills
        .map((s) => (s['skill_name'] ?? s['name'] ?? '').toString())
        .where((s) => s.isNotEmpty)
        .toList();

    // Shifts → list of maps with string values
    final rawShifts = job['shifts'] as List<dynamic>? ?? [];
    final parsedShifts = rawShifts.map((sh) {
      final m = sh as Map<String, dynamic>;
      return {
        'shift_date': (m['shift_date'] ?? '').toString(),
        'shift_start': (m['shift_start'] ?? '').toString(),
        'shift_end': (m['shift_end'] ?? '').toString(),
      };
    }).toList();

    return JobApplication(
      applicationId: (json['application_id'] as num).toInt(),
      status: json['status']?.toString() ?? 'Pending',
      message: json['message']?.toString(),
      appliedAt: json['applied_at']?.toString(),
      jobId: (job['job_id'] as num? ?? 0).toInt(),
      jobTitle: job['title']?.toString() ?? '',
      location: job['location']?.toString(),
      salary: job['salary']?.toString(),
      ownerName: job['owner_name']?.toString(),
      skills: skillNames,
      shifts: parsedShifts,
    );
  }
}
