import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _highScorePrefix = 'high_score_';
  static const String _totalGamesKey = 'total_games';

  static Future<void> saveHighScore(String category, int score) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('$_highScorePrefix$category') ?? 0;
    if (score > current) {
      await prefs.setInt('$_highScorePrefix$category', score);
    }
    final total = prefs.getInt(_totalGamesKey) ?? 0;
    await prefs.setInt(_totalGamesKey, total + 1);
  }

  static Future<int> getHighScore(String category) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_highScorePrefix$category') ?? 0;
  }

  static Future<int> getTotalGames() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_totalGamesKey) ?? 0;
  }

  static Future<Map<String, int>> getAllHighScores() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'Science': prefs.getInt('${_highScorePrefix}Science') ?? 0,
      'History': prefs.getInt('${_highScorePrefix}History') ?? 0,
      'Geography': prefs.getInt('${_highScorePrefix}Geography') ?? 0,
      'Current Affairs': prefs.getInt('${_highScorePrefix}Current Affairs') ?? 0,
      'Sports': prefs.getInt('${_highScorePrefix}Sports') ?? 0,
    };
  }
}
