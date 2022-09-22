# -*- mode: prolog -*-

:- module(search, [choose/3, hchoose/3, prova/1, ida_star/3, check_config/1]).
:- use_module('./regole.pl').
:- use_module('./heuristics.pl').
:- use_module('./utils.pl').
:- dynamic(fmin/1).
:- dynamic(deepness/1).
:- dynamic(prev_fmin/1).

% Needed for debugging purposes, see: https://www.metalevel.at/prolog/debugging
:- op(920,fy, *).
*_. 

% Benchmarks

% Normal test
% [tile(1,1,11),tile(2,1,7),tile(3,1,1),tile(4, 1,5),tile(1,2,3),tile(2,2,9),tile(3,2,4),tile(4,2,8),tile(1,3,2),tile(2,3,13),tile(3,3,12),tile(4,3,15),tile(1,4,6),tile(2,4,14),tile(3,4,10),tile(4,4,0)]

% Medium test:
% [tile(1,1,1),tile(2,1,2),tile(3,1,3),tile(4,1,4),tile(1,2,5),tile(2,2,6),tile(3,2,7),tile(4,2,8),tile(1,3,15),tile(2,3,0),tile(3,3,14),tile(4,3,11),tile(1,4,10),tile(2,4,12),tile(3,4,9),tile(4,4,13)]

% Easy test
% [tile(1,1,1),tile(2,1,2),tile(3,1,3),tile(4,1,4),tile(1,2,5),tile(2,2,6),tile(3,2,7),tile(4,2,8),tile(1,3,10),tile(2,3,11),tile(3,3,12),tile(4,3,15),tile(1,4,0),tile(2,4,9),tile(3,4,13),tile(4,4,14)]

% prova/1 - prova(+ListaAzioni)
prova(ListaAzioni) :-
    % Costruisci la configurazione iniziale
    heuristics:h(
        [tile(1,1,1),tile(2,1,2),tile(3,1,3),tile(4,1,4),tile(1,2,5),tile(2,2,6),tile(3,2,7),tile(4,2,8),tile(1,3,15),tile(2,3,0),tile(3,3,14),tile(4,3,11),tile(1,4,10),tile(2,4,12),tile(3,4,9),tile(4,4,13)]
        , Hval),
    write("Value: "),
    writeln(Hval),
    time(ida_star(
        Hval,
        [tile(1,1,1),tile(2,1,2),tile(3,1,3),tile(4,1,4),tile(1,2,5),tile(2,2,6),tile(3,2,7),tile(4,2,8),tile(1,3,15),tile(2,3,0),tile(3,3,14),tile(4,3,11),tile(1,4,10),tile(2,4,12),tile(3,4,9),tile(4,4,13)]
        , ListaAzioni
    )),
    writeln(ListaAzioni).

% generic_step_with_memory(+Deepness, +Config, +Visited, +Actions, -Plan)
generic_step_with_memory(Deepness, Config, _, _, []) :- Deepness > -1, check_config(Config), !.
generic_step_with_memory(0, Config, _, _, Plan) :-
    % Profondità zero, siamo ad una foglia, calcola la F e prosegui (facendo backtracking)
    heuristics:hamming(Config, Hmin),
    deepness(D),
    FMin is D + Hmin,
    findall(FM, fmin(FM), FMins),
    \+member(FMin, FMins),
    assertz(fmin(FMin)),
    write("STEP: Found Leaf. F-Value: "),
    writeln(FMin),
    write("Config @depth0: "),
    writeln(Config),
    writeln(""),
    generic_step_with_memory(-1, Config, _, _, Plan).

generic_step_with_memory(Deepness, Config, Visited, [action(Tile, Action)|_], [action(Tile, Action)|PlanT]) :-
    Deepness > 0,
    regole:trasforma(Config, Tile, NuovaConfig),
    \+member(NuovaConfig, Visited),
    NDeepness is Deepness -1,
    choose(NuovaConfig, [Config|Visited], Actions),
    generic_step_with_memory(NDeepness, NuovaConfig, [Config|Visited], Actions, PlanT).

generic_step_with_memory(Deepness, Config, Visited, [action(_, _)|ActionsT], PlanT) :-
    Deepness > 0,
    %write("Last action "),
    %write(action(Tile, Action)),
    %write(" was not successful, i'm trying the next one. Remaining: "),
    %writeln(ActionsT),
    generic_step_with_memory(Deepness, Config, Visited, ActionsT, PlanT).


% generic_step(+Deepness, +Config, +Actions, -Plan)
generic_step(Deepness, Config, _, []) :- Deepness > -1, check_config(Config), !.
generic_step(0, Config, _, Plan) :-
    % Profondità zero, siamo ad una foglia, calcola la F e prosegui (facendo backtracking)
    heuristics:h(Config, Hmin),
    deepness(D),
    FMin is D + Hmin,
    findall(FM, fmin(FM), FMins),
    \+member(FMin, FMins),
    assertz(fmin(FMin)),
    write("STEP: Found Leaf. F-Value: "),
    writeln(FMin),
    write("Config @depth0: "),
    writeln(Config),
    writeln(""),
    generic_step(-1, Config, _, Plan).

