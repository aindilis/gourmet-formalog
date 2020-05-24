:- set_prolog_stack(global, limit(40 000 000 000)).
:- set_prolog_stack(trail,  limit(8 000 000 000)).
:- set_prolog_stack(local,  limit(8 000 000 000)).

%% /var/lib/myfrdcsa/codebases/minor/gourmet-formalog/scripts/recipes/mm.pl

gourmetFormalogFlag(neg(test)).

loadGourmet :-
	(   gourmetFormalogFlag(test) -> true ;
	    (	
		ensure_loaded('/var/lib/myfrdcsa/codebases/minor/gourmet-formalog/scripts/fooddata/fooddata'),
		load_fooddata,
		ensure_loaded('/var/lib/myfrdcsa/codebases/minor/gourmet-formalog/scripts/recipes/mm')
	    )),

	ensure_loaded('/var/lib/myfrdcsa/codebases/minor/free-life-planner/lib/multifile-and-dynamic-directives.pl'),
	ensure_loaded('/var/lib/myfrdcsa/codebases/minor/cyclone/frdcsa/sys/flp/autoload/kbs.pl'),
	ensure_loaded('/var/lib/myfrdcsa/codebases/minor/free-life-planner/lib/util/util.pl'),
	ensure_loaded('/var/lib/myfrdcsa/codebases/minor/dialog-interface/frdcsa/sys/flp/dialog_interface.pl'),

	ensure_loaded('/var/lib/myfrdcsa/codebases/minor/flp-pddl/prolog-pddl-parser/prolog-pddl-3-0-parser-20140825/readFileI.pl'),

	ensure_loaded('/var/lib/myfrdcsa/codebases/minor/gourmet-formalog/scripts/gourmet/parsers/dcgs/dcgs.pl'),

	ensure_loaded('/var/lib/myfrdcsa/codebases/minor/gourmet-formalog/scripts/gourmet/parsers/ingredients.pl'),
	ensure_loaded('/var/lib/myfrdcsa/codebases/minor/gourmet-formalog/scripts/gourmet/parsers/foods.pl'),
	ensure_loaded('/var/lib/myfrdcsa/codebases/minor/gourmet-formalog/scripts/gourmet/parsers/branded_food__ingredients.pl'),

	ensure_loaded('/var/lib/myfrdcsa/codebases/minor/gourmet-formalog/scripts/receipts/inventory_import.pl'),
	

	(   gourmetFormalogFlag(test) -> true ;
	    (	
		ensure_loaded('/var/lib/myfrdcsa/codebases/minor/gourmet-formalog/scripts/wordnet/prolog/wnprolog.pl'),
		ensure_loaded('/var/lib/myfrdcsa/codebases/minor/gourmet-formalog/scripts/wordnet/gourmet_wordnet.pl'),
		ensure_loaded('/var/lib/myfrdcsa/codebases/minor/gourmet-formalog/scripts/receipts/inventory_import_data.pl'),
		wnCacheAllSpecs(food)
	    )),

	true.

rec(Title,Ingredients,Directions) :-
	recipe(Title,Ing,Dir),
	Ing =.. ['_prolog_list'|Ingredients],
	Dir =.. ['_prolog_list'|Directions].

searchRecipesByTitle(Search,Recipes) :-
	findall(rec(A,B,C),(rec(A,B,C),like(A,Search)),Recipes).

searchRecipeTitlesByDescription(Search,Titles) :-
	findall(A,(rec(A,B,C),like_case_insensitive(A,Search)),TmpTitles),
	sort(TmpTitles,Titles).


getShoppingListForRecipes(Recipes,ShoppingList) :-
	member(rec(Title,Ings,Dirs),Recipes),
	view([title,Title]),
	member(ing(_,_,Ing),Ings),
	view([ing,Ing]),
	tryToMatchIngredientToFoodData(Ing,Matches),
	print_term([ing(Ing),matches(Matches)],[quoted(true)]),nl,
	fail.
getShoppingListForRecipes(Recipes,ShoppingList).

tryToMatchIngredientToFoodData(Ing,Matches) :-
	food_nutrition(Ing,Matches).

test :-
	searchRecipesByTitle('Freezer',Recipes),
	getShoppingListForRecipes(Recipes,List).

%% atTimeQuery([2020-01-06,19:18:12],hasInventory(X,Y,Z)).

