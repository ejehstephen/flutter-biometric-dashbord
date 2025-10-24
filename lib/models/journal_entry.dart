class JournalEntry {
  final String date;
  final int mood;
  final String note;

  JournalEntry({
    required this.date,
    required this.mood,
    required this.note,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      date: json['date'] as String,
      mood: json['mood'] as int,
      note: json['note'] as String,
    );
  }
}
