String formatWithOrdinal(DateTime date) {
  String month = _monthName(date.month);
  String day = _ordinal(date.day);
  return "$month $day, ${date.year}";
}

String _monthName(int month) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return months[month - 1];
}

String _ordinal(int day) {
  if (day >= 11 && day <= 13) return '${day}th';

  switch (day % 10) {
    case 1:
      return '${day}st';
    case 2:
      return '${day}nd';
    case 3:
      return '${day}rd';
    default:
      return '${day}th';
  }
}