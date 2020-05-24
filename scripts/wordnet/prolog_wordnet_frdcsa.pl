qcompilerels:-
  semrels(L),
  member(R,L),
  swritef(F,'wn_%w.pl',[R]),
  writef('QCompiling %w relation: %w\n',[R,F]),
  qcompile(F),
  false.
qcompilerels:-
  nl.