generic_step(Deepness, Config, [action(Tile, Action)|_], [action(Tile, Action)|PlanT]) :-
    Deepness > 0,
    regole:trasforma(Config, Tile, NuovaConfig),
    NDeepness is Deepness -1,
    hchoose(NuovaConfig, [], Actions),
    generic_step(NDeepness, NuovaConfig, Actions, PlanT).

generic_step(Deepness, Config, [action(_, _)|ActionsT], PlanT) :-
    Deepness > 0,
    %write("Last action "),
    %write(action(Tile, Action)),
    %write(" was not successful, i'm trying the next one. Remaining: "),
    %writeln(ActionsT),
    generic_step(Deepness, Config, ActionsT, PlanT).

ida_star(Deepness, Config, Solution) :-
    write("MAIN: Deepness is: "),
    write(Deepness),
    writeln(". Recursing..."),
    hchoose(Config, [], Actions),
    retractall(deepness(_)),
    assertz(deepness(Deepness)),
    generic_step(Deepness, Config, Actions, Solution).
ida_star(Deepness, Config, Solution) :-
    write("MAIN: Deepness: "),
    write(Deepness),
    find_prevfmin(PM),
    findall(FM, fmin(FM), FMins),
    find_nextmin(PM, FMins, Min),
    Min > Deepness,
    retractall(fmin(_)),
    write(". Previous F: "),
    write(PM),
    retractall(prev_fmin(_)),
    assertz(prev_fmin(Min)),
    write(". Using new F: "),
    write(Min),
    writeln(". Invoking myself..."),
    ida_star(Min, Config, Solution).

find_prevfmin(X) :-
    prev_fmin(X).
find_prevfmin(1).

find_nextmin(PM, FMins, R) :-
    sort(FMins, SFmins),
    find_nextmin_aux(PM, SFmins, R).
find_nextmin_aux(PM, [Sf|_], Sf) :-
    Sf > PM.
find_nextmin_aux(PM, [_|Sft], R) :-
    find_nextmin_aux(PM, Sft, R).

% Choose a tile and an action for the current config
% Se non si è ancora visitato alcuno stato, qualsiasi azione è ugualmente importante*
% *per ora.
choose(Config, [], Testable) :-
    regole:actions(Config, Testable), !.
choose(Config, Visited, Testable) :-
    regole:actions(Config, Actions),
    choose_aux(Config, Visited, Actions, Testable).

choose_aux(_, _, [], []).
choose_aux(Config, Visited, [action(Tile, Action)|Actions], [action(Tile, Action)|Testable]) :-
    % Prova ad applicare la prima come trasformazione
    regole:trasforma(Config, Tile, Result),
    % Se questa configurazione non è ancora stata vista, aggiungila a quelle testabili
    \+member(Result, Visited),
    choose_aux(Config, Visited, Actions, Testable).
choose_aux(Config, Visited, [_|Actions], Testable) :-
    choose_aux(Config, Visited, Actions, Testable).

% Scelta della prossima azione basata sull'euristica
hchoose(Config, Visited, Stripped) :-
    % Trova tutte le azioni per questa configurazione
    regole:actions(Config, Actions),
    choose_aux(Config, Visited, Actions, Testable),
    % Valuta l'euristica sulle possibili evoluzioni
    choose_hmin(Config, Testable, Visited, Valued),
    % Ordina le azioni per valore dell'euristica decrescente
    action_sort(Valued, Sorted),
    % Rimuovi il valore dell'euristica dalle azioni
    strip_hval(Sorted, Stripped), !.

% Scegli un'azione tra quelle possibili che riduca la distanza di manhattan
% Tra la configurazione attuale e quella desiderata
% choose_hmin(Config, Testable, Visited, Hvals)
choose_hmin(_, [], _, [hval(none, 9999)]).
choose_hmin(Config, [action(Tile, Dir)|Tail], Visited, [hval(action(Tile, Dir), NextF)|Hvals]) :-
    choose_hmin(Config, Tail, Visited, Hvals),!,
    regole:trasforma(Config, Tile, Result),
    heuristics:f(Result, Visited, NextF).

action_sort([hval(A, V), hval(A1, V1)], [hval(A1, V1), hval(A, V)]) :-
    V > V1.
action_sort([hval(A, V), hval(A1, V1)], [hval(A, V), hval(A1, V1)]) :-
    V =< V1.
action_sort([hval(A, V)|Hvals], Sorted) :- 
    action_sort(Hvals, [hval(A1, V1)|SortedT]),
    action_sort([hval(A, V), hval(A1, V1)], SortedN),
    append(SortedN, SortedT, Sorted).

strip_hval([hval(none, 9999)], []).
strip_hval([hval(A, _)|Actions], [A|Stripped]) :- strip_hval(Actions, Stripped).
