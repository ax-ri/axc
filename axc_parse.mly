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
    | IDENT                                 { EExec($1) }

sound_list:
    | pitch                                             { [BasicSound(Rhythm(-1), $1)] }
    | pitch sound_list                                  { (BasicSound(Rhythm(-1), $1))::$2 }
    | rhythm pitch                                      { [BasicSound($1, $2)] }
    | rhythm pitch sound_list                           { (BasicSound($1, $2))::$3 }
    | compacted_rhythm                                  { $1 }
    | compacted_rhythm sound_list                       { $1@$2 }
    | TIE LPAR rhythm rhythm pitch RPAR                 { [LongSound($3, $4, $5)] }
    | TIE LPAR rhythm rhythm pitch RPAR sound_list      { (LongSound($3, $4, $5))::$7 }
    | DOT LPAR RHYTHM INT pitch RPAR                    { [LongSound(Rhythm($4), Rhythm(2 * $4), $5)] }
    | DOT LPAR RHYTHM INT pitch RPAR sound_list         { (LongSound(Rhythm($4), Rhythm(2 * $4), $5))::$7 }

compacted_rhythm:
    | rhythm LPAR pitch_list RPAR { (List.map (fun p -> BasicSound($1, p)) $3) }

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
    | RHYTHM INT    { Rhythm $2 }

