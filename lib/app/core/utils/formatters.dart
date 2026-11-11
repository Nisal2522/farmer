import 'package:intl/intl.dart';

class Fmt {
  Fmt._();

  static final _date = DateFormat('d MMM yyyy');
  static final _short = DateFormat('d MMM');
  static final _time = DateFormat('h:mm a');
  static final _weekday = DateFormat('EEE');
  static final _monthYear = DateFormat('MMMM yyyy');
  static final _num = NumberFormat.decimalPattern();

  static String date(DateTime d) => _date.format(d);
  static String short(DateTime d) => _short.format(d);
  static String time(DateTime d) => _time.format(d);
  static String weekday(DateTime d) => _weekday.format(d);
  static String monthYear(DateTime d) => _monthYear.format(d);
  static String dateTime(DateTime d) => '${_short.format(d)}, ${_time.format(d)}';
  static String number(num n) => _num.format(n);

  static String range(DateTime a, DateTime b) {
    if (isSameDay(a, b)) return date(a);
    if (a.year == b.year && a.month == b.month) {
      return '${a.day} – ${b.day} ${DateFormat('MMM yyyy').format(b)}';
    }
    return '${short(a)} – ${date(b)}';
  }

  static String relative(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return date(d);
  }

  static String greeting([DateTime? now]) {
    final h = (now ?? DateTime.now()).hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  static String initials(String name) {
    final parts = name.replaceAll('.', ' ').split(' ').where((p) => p.trim().isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  /// "1 sample", "3 samples".
  static String plural(int n, String one, [String? many]) => '$n ${n == 1 ? one : (many ?? '${one}s')}';

  static bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
