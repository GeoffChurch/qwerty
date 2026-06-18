:- use_module(library(qwerty)).

% qwerty uses term_expansion, which fires before goal_expansion, so it should check the original goal, not the rewritten.
% qwerty skips directives entirely, so we use that to avoid qwerty failing the goal_expansion call itself, since X cannot be both color and bool.
:- assertz(goal_expansion(rewriteme(X), rewritten(X))).

:- type color ---> r ; g ; b.
:- type bool ---> true ; false.
:- type _ ---> rewriteme(color).
:- type _ ---> rewritten(bool).

% Original rewriteme(X) constrains X to color.
% Compiled rewritten(X) constrains X to bool.
% So, qwerty should think p has type p(color).
p(X) :- rewriteme(X).

% ok, r is a color.
q :- p(r).

% Sanity check that p was indeed rewritten
:- clause(p(_), rewritten(_)) -> true ; throw(goal_expansion_did_not_fire).
