:- begin_tests(ricerca).
:- use_module('../ricerca.pl').

test(choose) :-
    ricerca:choose(
        [tile(1,1,1),tile(1,2,2),tile(1,3,3),tile(1,4,4),tile(2,1,5),tile(2,2,6),tile(2,3,7),tile(2,4,8),tile(3,1,10),tile(3,2,11),tile(3,3,12),tile(3,4,15),tile(4,1,0),tile(4,2,9),tile(4,3,13),tile(4,4,14)],
        [],
        [action(tile(3,1,10),right), action(tile(4,2,9), up)]
    ).

% Test in cui dfs dovrebbe avere successo
test(dfs) :-
    ricerca:dfs(
        [tile(1,1,1),tile(2,1,2),tile(3,1,3),tile(4, 1,4),tile(1,2,5),tile(2,2,6),tile(3,2,7),tile(4,2,8),tile(1,3,10),tile(2,3,11),tile(3,3,12),tile(4,3,15),tile(1,4,0),tile(2,4,9),tile(3,4,13),tile(4,4,14)],
        [], _
    ).

% Test di correct/2

test(correct) :-
    ricerca:correct(0, tile(4,4,0)).

test(correct) :-
    ricerca:correct(1, tile(1,1,1)).

test(correct) :-
    ricerca:correct(2, tile(2,1,2)).

test(correct) :-
    ricerca:correct(3, tile(3,1,3)).

test(correct) :-
    ricerca:correct(4, tile(4,1,4)).

test(correct) :-
    ricerca:correct(5, tile(1,2,5)).

test(correct) :-
    ricerca:correct(6, tile(2,2,6)).

test(correct) :-
    ricerca:correct(7, tile(3,2,7)).

test(correct) :-
    ricerca:correct(8, tile(4,2,8)).

test(correct) :-
    ricerca:correct(9, tile(1,3,9)).

test(correct) :-
    ricerca:correct(10, tile(2,3,10)).

test(correct) :-
    ricerca:correct(11, tile(3,3,11)).

test(correct) :-
    ricerca:correct(12, tile(4,3,12)).

test(correct) :-
    ricerca:correct(13, tile(1,4,13)).

test(correct) :-
    ricerca:correct(14, tile(2,4,14)).

test(correct) :-
    ricerca:correct(15, tile(3,4,15)).

test(correct) :-
    ricerca:correct(-1, -1).

test(correct) :-
    ricerca:correct(rabbit, rabbit).

:- end_tests(ricerca).