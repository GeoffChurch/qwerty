% Harness for the examples/ tests
:- module(examples_harness,
          [ with_examples/2,
            examples_directory/1,
            example_files_with_extension/2,
            sequence_groups/1,
            sequence_part_file/1,
            snapshot_file/2,
            example_cases/1,
            expect_case/1,
            load_errors/2
          ]).

:- use_module(library(qwerty/declaration)).
:- use_module(library(qwerty/ops)).
:- use_module(library(readutil)).

:- meta_predicate with_examples(+, 0).
with_examples(Files, Goal) :-
    retract_all_types_and_aliases,
    call_cleanup(
        ( maplist(load_example, Files),
          call(Goal)
        ),
        ( maplist(unload_file, Files),
          retract_all_types_and_aliases
        )
    ).

% Load each example file into its own module (the file's own path), to avoid collision.
load_example(File) :-
    catch(File:consult(File),
          error(E, Ctx),
          print_message(error, error(E, Ctx))).

examples_directory(Dir) :-
    predicate_property(with_examples(_,_), file(F)),
    file_directory_name(F, D),
    directory_file_path(D, examples, Dir).

all_example_files(Files) :-
    example_files_with_extension(pl, Files).

example_files_with_extension(Ext, Files) :-
    examples_directory(Dir),
    findall(File, directory_member(Dir, File, [recursive(true), extensions([Ext])]), Fs),
    sort(Fs, Files).

sequence_part(File, Key, Number) :-
    file_name_extension(Stem, pl, File),
    file_name_extension(Key, NumberAtom, Stem),
    atom_number(NumberAtom, Number),
    integer(Number),
    Number > 0.

sequence_groups(Groups) :-
    all_example_files(Files),
    sequence_groups_(Files, Groups).

sequence_groups_ -->
    convlist(sequence_part_pair), % [File, ...] -> [Key-(Number-File), ...]
    keysort,
    group_pairs_by_key.           % -> [Key-[Number-File, ...], ...]

sequence_part_pair(File, Key-(Number-File)) :-
    sequence_part(File, Key, Number).

sequence_part_file(File) :-
    all_example_files(Files),
    member(File, Files),
    sequence_part(File, _, _).

snapshot_file(File, ErrFile) :-
    file_name_extension(Key, pl, File),
    file_name_extension(Key, err, ErrFile).

example_cases(Cases) :-
    all_example_files(Files),
    phrase(( sequence_groups_,
             maplist(map_snd(phrase((keysort, pairs_values))))
           ), Files, SequenceCases),
    convlist(standalone_case, Files, StandaloneCases),
    append(SequenceCases, StandaloneCases, Cases).

:- meta_predicate map_snd(2, ?, ?).
map_snd(Goal, X-Y0, X-Y) :-
    call(Goal, Y0, Y).

% A file belonging to no sequence is its own case.
standalone_case(File, Key-[File]) :-
    \+ sequence_part(File, _, _),
    file_name_extension(Key, pl, File).

:- multifile user:message_hook/3.

:- dynamic error_happened/1.

:- meta_predicate capturing_errors(0, -).
capturing_errors(Goal, Errors) :-
    retractall(error_happened(_)),
    setup_call_cleanup(
        assertz((user:message_hook(E, error, _) :- assertz(error_happened(E))), Ref),
        Goal,
        erase(Ref)),
    findall(E, retract(error_happened(E)), Errors).

load_errors(Files, Errors) :-
    capturing_errors(with_examples(Files, true), Terms),
    convlist(error_formal, Terms, Errors).

error_formal(error(Formal, _), Formal).

expect_case(Key-Files) :-
    load_errors(Files, Errors),
    expected_errors(Key, Patterns),
    assertion(maplist(=@=, Patterns, Errors)).

expected_errors(Key, Patterns) :-
    file_name_extension(Key, err, ErrFile),
    ( exists_file(ErrFile)
    -> read_file_to_terms(ErrFile, Patterns, [])
    ;  Patterns = []
    ).
