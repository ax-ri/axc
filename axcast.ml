type expr = 
  | EIdent of string                          (* identifier *)
  | EPitch of string                          (* pitch (e.g. c4, a7 etc. )*)
  | ERhythm of (int)                          (* rhythm specifier *)
  | ETempo of (expr * int)                    (* tempo(<rhythm> duration) *)
  | EBeat of (int * expr)                     (* beat(count <rhythm>) *)
  | ETie of (expr * expr * expr)              (* tie(<rhythm> <rhythm> <pitch>) *)
  | EChord of (string list)                   (* chord(<pitch> <pitch>...) *)
;;

let rec print oc = function
  | EIdent s -> Printf.fprintf oc "%s" s
  | EPitch p -> Printf.fprintf oc "P%s" p
  | ERhythm i -> Printf.fprintf oc "R%d" i
  | ETempo(e, i) -> Printf.fprintf oc "Tempo %a = %d" print e i
  | EBeat(i, e) -> Printf.fprintf oc "Beat %d x %a" i print e
  | ETie(e1, e2, e3) -> Printf.fprintf oc "Tie %a %a %a" print e1 print e2 print e3
  | EChord(l) -> Printf.fprintf oc "Chord(%s)" (String.concat ", " l)
;;
