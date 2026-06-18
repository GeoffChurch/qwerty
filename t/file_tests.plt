:- use_module(examples_harness).

:- begin_tests(file_tests).

test(snapshots, [forall(( example_cases(Cases), member(Case, Cases) ))]) :-
    expect_case(Case).

:- end_tests(file_tests).
