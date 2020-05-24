%% see also /var/lib/myfrdcsa/codebases/minor/nl-to-cycl/process.pl

% Support for reading file as a list.
%% :- ensure_loaded('/var/lib/myfrdcsa/codebases/minor/agent-attempts/7/parser/readFile.pl').
%% :- ensure_loaded('/var/lib/myfrdcsa/codebases/minor/flp-pddl/prolog-pddl-parser/prolog-pddl-3-0-parser-20140825/readFileI.pl').

view(Item) :-
	write_term(Item,[quoted(true)]),nl,!.

flpFlag(neg(debug)).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Ingredient to Foods                           %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

parseIngredientToFoods(F, O):-
	parseIngredientToFoods(F, O, _).
parseIngredientToFoods(File, Output, R) :-
	read_file(File, List),
	nl,view([list,List]),
	parseIngredientsToFoodsText(Output, List, R),!.

parseIngredientsToFoodsText(IngredientsToFoods) --> oneOrMore(ingredients_to_foods,IngredientsToFoods).
%% parseIngredientsToFoodsText(IngredientsToFoods) --> oneOrMore(token,IngredientsToFoods).

isolate(A,B) :-
	(   length(A,1) ->
	    (	[B] = A ) ;
	    (	B = A)).

ingredients_to_foods(Entry) --> getNextListItem(TmpSubject),[','],oneOrMore(getNextListItem,Properties),
	{
	 viewIf('fuck you'),
	 isolate(TmpSubject,Subject),
	 viewIf('fuck you some more'),
	 First = [isa('$VAR'('Ingredient'),Subject)],
	 viewIf('keep fucking you'),
	 %% check_ingredient(Subject),
	 viewIf('continue to keep fucking you'),
	 findall(hasProperty('$VAR'('Ingredient'),Property),
	 	 (
	 	  member(TmpProperty,Properties),
	 	  isolate(TmpProperty,Property)
	 	 ),
	 	 Rest),
	 viewIf('fuck your whole family'),
	 append([First,Rest],Assertions),
	 viewIf('die scum'),
	 Entry = and(Assertions)
	},!.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Food Data to Foods                           %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

parseFooddataToFoods(F, O):-
	parseFooddataToFoods(F, O, _).
parseFooddataToFoods(File, Output, R) :-
	read_file(File, List),
	view([list,List]),
	parseFoodDataToFoodsText(Output, List, R),
	view([output,Output]),!.
parseFoodDataToFoodsText(FooddataToFoods) --> oneOrMore(ingredients_to_foods,FooddataToFoods),!.
parseFoodDataToFoodsText(IngredientsToFoods) --> oneOrMore(token,IngredientsToFoods).

%% parseFoodDataToFoodsText(FooddataToFoods) --> oneOrMore(getNextListItem,FooddataToFoods).



%% parseFoodDataToFoodsText(FooddataToFoods) --> dcg_food_category(FoodCategory),getNextListItem(TmpFooddataToFoods),
%% 	{
%% 	 FooddataToFoods = and(foodCategory(FoodCategory),TmpFooddataToFoods)
%% 	}.

%% dcg_food_category(FoodCategory) --> getNextListItem(FoodCategory),
%% 	{
%% 	 getFoodCategory(FoodCategory)
%% 	}.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% branded_food - ingredients                   %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

parse_branded_food__ingredients(F, O):-
	parse_branded_food__ingredients(F, O, _).
parse_branded_food__ingredients(File, Output, R) :-
	read_file(File, List),
	nl,view([list,List]),
	parse_branded_food__ingredients_text(Output, List, R).

parse_branded_food__ingredients_text(A) --> oneOrMore(branded_food__ingredients,A).

branded_food__ingredients(Entry) --> oneOrMore(getNextListItem,Entries),
	{
	 Entry = [entries(Entries)]
	}.

%% ingredient_list_ingredient(Ingredient) --> (oneOrMore(token,Tokens) ; (oneOrMore(token,Tokens),['('],oneOrMore(token,Parenthetical),[')'])),
%% 	{
%% 	 append([Tokens,Parenthetical],Ingredient),
%% 	 not(member(',',Tokens)),
%% 	 not(member('.',Tokens)),
%% 	 not(member(',',Parenthetical)),
%% 	 not(member('.',Parenthetical))
	 
%% 	}.




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% helpers                                      %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

