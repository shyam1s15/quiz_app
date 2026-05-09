import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/app/models/question.dart';
import 'package:quiz_app/app/models/quiz_result.dart';

void main() {
  group('Question Model', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 1,
        'category': 'Science',
        'question': 'What is H2O?',
        'options': ['Water', 'Oxygen', 'Hydrogen', 'Carbon dioxide'],
        'correctIndex': 0,
      };
      final q = Question.fromJson(json);
      expect(q.id, 1);
      expect(q.category, 'Science');
      expect(q.question, 'What is H2O?');
      expect(q.options.length, 4);
      expect(q.correctIndex, 0);
    });

    test('toJson round-trips correctly', () {
      const q = Question(
        id: 2,
        category: 'History',
        question: 'Who built the Taj Mahal?',
        options: ['Akbar', 'Shah Jahan', 'Humayun', 'Aurangzeb'],
        correctIndex: 1,
      );
      final json = q.toJson();
      final q2 = Question.fromJson(json);
      expect(q2.id, q.id);
      expect(q2.correctIndex, q.correctIndex);
    });
  });

  group('QuizResult', () {
    const result = QuizResult(
      category: 'Science',
      score: 8,
      total: 10,
      timeTaken: Duration(seconds: 150),
      answers: [true, true, false, true, true, true, true, false, true, true],
    );

    test('percentage is calculated correctly', () {
      expect(result.percentage, 80.0);
    });

    test('grade A for 80%', () {
      expect(result.grade, 'A');
    });

    test('grade A+ for 90%+', () {
      final r = QuizResult(
        category: 'Test',
        score: 10,
        total: 10,
        timeTaken: Duration.zero,
        answers: List.filled(10, true),
      );
      expect(r.grade, 'A+');
    });

    test('grade F for below 50%', () {
      final r = QuizResult(
        category: 'Test',
        score: 4,
        total: 10,
        timeTaken: Duration.zero,
        answers: List.filled(10, false),
      );
      expect(r.grade, 'F');
    });

    test('gradeMessage for 80% is Excellent', () {
      expect(result.gradeMessage, contains('Excellent'));
    });
  });
}
