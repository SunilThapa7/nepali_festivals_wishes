import 'package:intl/intl.dart';
import 'package:nepali_utils/nepali_utils.dart';

class DateFormatter {
  /// Formats a DateTime to display in the format: "April 13, 2023"
  static String formatFullDate(DateTime date) {
    return DateFormat.yMMMMd().format(date);
  }

  /// Formats a DateTime to display in the format: "Apr 13"
  static String formatShortDate(DateTime date) {
    return DateFormat.MMMd().format(date);
  }

  /// Formats a DateTime to display in the format: "13-04-2023"
  static String formatNumericDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }

  /// Returns time remaining until the given date in a readable format
  static String getTimeRemaining(DateTime futureDate) {
    final now = DateTime.now();

    if (futureDate.isBefore(now)) {
      return 'Already passed';
    }

    final difference = futureDate.difference(now);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} left';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} left';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} left';
    } else {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} left';
    }
  }

  /// Checks if the given date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Checks if the given date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  /// Convert to Nepali date and format as "२० चैत्र २०८०"
  static String formatNepaliDate(DateTime date) {
    final nepaliDate = NepaliDateTime.fromDateTime(date);
    return '${nepaliDate.day} ${_getNepaliMonth(nepaliDate.month)} ${nepaliDate.year}';
  }

  /// Convert to Nepali date and format with Nepali digits
  static String formatNepaliDateWithNepaliDigits(DateTime date) {
    final nepaliDate = NepaliDateTime.fromDateTime(date);
    final nepaliDay = NepaliUnicode.convert(nepaliDate.day.toString());
    final nepaliMonth = _getNepaliMonth(nepaliDate.month);
    final nepaliYear = NepaliUnicode.convert(nepaliDate.year.toString());
    return '$nepaliDay $nepaliMonth $nepaliYear';
  }

  /// Returns the Nepali month name
  static String _getNepaliMonth(int month) {
    switch (month) {
      case 1:
        return 'बैशाख';
      case 2:
        return 'जेठ';
      case 3:
        return 'असार';
      case 4:
        return 'श्रावण';
      case 5:
        return 'भदौ';
      case 6:
        return 'आश्विन';
      case 7:
        return 'कार्तिक';
      case 8:
        return 'मंसिर';
      case 9:
        return 'पुष';
      case 10:
        return 'माघ';
      case 11:
        return 'फाल्गुन';
      case 12:
        return 'चैत्र';
      default:
        return '';
    }
  }
}
