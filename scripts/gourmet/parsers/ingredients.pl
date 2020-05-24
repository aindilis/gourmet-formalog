convertIngredientToFoods(Text,Foods) :-
	Filename = '/tmp/gourmet_ingredients.txt',
	write_data_to_file(Text,Filename),
	%% view([filename,Filename,parse,Parse]),
	parseIngredientToFoods(Filename,Foods),!.

inputTextIngredients('Baguette, French, sliced - 3/4-inch thick, - sliced diagonally').
inputTextIngredients('Shrimp, fresh, shelled, - deveined').
inputTextIngredients('Crabmeat, fresh').
inputTextIngredients('Ginger, minced').
inputTextIngredients('Scallion, minced, white - and light green parts - only').
inputTextIngredients('Lard, fresh, minced').
inputTextIngredients('Salt, kosher').
inputTextIngredients('Wine, Chinese, rice OR').
inputTextIngredients('Sherry, dry').
inputTextIngredients('Water').
inputTextIngredients('Cornstarch').
inputTextIngredients('Waterchestnuts, fresh, - diced').
inputTextIngredients('Egg white, stiffly beaten').

%% hasEnglishGlossesData(baguette,['Baguette']).
%% hasEnglishGlossesData(shrimp,['Shrimp']).
%% hasEnglishGlossesData(crabmeat,['Crabmeat']).
%% hasEnglishGlossesData(ginger,['Ginger']).
%% hasEnglishGlossesData(scallion,['Scallion']).
%% hasEnglishGlossesData(lard,['Lard']).
%% hasEnglishGlossesData(salt,['Salt']).
%% hasEnglishGlossesData(wine,['Wine']).
%% hasEnglishGlossesData(sherry,['Sherry']).
%% hasEnglishGlossesData(watter,['Watter']).
%% hasEnglishGlossesData(cornstarch,['Cornstarch']).
%% hasEnglishGlossesData(waterchestnuts,['Waterchestnuts']).
%% hasEnglishGlossesData(eggwhite,['Eggwhite']).

%% are([baguette,shrimp,crabmeat,ginger,scallion,lard,salt,wine,sherry,watter,cornstarch,waterchestnuts,eggwhite],food).

%% [list,['Baguette',',','French',',',sliced,-,'3/4-inch',thick,',',-,sliced,diagonally]]
%% [list,['Shrimp',',',fresh,',',shelled,',',-,deveined]]
%% [list,['Crabmeat',',',fresh]]
%% [list,['Ginger',',',minced]]
%% [list,['Scallion',',',minced,',',white,-,and,light,green,parts,-,only]]
%% [list,['Lard',',',fresh,',',minced]]
%% [list,['Salt',',',kosher]]
%% [list,['Wine',',','Chinese',',',rice,'OR']]
%% [list,['Sherry',',',dry]]
%% [list,['Water']]
%% [list,['Cornstarch']]
%% [list,['Waterchestnuts',',',fresh,',',-,diced]]
%% [list,['Egg',white,',',stiffly,beaten]]

hasTestCases([   'Baguette, French, sliced - 3/4-inch thick, - sliced diagonally',
		 'Shrimp, fresh, shelled, - deveined',
		 'Crabmeat, fresh',
		 'Ginger, minced',
		 'Scallion, minced, white - and light green parts - only',
		 'Lard, fresh, minced',
		 'Salt, kosher',
		 'Wine, Chinese, rice OR',
		 'Sherry, dry',
		 'Water',
		 'Cornstarch',
		 'Waterchestnuts, fresh, - diced',
		 'Egg white, stiffly beaten',
		 '8" flour tortillas; Cut In Half',
		 '8 Oz Cream Cheese',
		 'Frozen baby shrimp',
		 'Garlic powder',
		 'Cucumbers; peeled',
		 'Salad oil',
		 'Minced fresh ginger',
		 'Clove garlic; minced',
		 '(2.5oz / 70.87 grams) minced green onions (including tops)',
		 '(453.6 grams) medium-sized shrimp; shelled and deveined salt',
		 'Artichokes (3/4 Lb. Each.)',
		 'Lemon Wedges',
		 'Water',
		 'Unpeeled Medium Shrimp',
		 '(8 Oz.)Carton Plain Yogurt',
		 'Minced Fresh Dillweed',
		 'Dijon Mustard',
		 'Grated Lemon Rind',
		 'Pepper',
		 'Minced Fresh Dillweed',
		 '(Optinal)',
		 'Onions,chopped',
		 'Green bell pepper,chopped',
		 'Celery,chopped',
		 'Eggplant,peeled,diced(1lb)',
		 'Garlic cloves,crushed',
		 'Butter or margarine',
		 'Shrimp,shelled/deveined',
		 'Rice,cooked',
		 'Worcestershire sauce',
		 'Salt',
		 'Black pepper',
		 'Thyme',
		 'Mayonnaise',
		 'Bread crumbs,buttered,soft',
		 'Shrimp, medium, cleaned,cook',
		 'Feta cheese,',
		 'Scallions, sliced',
		 'Tomato sauce',
		 'Olive oil',
		 'Lemon juice, fresh',
		 'Parsley, chopped',
		 'Basil, fresh, chopped',
		 'Dill, fresh, chopped',
		 'Salt',
		 'Pepper',
		 'Fettuccine, or flat noodle**',
		 'Shrimp, medium, cleaned,',
		 'Cooked',
		 'Feta cheese, *',
		 'Scallions, sliced',
		 'Tomato sauce',
		 'Olive oil',
		 'Lemon juice, fresh',
		 'Parsley, chopped',
		 'Basil, fresh, chopped',
		 'Dill, fresh, chopped',
		 'Salt',
		 'Pepper',
		 'Fettuccine, or flat',
		 'Noodle **',
		 'Medium shrimp; cooked, shelled and deveined',
		 'Feta cheese; rinsed, patted dry and crumbled',
		 '-(up to)',
		 'Green onions; chopped',
		 'Fresh minced oregano -or-',
		 'Dried oregano',
		 '-(up to)',
		 'Tomatoes; peeled, cored, seeded and chopped',
		 '-(up to)',
		 'Black olives; sliced or chopped',
		 'Salt to taste (be careful as Feta cheese is salty)',
		 'Freshly ground pepper to taste',
		 '(10-oz) pasta',
		 'Uncooked med. Shrimp',
		 'Can PB Pizza dough (or hmade',
		 'Olive oil',
		 'Crumbled Feta Cheese',
		 'Rosemary crushed',
		 'Cornmeal',
		 'Shredded Mozzeralla cheese',
		 'Minced Garlic cloves',
		 'Slice green onions',
		 'Can sliced ripe olives',
		 'Fat-free chicken broth;',
		 'Olive oil;',
		 'Scallions; thinly sliced'
	     ]).

testParseIngredients :-
	once(findnsols(100, Text, (rec(_,List,_),member(ing(_,_,Text),List),Text \= ''), Foods)),
	convertFooddataToFoodsForList(Foods).

testParseIngredients2 :-
	hasTestCases(Foods),
	convertFooddataToFoodsForList(Foods).

convertIngredientsToFoodsForList(Foods) :-
	member(Text,Foods),	
	inputTextIngredients(Text),
	print_term(Text,[]),
	convertIngredientToFoods(Text,Foods),
	print_term(Foods,[quoted(true)]),
	fail.
testParseIngredients :-
	true.
