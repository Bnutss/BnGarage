import 'package:intl/intl.dart';

class AppDateUtils {
  static final _fmt = DateFormat('dd.MM.yyyy');

  static String format(DateTime date) => _fmt.format(date);

  static String? formatNullable(DateTime? date) =>
      date != null ? _fmt.format(date) : null;

  static int daysUntil(DateTime date) {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final target = DateTime(date.year, date.month, date.day);
    return target.difference(today).inDays;
  }
}
