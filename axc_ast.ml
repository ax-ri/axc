type pitch = 
  | ESimplePitch of char * int * int              (* one pitch (e.g. c4, a7 etc. )*)
  | EMultiplePitch of (char * int * int) list     (* chord(<pitch> <pitch>...) *)
  
type rhythm =
| ERhythm of int                          (* rhythm specifier *)

type sound = 
  | EBasicSound of rhythm * pitch
  | ELongSound of rhythm * rhythm * pitch

type expr = 
  | ENone
  | EIdent of string                      (* identifier *)
  | ESound of sound list                  (* sound *)
  | ETempo of (rhythm * int)              (* tempo(<rhythm> duration) *)
  | EBeat of (int * rhythm)               (* beat(count <rhythm>) *)
  | EDefaultScale of int                  (* default_scale <scale> *)
  | EDefaultRhythm of rhythm              (* default_rhythm <rhythm> *)
;;

let string_of_pitch (p, s, a) = Printf.sprintf "%c%d%s" p s (match a with | 1 -> "#" | -1 -> "b" | _ -> "")

let print_pitch = function
  | ESimplePitch(p, s, a) -> string_of_pitch (p, s, a)
  | EMultiplePitch l -> Printf.sprintf "Chord(%s)" (String.concat "; " (List.map string_of_pitch l))
;;
;;
let print_rhythm = function
  | ERhythm i -> Printf.sprintf "R%d" i
;;

let print_sound = function
  | EBasicSound(r, p) -> Printf.sprintf "%s %s" (print_rhythm r) (print_pitch p)
  | ELongSound(r1, r2, p) -> Printf.sprintf "long %s %s %s" (print_rhythm r1) (print_rhythm r2) (print_pitch p)
;;

let rec print oc = function
  | ENone -> ()
  | EIdent s -> Printf.fprintf oc "%s" s
  | ESound l -> Printf.fprintf oc "Sound(%s)" (String.concat "; " (List.map print_sound l))
  | ETempo(r, i) -> Printf.fprintf oc "Tempo %s = %d" (print_rhythm r) i
  | EBeat(i, r) -> Printf.fprintf oc "Beat %d x %s" i (print_rhythm r)
  (* | ETie(r1, r2, p) -> Printf.fprintf oc "Tie %s %s %s" (print_rhythm r1) (print_rhythm r2) (print_pitch p) *)
  | EDefaultScale(s) -> Printf.fprintf oc "Default scale %d" s
  | EDefaultRhythm(r) -> Printf.fprintf oc "Default rhythm %s" (print_rhythm r)
  