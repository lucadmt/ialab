# -*- mode: prolog -*-

:- module(heuristics, [f/3, h/2, g/2, tile_h/2]).
:- use_module('./utils.pl').

% tile_h(+Tile, -N)
tile_h(tile(X, Y, Z), 0) :-
    % Se la tile è in posizione corretta, la sua euristica è 0
    utils:correct(Z, tile(X, Y, Z)), !.

tile_h(tile(X, Y, Z), N) :-
    % Se la tile non è corretta, la sua h è la distanza di manhattan
    % dalla posizione corretta
    utils:correct(Z, tile(I, J, Z)),
    N is abs((J - Y)) + abs((I - X)).

% f/2 - f(+Config, -N)
h([tile(1,1,1),tile(2,1,2),tile(3,1,3),tile(4,1,4),tile(1,2,5),tile(2,2,6),tile(3,2,7),tile(4,2,8),tile(1,3,9),tile(2,3,10),tile(3,3,11),tile(4,3,12),tile(1,4,13),tile(2,4,14),tile(3,4,15),tile(4,4,0)], 0).
h(Config, N) :-
    % Recupera tutte le tile in posizione scorretta
    % N è la somma delle loro distanze di manhattan
    utils:incorrects(Config, Incorrects),
    h_aux(Incorrects, N).

h_aux([], 0).
h_aux([TileH|Tiles], Num) :-
    tile_h(TileH, M),
    h_aux(Tiles, N),
    Num is N + M.

hamming([tile(1,1,1),tile(2,1,2),tile(3,1,3),tile(4,1,4),tile(1,2,5),tile(2,2,6),tile(3,2,7),tile(4,2,8),tile(1,3,9),tile(2,3,10),tile(3,3,11),tile(4,3,12),tile(1,4,13),tile(2,4,14),tile(3,4,15),tile(4,4,0)], 0).
hamming(Config, N) :-
    utils:incorrects(Config, Incorrects),
    length(Incorrects, N).


g(ListaAzioni, N) :- 
    length(ListaAzioni, N), !.

f(Config, ListaAzioni, F) :-
    h(Config, H),
    g(ListaAzioni, G),
    F is H + G, !.