countHowManyFoodsHaveInputFoods :-
	findall(FDC_ID,food(FDC_ID,_,_,_,_),FDC_IDs1),
	length(FDC_IDs1,L1),
	findall(FDC_ID,(food(FDC_ID,_,_,_,_),input_food(_,FDC_ID,_,_,_,_,_,_,_,_,_,_,_)),FDC_IDs2),
	length(FDC_IDs2,L2),
	findall(FDC_ID,(food(FDC_ID,_,_,_,_),input_food(_,_,FDC_ID,_,_,_,_,_,_,_,_,_,_)),FDC_IDs3),
	length(FDC_IDs3,L3),
	view([l1,L1,l2,L2,l3,L3]).

printInputFoods :-
	findall([FDC_ID,DESC],(food(FDC_ID,_,DESC,_,_),input_food(_,_,FDC_ID,_,_,_,_,_,_,_,_,_,_)),Results),
	print_term(Results,[quoted(true)]).

printFoods :-
	findall([FDC_ID,DESC],(food(FDC_ID,_,_,_,_),input_food(_,FDC_ID,_,_,_,_,DESC,_,_,_,_,_,_)),Results),
	print_term(Results,[quoted(true)]).

getFoodDescFromFDCID(FDC_ID,DESC) :-
	food(FDC_ID,_,DESC,_,_).

getBarcodeFromFDCID(FDC_ID,Barcode) :-
	branded_food(FDC_ID,_,Barcode,_,_,_,_,_,_,_,_).

foodNutritionFromFDCID(FDC_ID) :-
	getFoodDescFromFDCID(FDC_ID,DESC),
	food_nutrition(DESC,_).

lookup_branded_food_by_barcode(Barcode,FDC_ID,DESC) :-
	branded_food(FDC_ID,_,Barcode,_,_,_,_,_,_,_,_),
	like(Barcode,SearchBarcode),
	getFoodDescFromFDCID(FDC_ID,DESC).

lookup_branded_food_by_barcode_atom(BarcodeAtom,FDC_ID,DESC) :-
	atom_number(BarcodeAtom,Barcode),
	branded_food(FDC_ID,_,Barcode,_,_,_,_,_,_,_,_),
	like(Barcode,SearchBarcode),
	getFoodDescFromFDCID(FDC_ID,DESC),
	!.

search_branded_food_by_barcode_search(SearchBarcode,Barcode,FDC_ID,DESC) :-
	branded_food(FDC_ID,_,Barcode,_,_,_,_,_,_,_,_),
	like(Barcode,SearchBarcode),
	getFoodDescFromFDCID(FDC_ID,DESC).

search_branded_food_by_description_search(SearchDescription,FDC_ID,DESC,Barcode) :-
	food(FDC_ID,_,Description,_,_),
	like_case_insensitive(Description,SearchDescription),
	getFoodDescFromFDCID(FDC_ID,DESC),
	getBarcodeFromFDCID(FDC_ID,Barcode).


get_all_for_barcode_atom(BarcodeAtom,[FDC_ID,DESC,NutritionSearchResults,Ingredients]) :-
	get_nutrition_for_barcode_atom(BarcodeAtom,[FDC_ID,DESC,NutritionSearchResults]),
	get_ingredients_for_barcode_atom(BarcodeAtom,[FDC_ID,DESC,Ingredients]).

get_nutrition_for_barcode_atom(BarcodeAtom,[FDC_ID,DESC,NutritionSearchResults]) :-
	lookup_branded_food_by_barcode_atom(BarcodeAtom,FDC_ID,DESC),
	food_nutrition_by_fdc_id(FDC_ID,NutritionSearchResults).

get_ingredients_for_barcode_atom(BarcodeAtom,[FDC_ID,DESC,Ingredients]) :-
	lookup_branded_food_by_barcode_atom(BarcodeAtom,FDC_ID,DESC),
	food_ingredients_by_fdc_id(FDC_ID,Ingredients).

has_high_fructose_corn_syrup(BarcodeAtom) :-
	has_ingredient(BarcodeAtom,'HIGH FRUCTOSE CORN SYRUP').

has_ingredient(BarcodeAtom,Allergen) :-
	get_ingredients_for_barcode_atom(BarcodeAtom,[FDC_ID,DESC,Ingredients]),
	%% FIXME: parse the ingredients first, then check
	like_case_insensitive(Ingredients,Allergen).

check_ingredient(Ingredient) :-
	allSpecs(food,Specs),
	downcase_atom(Ingredient,DCIngredient),
	member(DCIngredient,Specs).

meredithTest :-
	findnsols(1,rec(X,Y,Z),rec(X,Y,Z),Results).

