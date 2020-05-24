:- dynamic allSpecs/2.

wnAllGenls(W,S1) :-
	findall(X, wordrel(thyp,W,X), L1),
	out2set(L1,W,R,S1).

wnGenlsP(W,Y) :-
	wnAllGenls(W,S1),
	member(Y,S1).

wnSpecsP(W,Y) :-
	wnAllSpecs(W,S1),
	member(Y,S1).

wnAllSpecs(W,S2) :-
	findall(Y, wordrel(thyp,Y,W), L2),
	out2set(L2,W,Ri,S2).

wnCacheAllSpecs(W) :-
	(   allSpecs(W,_) -> 
	    true ;
	    (	
		wnAllSpecs(W,Specs),
		assert(allSpecs(W,Specs))
	    )
	).
