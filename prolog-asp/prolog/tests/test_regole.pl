:- begin_tests(regole).
:- use_module('../regole.pl').

% Test dei cas in cui applicabile deve avere successo

test(applicabile) :-
    applicabile(
        [tile(4, 3, 2), tile(2, 1, 1), tile(3, 3, 0), tile(4, 1, 3), tile(4, 4, 4), tile(2, 4, 5), tile(1, 3, 6), tile(1, 4, 7), tile(1, 2, 8), tile(2, 2, 9), tile(3, 4, 10), tile(3, 2, 11), tile(3, 1, 12), tile(1, 1, 13), tile(4, 2, 14), tile(2, 3, 15)],
        tile(3, 4, 10), up).

test(applicabile) :-
    applicabile(
        [tile(4, 3, 2), tile(2, 1, 1), tile(3, 3, 0), tile(4, 1, 3), tile(4, 4, 4), tile(2, 4, 5), tile(1, 3, 6), tile(1, 4, 7), tile(1, 2, 8), tile(2, 2, 9), tile(3, 4, 10), tile(3, 2, 11), tile(3, 1, 12), tile(1, 1, 13), tile(4, 2, 14), tile(2, 3, 15)],
        tile(2, 3, 15), right).

test(applicabile) :-
    applicabile(
    [tile(4, 3, 2), tile(2, 1, 1), tile(3, 3, 0), tile(4, 1, 3), tile(4, 4, 4), tile(2, 4, 5), tile(1, 3, 6), tile(1, 4, 7), tile(1, 2, 8), tile(2, 2, 9), tile(3, 4, 10), tile(3, 2, 11), tile(3, 1, 12), tile(1, 1, 13), tile(4, 2, 14), tile(2, 3, 15)],
        tile(4, 3, 2), left).

test(applicabile) :-
    applicabile(
        [tile(4, 3, 2), tile(2, 1, 1), tile(3, 3, 0), tile(4, 1, 3), tile(4, 4, 4), tile(2, 4, 5), tile(1, 3, 6), tile(1, 4, 7), tile(1, 2, 8), tile(2, 2, 9), tile(3, 4, 10), tile(3, 2, 11), tile(3, 1, 12), tile(1, 1, 13), tile(4, 2, 14), tile(2, 3, 15)],
        tile(3, 2, 11), down).

% Test dei casi in cui applicabile deve fallire

test(applicabile, [fail]) :-
    applicabile(
        [tile(4, 3, 2), tile(2, 1, 1), tile(3, 3, 0), tile(4, 1, 3), tile(4, 4, 4), tile(2, 4, 5), tile(1, 3, 6), tile(1, 4, 7), tile(1, 2, 8), tile(2, 2, 9), tile(3, 4, 10), tile(3, 2, 11), tile(3, 1, 12), tile(1, 1, 13), tile(4, 2, 14), tile(2, 3, 15)],
        tile(1, 1, 13), left).

test(applicabile, [fail]) :-
    applicabile(
        [tile(4, 3, 2), tile(2, 1, 1), tile(3, 3, 0), tile(4, 1, 3), tile(4, 4, 4), tile(2, 4, 5), tile(1, 3, 6), tile(1, 4, 7), tile(1, 2, 8), tile(2, 2, 9), tile(3, 4, 10), tile(3, 2, 11), tile(3, 1, 12), tile(1, 1, 13), tile(4, 2, 14), tile(2, 3, 15)],
        tile(1, 1, 13   ), up).

test(applicabile, [fail]) :-
    applicabile(
        [tile(4, 3, 2), tile(2, 1, 1), tile(3, 3, 0), tile(4, 1, 3), tile(4, 4, 4), tile(2, 4, 5), tile(1, 3, 6), tile(1, 4, 7), tile(1, 2, 8), tile(2, 2, 9), tile(3, 4, 10), tile(3, 2, 11), tile(3, 1, 12), tile(1, 1, 13), tile(4, 2, 14), tile(2, 3, 15)],
        tile(4, 0, 0), right).

test(applicabile, [fail]) :-
    applicabile(
        [tile(4, 3, 2), tile(2, 1, 1), tile(3, 3, 0), tile(4, 1, 3), tile(4, 4, 4), tile(2, 4, 5), tile(1, 3, 6), tile(1, 4, 7), tile(1, 2, 8), tile(2, 2, 9), tile(3, 4, 10), tile(3, 2, 11), tile(3, 1, 12), tile(1, 1, 13), tile(4, 2, 14), tile(2, 3, 15)],
        tile(1, 4, 4), down).

