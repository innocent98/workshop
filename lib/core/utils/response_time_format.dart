/// Human-friendly artisan response time.
///
/// The backend sends `response_time_avg_minutes`: an integer number of minutes
/// (never below 1 once set) or `null` until the artisan's first accepted
/// booking. `null` (or a non-positive value, which the backend never sends) must
/// render as *nothing*: never "0 min" and never "N/A".
library;

const int _minutesPerHour = 60;
const int _minutesPerDay = 24 * _minutesPerHour;

/// Short duration: `~12 min`, `~1 hr`, `~1.5 hrs`, `~2 hrs`, `~1 day`.
/// Returns null when there is no usable value.
String? formatResponseTime(int? minutes) {
  if (minutes == null || minutes < 1) return null;

  if (minutes < _minutesPerHour) return '~$minutes min';

  if (minutes < _minutesPerDay) {
    // Nearest half hour, so 90 -> 1.5 hrs but 61 -> 1 hr.
    final halfHours = (minutes / (_minutesPerHour / 2)).round();
    final hours = halfHours / 2;
    final text = halfHours.isEven ? '${halfHours ~/ 2}' : hours.toString();
    return '~$text ${hours == 1 ? 'hr' : 'hrs'}';
  }

  final days = (minutes / _minutesPerDay).round();
  return '~$days ${days == 1 ? 'day' : 'days'}';
}

/// Label for profiles and cards: `Replies in ~12 min`. Null when there is no
/// usable value, so callers can simply skip rendering.
String? responseTimeLabel(int? minutes) {
  final short = formatResponseTime(minutes);
  return short == null ? null : 'Replies in $short';
}
