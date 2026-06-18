:- use_module(library(qwerty)).

:- type _ ---> p(_). % p is parametric

p(_). % ok, head has type p(X) for existential X
p(a). % ok, head has type p(a), X is bound to a
p(b). % FAIL, p(a) and p(b) don't unify (semantic failure via head unification)