getNextListItem(Entry) --> oneOrMore(token,Entry),([','];['.'];['-'];[]),
	{
	 viewIf('fuck your whole family 2'),
	 not(member(',',Entry)),
	 viewIf('fuck your whole family 3'),
	 not(member('.',Entry)),
	 viewIf('fuck your whole family 4'),
	 not(member('-',Entry)),
	 viewIf('fuck your whole family 5')
	}.

listItem(Token) --> grabber(Token,token),
	{
	 not(
	     Token = ',' ;
	     Token = '.' ;
	     Token = '-'
	    )
	}.

%% capitalize(WordLC, WordUC) :-
%% 	atom_chars(WordLC, [FirstChLow|LWordLC]),
%% 	atom_chars(FirstLow, [FirstChLow]),
%% 	upcase_atom(FirstLow, FirstUpp),
%% 	atom_chars(FirstUpp, [FirstChUpp]),
%% 	atom_chars(WordUC, [FirstChUpp|LWordLC]),!.

%% 				% Defining operator ?. It is a syntax sugar for marking variables: ?x
%% :-op(300, fy, ?).

%% %% :- prolog_consult('/var/lib/myfrdcsa/codebases/minor/universal-parser/languages/dcg/inputs.pl').

%% stripVars(List,ListNoVars) :-
%% 	findall(Element,(member(Element,List),nonvar(Element)),ListNoVars).

%% nth(A,B,C) :-
%% 	nth1(A,B,C).

%% %% grab(TokenizedGloss,Class,Symbol) :-
%% %% 	stripVars(TokenizedGloss,TokenizedGlossNoVars),
%% %% 	englishGlossHasTokenizedEnglishGloss2(Gloss,TokenizedGlossNoVars),
%% %% 	hasEnglishGloss2(Symbol,Gloss),
%% %% 	isa(Symbol,Class).
%% %% %% FIXME: do this correctly, instead of this hack.  but if we use the
%% %% %% hack in the meantime, handle case and camelcase correctly
%% %% grab([Item|_],Class,Symbol) :-
%% %% 	isa(Item,Class),
%% %% 	Symbol = Item.

%% locationPhrase(Location)     --> ['in','the'],location(Location).
%% location(Location)           --> glossIsa(Location,location).

%% glossIsaH(Glosses,Class)     --> oneOrMore(name,Glosses),{glossIsa(Glosses,Class)}.

%% split_atom(Atom,Separator,Padding,Result) :-
%% 	split_string(Atom,Separator,Padding,StringResult),
%% 	findall(Item,(member(String,StringResult),atom_string(Item,String)),Result).

%% englishGlossHasTokenizedEnglishGloss1(Gloss,TokenizedGloss) :-
%% 	split_atom(Gloss,' ','',TokenizedGloss).
%% englishGlossHasTokenizedEnglishGloss2(Gloss,TokenizedGloss) :-
%% 	atomic_list_concat(TokenizedGloss,' ',Gloss).

%% %% check whether this
%% tokenizedGlossIsa1(TokenizedGloss,Class) :-
%% 	englishGlossHasTokenizedEnglishGloss2(Gloss,TokenizedGloss),
%% 	hasEnglishGloss(Item,Gloss),
%% 	isa(Item,Class).

%% tokenizedGlossIsa2(TokenizedGloss, Class) :-
%% 	isa(Item, Class),
%% 	hasEnglishGlosses(Item, Glosses),
%% 	member(Gloss, Glosses),
%% 	englishGlossHasTokenizedEnglishGloss1(Gloss, TokenizedGloss).
	
%% glossIsaA(Glosses,Class)     --> {glossIsa(Gloss,Class)}.

%% glossIsa(Gloss,Class) :-
%% 	isa(Item,Class),
%% 	hasEnglishGlosses(Item,Glosses),
%% 	member(Gloss,Glosses).



%% token(T)                     --> name(T).

%% toDoListCommand(Command)         --> ['('],toDoListFunctionSymbol(F),zeroOrMore(toDoListArgument,Args),[')'],{Command =.. [F|Args]}.

%% toDoListAssertionStatement([A,C]) --> ['#','<','AS',':'],formula(A),[':'],cycMt(C),['>'].