search_food_data_central(BarcodeAtom,[invFn,invFn(idFn(gourmetFDC,FDC_ID),barcodeFn(BarcodeAtom)),invCat,Branded_Food_Category,flpNameFn,ProductIDDescriptive,brandOwner,Brand_Owner,description,DESC,nutrition,NutritionSearchResults,ingredients,Ingredients]) :-
	view([barcodeAtom,BarcodeAtom]),
	lookup_branded_food_by_barcode_atom(BarcodeAtom,FDC_ID,DESC),
	branded_food(FDC_ID,Brand_Owner,Gtin_Upc,Ingredients,Serving_Size,Serving_Size_Unit,Household_Serving_Fulltext,Branded_Food_Category,Data_Source,Modified_Date,Available_Date),
        prologify(DESC,ItemNamePrologified),
        prologifyRest(Brand_Owner,BrandNamePrologifiedRest),
        atomic_list_concat([ItemNamePrologified,BrandNamePrologifiedRest],'_',ProductIDDescriptive),
	get_all_for_barcode_atom(BarcodeAtom,[_FDC_ID,_DESC,NutritionSearchResults,Ingredients]).

%% get_nutrition_for_barcode_atom('041250025979',X).

fdcNutritionToNutritionix('Total lipid (fat)',grams,total_fat,grams).
%% fdcNutritionToNutritionix('Total fat (NLEA)',grams,total_fat,grams).
fdcNutritionToNutritionix('Fatty acids, total saturated',grams,saturated_fat,grams).
fdcNutritionToNutritionix('Cholesterol',milligrams,cholesterol,milligrams).
fdcNutritionToNutritionix('Sodium',milligrams,sodium,milligrams).
fdcNutritionToNutritionix('Carbohydrate, by difference',grams,total_carbohydrate,grams).
%% fdcNutritionToNutritionix('Carbohydrate, by summation',grams,total_carbohydrate,grams).
fdcNutritionToNutritionix('Fiber, total dietary',grams,dietary_fiber,grams).
fdcNutritionToNutritionix('Energy',kilocalories,calories,calories).
%% serving_weight_grams

conversionFactor(Item,Item,1.0).
conversionFactor(kilocalories,calories,1000.0).

map_nutrition_info_for_barcode_atom(BarcodeAtom,MappedNutritionInfo) :-
	get_nutrition_for_barcode_atom(BarcodeAtom,[FDC_ID,DESC,FDCNutritionInfo]),
	view([FDC_ID,DESC,FDCNutritionInfo]),
	findall(nf(NutritionixNutrientName,idFn(gourmetFDC,FDC_ID),Amount),
		(
		 member(result(FDCNutrientID,FDCNutrientName,FDCAmount,_FDCNutrientUnitName),FDCNutritionInfo),
		 view([FDCNutrientID,FDCNutrientName,FDCAmount,_FDCNutrientUnitName]),
		 fdcNutritionToNutritionix(FDCNutrientName,FDCNutrientUnitName,NutritionixNutrientName,NutritionixUnitName),
		 conversionFactor(FDCNutrientUnitName,NutritionixUnitName,ConversionFactor),
		 (   nonvar(ConversionFactor) ->
		     (
		      view([conversionFactor,ConversionFactor]),
		      NutritionixAmount is FDCAmount * ConversionFactor,
		      Amount =.. [NutritionixUnitName,NutritionixAmount]
		     ) ;
		     Amount = unknown(_)
		 )
		),
		MappedNutritionInfo).
		
%% prolog_list('619542','CAVATAPPI',
%% 	    _prolog_list(result('1003','Protein','12.5','G'),
%% 			 result('1004','Total lipid (fat)','1.7o9','G'),
%% 			 result('1005','Carbohydrate, by difference','73.21','G'),
%% 			 result('1008','Energy','357','KCAL'),
%% 			 result('2000','Sugars, total including NLEA','3.57','G'),
%% 			 result('1079','Fiber, total dietary','3.6','G'),
%% 			 result('1087','Calcium, Ca','0','MG'),
%% 			 result('1089','Iron, Fe','3.21','MG'),
%% 			 result('1093','Sodium, Na','0','MG'),
%% 			 result('1104','Vitamin A, IU','0','IU'),
%% 			 result('1162','Vitamin C, total ascorbic acid','0','MG'),
%% 			 result('1253','Cholesterol','0','MG'),
%% 			 result('1257','Fatty acids, total trans','0','G'),
%% 			 result('1258','Fatty acids, total saturated','0','G')
%% 			)).

