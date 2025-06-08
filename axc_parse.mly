%{
    open Axc_ast;;
%}

%token <int> INT
%token <string> IDENT
%token <char * int * int> PITCH
%token RHYTHM
%token EQUAL
%token LPAR RPAR NEWLINE
%token TEMPO BEAT TIE DOT CHORD DEFAULT_SCALE DEFAULT_RHYTHM TRANSPOSE

%start main
%type <Axc_ast.expr> main

%%

main:
    | NEWLINE      { ENone }
    | expr NEWLINE { $1 }
;

expr: 
    | sound_list                            { ESound($1) }
    | TEMPO rhythm INT                      { ETempo($2, $3) }
    | BEAT INT rhythm                       { EBeat($2, $3) }
    | DEFAULT_SCALE INT                     { EDefaultScale($2) }
    | DEFAULT_RHYTHM rhythm                 { EDefaultRhythm($2) }
    | TRANSPOSE INT                         { ETranspose($2) }
    | IDENT EQUAL expr                      { EAssign($1, $3) }
    | ident_list                            { EExec($1) }

sound_list:
    | pitch                                             { [SimpleRhythm(-1), $1] }
    | pitch sound_list                                  { (SimpleRhythm(-1), $1)::$2 }
    | rhythm pitch                                      { [$1, $2] }
    | rhythm pitch sound_list                           { ($1, $2)::$3 }
    | compacted_rhythm                                  { $1 }
    | compacted_rhythm sound_list                       { $1@$2 }

compacted_rhythm:
    | rhythm LPAR pitch_list RPAR { (List.map (fun p -> ($1, p)) $3) }

pitch:
    | PITCH                                { let (p, s, a) = $1 in SimplePitch(p, s, a) }
    | CHORD LPAR simple_pitch_list RPAR    { MultiplePitch $3 }

simple_pitch_list: 
    | { [] }
    | PITCH simple_pitch_list { $1::$2 }

pitch_list: 
    | { [] }
    | pitch pitch_list { $1::$2 }

rhythm:
    | RHYTHM INT                    { SimpleRhythm $2 }
    | TIE LPAR rhythm rhythm RPAR   { ComposedRhythm($3, $4) }
    | DOT LPAR rhythm RPAR          { Utils.dot_to_tie $3 }

ident_list:
    | IDENT             { [$1] }
    | IDENT ident_list  { $1::$2 }