:- begin_tests(utils).
:- use_module('../utils.pl').

% Test in cui replace deve avere successo

test(replace) :-
    utils:replace(1, 2, [1,2,3], [2,2,3]).

test(replace) :-
    utils:replace(tile(4,3,0), tile(1,2,3), [tile(1,2,3), tile(4,5,6), tile(4,3,0)], [tile(1,2,3), tile(4,5,6), tile(1,2,3)]).

test(replace) :-
    utils:replace(tile(4,3,0), tile(1,2,3), [tile(1,2,3), tile(4,5,6), tile(4,3,0), 1, 5], [tile(1,2,3), tile(4,5,6), tile(1,2,3), 1, 5]).

test(replace) :-
    utils:replace(tile(4,3,0), tile(1,2,3), [tile(1,2,3), tile(4,5,6), 1, 5, tile(4,3,0)], [tile(1,2,3), tile(4,5,6), 1, 5, tile(1,2,3)]).

test(replace) :-
    utils:replace(tile(4,3,0), tile(1,2,3), [tile(4,3,0), tile(4,5,6), 1, 5, tile(4,3,0)], [tile(1,2,3), tile(4,5,6), 1, 5, tile(1,2,3)]).

test(replace) :-
    utils:replace(1, 5, [2,2,3], [2,2,3]).

test(replace) :-
    utils:replace([], [1,2,3], [[], 2, 3], [[1,2,3], 2, 3]).

% Test in cui swap deve avere successo

test(swap) :-
    utils:swap(1, 2, [1,2,3], [2,1,3]).

test(swap) :-
    utils:swap(tile(4,3,0), tile(1,2,3), [tile(1,2,3), tile(4,5,6), tile(4,3,0)], [tile(4,3,0), tile(4,5,6), tile(1,2,3)]).

test(swap) :-
    utils:swap(tile(4,3,0), tile(1,2,3), [tile(1,2,3), tile(4,5,6), tile(4,3,0), 1, 5], [tile(4,3,0), tile(4,5,6), tile(1,2,3), 1, 5]).

test(swap) :-
    utils:swap(tile(4,3,0), tile(1,2,3), [tile(1,2,3), tile(4,5,6), 1, 5, tile(4,3,0)], [tile(4,3,0), tile(4,5,6), 1, 5, tile(1,2,3)]).

test(swap) :-
    utils:swap(tile(4,3,0), tile(1,2,3), [tile(4,3,0), tile(4,5,6), 1, 5, tile(4,3,0)], [tile(4,3,0), tile(4,5,6), 1, 5, tile(1,2,3)]).

test(swap) :-
    utils:swap(1, 5, [2,2,3], [2,2,3]).

test(swap) :-
    utils:swap([], [1,2,3], [[], 2, 3], [[1,2,3], 2, 3]).

% Test in cui tile_swap deve avere successo

test(tile_swap) :-
    utils:tile_swap(tile(1,1,1), tile(1,2,2),
        [tile(1,1,1),tile(1,2,2),tile(1,3,3),tile(1,4,4),tile(2,1,5),tile(2,2,6),tile(2,3,7),tile(2,4,8),tile(3,1,10),tile(3,2,11),tile(3,3,12),tile(3,4,15),tile(4,1,0),tile(4,2,9),tile(4,3,13),tile(4,4,14)],
        [tile(1,1,2),tile(1,2,1),tile(1,3,3),tile(1,4,4),tile(2,1,5),tile(2,2,6),tile(2,3,7),tile(2,4,8),tile(3,1,10),tile(3,2,11),tile(3,3,12),tile(3,4,15),tile(4,1,0),tile(4,2,9),tile(4,3,13),tile(4,4,14)]
    ).

test(tile_swap) :-
    utils:tile_swap(tile(2,4,8), tile(4,1,0),
        [tile(1,1,1),tile(1,2,2),tile(1,3,3),tile(1,4,4),tile(2,1,5),tile(2,2,6),tile(2,3,7),tile(2,4,8),tile(3,1,10),tile(3,2,11),tile(3,3,12),tile(3,4,15),tile(4,1,0),tile(4,2,9),tile(4,3,13),tile(4,4,14)],
        [tile(1,1,1),tile(1,2,2),tile(1,3,3),tile(1,4,4),tile(2,1,5),tile(2,2,6),tile(2,3,7),tile(2,4,0),tile(3,1,10),tile(3,2,11),tile(3,3,12),tile(3,4,15),tile(4,1,8),tile(4,2,9),tile(4,3,13),tile(4,4,14)]
    ).

:- end_tests(utils).