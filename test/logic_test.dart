import 'package:fa26_prm393_ce191720/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('alert thresholds 19/20/49/50', () {
    expect([19, 20, 49, 50].map(levelOf), ['Low', 'Moderate', 'Moderate', 'High']);
  });

  test('time parse + current/upcoming filter at 2026-11-08 09:00', () {
    expect(parseTime('2026-11-08 06:00'), isNotNull);
    expect(parseTime('2026-02-30 06:00'), isNull);
    expect(parseTime('8/11/2026'), isNull);
    final now = DateTime(2026, 11, 8, 9, 0);
    Flood f(String end, int d) => Flood(areaName: 'a', location: 'l', expectedDepthEm: d, startTime: '2026-11-07 00:00', endTime: end);
    final all = [
      f('2026-11-08 12:00', 50), f('2026-11-08 11:00', 19), f('2026-11-07 15:00', 20),
      f('2026-11-08 14:00', 35), f('2026-11-09 10:30', 49), f('2026-11-08 13:00', 50),
      f('2026-11-08 22:00', 75), f('2026-11-07 19:00', 60), f('2026-11-07 09:00', 15),
      f('2026-11-10 12:00', 28),
    ];
    final cur = all.where((x) => isCurrentOrUpcoming(x, now)).toList();
    expect(cur.length, 7); // đề ghi 8, nhưng chỉ 7 bản ghi có End >= 09:00
    expect(cur.where((x) => x.alertLevel == 'High').length, 3); // đề ghi 2 nhưng depth 50/50/75 đều High
    expect(isCurrentOrUpcoming(f('2026-11-08 09:00', 10), now), isTrue); // end == phút hiện tại
  });
}
