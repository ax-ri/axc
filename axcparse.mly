%{
    open Axcast;;
%}

%token <int> INT
%token <string> IDENT
%token <string> PITCH
%token RHYTHM
%token LPAR RPAR NEWLINE
%token TEMPO BEAT TIE DOT CHORD

%start main
%type <Axcast.expr> main

%%

main:
    | expr NEWLINE { $1 }
;

expr: 
    | IDENT                                 { EIdent $1 }
    | rhythm pitch                          { ESound($1, $2) }
    | TEMPO rhythm INT                      { ETempo($2, $3) }
    | BEAT INT rhythm                       { EBeat($2, $3) }
    | TIE LPAR rhythm rhythm pitch RPAR     { ETie($3, $4, $5) }
    | DOT LPAR RHYTHM INT pitch RPAR        { ETie(ERhythm($4), ERhythm(2 * $4), $5) }

pitch:
    | PITCH                         { ESimplePitch $1 }
    | CHORD LPAR pitch_list RPAR    { EMultiplePitch $3 }

pitch_list: 
    | { [] }
    | PITCH pitch_list { $1::$2 }

rhythm:
    | RHYTHM INT    { ERhythm $2 }

