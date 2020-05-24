convert_branded_food__ingredients(Text,Fooddata) :-
	Filename = '/tmp/gourmet_foods.txt',
	write_data_to_file(Text,Filename),
	%% view([filename,Filename,parse,Parse]),
	parse_branded_food__ingredients(Filename,Fooddata),!.

input_text_branded_food__ingredients('Meat Ingredients (Beef and Pork), Water, Tomato Puree (Water, Tomato Paste), Beef Broth, Whole Rolled Oats, Chili Pepper, Contains less than 2% of: Salt, Sugar, Spices, Garlic Powder, Soy Lecithin, Caramel Color, Sodium Phosphate. CONTAINS: SOY.').
input_text_branded_food__ingredients('Meat Ingredients (Beef and Pork), Water, Tomato Puree (Water, Tomato Paste), Rolled Oats, Chili Pepper, Contains less than 2% of: Textured Soy Flour, Salt, Sugar, Spices, Garlic Powder, Caramel Color, Soy Lecithin, Sodium Phosphate. CONTAINS: SOY.').
input_text_branded_food__ingredients('Instant Nonfat Dry Milk, Vitamins A and D3.').
input_text_branded_food__ingredients('Sugar, Corn Syrup, Cocoa (Processed with Alkali), Hydrogenated Coconut Oil, Nonfat Milk, Less Than 2% Of: Salt, Dipotassium Phosphate, Cocoa Powder, Mono- and Diglycerides, Natural Flavor. CONTAINS: MILK.').
input_text_branded_food__ingredients('Nonfat Milk, Sugar, Water, Modified Corn Starch, Hydrogenated Coconut Oil, Less than 2% of: Salt, Sodium Stearoyl Lactylate, Calcium Carbonate, Natural and Artificial Flavor, Color Added (Including Yellow 5, Yellow 6).CONTAINS: MILK').
input_text_branded_food__ingredients('Nonfat Milk, Sugar, Water, Modified Corn Starch, Hydrogenated Coconut Oil, Cocoa (Processed with Alkali), Less than 2% of: Salt, Sodium Stearoyl Lactylate, Calcium Carbonate, Color Added, Artificial Flavor.  CONTAINS: MILK').
input_text_branded_food__ingredients('Nonfat Milk, Sugar, Modified Corn Starch, Water, Hydrogenated Coconut Oil, Less than 2% of: Cocoa (Processed with Alkali), Salt, Color Added, Sodium Stearoyl Lactylate, Coffee Powder, Calcium Carbonate, Artificial Flavors.CONTAINS: MILK').
input_text_branded_food__ingredients('Nonfat Milk, Sugar, Water,\240\Modified Corn Starch, Hydrogenated Coconut Oil, Cocoa (Processed with Alkali), Less than 2% of: Salt, Sodium Stearoyl Lactylate, Color Added, Artificial Flavors. CONTAINS: MILK.').
input_text_branded_food__ingredients('Sugar, Modified Whey, Cocoa (Processed with Alkali), Corn Syrup, Less than 2% of: Hydrogenated Coconut Oil, Salt, Nonfat Dry Milk, Cellulose Gum, Sodium Aluminosilicate, Dipotassium Phosphate, Artificial Flavor, Mono- and Diglycerides.CONTAINS: MILK').
input_text_branded_food__ingredients('Nonfat Milk, Cocoa (Processed with Alkali), Calcium Carbonate, Modified Whey, Salt, Less Than 2% Of: Carrageenan, Acesulfame Potassium, Sucralose, Natural And Artificial Flavors, Milk, Disodium Phosphate, Caramel Color. Contains: MILK').

%% hasEnglishGlossesData(baguette,['Baguette']).

test_parse_branded_food__ingredients :-
	input_text_branded_food__ingredients(Text),
	convert_branded_food__ingredients(Text,Foods),
	print_term(Foods,[quoted(true)]),
	fail.
test_parse_branded_food__ingredients :-
	true.
