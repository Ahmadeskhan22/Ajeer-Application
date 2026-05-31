class NotificationModel {
  final int id;
  final String title;
  final String message;
  bool isRead;
  final String createdAt;
  final String timeAgo;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    required this.timeAgo,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: (json['notification_id'] ?? 0) as int,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      createdAt: json['created_at'] ?? '',
      timeAgo: json['time_ago'] ?? '',
    );
  }
}
