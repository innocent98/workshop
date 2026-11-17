import 'package:intl/intl.dart';

final NumberFormat _groupedFormat = NumberFormat('#,###');

/// Formats a naira amount with thousand separators, e.g. 5000 -> '₦5,000'.
String formatNaira(num amount) => '₦${_groupedFormat.format(amount.round())}';

/// Formats a naira range, e.g. '₦5,000 - ₦8,000'.
String formatNairaRange(num min, num max) =>
    '${formatNaira(min)} - ${formatNaira(max)}';
