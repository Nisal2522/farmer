import 'package:cu_farmer/app/core/utils/formatters.dart';
import 'package:cu_farmer/app/data/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('initials use first and last name parts', () {
    expect(Fmt.initials('M.W.J. Bandara'), 'MB');
    expect(Fmt.initials('Kasun Jayasinghe'), 'KJ');
  });

  test('field change direction', () {
    const up = FieldChange(section: 's', label: 'l', previous: '1.0', current: '2.5');
    const same = FieldChange(section: 's', label: 'l', previous: 'ORG', current: 'ORG');
    expect(up.direction, 1);
    expect(up.isChanged, isTrue);
    expect(same.isChanged, isFalse);
  });
}
