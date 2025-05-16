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
    | PITCH                                         { EPitch($1) }
    | IDENT                                         { EIdent($1) }
    | RHYTHM INT                                    { ERhythm($2) }
    | TEMPO expr INT                                { ETempo($2, $3) }
    | BEAT INT expr                                 { EBeat($2, $3) }
    | TIE LPAR expr expr expr RPAR                  { ETie($3, $4, $5) }
    | DOT LPAR RHYTHM INT expr RPAR                 { ETie(ERhythm($4), ERhythm(2 * $4), $5) }
    | CHORD LPAR pitch_list RPAR                    { EChord($3) }

pitch_list: 
 | { [] }
 | PITCH pitch_list { $1::$2 }

