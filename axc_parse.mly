%{
    open Axc_ast;;
%}

%token <int> INT
%token <string> IDENT
%token <char * int * int> PITCH
%token RHYTHM
%token LPAR RPAR NEWLINE
%token TEMPO BEAT TIE DOT CHORD

%start main
%type <Axc_ast.expr> main

%%

main:
    | NEWLINE      { ENone }
    | expr NEWLINE { $1 }
;

expr: 
    // | IDENT                                 { EIdent $1 }
    | sound_list                            { ESound($1) }
    | TEMPO rhythm INT                      { ETempo($2, $3) }
    | BEAT INT rhythm                       { EBeat($2, $3) }
    | TIE LPAR rhythm rhythm pitch RPAR     { ETie($3, $4, $5) }
    | DOT LPAR RHYTHM INT pitch RPAR        { ETie(ERhythm($4), ERhythm(2 * $4), $5) }

sound_list:
    // | { [] }
    | rhythm pitch                 { [($1, $2)] }
    | compacted_rhythm             { $1 }
    | rhythm pitch sound_list      { ($1, $2)::$3 }
    | compacted_rhythm sound_list  { $1@$2 }

compacted_rhythm:
    | RHYTHM INT LPAR pitch_list RPAR { (List.map (fun p -> ERhythm($2), p) $4) }

pitch:
    | PITCH                                { let (p, s, a) = $1 in ESimplePitch(p, s, a) }
    | CHORD LPAR simple_pitch_list RPAR    { EMultiplePitch $3 }

simple_pitch_list: 
    | { [] }
    | PITCH simple_pitch_list { $1::$2 }

pitch_list: 
    | { [] }
    | pitch pitch_list { $1::$2 }

rhythm:
    | RHYTHM INT    { ERhythm $2 }

