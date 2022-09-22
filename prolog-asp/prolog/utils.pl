# -*- mode: prolog -*-

:- module(utils, [replace/4, swap/4, incorrects/2, correct/2, check_config/1]).

% replace(+Item, +NewItem, +List, -Result)
% sostituisce +Item con +NewItem in +List.
replace(_, _, [], []).
replace(Item, NewItem, [Item|Tail], [NewItem|Tail2]) :-
    replace(Item, NewItem, Tail, Tail2), !.
replace(Item, NewItem, [Different|Tail], [Different|Tail2]) :-
    Different \= Item, replace(Item, NewItem, Tail, Tail2), !.

swap(_, _, [], []).
swap(Item, NewItem, [Item|Tail], [NewItem|Tail2]) :-
    swap(Item, NewItem, Tail, Tail2).
swap(Item, NewItem, [NewItem|Tail], [Item|Tail2]) :-
    swap(Item, NewItem, Tail, Tail2).
swap(Item, NewItem, [Different|Tail], [Different|Tail2]) :-
    Different \== Item, swap(Item, NewItem, Tail, Tail2), !.
swap(Item, NewItem, [Different|Tail], [Different|Tail2]) :-
    Different \== NewItem, swap(Item, NewItem, Tail, Tail2), !.

% incorrects/2 - incorrects(+Config, -Tiles)
% Trova le tiles fuori posto, data una configurazione
incorrects([], []).
incorrects([tile(X,Y,Z)|ConfigT], [tile(X, Y, Z)|Tiles]) :-
    correct(Z, tile(I,_,Z)),
    I \== X,
    incorrects(ConfigT, Tiles), !.
incorrects([tile(X,Y,Z)|ConfigT], [tile(X, Y, Z)|Tiles]) :-
    correct(Z, tile(_,J,Z)),
    J \== Y,
    incorrects(ConfigT, Tiles), !.
incorrects([tile(X,Y,Z)|ConfigT], Tiles) :-
    correct(Z, tile(X, Y, Z)),
    incorrects(ConfigT, Tiles).


% correct/2 - correct(+N, -Correct)
% Restituisce le coordinate corrette dato il numero di una tile
correct(N, Correct) :-
    correct_aux(
        N,
        [tile(1,1,1),tile(2,1,2),tile(3,1,3),tile(4,1,4),tile(1,2,5),tile(2,2,6),tile(3,2,7),tile(4,2,8),tile(1,3,9),tile(2,3,10),tile(3,3,11),tile(4,3,12),tile(1,4,13),tile(2,4,14),tile(3,4,15),tile(4,4,0)],
        Correct
    ).

% correct_aux/3 - correct_aux(+N, +Config, -Correct)
correct_aux(N, [], N) :- !.
correct_aux(N, [tile(X, Y, N)|_], tile(X, Y, N)) :- !.
correct_aux(N, [tile(_, _, Z)|Tiles], Correct) :-
    N \== Z,
    correct_aux(N, Tiles, Correct), !.
    

% check_config/1 - check_config(Tiles)
/***
 * Controlla che Tiles siano nella posizione corretta
 * (Che abbiano un corrispondente correct(tile) in dominio.pl)
 */
check_config([]).
check_config([ConfigH|ConfigT]) :-
    member(ConfigH, [tile(1,1,1),tile(2,1,2),tile(3,1,3),tile(4,1,4),tile(1,2,5),tile(2,2,6),tile(3,2,7),tile(4,2,8),tile(1,3,9),tile(2,3,10),tile(3,3,11),tile(4,3,12),tile(1,4,13),tile(2,4,14),tile(3,4,15),tile(4,4,0)]),
    check_config(ConfigT), !.

head([H|_], H).
tail([_|Tail], Tail).
