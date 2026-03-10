class PublicationModel {
  final String? id;
  final String? reference;
  final String? type;
  final String? date;
  final String title;
  final String? content;
  final String? author;
  final String? status;
  final String? validationDate;
  final String? recipient;
  final String? category;

  const PublicationModel({
    this.id,
    this.reference,
    this.type,
    this.date,
    required this.title,
    this.content,
    this.author,
    this.status,
    this.validationDate,
    this.recipient,
    this.category,
  });

  factory PublicationModel.fromJson(Map<String, dynamic> json) {
    return PublicationModel(
      id: json['id']?.toString(),
      reference: json['reference'],
      type: json['type'],
      date: json['date'],
      title: json['title'] ?? '',
      content: json['content'],
      author: json['author'],
      status: json['status'],
      validationDate: json['validationDate'] ?? json['validation_date'],
      recipient: json['recipient'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() => {
    'reference': reference,
    'type': type,
    'title': title,
    'content': content,
    'author': author,
    'status': status,
    'recipient': recipient,
    'category': category,
  };
}
