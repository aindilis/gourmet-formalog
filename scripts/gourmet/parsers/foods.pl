%% "id","fdc_id","fdc_id_of_input_food","seq_num","amount","sr_code","sr_description","unit","portion_code","portion_description","gram_weight","retention_code","survey_flag"

getFood(G) :-
	input_food(_A,_B,_C,_D,_E,_F,G,_H,_I,_J,_K,_L,_M).

getFoods :-
	findall(G,getFood(G),SRDescriptions),
	print_term(SRDescriptions,[]).

convertFooddataToFoods(Text,Fooddata) :-
	Filename = '/tmp/gourmet_foods.txt',
	write_data_to_file(Text,Filename),
	view([filename,Filename,parse,Parse]),
	parseFooddataToFoods(Filename,Fooddata).

getFoodCategory(C) :-
	food_category(_A,_B,C).

testParseFooddata :-
	once(findnsols(10, Text, (getFood(Text),Text \= ''), Foods)),
	convertFooddataToFoodsForList(Foods).

convertFooddataToFoodsForList(InputFoods) :-
	member(Text,InputFoods),
	nl,nl,writeln(Text),
	convertFooddataToFoods(Text,Foods),
	print_term(Foods,[quoted(true)]),
	fail.
convertFooddataToFoodsForList(_Foods) :-
	true.
