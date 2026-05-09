class QuizResult {
  final String category;
  final int score;
  final int total;
  final Duration timeTaken;
  final List<bool> answers; // true = correct, false = wrong

  const QuizResult({
    required this.category,
    required this.score,
    required this.total,
    required this.timeTaken,
    required this.answers,
  });

  double get percentage => total > 0 ? (score / total) * 100 : 0;

  String get grade {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 60) return 'C';
    if (percentage >= 50) return 'D';
    return 'F';
  }

  String get gradeMessage {
    if (percentage >= 90) return 'Outstanding! 🏆';
    if (percentage >= 80) return 'Excellent! 🌟';
    if (percentage >= 70) return 'Good Job! 👍';
    if (percentage >= 60) return 'Not Bad! 😊';
    if (percentage >= 50) return 'Keep Trying! 💪';
    return 'Better Luck Next Time! 📚';
  }
}
