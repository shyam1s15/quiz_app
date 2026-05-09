import 'dart:async';
import 'package:get/get.dart';
import '../models/question.dart';
import '../models/quiz_result.dart';
import '../services/question_service.dart';
import '../services/analytics_service.dart';
import '../services/storage_service.dart';
import '../routes.dart';

class QuizController extends GetxController {
  // ── State ──────────────────────────────────────────────────
  final RxList<Question> questions = <Question>[].obs;
  final RxInt currentIndex = 0.obs;
  final RxInt score = 0.obs;
  final RxBool isLoading = true.obs;
  final RxBool isAnswered = false.obs;
  final RxInt selectedOptionIndex = (-1).obs;
  final RxList<bool> answerLog = <bool>[].obs;

  // Timer
  final RxInt timeLeft = 30.obs;
  Timer? _timer;
  final Stopwatch _stopwatch = Stopwatch();

  // Current category
  String category = '';

  // ── Lifecycle ───────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is String) {
      category = args;
    }
    _loadQuestions();
  }

  @override
  void onClose() {
    _timer?.cancel();
    _stopwatch.stop();
    super.onClose();
  }

  // ── Load Questions ───────────────────────────────────────────
  Future<void> _loadQuestions() async {
    isLoading.value = true;
    try {
      final loaded = category.isEmpty || category == 'Random'
          ? await QuestionService.getRandomQuestions()
          : await QuestionService.getQuestionsByCategory(category);
      questions.assignAll(loaded);
      answerLog.assignAll(List.filled(loaded.length, false));
      AnalyticsService.logQuizStart(category: category);
      _startTimer();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load questions: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
      _stopwatch.start();
    }
  }

  // ── Timer ────────────────────────────────────────────────────
  void _startTimer() {
    timeLeft.value = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft.value > 0) {
        timeLeft.value--;
      } else {
        // Time up – auto-advance
        _autoAnswer();
      }
    });
  }

  void _autoAnswer() {
    if (!isAnswered.value) {
      isAnswered.value = true;
      answerLog[currentIndex.value] = false;
      AnalyticsService.logQuestionAnswered(
        questionId: questions[currentIndex.value].id,
        correct: false,
        category: category,
      );
      Future.delayed(const Duration(milliseconds: 800), _nextQuestion);
    }
  }

  // ── Answer Handling ──────────────────────────────────────────
  void answer(int optionIndex) {
    if (isAnswered.value) return;
    isAnswered.value = true;
    selectedOptionIndex.value = optionIndex;
    _timer?.cancel();

    final isCorrect =
        questions[currentIndex.value].correctIndex == optionIndex;
    if (isCorrect) score.value++;
    answerLog[currentIndex.value] = isCorrect;

    AnalyticsService.logQuestionAnswered(
      questionId: questions[currentIndex.value].id,
      correct: isCorrect,
      category: category,
    );

    Future.delayed(const Duration(milliseconds: 1000), _nextQuestion);
  }

  void _nextQuestion() {
    if (currentIndex.value < questions.length - 1) {
      currentIndex.value++;
      isAnswered.value = false;
      selectedOptionIndex.value = -1;
      _startTimer();
    } else {
      _finishQuiz();
    }
  }

  // ── Finish ───────────────────────────────────────────────────
  void _finishQuiz() {
    _timer?.cancel();
    _stopwatch.stop();

    final result = QuizResult(
      category: category,
      score: score.value,
      total: questions.length,
      timeTaken: _stopwatch.elapsed,
      answers: List<bool>.from(answerLog),
    );

    AnalyticsService.logQuizComplete(
      score: score.value,
      total: questions.length,
      category: category,
      durationSeconds: _stopwatch.elapsed.inSeconds,
    );

    StorageService.saveHighScore(category, score.value);

    Get.offNamed(Routes.result, arguments: result);
  }

  // ── Helpers ──────────────────────────────────────────────────
  Question get currentQuestion => questions[currentIndex.value];
  bool get isLastQuestion => currentIndex.value == questions.length - 1;
  double get progress =>
      questions.isEmpty ? 0 : (currentIndex.value + 1) / questions.length;
}
