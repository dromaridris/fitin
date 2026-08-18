import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/nutrition_profile.dart';
import '../services/nutrition_log_service.dart';
import '../services/nutrition_profile_service.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/larc_progress.dart';

class NutritionDashboardScreen extends StatefulWidget {
  const NutritionDashboardScreen({super.key});

  @override
  State<NutritionDashboardScreen> createState() =>
      _NutritionDashboardScreenState();
}

class _NutritionDashboardScreenState extends State<NutritionDashboardScreen> {
  final NutritionProfileService service = NutritionProfileService();
  final NutritionLogService logService = NutritionLogService();
  final TextEditingController age = TextEditingController();
  final TextEditingController height = TextEditingController();
  final TextEditingController weight = TextEditingController();

  String sex = 'female';
  String activity = 'low';
  bool breastfeeding = false;
  NutritionProfileResult? result;
  String? error;

  @override
  void dispose() {
    age.dispose();
    height.dispose();
    weight.dispose();
    super.dispose();
  }

  void calculate() {
    final parsedAge = int.tryParse(age.text);
    final parsedHeight = double.tryParse(height.text);
    final parsedWeight = double.tryParse(weight.text);

    if (parsedAge == null || parsedHeight == null || parsedWeight == null) {
      setState(() {
        result = null;
        error = 'invalid';
      });
      return;
    }

    try {
      final calculated = service.calculate(
        age: parsedAge,
        sex: sex,
        heightCm: parsedHeight,
        weightKg: parsedWeight,
        activityLevel: activity,
        breastfeeding: breastfeeding,
      );
      setState(() {
        result = calculated;
        error = null;
      });
      context.read<AppState>().setCalorieTarget(calculated.calorieTarget);
    } catch (_) {
      setState(() {
        result = null;
        error = 'invalid';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Directionality(
      textDirection: state.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            state.isArabic ? 'ملفي الغذائي' : 'Nutrition Dashboard',
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _TodaySection(logService: logService),
            const SizedBox(height: 28),
            Text(
              state.isArabic
                  ? 'أدخل بياناتك للحصول على مؤشرات تقديرية'
                  : 'Enter your data for estimated nutrition indicators.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: age,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: state.isArabic ? 'العمر' : 'Age',
              ),
            ),
            TextField(
              controller: height,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: state.isArabic ? 'الطول (سم)' : 'Height (cm)',
              ),
            ),
            TextField(
              controller: weight,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: state.isArabic ? 'الوزن (كغ)' : 'Weight (kg)',
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: sex,
              items: const [
                DropdownMenuItem(value: 'female', child: Text('Female')),
                DropdownMenuItem(value: 'male', child: Text('Male')),
              ],
              onChanged: (value) => setState(() => sex = value ?? 'female'),
              decoration: const InputDecoration(labelText: 'Sex'),
            ),
            DropdownButtonFormField<String>(
              initialValue: activity,
              items: const [
                DropdownMenuItem(
                  value: 'sedentary',
                  child: Text('Sedentary'),
                ),
                DropdownMenuItem(value: 'low', child: Text('Low')),
                DropdownMenuItem(value: 'moderate', child: Text('Moderate')),
                DropdownMenuItem(value: 'high', child: Text('High')),
              ],
              onChanged: (value) => setState(() => activity = value ?? 'low'),
              decoration: const InputDecoration(labelText: 'Activity'),
            ),
            SwitchListTile(
              title: Text(
                state.isArabic ? 'الرضاعة الطبيعية' : 'Breastfeeding',
              ),
              value: breastfeeding,
              onChanged: (value) => setState(() => breastfeeding = value),
            ),
            FilledButton(
              onPressed: calculate,
              child: Text(state.isArabic ? 'احسب المؤشرات' : 'Calculate'),
            ),
            const SizedBox(height: 16),
            if (error != null)
              Text(
                state.isArabic
                    ? 'يرجى إدخال قيم صحيحة'
                    : 'Please enter valid values',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            if (result != null) ...[
              _indicator('BMI', result!.bmi.toStringAsFixed(1)),
              _indicator(
                state.isArabic ? 'تصنيف BMI' : 'BMI Range',
                result!.bmiCategory,
              ),
              _indicator('BMR', '${result!.bmr.round()} kcal'),
              _indicator('TDEE', '${result!.tdee.round()} kcal'),
              _indicator(
                state.isArabic
                    ? 'الهدف اليومي التقديري'
                    : 'Estimated Daily Target',
                '${result!.calorieTarget.round()} kcal',
              ),
              const SizedBox(height: 8),
              Text(
                state.isArabic
                    ? 'هذه مؤشرات تقديرية وليست تشخيصًا طبيًا.'
                    : 'These are estimates, not medical diagnoses.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
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

class _TodaySection extends StatelessWidget {
  const _TodaySection({required this.logService});

  final NutritionLogService logService;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final summary = logService.summarize(
      calorieTarget: state.calorieTarget,
      items: state.todayLog,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          state.isArabic ? 'اليوم' : 'Today',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        if (state.todayLog.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                state.isArabic
                    ? 'لم تُضف أي وصفة بعد اليوم. افتح وصفة ثم اضغط "أضف إلى سعرات اليوم".'
                    : 'Nothing logged yet today. Open a recipe and tap "Add to Today\'s Calories".',
              ),
            ),
          )
        else ...[
          Row(
            children: [
              LarcProgressRing(
                value: summary.progressPercent / 100,
                label: '${summary.progressPercent.round()}%',
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.isArabic
                          ? '${summary.consumedCalories.round()} من ${summary.targetCalories.round()} سعرة'
                          : '${summary.consumedCalories.round()} / ${summary.targetCalories.round()} kcal',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      state.isArabic
                          ? '${summary.remainingCalories.round()} سعرة متبقية'
                          : '${summary.remainingCalories.round()} kcal remaining',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...state.todayLog.asMap().entries.map((entry) {
            final index = entry.key;
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
                onPressed: () => state.removeFromTodayLog(index),
              ),
            );
          }),
        ],
      ],
    );
  }
}
