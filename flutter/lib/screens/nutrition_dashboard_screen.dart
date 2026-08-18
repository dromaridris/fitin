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
  @override State<NutritionDashboardScreen> createState()=>_NutritionDashboardScreenState();
}
class _NutritionDashboardScreenState extends State<NutritionDashboardScreen>{
  final service=NutritionProfileService(); final logService=NutritionLogService();
  final age=TextEditingController(); final height=TextEditingController(); final weight=TextEditingController();
  String sex='female'; String activity='low'; bool breastfeeding=false; NutritionProfileResult? result; String? error;
  void calculate(){
    final a=int.tryParse(age.text); final h=double.tryParse(height.text); final w=double.tryParse(weight.text);
    if(a==null||h==null||w==null){setState((){result=null;error='invalid';});return;}
    try{final r=service.calculate(age:a,sex:sex,heightCm:h,weightKg:w,activityLevel:activity,breastfeeding:breastfeeding);setState((){result=r;error=null;});context.read<AppState>().setCalorieTarget(r.calorieTarget);}catch(_){setState((){result=null;error='invalid';});}
  }
  @override Widget build(BuildContext context){final s=context.watch<AppState>();return Directionality(textDirection:s.isArabic?TextDirection.rtl:TextDirection.ltr,child:Scaffold(appBar:AppBar(title:Text(s.isArabic?'ملفي الغذائي':'Nutrition Dashboard')),body:ListView(padding:const EdgeInsets.all(16),children:[
    _TodaySection(logService:logService),const SizedBox(height:28),Text(s.isArabic?'أدخل بياناتك للحصول على مؤشرات تقديرية':'Enter your data for estimated nutrition indicators.'),const SizedBox(height:12),
    TextField(controller:age,keyboardType:TextInputType.number,decoration:InputDecoration(labelText:s.isArabic?'العمر':'Age')),
    TextField(controller:height,keyboardType:TextInputType.number,decoration:InputDecoration(labelText:s.isArabic?'الطول (سم)':'Height (cm)')),
    TextField(controller:weight,keyboardType:TextInputType.number,decoration:InputDecoration(labelText:s.isArabic?'الوزن (كغ)':'Weight (kg)')),const SizedBox(height:8),
    DropdownButtonFormField<String>(initialValue:sex,items:const [DropdownMenuItem(value:'female',child:Text('Female')),DropdownMenuItem(value:'male',child:Text('Male'))],onChanged:(v)=>setState(()=>sex=v??'female'),decoration:const InputDecoration(labelText:'Sex')),
    DropdownButtonFormField<String>(initialValue:activity,items:const [DropdownMenuItem(value:'sedentary',child:Text('Sedentary')),DropdownMenuItem(value:'low',child:Text('Low')),DropdownMenuItem(value:'moderate',child:Text('Moderate')),DropdownMenuItem(value:'high',child:Text('High'))],onChanged:(v)=>setState(()=>activity=v??'low'),decoration:const InputDecoration(labelText:'Activity')),
    SwitchListTile(title:Text(s.isArabic?'الرضاعة الطبيعية':'Breastfeeding'),value:breastfeeding,onChanged:(v)=>setState(()=>breastfeeding=v)),
    FilledButton(onPressed:calculate,child:Text(s.isArabic?'احسب المؤشرات':'Calculate')),const SizedBox(height:16),
    if(error!=null) Text(s.isArabic?'يرجى إدخال قيم صحيحة':'Please enter valid values',style:TextStyle(color:Theme.of(context).colorScheme.error)),
    if(result!=null)...[_indicator('BMI',result!.bmi.toStringAsFixed(1)),_indicator(s.isArabic?'تصنيف BMI':'BMI Range',result!.bmiCategory),_indicator('BMR','${result!.bmr.round()} kcal'),_indicator('TDEE','${result!.tdee.round()} kcal'),_indicator(s.isArabic?'الهدف اليومي التقديري':'Estimated Daily Target','${result!.calorieTarget.round()} kcal'),const SizedBox(height:8),Text(s.isArabic?'هذه مؤشرات تقديرية وليست تشخيصًا طبيًا.':'These are estimates, not medical diagnoses.',style:Theme.of(context).textTheme.bodySmall)]
  ]))));}
  Widget _indicator(String label,String value)=>Card(child:ListTile(title:Text(label),trailing:Text(value,style:const TextStyle(fontWeight:FontWeight.bold))));
}

class _TodaySection extends StatelessWidget{
  const _TodaySection({required this.logService}); final NutritionLogService logService;
  @override Widget build(BuildContext context){final s=context.watch<AppState>();final sum=logService.summarize(calorieTarget:s.calorieTarget,items:s.todayLog);return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Text(s.isArabic?'اليوم':'Today',style:Theme.of(context).textTheme.headlineSmall),const SizedBox(height:12),
    if(s.todayLog.isEmpty) Card(child:Padding(padding:const EdgeInsets.all(16),child:Text(s.isArabic?'لم تُضف أي وصفة بعد اليوم. افتح وصفة ثم اضغط "أضف إلى سعرات اليوم".':'Nothing logged yet today. Open a recipe and tap "Add to Today\'s Calories".')))
    else ...[
      Row(children:[LarcProgressRing(value:sum.progressPercent/100,label:'${sum.progressPercent.round()}%'),const SizedBox(width:16),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(s.isArabic?'${sum.consumedCalories.round()} من ${sum.targetCalories.round()} سعرة':'${sum.consumedCalories.round()} / ${sum.targetCalories.round()} kcal',style:Theme.of(context).textTheme.titleMedium),Text(s.isArabic?'${sum.remainingCalories.round()} سعرة متبقية':'${sum.remainingCalories.round()} kcal remaining',style:Theme.of(context).textTheme.bodySmall)]))]),const SizedBox(height:14),
      ...s.todayLog.asMap().entries.map((entry){final i=entry.key;final item=entry.value;return ListTile(contentPadding:EdgeInsets.zero,dense:true,title:Text(item.name),subtitle:Text('${item.calories.round()} kcal'),trailing:IconButton(icon:const Icon(Icons.close,size:18,color:AppColors.textMuted),onPressed:()=>s.removeFromTodayLog(i)));})
    ]
  ]);}
}
