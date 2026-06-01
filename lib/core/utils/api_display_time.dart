const Duration apiDisplayTimeOffset = Duration(hours: 6);

DateTime applyApiDisplayTimeOffset(DateTime date) {
  return date.add(apiDisplayTimeOffset);
}

DateTime? applyApiDisplayTimeOffsetOrNull(DateTime? date) {
  if (date == null) return null;
  return applyApiDisplayTimeOffset(date);
}
