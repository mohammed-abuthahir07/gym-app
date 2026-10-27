import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppDateUtils {
  static String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatDateTime(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  static String formatTime(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('HH:mm').format(date);
  }

  static String formatMonth(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMMM').format(date).toUpperCase();
  }

  static DateTime? parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static String todayDateString() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  static String currentDayName() {
    return DateFormat('EEEE').format(DateTime.now()).toUpperCase();
  }

  static String dayNameFromDate(DateTime date) {
    return DateFormat('EEEE').format(date).toUpperCase();
  }

  static String currentMonthName() {
    return DateFormat('MMMM').format(DateTime.now()).toUpperCase();
  }

  static int currentYear() {
    return DateTime.now().year;
  }
}