%% barcode(idFn(nutritionix,'51c37b3c97c3e6d27282496f'),'041196915051').
%% nf(serving_weight_grams,idFn(nutritionix,'51c37b3c97c3e6d27282496f'),grams('239')).
%% nf(protein,idFn(nutritionix,'51c37b3c97c3e6d27282496f'),grams('6')).
%% updated_at(idFn(nutritionix,'51c37b3c97c3e6d27282496f'),unknown2('2017-01-24T07:13:14.000Z')).
%% nf(ingredient_statement,idFn(nutritionix,'51c37b3c97c3e6d27282496f'),unknown1('Chicken Broth, Cooked Meatballs (Pork, Beef, Water, Eggs, Textured Soy Protein [Soy Protein Concentrate, Caramel Color], Romano Cheese [Made from Sheep_SINGLEQUOTE_s Milk, Cultures, Salt, Enzymes], Bread Crumbs [Bleached Wheat Flour, Dextr\
%% ose, Salt, Yeast], Corn Syrup, Onion, Soy Protein Concentrate, Salt, Spice, Sodium Phosphate, Garlic Powder, Dried Parsley, Onion Powder, Natural Flavor), Carrots, Tubetti Pasta (Semolina Wheat, Egg Whites), Spinach. Contains Less than 2% of: Onions, Modified Food Starch, Salt, Chicken Fat, Carrot Puree, Corn Protein\
%%  (Hydrolyzed), Potassium Chloride, Onion Powder, Sugar, Yeast Extract, Spice, Garlic Powder, Soybean Oil, Natural Flavor, Beta Carotene (Color).')).
%% nf(serving_size_unit,idFn(nutritionix,'51c37b3c97c3e6d27282496f'),unit(cup)).
%% nf(vitamin_c_dv,idFn(nutritionix,'51c37b3c97c3e6d27282496f'),percent('0')).
%% nf(calories_from_fat,idFn(nutritionix,'51c37b3c97c3e6d27282496f'),calories('35')).
%% nf(calories,idFn(nutritionix,'51c37b3c97c3e6d27282496f'),calories('120')).
%% nf(cholesterol,idFn(nutritionix,'51c37b3c97c3e6d27282496f'),milligrams('10')).
%% nf(servings_per_container,idFn(nutritionix,'51c37b3c97c3e6d27282496f'),servings('2')).
%% nf(dietary_fiber,idFn(nutritionix,'51c37b3c97c3e6d27282496f'),grams('1')).
%% nf(monounsaturated_fat,idFn(nutritionix,'51c37b3c97c3e6d27282496f'),grams('1.5')).
%% item_description(idFn(nutritionix,'51c37b3c97c3e6d27282496f'),unknown2('Italian-Style Wedding')).
%% nf(vitamin_a_dv,idFn(nutritionix,'51c37b3c97c3e6d27282496f'),percent('25')).
%% nf(iron_dv,idFn(nutritionix,'51c37b3c97c3e6d27282496f'),percent('4')).
%% nf(calcium_dv,idFn(nutritionix,'51c37b3c97c3e6d27282496f'),percent('2')).
%% nf(polyunsaturated_fat,idFn(nutritionix,'51c37b3c97c3e6d27282496f'),grams('0')).
%% item_id(idFn(nutritionix,'51c37b3c97c3e6d27282496f'),unknown2('51c37b3c97c3e6d27282496f')).
%% nf(serving_size_qty,idFn(nutritionix,'51c37b3c97c3e6d27282496f'),quantity('1')).
%% nf(sodium,idFn(nutritionix,'51c37b3c97c3e6d27282496f'),milligrams('690')).
%% nf(total_carbohydrate,idFn(nutritionix,'51c37b3c97c3e6d27282496f'),grams('15')).
%% nf(sugars,idFn(nutritionix,'51c37b3c97c3e6d27282496f'),grams('2')).
%% item_name(idFn(nutritionix,'51c37b3c97c3e6d27282496f'),unknown2('Italian-Style Wedding Soup')).
%% brand_name(idFn(nutritionix,'51c37b3c97c3e6d27282496f'),unknown2('Progresso')).
%% nf(total_fat,idFn(nutritionix,'51c37b3c97c3e6d27282496f'),grams('4')).
%% brand_id(idFn(nutritionix,'51c37b3c97c3e6d27282496f'),unknown2('51db37b4176fe9790a898803')).
%% nf(trans_fatty_acid,idFn(nutritionix,'51c37b3c97c3e6d27282496f'),grams('0')).
%% nf(saturated_fat,idFn(nutritionix,'51c37b3c97c3e6d27282496f'),grams('1.5')).

