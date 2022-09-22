:- module(regole, [apply/3, adjacent/3, adjacent/4, applicabile/3, trasforma/3, tileid/3, actions/2]).

side(4).

% adjacent/2 - adjacent(+Config, +Tilef, -Tiles)
adjacent(Config, TileF, Tiles) :-
    findall(T, adjacent(Config, TileF, T, _), Tiles).

% adjacent/3 - adjacent(tile_1, tile_2, direction)
% true se le tile_1 ha tile_2, alla propria direction.
adjacent(_, tile(X1, Y1, _), tile(X1, Y1, _), _) :- false.
adjacent(_, tile(1, _, left), tile(1, _, _), left) :- false.
adjacent(_, tile(X1, 1, _), tile(X1, 1, _), up) :- false.
adjacent(_, tile(4, _, right), tile(4, _, right), _) :- false.
adjacent(_, tile(X1, 4, down), tile(X1, 4, down), _) :- false.
adjacent(Config, tile(X1, Y1, N1), tile(X2, Y1, N2), left) :- 
    member(tile(X1, Y1, N1), Config),
    member(tile(X2, Y1, N2), Config),
    X2 is X1-1,
    X2 \== 0,
    N1 \== N2,
    tileid(Config, N2, tile(X2, Y1, N2)).

adjacent(Config, tile(X1, Y1, N1), tile(X2, Y1, N2), right) :- 
    member(tile(X1, Y1, N1), Config),
    member(tile(X2, Y1, N2), Config),
    X2 is X1+1,
    side(S),
    X2 \== S+1,
    N1 \== N2,
    tileid(Config, N2, tile(X2, Y1, N2)).

adjacent(Config, tile(X1, Y1, N1), tile(X1, Y2, N2), up) :- 
    member(tile(X1, Y1, N1), Config),
    member(tile(X1, Y2, N2), Config),
    Y2 is Y1-1,
    Y2 \== 0,
    N1 \== N2,
    tileid(Config, N2, tile(X1, Y2, N2)).

adjacent(Config, tile(X1, Y1, N1), tile(X1, Y2, N2), down) :- 
    member(tile(X1, Y1, N1), Config),
    member(tile(X1, Y2, N2), Config),
    Y2 is Y1+1,
    side(S),
    Y2 \== S+1,
    N1 \== N2,
    tileid(Config, N2, tile(X1, Y2, N2)).


% tileid/2 - tileid(Config, TileNum, TileInstance)
tileid(Config, Num, tile(X, Y, Num)) :-
    member(tile(X, Y, Num), Config), !.

% apply/3 - apply(configurazione, azioni, nuova_config)
% configurazione e nuova_config sono liste di tile/3
% azioni sono liste di action(tile/3, [up|down|left|right])
apply(Config, [], Config).
apply(Config, [action(Tile, _)|Azioni], NNCfg) :-
    regole:trasforma(Config, Tile, NuCfg),
    apply(NuCfg, Azioni, NNCfg).

% actions/2 - actions(+Config, -ActionList)
% trova gli elementi mobili da una configurazione
actions([], []).
actions(Config, Actions) :-
    tileid(Config, 0, TileZ),
    findall(action(Tile, Action), adjacent(Config, Tile, TileZ, Action), Actions).

% applicabile/2 - applicabile(stato, azione)
% descrive le azioni applicabili data una certa tile.
/* Nota: controlla a livello numerico la posizione delle tiles
 * *e* controlla se si può fisicamente muovere lì (lo spazio vuoto è adiacente)
 * Osservazione: Una tile può avere solo un'azione disponibile per volta.
 *               Se è applicabile 'left' *non* può essere applicabile right, up, left o down.
 *               Eccezione fatta per la 'pseudo-tile' 0 (può muovere ovunque)
 */
% Ci si limita al caso 4x4
applicabile(_, tile(X, _, _), _) :- X =< 0.
applicabile(_, tile(_, X, _), _) :- X =< 0.
applicabile(_, tile(X, _, _), _) :- X >= 5.
applicabile(_, tile(_, X, _), _) :- X >= 5.

% vieta azioni illegali se la tile è quella corretta
applicabile(_, tile(1, _, _), left) :- false.
applicabile(_, tile(_, 1, _), up) :- false.
applicabile(_, tile(4, _, _), right) :- false.
applicabile(_, tile(_, 4, _), down) :- false.

% Definizione nel caso in cui l'azione è legale
applicabile(Config, tile(X, Y, Z), left) :- 
    member(tile(X, Y, Z), Config),
    X > 1,
    tileid(Config, 0, TileZ),
    adjacent(Config, tile(X, Y, Z), TileZ, left), !.

applicabile(Config, tile(X, Y, Z), right) :- 
    member(tile(X, Y, Z), Config),
    side(M), X < M,
    tileid(Config, 0, TileZ),
    adjacent(Config, tile(X, Y, Z), TileZ, right), !.

applicabile(Config, tile(X, Y, Z), up) :- 
    member(tile(X, Y, Z), Config),
    Y > 1,
    tileid(Config, 0, TileZ),
    adjacent(Config, tile(X, Y, Z), TileZ, up), !.

applicabile(Config, tile(X, Y, Z), down) :- 
    member(tile(X, Y, Z), Config),
    side(M), Y < M, tileid(Config, 0, TileZ),
    adjacent(Config, tile(X, Y, Z), TileZ, down), !.

% tile_swap(tile(X, Y, Z), tile(I, J, K), Config, NewConfig)
tile_swap(_, _, [], []).
tile_swap(tile(X, Y, Z), tile(I, J, K), [tile(X, Y, Z)|Tail], [tile(X, Y, K)|Tail2]) :-
    tile_swap(tile(X, Y, Z), tile(I, J, K), Tail, Tail2), !.
tile_swap(tile(X, Y, Z), tile(I, J, K), [tile(I, J, K)|Tail], [tile(I, J, Z)|Tail2]) :-
    tile_swap(tile(X, Y, Z), tile(I, J, K), Tail, Tail2), !.
tile_swap(tile(X, Y, Z), tile(I, J, K), [Different|Tail], [Different|Tail2]) :-
    !, Different \== tile(X, Y, Z), !, tile_swap(tile(X, Y, Z), tile(I, J, K), Tail, Tail2).
tile_swap(tile(X, Y, Z), tile(I, J, K), [Different|Tail], [Different|Tail2]) :-
    !, Different \== tile(I, J, K), !, tile_swap(tile(X, Y, Z), tile(I, J, K), Tail, Tail2).

% trasforma/3 - trasforma(azione, stato, nuovo_stato)
% "Stato" e "NuovoStato" sono tile/3
% Attualmente ha dei punti di backtracking.
trasforma(Config, Tile, NuovaConfig) :- applicabile(Config, Tile, left), tileid(Config, 0, TileZ), tile_swap(TileZ, Tile, Config, NuovaConfig).
trasforma(Config, Tile, NuovaConfig) :- applicabile(Config, Tile, right), tileid(Config, 0, TileZ), tile_swap(TileZ, Tile, Config, NuovaConfig).
trasforma(Config, Tile, NuovaConfig) :- applicabile(Config, Tile, up), tileid(Config, 0, TileZ), tile_swap(TileZ, Tile, Config, NuovaConfig).
trasforma(Config, Tile, NuovaConfig) :- applicabile(Config, Tile, down), tileid(Config, 0, TileZ), tile_swap(TileZ, Tile, Config, NuovaConfig).