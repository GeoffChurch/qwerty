% Tests the testing infra
:- use_module(examples_harness).

natseq(Numbers) :-
    length(Numbers, N),
    numlist(1, N, Numbers).

snapshotted_case(Key-_) :-
    file_name_extension(Key, err, ErrFile),
    exists_file(ErrFile).

sequence_case(_-[_, _|_]).

example_naming_error(non_consecutive_sequence(Key, Numbers)) :-
    sequence_groups(Groups),
    member(Key-NumberedFiles, Groups),
    keysort(NumberedFiles, Sorted),
    pairs_keys(Sorted, Numbers),
    \+ natseq(Numbers).

example_naming_error(sequence_conflicts_with_standalone(Key, Standalone)) :-
    sequence_groups(Groups),
    member(Key-_, Groups),
    file_name_extension(Key, pl, Standalone),
    exists_file(Standalone).

example_naming_error(sequence_part_has_snapshot(File, ErrFile)) :-
    sequence_part_file(File),
    snapshot_file(File, ErrFile),
    exists_file(ErrFile).

example_naming_error(orphaned_snapshot(ErrFile)) :-
    example_files_with_extension(err, ErrFiles),
    member(ErrFile, ErrFiles),
    file_name_extension(Key, err, ErrFile),
    \+ (example_cases(Cases), memberchk(Key-_, Cases)).

:- meta_predicate and(1, 1, ?).
and(G1, G2, X) :-
    call(G1, X),
    call(G2, X).

:- meta_predicate not(1, ?).
not(G, X) :-
    \+ call(G, X).

:- meta_predicate nonempty_output(2, ?).
nonempty_output(G, X) :-
    call(G, X, Y),
    is_list(Y),
    Y = [_|_].

:- begin_tests(meta_tests).

test(example_names_well_formed) :-
    findall(Error, example_naming_error(Error), Errors),
    assertion(Errors == []).

test(examples_get_different_modules) :-
    examples_directory(Dir),
    maplist(directory_file_path(Dir),
            ['good/intra.pl', 'good/with_goal_expansion.pl'],
            [A, B]),
    with_examples([A, B],
        ( predicate_property(A:p(_), file(FA)),
          predicate_property(B:p(_), file(FB)) )
    ),
    maplist(same_file, [FA, FB], [A, B]),
    \+ same_file(FA, FB).

test(tests_include_every_example_class) :-
    example_cases(Cases),
    assertion(nonempty_output(include(and(    snapshotted_case,      sequence_case)),  Cases)),
    assertion(nonempty_output(include(and(    snapshotted_case,  not(sequence_case))), Cases)),
    assertion(nonempty_output(include(and(not(snapshotted_case),     sequence_case)),  Cases)),
    assertion(nonempty_output(include(and(not(snapshotted_case), not(sequence_case))), Cases)).

test(no_residual_state_after_case, [forall(( example_cases(Cases), member(_-Files, Cases) ))]) :-
    load_errors(Files, _),
    assertion(\+ qwerty:term_to_check(_)),
    assertion(\+ db:ctor_pretype_type(_, _, _)),
    assertion(\+ db:alias_canonical(_, _)).

:- end_tests(meta_tests).
