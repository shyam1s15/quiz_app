import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart' show Share;
import '../../controllers/result_controller.dart';
import '../../utils/theme.dart';
import '../../routes.dart';
import '../../widgets/banner_ad_widget.dart';

class ResultPage extends GetView<ResultController> {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final result = controller.result;
    final categoryColor =
        AppTheme.categoryColors[result.category] ?? AppTheme.primary;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0E1A), Color(0xFF131929)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildScoreCircle(result, categoryColor),
                      const SizedBox(height: 24),
                      _buildStatsRow(result),
                      const SizedBox(height: 24),
                      _buildAnswerBreakdown(result),
                      const SizedBox(height: 24),
                      _buildActionButtons(result),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              const BannerAdWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCircle(result, Color color) {
    return Column(
      children: [
        Text(
          result.gradeMessage,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 20),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 160,
              height: 160,
              child: CircularProgressIndicator(
                value: result.percentage / 100,
                strokeWidth: 12,
                backgroundColor: AppTheme.divider,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeCap: StrokeCap.round,
              ),
            ),
            Column(
              children: [
                Text(
                  '${result.score}/${result.total}',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  result.grade,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow(result) {
    final minutes = result.timeTaken.inMinutes;
    final seconds = result.timeTaken.inSeconds % 60;
    return Row(
      children: [
        _statCard(
          icon: Icons.percent_rounded,
          label: 'Accuracy',
          value: '${result.percentage.toStringAsFixed(0)}%',
          color: AppTheme.accent,
        ),
        const SizedBox(width: 12),
        _statCard(
          icon: Icons.timer_rounded,
          label: 'Time',
          value: '${minutes}m ${seconds}s',
          color: AppTheme.accentGold,
        ),
        const SizedBox(width: 12),
        _statCard(
          icon: Icons.quiz_rounded,
          label: 'Category',
          value: result.category,
          color: AppTheme.primary,
          small: true,
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool small = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: small ? 11 : 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerBreakdown(result) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Answer Breakdown',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(result.answers.length, (i) {
              final correct = result.answers[i];
              return Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: correct
                      ? AppTheme.success.withValues(alpha: 0.15)
                      : AppTheme.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: correct
                        ? AppTheme.success.withValues(alpha: 0.5)
                        : AppTheme.error.withValues(alpha: 0.5),
                  ),
                ),
                child: Icon(
                  correct ? Icons.check_rounded : Icons.close_rounded,
                  color: correct ? AppTheme.success : AppTheme.error,
                  size: 20,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(result) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () =>
                Get.offNamed(Routes.quiz, arguments: result.category),
            icon: const Icon(Icons.replay_rounded, size: 20),
            label: const Text('Play Again'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Get.offAllNamed(Routes.category),
                icon: const Icon(Icons.category_rounded,
                    size: 18, color: AppTheme.textSecondary),
                label: const Text(
                  'Categories',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.divider),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Share.share(
                    '🧠 I scored ${result.score}/${result.total} '
                    '(${result.percentage.toStringAsFixed(0)}%) on the '
                    '${result.category} quiz in GK Quiz App! '
                    'Can you beat me? 🏆 #GKQuiz #Trivia',
                  );
                },
                icon: const Icon(Icons.share_rounded,
                    size: 18, color: AppTheme.accent),
                label: const Text(
                  'Share',
                  style: TextStyle(color: AppTheme.accent),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppTheme.accent.withValues(alpha: 0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
