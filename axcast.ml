type pitch = 
  | ESimplePitch of string                    (* one pitch (e.g. c4, a7 etc. )*)
  | EMultiplePitch of (string list)           (* chord(<pitch> <pitch>...) *)
  
type rhythm =
| ERhythm of int                          (* rhythm specifier *)

type expr = 
  | EIdent of string                      (* identifier *)
  | ESound of (rhythm * pitch)            (* sound *)
  | ETempo of (rhythm * int)              (* tempo(<rhythm> duration) *)
  | EBeat of (int * rhythm)               (* beat(count <rhythm>) *)
  | ETie of (rhythm * rhythm * pitch)     (* tie(<rhythm> <rhythm> <pitch>) *)
;;

let rec print_pitch oc = function
  | ESimplePitch p -> Printf.fprintf oc "P%s" p
  | EMultiplePitch l -> Printf.fprintf oc "Chord(%s)" (String.concat ", " l)
;;
;;
let rec print_rhythm oc = function
  | ERhythm i -> Printf.fprintf oc "R%d" i
;;

let rec print oc = function
  | EIdent s -> Printf.fprintf oc "%s" s
  | ESound(r, p) -> Printf.fprintf oc "Sound(%a %a)" print_rhythm r print_pitch p
  | ETempo(r, i) -> Printf.fprintf oc "Tempo %a = %d" print_rhythm r i
  | EBeat(i, r) -> Printf.fprintf oc "Beat %d x %a" i print_rhythm r
  | ETie(r1, r2, p) -> Printf.fprintf oc "Tie %a %a %a" print_rhythm r1 print_rhythm r2 print_pitch p
  