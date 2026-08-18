import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../services/nutrition_profile_service.dart';
import '../services/nutrition_log_service.dart';
import '../models/nutrition_profile.dart';
import '../theme/app_colors.dart';
import '../widgets/larc_progress.dart';

class NutritionDashboardScreen extends StatefulWidget {
  const NutritionDashboardScreen({super.key});
  @override State<NutritionDashboardScreen> createState() =>
      _NutritionDashboardScreenState();
}

class _NutritionDashboardScreenState
    extends State<NutritionDashboardScreen> {
  final service = NutritionProfileService();
  final logService = NutritionLogService();
  final age = TextEditingController();
  final height = TextEditingController();
  final weight = TextEditingController();
  String sex = 'female';
  String activity = 'low';
  bool breastfeeding = false;
  Future<NutritionProfileResult>? future;

  void calculate() {
    final a = int.tryParse(age.text);
    final h = double.tryParse(height.text);
    final w = double.tryParse(weight.text);
    if (a == null || h == null || w == null) return;
    setState(() {
      future = service.calculate(
        age: a,
        sex: sex,
        heightCm: h,
        weightKg: w,
        activityLevel: activity,
        breastfeeding: breastfeeding,
      );
    });
    future!.then((result) {
      if (mounted) context.read<AppState>().setCalorieTarget(result.calorieTarget);
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Directionality(
      textDirection: s.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.isArabic ? 'ملفي الغذائي' : 'Nutrition Dashboard'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _TodaySection(logService: logService),
            const SizedBox(height: 28),
            Text(
              s.isArabic
                  ? 'أدخل بياناتك للحصول على مؤشرات تقديرية'
                  : 'Enter your data for estimated nutrition indicators.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: age,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: s.isArabic ? 'العمر' : 'Age',
              ),
            ),
            TextField(
              controller: height,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: s.isArabic ? 'الطول (سم)' : 'Height (cm)',
              ),
            ),
            TextField(
              controller: weight,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: s.isArabic ? 'الوزن (كغ)' : 'Weight (kg)',
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: sex,
              items: const [
                DropdownMenuItem(value: 'female', child: Text('Female')),
                DropdownMenuItem(value: 'male', child: Text('Male')),
              ],
              onChanged: (v) => setState(() => sex = v ?? 'female'),
              decoration: const InputDecoration(labelText: 'Sex'),
            ),
            DropdownButtonFormField<String>(
              value: activity,
              items: const [
                DropdownMenuItem(value: 'sedentary', child: Text('Sedentary')),
                DropdownMenuItem(value: 'low', child: Text('Low')),
                DropdownMenuItem(value: 'moderate', child: Text('Moderate')),
                DropdownMenuItem(value: 'high', child: Text('High')),
              ],
              onChanged: (v) => setState(() => activity = v ?? 'low'),
              decoration: const InputDecoration(labelText: 'Activity'),
            ),
            SwitchListTile(
              title: Text(
                s.isArabic
                    ? 'الرضاعة الطبيعية'
                    : 'Breastfeeding',
              ),
              value: breastfeeding,
              onChanged: (v) => setState(() => breastfeeding = v),
            ),
            FilledButton(
              onPressed: calculate,
              child: Text(s.isArabic ? 'احسب المؤشرات' : 'Calculate'),
            ),
            const SizedBox(height: 16),
            if (future != null)
              FutureBuilder<NutritionProfileResult>(
                future: future,
                builder: (_, snap) {
                  if (!snap.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final p = snap.data!;
                  return Column(
                    children: [
                      _indicator('BMI', p.bmi.toStringAsFixed(1)),
                      _indicator(
                        s.isArabic ? 'تصنيف BMI' : 'BMI Range',
                        p.bmiCategory,
                      ),
                      _indicator('BMR', '${p.bmr.round()} kcal'),
                      _indicator('TDEE', '${p.tdee.round()} kcal'),
                      _indicator(
                        s.isArabic
                            ? 'الهدف اليومي التقديري'
                            : 'Estimated Daily Target',
                        '${p.calorieTarget.round()} kcal',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        s.isArabic
                            ? 'هذه مؤشرات تقديرية وليست تشخيصًا طبيًا.'
                            : 'These are estimates, not medical diagnoses.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _indicator(String label, String value) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

/// "Today" — shows consumed / target / remaining calories, computed by
/// the backend Nutrition Engine (POST /nutrition-log/summary) from the
/// items the user has added via Recipe Details -> Nutrition -> "Add to
/// Today's Calories". Also lets the user remove a logged item.
class _TodaySection extends StatefulWidget {
  const _TodaySection({required this.logService});
  final NutritionLogService logService;

  @override
  State<_TodaySection> createState() => _TodaySectionState();
}

class _TodaySectionState extends State<_TodaySection> {
  Future<DailyNutritionSummary>? _future;
  int _lastCount = -1;
  double _lastTarget = -1;

  void _refresh(AppState s) {
    if (s.todayLog.length == _lastCount && s.calorieTarget == _lastTarget) {
      return;
    }
    _lastCount = s.todayLog.length;
    _lastTarget = s.calorieTarget;
    _future = widget.logService.summarize(
      calorieTarget: s.calorieTarget,
      items: s.todayLog,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    _refresh(s);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.isArabic ? 'اليوم' : 'Today',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        if (s.todayLog.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                s.isArabic
                    ? 'لم تُضف أي وصفة بعد اليوم. افتح وصفة ثم اضغط "أضف إلى سعرات اليوم".'
                    : 'Nothing logged yet today. Open a recipe and tap '
                        '"Add to Today\'s Calories".',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          )
        else
          FutureBuilder<DailyNutritionSummary>(
            future: _future,
            builder: (_, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snap.hasError || !snap.hasData) {
                return Text(
                  s.isArabic
                      ? 'تعذر حساب ملخص اليوم'
                      : "Could not calculate today's summary",
                  style: Theme.of(context).textTheme.bodySmall,
                );
              }
              final sum = snap.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      LarcProgressRing(
                        value: sum.progressPercent / 100,
                        label: '${sum.progressPercent.round()}%',
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.isArabic
                                  ? '${sum.consumedCalories.round()} من ${sum.targetCalories.round()} سعرة'
                                  : '${sum.consumedCalories.round()} / '
                                      '${sum.targetCalories.round()} kcal',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              s.isArabic
                                  ? '${sum.remainingCalories.round()} سعرة متبقية'
                                  : '${sum.remainingCalories.round()} kcal remaining',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ...s.todayLog.asMap().entries.map((entry) {
                    final i = entry.key;
                    final item = entry.value;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: Text(item.name),
                      subtitle: Text('${item.calories.round()} kcal'),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                        onPressed: () => s.removeFromTodayLog(i),
                      ),
                    );
                  }),
                ],
              );
            },
          ),
      ],
    );
  }
}