% Testa i casi in cui trasforma deve funzionare

test(trasforma) :-
    trasforma(
        [tile(4, 3, 2), tile(2, 1, 1), tile(3, 3, 0), tile(4, 1, 3), tile(4, 4, 4), tile(2, 4, 5), tile(1, 3, 6), tile(1, 4, 7), tile(1, 2, 8), tile(2, 2, 9), tile(3, 4, 10), tile(3, 2, 11), tile(3, 1, 12), tile(1, 1, 13), tile(4, 2, 14), tile(2, 3, 15)],
        right, tile(2, 3, 15), tile(3, 3, 15)).

test(trasforma) :-
    trasforma(
        [tile(4, 3, 2), tile(2, 1, 1), tile(3, 3, 0), tile(4, 1, 3), tile(4, 4, 4), tile(2, 4, 5), tile(1, 3, 6), tile(1, 4, 7), tile(1, 2, 8), tile(2, 2, 9), tile(3, 4, 10), tile(3, 2, 11), tile(3, 1, 12), tile(1, 1, 13), tile(4, 2, 14), tile(2, 3, 15)],
        down, tile(3, 2, 11), tile(3, 3, 11)).

test(trasforma) :-
    trasforma(
        [tile(4, 3, 2), tile(2, 1, 1), tile(3, 3, 0), tile(4, 1, 3), tile(4, 4, 4), tile(2, 4, 5), tile(1, 3, 6), tile(1, 4, 7), tile(1, 2, 8), tile(2, 2, 9), tile(3, 4, 10), tile(3, 2, 11), tile(3, 1, 12), tile(1, 1, 13), tile(4, 2, 14), tile(2, 3, 15)],
        left, tile(4, 3, 2), tile(3, 3, 2)).

test(trasforma) :-
    trasforma(
        [tile(4, 3, 2), tile(2, 1, 1), tile(3, 3, 0), tile(4, 1, 3), tile(4, 4, 4), tile(2, 4, 5), tile(1, 3, 6), tile(1, 4, 7), tile(1, 2, 8), tile(2, 2, 9), tile(3, 4, 10), tile(3, 2, 11), tile(3, 1, 12), tile(1, 1, 13), tile(4, 2, 14), tile(2, 3, 15)],
        up, tile(3, 4, 10), tile(3, 3, 10)).

% Testa i casi in cui trasforma deve fallire

test(trasforma, [fail]) :-
    trasforma(
        [tile(4, 3, 2), tile(2, 1, 1), tile(3, 3, 0), tile(4, 1, 3), tile(4, 4, 4), tile(2, 4, 5), tile(1, 3, 6), tile(1, 4, 7), tile(1, 2, 8), tile(2, 2, 9), tile(3, 4, 10), tile(3, 2, 11), tile(3, 1, 12), tile(1, 1, 13), tile(4, 2, 14), tile(2, 3, 15)],
        left, tile(1, 3, 3), _).

test(trasforma, [fail]) :-
    trasforma(
        [tile(4, 3, 2), tile(2, 1, 1), tile(3, 3, 0), tile(4, 1, 3), tile(4, 4, 4), tile(2, 4, 5), tile(1, 3, 6), tile(1, 4, 7), tile(1, 2, 8), tile(2, 2, 9), tile(3, 4, 10), tile(3, 2, 11), tile(3, 1, 12), tile(1, 1, 13), tile(4, 2, 14), tile(2, 3, 15)],
        down, tile(3, 4, 3), _).

test(trasforma, [fail]) :-
    trasforma(
        [tile(4, 3, 2), tile(2, 1, 1), tile(3, 3, 0), tile(4, 1, 3), tile(4, 4, 4), tile(2, 4, 5), tile(1, 3, 6), tile(1, 4, 7), tile(1, 2, 8), tile(2, 2, 9), tile(3, 4, 10), tile(3, 2, 11), tile(3, 1, 12), tile(1, 1, 13), tile(4, 2, 14), tile(2, 3, 15)],
        right, tile(4, 3, 3), _).

test(trasforma, [fail]) :-
    trasforma(
        [tile(4, 3, 2), tile(2, 1, 1), tile(3, 3, 0), tile(4, 1, 3), tile(4, 4, 4), tile(2, 4, 5), tile(1, 3, 6), tile(1, 4, 7), tile(1, 2, 8), tile(2, 2, 9), tile(3, 4, 10), tile(3, 2, 11), tile(3, 1, 12), tile(1, 1, 13), tile(4, 2, 14), tile(2, 3, 15)],
        up, tile(3, 1, 3), _).

