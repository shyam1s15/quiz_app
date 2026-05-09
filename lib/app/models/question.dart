class Question {
  final int id;
  final String category;
  final String question;
  final List<String> options;
  final int correctIndex;

  const Question({
    required this.id,
    required this.category,
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as int,
      category: json['category'] as String,
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctIndex: json['correctIndex'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'question': question,
        'options': options,
        'correctIndex': correctIndex,
      };
}
