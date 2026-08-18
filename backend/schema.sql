-- PostgreSQL logical schema for BUILD 13.
CREATE TABLE ingredients (
  id SERIAL PRIMARY KEY,
  name_en VARCHAR(120) NOT NULL UNIQUE,
  name_ar VARCHAR(120) NOT NULL DEFAULT '',
  name_ro VARCHAR(120) NOT NULL DEFAULT '',
  category VARCHAR(80) NOT NULL DEFAULT '',
  calories_per_100g DOUBLE PRECISION NOT NULL DEFAULT 0,
  protein_per_100g DOUBLE PRECISION NOT NULL DEFAULT 0,
  carbs_per_100g DOUBLE PRECISION NOT NULL DEFAULT 0,
  fat_per_100g DOUBLE PRECISION NOT NULL DEFAULT 0,
  fiber_per_100g DOUBLE PRECISION NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE recipes (
  id SERIAL PRIMARY KEY,
  name_en VARCHAR(180) NOT NULL,
  name_ar VARCHAR(180) NOT NULL DEFAULT '',
  name_ro VARCHAR(180) NOT NULL DEFAULT '',
  cuisine VARCHAR(80) NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  instructions TEXT NOT NULL DEFAULT '',
  servings INTEGER NOT NULL DEFAULT 4,
  prep_minutes INTEGER NOT NULL DEFAULT 0,
  cook_minutes INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE recipe_ingredients (
  id SERIAL PRIMARY KEY,
  recipe_id INTEGER NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
  ingredient_id INTEGER NOT NULL REFERENCES ingredients(id) ON DELETE RESTRICT,
  quantity_g DOUBLE PRECISION NOT NULL CHECK (quantity_g > 0)
);

CREATE INDEX idx_recipe_name_en ON recipes(name_en);
CREATE INDEX idx_recipe_cuisine ON recipes(cuisine);
CREATE INDEX idx_ingredient_name_en ON ingredients(name_en);
