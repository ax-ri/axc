{
  open Axc_parse;;
  exception Eoi;;

  exception LexError of (Lexing.position * Lexing.position) ;;

  let pitch_symbol_as_char = function
    | "do" -> 'c'
    | "ut" -> 'c'
    | "ré" -> 'd'
    | "re" -> 'd'
    | "mi" -> 'e'
    | "fa" -> 'f'
    | "sol" -> 'g'
    | "la" -> 'a'
    | "si" -> 'b'
    | "ti" -> 'b'
    | p -> p.[0]

  let scale_of_char = function
    | Some c -> (int_of_char c) - (int_of_char '0')
    | None -> -1

  let acc_of_string = function
    | Some '+' | Some '#' | Some 's' -> 1
    | Some '-' | Some 'b' | Some 'f' -> -1
    | _ -> 0
}

let newline = ('\010' | '\013' | "\013\010")
let pitch_symbol = ['a'-'g'] | "do" | "ut" | "ré" | "re" | "mi" | "fa" | "sol" | "la" | "si" | "ti"
let scale_symbol = ['1'-'7']
let accidental_symbol = ['+''#''s' '-''b''f']

rule lex = parse
  | ' ' { lex lexbuf }
  | '#' { in_one_line_comment lexbuf }
  | newline { NEWLINE }
  | '!' { RHYTHM }
  | '(' { LPAR }
  | ')' { RPAR }
  | (pitch_symbol as p)(scale_symbol as s)?(accidental_symbol as a)? { PITCH(pitch_symbol_as_char p, scale_of_char s, acc_of_string a) }
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

