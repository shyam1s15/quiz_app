import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/quiz_controller.dart';
import '../../utils/theme.dart';
import '../../widgets/banner_ad_widget.dart';

class QuizPage extends GetView<QuizController> {
  const QuizPage({super.key});

  @override
  Widget build(BuildContext context) {
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
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              );
            }
            return Column(
              children: [
                _buildHeader(context),
                _buildProgressBar(),
                Expanded(child: _buildQuestionCard(context)),
                const BannerAdWidget(),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppTheme.textPrimary, size: 18),
            ),
          ),
          Obx(() => Text(
                'Q ${controller.currentIndex.value + 1} / ${controller.questions.length}',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              )),
          Obx(() => Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: controller.timeLeft.value <= 10
                          ? AppTheme.error.withValues(alpha: 0.2)
                          : AppTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: controller.timeLeft.value <= 10
                          ? Border.all(
                              color: AppTheme.error.withValues(alpha: 0.5))
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.timer_rounded,
                          size: 16,
                          color: controller.timeLeft.value <= 10
                              ? AppTheme.error
                              : AppTheme.accent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${controller.timeLeft.value}s',
                          style: TextStyle(
                            color: controller.timeLeft.value <= 10
                                ? AppTheme.error
                                : AppTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 16, color: AppTheme.accentGold),
                        const SizedBox(width: 4),
                        Text(
                          '${controller.score.value}',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Obx(() => ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: controller.progress,
              minHeight: 6,
              backgroundColor: AppTheme.divider,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
          )),
    );
  }

  Widget _buildQuestionCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Obx(() {
        if (controller.questions.isEmpty) return const SizedBox();
        final question = controller.currentQuestion;
        final categoryColor =
            AppTheme.categoryColors[question.category] ?? AppTheme.primary;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: categoryColor.withValues(alpha: 0.4), width: 1),
                ),
                child: Text(
                  question.category,
                  style: TextStyle(
                    color: categoryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Text(
                  question.question,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ...List.generate(question.options.length, (i) {
                return _buildOptionButton(i, question, categoryColor);
              }),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildOptionButton(int index, question, Color categoryColor) {
    return Obx(() {
      final isAnswered = controller.isAnswered.value;
      final selected = controller.selectedOptionIndex.value;
      final isCorrect = question.correctIndex == index;
      final isSelected = selected == index;

      Color borderColor = AppTheme.divider;
      Color bgColor = AppTheme.surfaceElevated;
      Color textColor = AppTheme.textPrimary;
      IconData? trailingIcon;
      Color? iconColor;

      if (isAnswered) {
        if (isCorrect) {
          borderColor = AppTheme.success;
          bgColor = AppTheme.success.withValues(alpha: 0.12);
          textColor = AppTheme.success;
          trailingIcon = Icons.check_circle_rounded;
          iconColor = AppTheme.success;
        } else if (isSelected && !isCorrect) {
          borderColor = AppTheme.error;
          bgColor = AppTheme.error.withValues(alpha: 0.12);
          textColor = AppTheme.error;
          trailingIcon = Icons.cancel_rounded;
          iconColor = AppTheme.error;
        }
      }

      return GestureDetector(
        onTap: () => controller.answer(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isAnswered && isCorrect
                      ? AppTheme.success.withValues(alpha: 0.2)
                      : isAnswered && isSelected
                          ? AppTheme.error.withValues(alpha: 0.2)
                          : AppTheme.divider,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question.options[index],
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: 8),
                Icon(trailingIcon, color: iconColor, size: 22),
              ],
            ],
          ),
        ),
      );
    });
  }
}
