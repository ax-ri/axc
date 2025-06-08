type pitch =
  | SimplePitch of char * int * int (* one pitch (e.g. c4, a7 etc. )*)
  | MultiplePitch of (char * int * int) list (* chord(<pitch> <pitch>...) *)

type rhythm =
  | SimpleRhythm of int (* rhythm specifier *)
  | ComposedRhythm of rhythm * rhythm

type sound = rhythm * pitch

type expr =
  | ENone (* no expression *)
  | ESound of sound list (* sound *)
  | ETempo of (rhythm * int) (* tempo(<rhythm> duration) *)
  | EBeat of (int * rhythm) (* beat(count <rhythm>) *)
  | EDefaultScale of int (* default_scale <scale> *)
  | EDefaultRhythm of rhythm (* default_rhythm <rhythm> *)
  | ETranspose of int (* transpose <semitones> *)
  | EAssign of (string * expr) (* identifier = <expr> *)
  | EExec of string list (* identifier list *)

let string_of_pitch (p, s, a) =
  Printf.sprintf
    "%c%d%s"
    p
    s
    (match a with
     | 1 -> "#"
     | -1 -> "b"
     | _ -> "")
;;

let print_pitch = function
  | SimplePitch (p, s, a) -> string_of_pitch (p, s, a)
  | MultiplePitch l ->
    Printf.sprintf "Chord(%s)" (String.concat "; " (List.map string_of_pitch l))
;;

let rec print_rhythm = function
  | SimpleRhythm i -> Printf.sprintf "R%d" i
  | ComposedRhythm (a, b) -> Printf.sprintf "R(%s %s)" (print_rhythm a) (print_rhythm b)
;;

let print_sound (r, p) = Printf.sprintf "%s %s" (print_rhythm r) (print_pitch p)

let rec print oc = function
  | ENone -> Printf.fprintf oc "<none>"
  | ESound l ->
    Printf.fprintf oc "Sound(%s)" (String.concat "; " (List.map print_sound l))
  | ETempo (r, i) -> Printf.fprintf oc "Tempo %s = %d" (print_rhythm r) i
  | EBeat (i, r) -> Printf.fprintf oc "Beat %d x %s" i (print_rhythm r)
  | EDefaultScale s -> Printf.fprintf oc "Default scale %d" s
  | EDefaultRhythm r -> Printf.fprintf oc "Default rhythm %s" (print_rhythm r)
  | ETranspose n -> Printf.fprintf oc "Transpose %d" n
  | EAssign (s, e) -> Printf.fprintf oc "Ident %s is %a" s print e
  | EExec l ->
    Printf.fprintf
      oc
      "%s"
      (String.concat "; " (List.map (fun s -> Printf.sprintf "Exec %s" s) l))
;;
