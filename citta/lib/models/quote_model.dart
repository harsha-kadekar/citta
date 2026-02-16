class QuoteModel {
  final String id;
  final String source;
  final String reference;
  final String originalText;
  final String originalLanguage;
  final String translation;
  final bool userAdded;

  const QuoteModel({
    required this.id,
    required this.source,
    required this.reference,
    required this.originalText,
    this.originalLanguage = 'sanskrit',
    required this.translation,
    this.userAdded = false,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      id: json['id'] as String,
      source: json['source'] as String,
      reference: json['reference'] as String? ?? '',
      originalText: json['originalText'] as String,
      originalLanguage: json['originalLanguage'] as String? ?? 'sanskrit',
      translation: json['translation'] as String,
      userAdded: json['userAdded'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'source': source,
      'reference': reference,
      'originalText': originalText,
      'originalLanguage': originalLanguage,
      'translation': translation,
      'userAdded': userAdded,
    };
  }
}
