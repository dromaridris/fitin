from sqlalchemy import select
from app.db import SessionLocal
from app.models import Ingredient, IngredientAlias, Recipe, RecipeIngredient

def seed():
    db=SessionLocal()
    try:
        if db.scalar(select(Ingredient).limit(1)): return
        data=[
          ('chicken','Chicken','دجاج','Murghi','meat',165,31,0,3.6,0),
          ('potato','Potato','بطاطا','Aloo','vegetable',77,2,17,.1,2.2),
          ('onion','Onion','بصل','Pyaaz','vegetable',40,1.1,9.3,.1,1.7),
          ('tomato','Tomato','بندورة','Tamatar','vegetable',18,.9,3.9,.2,1.2),
          ('lentils_brown','Brown Lentils','عدس بني','Masoor Dal','legume',352,24.6,63.4,1.1,10.7),
          ('bulgur','Bulgur','برغل','Bulgur','grain',342,12.3,75.9,1.3,18.3),
          ('rice','Rice, dry','أرز','Chawal','grain',365,7.1,80,0.7,1.3),
          ('yogurt','Plain Yogurt','لبن','Dahi','dairy',61,3.5,4.7,3.3,0),
          ('chickpeas','Chickpeas, cooked','حمص','Chana','legume',164,8.9,27.4,2.6,7.6),
          ('olive_oil','Olive Oil','زيت زيتون','Zait Zaytoon','oil',884,0,0,100,0),
          ('egg','Egg','بيض','Anda','protein',143,12.6,0.7,9.5,0),
          ('garlic','Garlic','ثوم','Lehsan','vegetable',149,6.4,33.1,.5,2.1),
          ('lemon','Lemon Juice','عصير ليمون','Nimbu','fruit',22,.4,6.9,.2,.3),
          ('spinach','Spinach','سبانخ','Palak','vegetable',23,2.9,3.6,.4,2.2),
        ]
        ingredients=[]
        for row in data:
            i=Ingredient(canonical_key=row[0],name_en=row[1],name_ar=row[2],name_ro=row[3],category=row[4],calories_per_100g=row[5],protein_per_100g=row[6],carbs_per_100g=row[7],fat_per_100g=row[8],fiber_per_100g=row[9])
            ingredients.append(i); db.add(i)
        db.flush()
        aliases={
          0:['chicken','murghi','murgi','دجاج'],1:['potato','potatoes','aloo','بطاطا','بطاطس'],2:['onion','pyaaz','pyaz','بصل'],3:['tomato','tamatar','بندورة','طماطم'],4:['lentil','dal','daal','عدس'],6:['rice','chawal','رز','أرز'],7:['yogurt','dahi','لبن'],8:['chickpeas','chana','حمص'],9:['olive oil','zait','زيت زيتون'],10:['egg','anda','بيض'],11:['garlic','lehsan','ثوم'],13:['spinach','palak','سبانخ']}
        for idx,names in aliases.items():
            for n in names: db.add(IngredientAlias(ingredient_id=ingredients[idx].id,language='multi',alias=n))
        recipes=[
          ('chicken-potato-curry','Chicken Potato Curry','كاري الدجاج والبطاطا','Chicken Aloo Curry','Pakistani',4,15,35),
          ('mujaddara','Mujaddara','مجدرة','Mujaddara','Syrian',4,10,45),
          ('hummus','Classic Hummus','حمص بطحينة','Hummus','Arabic',4,10,5),
          ('chicken-rice-bowl','Chicken Rice Bowl','وعاء الدجاج والأرز','Chicken Rice Bowl','International',4,15,25),
          ('spinach-yogurt','Spinach Yogurt','سبانخ باللبن','Palak Dahi','Syrian',4,10,15),
          ('egg-potato-skillet','Egg Potato Skillet','بيض مع البطاطا','Aloo Anda','Pakistani',2,10,20),
          ('chickpea-salad','Chickpea Tomato Salad','سلطة الحمص والبندورة','Chana Salad','Arabic',4,15,0),
          ('lemon-chicken','Lemon Garlic Chicken','دجاج بالليمون والثوم','Lemon Chicken','International',4,15,30),
        ]
        rs=[]
        for x in recipes:
            r=Recipe(slug=x[0],name_en=x[1],name_ar=x[2],name_ro=x[3],cuisine=x[4],servings=x[5],prep_minutes=x[6],cook_minutes=x[7]); rs.append(r); db.add(r)
        db.flush()
        by={i.canonical_key:i.id for i in ingredients}
        links={
          0:[('chicken',600),('potato',500),('onion',150),('tomato',250),('olive_oil',20)],
          1:[('lentils_brown',200),('bulgur',200),('onion',200),('olive_oil',15)],
          2:[('chickpeas',500),('yogurt',100),('lemon',30),('garlic',10),('olive_oil',20)],
          3:[('chicken',500),('rice',300),('tomato',150),('onion',100),('olive_oil',15)],
          4:[('spinach',500),('yogurt',300),('garlic',10),('olive_oil',10)],
          5:[('egg',100),('potato',300),('onion',80),('olive_oil',10)],
          6:[('chickpeas',400),('tomato',250),('onion',100),('lemon',30),('olive_oil',15)],
          7:[('chicken',600),('lemon',60),('garlic',20),('olive_oil',20)],
        }
        for ri,pairs in links.items():
            for key,q in pairs: db.add(RecipeIngredient(recipe_id=rs[ri].id,ingredient_id=by[key],quantity_g=q))
        db.commit()
    finally: db.close()

if __name__=='__main__': seed(); print('Seed complete')
