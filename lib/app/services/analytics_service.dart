// Stub analytics service – replace with real Firebase Analytics when
// google-services.json is in place.
//
// Usage:
//   AnalyticsService.logQuizStart(category: 'Science');
//   AnalyticsService.logQuizComplete(score: 8, total: 10);
//   AnalyticsService.logAdViewed(adType: 'banner');

class AnalyticsService {
  // ignore: avoid_print
  static void _log(String event, [Map<String, dynamic>? params]) {
    // TODO: Replace with FirebaseAnalytics.instance.logEvent(name: event, parameters: params)
    // ignore: avoid_print
    print('[Analytics] $event | params: $params');
  }

  static void logAppOpen() => _log('app_open');

  static void logCategorySelected(String category) =>
      _log('category_selected', {'category': category});

  static void logQuizStart({required String category}) =>
      _log('quiz_start', {'category': category});

  static void logQuestionAnswered({
    required int questionId,
    required bool correct,
    required String category,
  }) =>
      _log('question_answered',
          {'question_id': questionId, 'correct': correct, 'category': category});

  static void logQuizComplete({
    required int score,
    required int total,
    required String category,
    required int durationSeconds,
  }) =>
      _log('quiz_complete', {
        'score': score,
        'total': total,
        'category': category,
        'duration_seconds': durationSeconds,
      });

  static void logAdViewed({required String adType}) =>
      _log('ad_viewed', {'ad_type': adType});

  static void logShareClick({required String platform}) =>
      _log('share_click', {'platform': platform});
}
