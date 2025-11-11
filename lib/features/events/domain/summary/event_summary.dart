class EventSummary {
  final Map<String, int> byType;

  const EventSummary({required this.byType});

  int get totalCount => byType.values.fold(0, (sum, value) => sum + value);
}
