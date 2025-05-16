{
  open Axcparse;;
  exception Eoi;;

  exception LexError of (Lexing.position * Lexing.position) ;;
}

let newline = ('\010' | '\013' | "\013\010")
let pitch_symbol = ['a'-'g'] | "do" | "ut" | "ré" | "re" | "mi" | "fa" | "sol" | "la" | "si" | "ti"

rule lex = parse
  | ' ' { lex lexbuf }
  | '#' { in_one_line_comment lexbuf }
  | newline { NEWLINE }
  | '!' { RHYTHM }
  | '(' { LPAR }
  | ')' { RPAR }
  | (pitch_symbol)['1'-'7'](['+''-'])? as pitch { PITCH(pitch) }
  | ['1'-'9']['0'-'9']* as lxm { INT(int_of_string lxm) }
  | [ 'A'-'Z' 'a'-'z' ] [ 'A'-'Z' 'a'-'z' ]* as lxm { match lxm with
    | "tempo" -> TEMPO
    | "beat" -> BEAT
    | "tie" -> TIE
    | "dot" -> DOT
    | "chord" -> CHORD
    | _ -> IDENT(lxm)
  }
  | eof   { raise Eoi }
  | _     { raise (LexError (lexbuf.Lexing.lex_start_p, lexbuf.Lexing.lex_curr_p)) }

and in_one_line_comment = parse
  | '\n' { lex lexbuf }
  | _ { in_one_line_comment lexbuf }
  | eof  { raise Eoi }

