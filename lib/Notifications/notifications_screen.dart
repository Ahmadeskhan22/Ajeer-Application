// lib/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Theme/app_theme.dart';
import '../Translations/translations.dart';
import '../provider/app_provider.dart';
import '../widgets/EmptyState.dart';
import '../widgets/Seeker_BottomNavi.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final t = (String k) => Tr.get(k, prov.lang);
    final list = prov.notifications;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(children: [
          Text(t('notifications')),
          if (prov.unreadNotificationsCount > 0) ...[
            const SizedBox(width: 8),
            // Unread count badge next to title
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.danger,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${prov.unreadNotificationsCount}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ]),
        actions: [
          if (list.isNotEmpty && prov.unreadNotificationsCount > 0)
            TextButton(
              onPressed: prov.markAllNotificationsAsRead,
              child: Text(
                t('markAllRead'),
                style: const TextStyle(color: AppTheme.primary),
              ),
            ),
        ],
      ),
      body: prov.isLoading
          ? const Center(child: CircularProgressIndicator())
          : list.isEmpty
              ? EmptyState(
                  icon: Icons.notifications_none_rounded,
                  title: t('noNotifications'),
                  subtitle: t('noNotificationsSub'),
                )
              : RefreshIndicator(
                  onRefresh: prov.fetchNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final n = list[i];
                      return _NotificationTile(
                        notification: n,
                        onTap: () => prov.markNotificationAsRead(n.id),
                        onDismiss: () =>
                            _deleteNotification(context, prov, n.id),
                      );
                    },
                  ),
                ),
      bottomNavigationBar: const SeekerBottomNav(index: 2),
    );
  }

  Future<void> _deleteNotification(
      BuildContext ctx, AppProvider prov, int id) async {
    // Optimistic: remove from local list immediately
    // then tell server (fire-and-forget; re-fetch on failure)
    try {
      await prov.deleteNotification(id);
    } catch (_) {
      prov.fetchNotifications();
    }
  }
}

// ── Single notification tile ───────────────────────────────────────────────
class _NotificationTile extends StatelessWidget {
  final dynamic notification; // NotificationModel
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final n = notification;
    return Dismissible(
      key: ValueKey(n.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.danger.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppTheme.danger),
      ),
      onDismissed: (_) => onDismiss(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: n.isRead ? Colors.white : AppTheme.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: n.isRead
                ? Colors.grey.shade200
                : AppTheme.primary.withOpacity(0.2),
          ),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          onTap: onTap,
          leading: CircleAvatar(
            backgroundColor: n.isRead ? Colors.grey.shade100 : AppTheme.primary,
            child: Icon(
              n.isRead
                  ? Icons.notifications_outlined
                  : Icons.notifications_active,
              color: n.isRead ? Colors.grey : Colors.white,
              size: 20,
            ),
          ),
          title: Text(
            n.title,
            style: TextStyle(
              fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w800,
              fontSize: 14,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(n.message, style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 6),
              Text(n.timeAgo,
                  style:
                      const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
            ],
          ),
          // Unread dot indicator
          trailing: n.isRead
              ? null
              : Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
        ),
      ),
    );
  }
}
