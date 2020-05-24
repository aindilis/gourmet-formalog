:- use_module(library(sgml)).

run :-
	load_xml_file('mm.xml.cleaned.txt',Dom),
	write_term(Dom,[quoted(true)]).