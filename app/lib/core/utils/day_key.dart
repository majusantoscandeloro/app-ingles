/// Chave de dia local no formato `yyyy-MM-dd`.
String dayKey(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

String yesterdayKey(DateTime now) => dayKey(DateTime(now.year, now.month, now.day - 1));
