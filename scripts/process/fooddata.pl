:- discontiguous schema/1.
:- multifile schema/1.

:- consult('/var/lib/myfrdcsa/codebases/minor/free-life-planner/lib/util/util.pl').

fooddata_dir('/var/lib/myfrdcsa/codebases/minor/gourmet-formalog/scripts/process/USDA-Food-DB/').

load_fooddata :-
	fooddata_dir(FooddataDir),
	directory_files(FooddataDir,Files),
	member(Filename,Files),
	concat_atom([_Tmp,'.qlf'],Filename),
	concat_atom([FooddataDir,Filename],AbsoluteFilename),
	consult(AbsoluteFilename),
	fail.
load_fooddata.

test2 :-
	findall(schema(X),schema(X),Z),print_term(Z,[]).


food_search(Search,Results) :-
	findall(food(A,B,C,D,E),(food(A,B,C,D,E),like_case_insensitive(C,Search)),Results),
	print_term(Results,[quoted(true)]),nl.

like(Entry,Search) :-
	sub_string(Entry, Before, _, After, Search).

like_case_insensitive(Entry,Search) :-
	downcase_atom(Entry,LCEntry),
	downcase_atom(Search,LCSearch),
	sub_string(LCEntry, Before, _, After, LCSearch).

food_nutrition(Food,NutritionSearchResults) :-
	food_search(Food,SearchResults),
	member(food(FDC_ID,_,FoodName,_,_),SearchResults),
	pr([FoodName,FDC_ID]),nl,
	food_nutrition_search(FDC_ID,NutritionSearchResults),
	print_term(NutritionSearchResults,[quoted(true)]),nl,nl.

food_nutrition_by_fdc_id(FDC_ID,NutritionSearchResults) :-
	food_nutrition_search(FDC_ID,NutritionSearchResults),
	print_term(NutritionSearchResults,[quoted(true)]),nl,nl.

food_nutrition_search(FDC_ID,NutritionSearchResults) :-
	findall(result(NutrientID,NutrientName,Amt,UnitName),
		(
		 food_nutrient(_,FDC_ID,NutrientID,Amt,_,_,_,_,_,_,_),
		 once(nutrient(NutrientID,NutrientName,UnitName,_,_))
		),
		NutritionSearchResults).

food_ingredients_by_fdc_id(FDC_ID,Ingredients) :-
	food_ingredient_search(FDC_ID,Ingredients),
	print_term(Ingredients,[quoted(true)]),nl,nl.

food_ingredient_search(FDC_ID,Ingredients) :-
	branded_food(FDC_ID,_,_,Ingredients,_,_,_,_,_,_,_).
