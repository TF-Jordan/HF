class DailyVerseModel {
  final String? id;
  final String? date;
  final String reference;
  final String verse;
  final String? version;
  final String? comment;
  final String? author;

  const DailyVerseModel({
    this.id,
    this.date,
    required this.reference,
    required this.verse,
    this.version,
    this.comment,
    this.author,
  });

  factory DailyVerseModel.fromJson(Map<String, dynamic> json) {
    return DailyVerseModel(
      id: json['id']?.toString(),
      date: json['date'],
      reference: json['reference'] ?? '',
      verse: json['verse'] ?? '',
      version: json['version'],
      comment: json['comment'],
      author: json['author'],
    );
  }

  Map<String, dynamic> toJson() => {
    'reference': reference,
    'verse': verse,
    'version': version,
    'comment': comment,
    'author': author,
  };
}
