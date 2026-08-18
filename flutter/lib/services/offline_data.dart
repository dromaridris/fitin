class OfflineIngredient {
  final int id;
  final String key, nameEn, nameAr, nameRo;
  final double calories, protein, carbs, fat, fiber;
  const OfflineIngredient(this.id, this.key, this.nameEn, this.nameAr, this.nameRo,
      this.calories, this.protein, this.carbs, this.fat, this.fiber);
}

class OfflineRecipeIngredient {
  final int ingredientId;
  final double quantityG;
  const OfflineRecipeIngredient(this.ingredientId, this.quantityG);
}

class OfflineRecipe {
  final int id;
  final String nameEn, nameAr, nameRo, cuisine;
  final int servings, prepMinutes, cookMinutes;
  final List<OfflineRecipeIngredient> ingredients;
  const OfflineRecipe(this.id, this.nameEn, this.nameAr, this.nameRo, this.cuisine,
      this.servings, this.prepMinutes, this.cookMinutes, this.ingredients);
}

const offlineIngredients = <OfflineIngredient>[
  OfflineIngredient(1,'chicken','Chicken','دجاج','Murghi',165,31,0,3.6,0),
  OfflineIngredient(2,'potato','Potato','بطاطا','Aloo',77,2,17,.1,2.2),
  OfflineIngredient(3,'onion','Onion','بصل','Pyaaz',40,1.1,9.3,.1,1.7),
  OfflineIngredient(4,'tomato','Tomato','بندورة','Tamatar',18,.9,3.9,.2,1.2),
  OfflineIngredient(5,'lentils_brown','Brown Lentils','عدس بني','Masoor Dal',352,24.6,63.4,1.1,10.7),
  OfflineIngredient(6,'bulgur','Bulgur','برغل','Bulgur',342,12.3,75.9,1.3,18.3),
  OfflineIngredient(7,'rice','Rice, dry','أرز','Chawal',365,7.1,80,.7,1.3),
  OfflineIngredient(8,'yogurt','Plain Yogurt','لبن','Dahi',61,3.5,4.7,3.3,0),
  OfflineIngredient(9,'chickpeas','Chickpeas, cooked','حمص','Chana',164,8.9,27.4,2.6,7.6),
  OfflineIngredient(10,'olive_oil','Olive Oil','زيت زيتون','Zait Zaytoon',884,0,0,100,0),
  OfflineIngredient(11,'egg','Egg','بيض','Anda',143,12.6,.7,9.5,0),
  OfflineIngredient(12,'garlic','Garlic','ثوم','Lehsan',149,6.4,33.1,.5,2.1),
  OfflineIngredient(13,'lemon','Lemon Juice','عصير ليمون','Nimbu',22,.4,6.9,.2,.3),
  OfflineIngredient(14,'spinach','Spinach','سبانخ','Palak',23,2.9,3.6,.4,2.2),
];

const offlineRecipes = <OfflineRecipe>[
  OfflineRecipe(1,'Chicken Potato Curry','كاري الدجاج والبطاطا','Chicken Aloo Curry','Pakistani',4,15,35,[OfflineRecipeIngredient(1,600),OfflineRecipeIngredient(2,500),OfflineRecipeIngredient(3,150),OfflineRecipeIngredient(4,250),OfflineRecipeIngredient(10,20)]),
  OfflineRecipe(2,'Mujaddara','مجدرة','Mujaddara','Syrian',4,10,45,[OfflineRecipeIngredient(5,200),OfflineRecipeIngredient(6,200),OfflineRecipeIngredient(3,200),OfflineRecipeIngredient(10,15)]),
  OfflineRecipe(3,'Classic Hummus','حمص بطحينة','Hummus','Arabic',4,10,5,[OfflineRecipeIngredient(9,500),OfflineRecipeIngredient(8,100),OfflineRecipeIngredient(13,30),OfflineRecipeIngredient(12,10),OfflineRecipeIngredient(10,20)]),
  OfflineRecipe(4,'Chicken Rice Bowl','وعاء الدجاج والأرز','Chicken Rice Bowl','International',4,15,25,[OfflineRecipeIngredient(1,500),OfflineRecipeIngredient(7,300),OfflineRecipeIngredient(4,150),OfflineRecipeIngredient(3,100),OfflineRecipeIngredient(10,15)]),
  OfflineRecipe(5,'Spinach Yogurt','سبانخ باللبن','Palak Dahi','Syrian',4,10,15,[OfflineRecipeIngredient(14,500),OfflineRecipeIngredient(8,300),OfflineRecipeIngredient(12,10),OfflineRecipeIngredient(10,10)]),
  OfflineRecipe(6,'Egg Potato Skillet','بيض مع البطاطا','Aloo Anda','Pakistani',2,10,20,[OfflineRecipeIngredient(11,100),OfflineRecipeIngredient(2,300),OfflineRecipeIngredient(3,80),OfflineRecipeIngredient(10,10)]),
  OfflineRecipe(7,'Chickpea Tomato Salad','سلطة الحمص والبندورة','Chana Salad','Arabic',4,15,0,[OfflineRecipeIngredient(9,400),OfflineRecipeIngredient(4,250),OfflineRecipeIngredient(3,100),OfflineRecipeIngredient(13,30),OfflineRecipeIngredient(10,15)]),
  OfflineRecipe(8,'Lemon Garlic Chicken','دجاج بالليمون والثوم','Lemon Chicken','International',4,15,30,[OfflineRecipeIngredient(1,600),OfflineRecipeIngredient(13,60),OfflineRecipeIngredient(12,20),OfflineRecipeIngredient(10,20)]),
];

OfflineIngredient ingredientById(int id) => offlineIngredients.firstWhere((x) => x.id == id);

String normalizeOfflineIngredient(String value) {
  final v = value.trim().toLowerCase();
  const aliases = <String, String>{
    'chicken':'chicken','murghi':'chicken','murgi':'chicken','دجاج':'chicken',
    'potato':'potato','potatoes':'potato','aloo':'potato','بطاطا':'potato','بطاطس':'potato',
    'onion':'onion','pyaaz':'onion','pyaz':'onion','بصل':'onion',
    'tomato':'tomato','tomatoes':'tomato','tamatar':'tomato','بندورة':'tomato','طماطم':'tomato',
    'lentil':'lentils_brown','lentils':'lentils_brown','dal':'lentils_brown','daal':'lentils_brown','عدس':'lentils_brown','عدس بني':'lentils_brown',
    'bulgur':'bulgur','برغل':'bulgur',
    'rice':'rice','chawal':'rice','رز':'rice','أرز':'rice',
    'yogurt':'yogurt','dahi':'yogurt','لبن':'yogurt',
    'chickpeas':'chickpeas','chickpea':'chickpeas','chana':'chickpeas','حمص':'chickpeas',
    'olive oil':'olive_oil','زيت زيتون':'olive_oil','zait zaytoon':'olive_oil',
    'egg':'egg','eggs':'egg','anda':'egg','بيض':'egg',
    'garlic':'garlic','lehsan':'garlic','ثوم':'garlic',
    'lemon':'lemon','nimbu':'lemon','ليمون':'lemon','عصير ليمون':'lemon',
    'spinach':'spinach','palak':'spinach','سبانخ':'spinach',
  };
  return aliases[v] ?? v;
}
