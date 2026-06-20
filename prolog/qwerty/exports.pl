:- module(exports, []).

:- reexport(library(qwerty/ops)).

:- reexport(library(qwerty/declaration), [
    (type)/1,
    retract_all_types_and_aliases/0]).

:- reexport(library(qwerty/check), [
    typecheck/2,
    typecheck/3]).