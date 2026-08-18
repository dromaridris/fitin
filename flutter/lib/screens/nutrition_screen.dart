import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/larc_button.dart';
import '../services/offline_data.dart';

class NutritionScreen extends StatefulWidget {
  final int recipeId; final String? recipeTitle; final int initialServings;
  const NutritionScreen({super.key,required this.recipeId,this.recipeTitle,required this.initialServings});
  @override State<NutritionScreen> createState()=>_NutritionScreenState();
}
class _NutritionScreenState extends State<NutritionScreen>{
  late int servings; bool _addedToday=false;
  @override void initState(){super.initState();servings=widget.initialServings<1?1:widget.initialServings;}
  Map<String,dynamic> calculate(){
    final r=offlineRecipes.firstWhere((x)=>x.id==widget.recipeId);
    final factor=servings/r.servings;
    double cal=0,p=0,c=0,f=0,fiber=0;
    final items=<Map<String,dynamic>>[];
    for(final ri in r.ingredients){final i=ingredientById(ri.ingredientId);final q=ri.quantityG*factor;final nf=q/100.0;cal+=i.calories*nf;p+=i.protein*nf;c+=i.carbs*nf;f+=i.fat*nf;fiber+=i.fiber*nf;items.add({'name_en':i.nameEn,'name_ar':i.nameAr,'name_ro':i.nameRo,'quantity_g':double.parse(q.toStringAsFixed(1))});}
    double one(double v)=>double.parse(v.toStringAsFixed(1));
    final total={'calories':one(cal),'protein_g':one(p),'carbs_g':one(c),'fat_g':one(f),'fiber_g':one(fiber)};
    final per={'calories':one(cal/servings),'protein_g':one(p/servings),'carbs_g':one(c/servings),'fat_g':one(f/servings),'fiber_g':one(fiber/servings)};
    return {'nutrition':total,'nutrition_per_serving':per,'ingredients':items};
  }
  void change(int value){if(value<1||value>100)return;setState((){servings=value;_addedToday=false;});}
  void addToToday(Map<String,dynamic> nutrition){final state=context.read<AppState>();state.addToTodayLog(FoodLogItem(name:widget.recipeTitle??'Recipe #${widget.recipeId}',calories:(nutrition['calories'] as num? ?? 0).toDouble(),proteinG:(nutrition['protein_g'] as num? ?? 0).toDouble(),carbsG:(nutrition['carbs_g'] as num? ?? 0).toDouble(),fatG:(nutrition['fat_g'] as num? ?? 0).toDouble()));setState(()=>_addedToday=true);ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(state.isArabic?'أُضيف إلى سعرات اليوم':"Added to today's calories")));}
  @override Widget build(BuildContext context){final s=context.watch<AppState>();final data=calculate();final total=data['nutrition'] as Map<String,dynamic>;final per=data['nutrition_per_serving'] as Map<String,dynamic>;final ingredients=data['ingredients'] as List;
    return Directionality(textDirection:s.isArabic?TextDirection.rtl:TextDirection.ltr,child:Scaffold(appBar:AppBar(title:Text(s.isArabic?'السعرات والكميات':'Nutrition')),body:ListView(padding:const EdgeInsets.all(20),children:[
      Card(child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Padding(padding:const EdgeInsets.all(16),child:Text(s.isArabic?'الحصص':'Servings')),Row(children:[IconButton(onPressed:()=>change(servings-1),icon:const Icon(Icons.remove)),Text('$servings'),IconButton(onPressed:()=>change(servings+1),icon:const Icon(Icons.add))])])),const SizedBox(height:16),
      Text(s.isArabic?'الإجمالي لـ $servings حصص':'Total for $servings serving(s)',style:Theme.of(context).textTheme.titleLarge),const SizedBox(height:10),Wrap(spacing:8,runSpacing:8,children:[_metric('Calories','${total['calories']} kcal'),_metric('Protein','${total['protein_g']} g'),_metric('Carbs','${total['carbs_g']} g'),_metric('Fat','${total['fat_g']} g'),_metric('Fiber','${total['fiber_g']} g')]),const SizedBox(height:16),
      Text(s.isArabic?'لكل حصة':'Per Serving',style:Theme.of(context).textTheme.titleMedium),const SizedBox(height:8),Text('${per['calories']} kcal • ${per['protein_g']}g P • ${per['carbs_g']}g C • ${per['fat_g']}g F'),const SizedBox(height:20),
      LarcPrimaryButton(label:_addedToday?(s.isArabic?'أُضيف ✓':'Added ✓'):(s.isArabic?'أضف إلى سعرات اليوم':"Add to Today's Calories"),icon:Icons.add_circle_outline,onPressed:_addedToday?null:()=>addToToday(total)),const SizedBox(height:20),
      Text(s.isArabic?'الكميات':'Scaled Quantities',style:Theme.of(context).textTheme.titleLarge),...ingredients.map((i)=>ListTile(title:Text(s.isArabic?(i['name_ar']??i['name_en']):(i['name_en']??'')),trailing:Text('${i['quantity_g']} g'))),
    ])));
  }
  Widget _metric(String n,String v)=>Card(child:Padding(padding:const EdgeInsets.all(12),child:Column(children:[Text(n),Text(v,style:const TextStyle(fontWeight:FontWeight.bold))])));
}
