import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/question.dart';
import '../utils/constants.dart';

class QuestionService {
  static List<Question>? _cachedQuestions;

  static Future<List<Question>> loadQuestions() async {
    if (_cachedQuestions != null) return _cachedQuestions!;
    final jsonString =
        await rootBundle.loadString('assets/data/questions.json');
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    _cachedQuestions =
        jsonList.map((e) => Question.fromJson(e as Map<String, dynamic>)).toList();
    return _cachedQuestions!;
  }

  static Future<List<Question>> getQuestionsByCategory(String category) async {
    final all = await loadQuestions();
    final filtered = all.where((q) => q.category == category).toList();
    filtered.shuffle();
    return filtered.take(AppConstants.questionsPerQuiz).toList();
  }

  static Future<List<Question>> getRandomQuestions() async {
    final all = await loadQuestions();
    final shuffled = List<Question>.from(all)..shuffle();
    return shuffled.take(AppConstants.questionsPerQuiz).toList();
  }
}
