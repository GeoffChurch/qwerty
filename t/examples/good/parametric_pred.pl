:- use_module(library(qwerty)).

:- type _ ---> p(_). % p is parametric

p(f(_)). % ok, this clause's head has type p(f(X)) for skolemized f/1 and existential X
p(f(b)). % ok, X = b for skolemized b/0
