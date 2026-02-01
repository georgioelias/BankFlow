import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../theme/colors.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    
    final notifications = await SupabaseService.getNotifications();
    
    if (mounted) {
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBgColor,
      appBar: AppBar(
        backgroundColor: AppColor.appBgColor,
        title: const Text('Notifications'),
        actions: [
          if (_notifications.any((n) => n['is_read'] == false))
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _notifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationItem(_notifications[index]);
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No notifications', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    final isRead = notification['is_read'] == true;
    final date = DateTime.tryParse(notification['created_at'] ?? '');
    final timeAgo = date != null ? _formatTimeAgo(date) : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : AppColor.primary.withAlpha(13),
        borderRadius: BorderRadius.circular(12),
        border: isRead ? null : Border.all(color: AppColor.primary.withAlpha(51)),
      ),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getNotificationColor(notification['type']).withAlpha(51),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getNotificationIcon(notification['type']),
            color: _getNotificationColor(notification['type']),
          ),
        ),
        title: Text(
          notification['title'] ?? 'Notification',
          style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification['message'] ?? ''),
            const SizedBox(height: 4),
            Text(timeAgo, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ],
        ),
        trailing: !isRead
            ? Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(color: AppColor.primary, shape: BoxShape.circle),
              )
            : null,
        onTap: () => _handleNotificationTap(notification),
      ),
    );
  }

  void _handleNotificationTap(Map<String, dynamic> notification) async {
    if (notification['is_read'] != true) {
      await SupabaseService.markNotificationRead(notification['id']);
      await _loadNotifications();
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getNotificationColor(notification['type']).withAlpha(51),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getNotificationIcon(notification['type']),
                    color: _getNotificationColor(notification['type']),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    notification['title'] ?? 'Notification',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(notification['message'] ?? '', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _markAllAsRead() async {
    for (var notification in _notifications) {
      if (notification['is_read'] != true) {
        await SupabaseService.markNotificationRead(notification['id']);
      }
    }
    await _loadNotifications();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All notifications marked as read')),
      );
    }
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'transaction': return Icons.swap_horiz;
      case 'success': return Icons.check_circle;
      case 'warning': return Icons.warning;
      case 'error': return Icons.error;
      default: return Icons.info;
    }
  }

  Color _getNotificationColor(String? type) {
    switch (type) {
      case 'transaction': return AppColor.primary;
      case 'success': return AppColor.green;
      case 'warning': return AppColor.yellow;
      case 'error': return AppColor.red;
      default: return AppColor.appBgColorSecondary;
    }
  }
}