%% formula(F)                   --> ['('],cycPredicate(P),zeroOrMore(argument,Args),[')'],{F =.. [P|Args]}.
%% formula(F)                   --> ['('],zeroOrMore(argument,Args),[')'],{F =.. ['_emptyPredicate'|Args]}.
%% %% formula(V)                 --> ['('],variable(V),[')'].

%% cycPredicate(P)              --> cycConstant(P).

%% toDoListArgument(A)              --> toDoListConstant(A).
%% toDoListArgument(A)              --> argument(A).

%% toDoListFunctionSymbol(A)        --> name(A).
%% toDoListConstant(A)              --> name(A).

%% argument(A)                  --> cycConstant(A).
%% argument(A)                  --> variable(A).
%% argument(A)                  --> formula(A).
%% argument(A)                  --> number(A).
%% argument(A)                  --> string(A).

%% string(A)                    --> ['"'],
%% 	                         oneOrMore(anything,A), ['"'].
%% anything(A)                  --> [A]. %% , {not(A = '(' ; A = ')')}.

%% cycConstant(A)               --> cyc_constant_with_sigil(A).
%% cycConstant(A)               --> cyc_constant_without_sigil(A).

%% cyc_constant_with_sigil(A)       --> name(Name), {atom_concat('#$',A,Name)}.
%% cyc_constant_without_sigil(A)    --> name(A).

%% variable('$VAR'(V))          --> ['?','?'], name(N), {capitalize(N,V)}.
%% variable('$VAR'(V))          --> ['?'], name(N), {capitalize(N,V)}.

%% cycMt(Mt)                     --> cycConstant(Mt).

%% % BNF description include operator <term>+ to mark zero or more replacements.
%% % This DCG extension to overcome this. 
%% oneOrMore(W, [R|Rs], A, C) :- F =.. [W, R, A, B], F, (
%% 					oneOrMore(W, Rs, B, C) ;
%% 					(Rs = [] , C = B) 
%% 				).
%% % BNF operator <term>*
%% zeroOrMore(W, R)		--> oneOrMore(W, R).
%% zeroOrMore(_, [])		--> [].

%% openText(Text)                  --> oneOrMore(token,Text).

%% %% way incorrect:
%% %% zeroOrOne(W, [R|Rs], A, C) :- F =.. [W, R, A, B], F.
%% %% zeroOrOne(_, [])		--> [].

%% % Name is everything that is not number, bracket or question mark.
%% % Those rules are not necessary, but rapidly speed up parsing process.
%% name(N)				--> [N], {integer(N), !, fail}.
%% name(N)				--> [N], {N=')', !, fail}.
%% name(N)				--> [N], {N='(', !, fail}.
%% %% name(N)				--> [N], {N=']', !, fail}.
%% %% name(N)				--> [N], {N='[', !, fail}.
%% name(N)				--> [N], {N='?', !, fail}.
%% name(N)				--> [N].


%% number(N)			--> [N], {integer(N)}.
%% %% number(N)			--> mfloat(N).
%% %% mfloat(F)                       --> [N1,'.',N2], {number(N1), number(N2), atomic_list_concat([N1,'.',N2],'',Tmp),atom_number(Tmp,F)}.



%% %%% NEW LOGIC

%% grabber(Symbol,Class)                 --> ([A] ; [A,B] ; [A,B,C] ; [A,B,C,D] ; [A,B,C,D,E] ; [A,B,C,D,E,F]),{grab([A,B,C,D,E,F],Class,Symbol)}.

%% at                              --> ([] ; ['a']).
%% adt                             --> ([] ; ['a'] ; ['the']).
%% dt                              --> ([] ; ['the']).

%% dollarAmount(N)                 --> [D], {atom_concat('$',S,D),atom_number(S,N)}.

%% %%%%%%%%%%%%%%%%%%%
%% %% TESTS

%% %% dialogInterfaceQuery(Entry)  --> [Object],{glossIsa(Object,object)}.
%% %% dialogInterfaceQuery(Entry)  --> [A,B],{tokenizedGlossIsa([A,B],object)}.




%% %% hasEnglishGlossesData(andrewDougherty,['Andrew','Andrew','andy','andrew','Andrew Dougherty','andrew dougherty','Andy Dougherty','andy dougherty','and I','And I','and drew','And Drew','And drew']).

%% %% isa(vanillaPudding,food).
%% %% isa(cottageCheese,food).
