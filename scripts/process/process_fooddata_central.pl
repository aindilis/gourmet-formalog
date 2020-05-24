:- use_module(library(tsv_read_and_assert)).

:- module(user).

:- read_in_and_assert_to_name('USDA-Food-DB/branded_food.csv','branded').

:- findall(tsv_read_and_assert:branded(A,B,C,D,E,F,G,H,I,J,K),tsv_read_and_assert:branded(A,B,C,D,E,F,G,H,I,J,K),X),
	print_term(X,[quote(true)]).
