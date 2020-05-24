run :-
	consult('mm.pl.cleaned.txt'),
	findall(Ingredients,recipe(_,Ingredients,_),AllIngredients),print_term(AllIngredients,[quoted(true)]).
	%% findall(Steps,recipe(head(_,_,directions(Steps))),AllSteps),print_term(AllSteps,[quoted(true)]).
        %% findall(Title,recipe(head(title(Title),_,_)),Titles),print_term(Titles,[quoted(true)]).

