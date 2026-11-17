import 'package:flutter_test/flutter_test.dart';
import 'package:workchop/core/utils/money_format.dart';

void main() {
  test('formats naira with thousand separators', () {
    expect(formatNaira(5000), '₦5,000');
    expect(formatNaira(10000), '₦10,000');
    expect(formatNaira(1250000), '₦1,250,000');
    expect(formatNaira(0), '₦0');
    expect(formatNaira(5000.4), '₦5,000');
  });

  test('formats a range', () {
    expect(formatNairaRange(5000, 8000), '₦5,000 - ₦8,000');
  });
}