% testa i casi in cui adjacent deve avere successo
% tile(1, 2, 8), tile(3, 2, 11), tile(2, 1, 1), tile(2, 3, 15)

test(adjacent) :-
    adjacent(
        [tile(4, 3, 2), tile(2, 1, 1), tile(3, 3, 0), tile(4, 1, 3), tile(4, 4, 4), tile(2, 4, 5), tile(1, 3, 6), tile(1, 4, 7), tile(1, 2, 8), tile(2, 2, 9), tile(3, 4, 10), tile(3, 2, 11), tile(3, 1, 12), tile(1, 1, 13), tile(4, 2, 14), tile(2, 3, 15)],
        tile(2, 2, 9), tile(2, 3, 15), down).

test(adjacent) :-
    adjacent(
        [tile(4, 3, 2), tile(2, 1, 1), tile(3, 3, 0), tile(4, 1, 3), tile(4, 4, 4), tile(2, 4, 5), tile(1, 3, 6), tile(1, 4, 7), tile(1, 2, 8), tile(2, 2, 9), tile(3, 4, 10), tile(3, 2, 11), tile(3, 1, 12), tile(1, 1, 13), tile(4, 2, 14), tile(2, 3, 15)],
        tile(2, 2, 9), tile(2, 1, 1), up).

test(adjacent) :-
    adjacent(
        [tile(4, 3, 2), tile(2, 1, 1), tile(3, 3, 0), tile(4, 1, 3), tile(4, 4, 4), tile(2, 4, 5), tile(1, 3, 6), tile(1, 4, 7), tile(1, 2, 8), tile(2, 2, 9), tile(3, 4, 10), tile(3, 2, 11), tile(3, 1, 12), tile(1, 1, 13), tile(4, 2, 14), tile(2, 3, 15)],
        tile(2, 2, 9), tile(1, 2, 8), left).

test(adjacent) :-
    adjacent(
        [tile(4, 3, 2), tile(2, 1, 1), tile(3, 3, 0), tile(4, 1, 3), tile(4, 4, 4), tile(2, 4, 5), tile(1, 3, 6), tile(1, 4, 7), tile(1, 2, 8), tile(2, 2, 9), tile(3, 4, 10), tile(3, 2, 11), tile(3, 1, 12), tile(1, 1, 13), tile(4, 2, 14), tile(2, 3, 15)],
        tile(2, 2, 9), tile(3, 2, 11), right).

% testa i casi in cui adjacent deve fallire

test(adjacent, [fail]) :-
    adjacent(
        [tile(4, 3, 2), tile(2, 1, 1), tile(3, 3, 0), tile(4, 1, 3), tile(4, 4, 4), tile(2, 4, 5), tile(1, 3, 6), tile(1, 4, 7), tile(1, 2, 8), tile(2, 2, 9), tile(3, 4, 10), tile(3, 2, 11), tile(3, 1, 12), tile(1, 1, 13), tile(4, 2, 14), tile(2, 3, 15)],
        tile(2, 2, 1), tile(4, 4, 2), _).

test(adjacent, [fail]) :-
    adjacent(
        [tile(4, 3, 2), tile(2, 1, 1), tile(3, 3, 0), tile(4, 1, 3), tile(4, 4, 4), tile(2, 4, 5), tile(1, 3, 6), tile(1, 4, 7), tile(1, 2, 8), tile(2, 2, 9), tile(3, 4, 10), tile(3, 2, 11), tile(3, 1, 12), tile(1, 1, 13), tile(4, 2, 14), tile(2, 3, 15)],
        tile(2, 2, 1), tile(2, 2, 2), _).

% testa i casi in cui actions deve avere successo

test(actions) :-
    actions(
        [tile(4, 3, 2), tile(2, 1, 1), tile(3, 3, 0), tile(4, 1, 3), tile(4, 4, 4), tile(2, 4, 5), tile(1, 3, 6), tile(1, 4, 7), tile(1, 2, 8), tile(2, 2, 9), tile(3, 4, 10), tile(3, 2, 11), tile(3, 1, 12), tile(1, 1, 13), tile(4, 2, 14), tile(2, 3, 15)],
        [action(tile(4, 3, 2), left), action(tile(2, 3, 15), right), action(tile(3, 4, 10), up), action(tile(3, 2, 11), down)]
    ).


:- end_tests(regole).
