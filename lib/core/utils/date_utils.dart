import 'package:intl/intl.dart';

/// Date formatting and utility helpers.

class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _displayDate = DateFormat('MMM d, yyyy');
  static final DateFormat _displayDateTime = DateFormat('MMM d, yyyy h:mm a');
  static final DateFormat _shortDate = DateFormat('MM/dd/yyyy');
  static final DateFormat _isoDate = DateFormat('yyyy-MM-dd');

  /// Format a DateTime for display (e.g., "Jan 5, 2026")
  static String formatDate(DateTime date) => _displayDate.format(date);

  /// Format a DateTime with time (e.g., "Jan 5, 2026 3:30 PM")
  static String formatDateTime(DateTime date) => _displayDateTime.format(date);

  /// Format a DateTime as short date (e.g., "01/05/2026")
  static String formatShortDate(DateTime date) => _shortDate.format(date);

  /// Format a DateTime as ISO date string (e.g., "2026-01-05")
  static String formatIsoDate(DateTime date) => _isoDate.format(date);

  /// Parse an ISO date string (e.g., "2026-01-05")
  static DateTime? parseIsoDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  /// Get a human-readable relative time string
  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Check if a date is overdue (past due date)
  static bool isOverdue(DateTime dueDate) {
    final now = DateTime.now();
    return dueDate.isBefore(DateTime(now.year, now.month, now.day));
  }

  /// Check if a date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Get days remaining until due date (negative if overdue)
  static int daysUntil(DateTime dueDate) {
    final now =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.difference(now).inDays;
  }

  /// Get a display string for days remaining
  static String dueDateDisplay(DateTime dueDate) {
    final days = daysUntil(dueDate);
    if (days < 0) {
      return '${-days} ${-days == 1 ? 'day' : 'days'} overdue';
    } else if (days == 0) {
      return 'Due today';
    } else if (days == 1) {
      return 'Due tomorrow';
    } else if (days <= 7) {
      return 'Due in $days days';
    } else {
      return 'Due ${formatDate(dueDate)}';
    }
  }
}
