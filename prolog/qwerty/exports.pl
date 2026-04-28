:- module(exports, []).

:- reexport(library(qwerty/declaration), [
    op(1150,  fx, type),
    op(1130, xfx, --->),
    (type)/1,
    retract_all_types_and_aliases/0]).

:- reexport(library(qwerty/check), [
    typecheck/2,
    typecheck/3]).