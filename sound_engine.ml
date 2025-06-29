let audio_backend = ref "alsa"

(* play a sound using the sox library *)
(* f is the sound frequency (Hz) and l the length (s) *)
let sox_beep f l =
  let l_ms = l /. 1000.0 in
  let freq_list = String.concat " " (List.map (fun f -> Printf.sprintf "pl %f" f) f) in
  let command =
    Printf.sprintf "play -nq -t %s synth %f %s" !audio_backend l_ms freq_list
  in
  let _ = Unix.system command in
  ()
;;

(* play a rest (i.e. no sound) *)
(* l is the length (s) *)
let rest l =
  let _ =
    if Unix.fork () = 0
    then Unix.execvp "sleep" [| "sleep"; string_of_float l |]
    else Unix.wait ()
  in
  ()
;;

let semitones_above_middle_c = function
  | 'c' -> 0
  | 'd' -> 2
  | 'e' -> 4
  | 'f' -> 5
  | 'g' -> 7
  | 'a' -> 9
  | 'b' -> 11
  | _ as p -> failwith (Printf.sprintf "Invalid pitch letter '%c'" p)
;;

(* based on https://en.wikipedia.org/wiki/Scientific_pitch_notation#Table_of_note_frequencies *)
let freq_of_pitch p s a =
  let a_tuning = 440. in
  (* A4 is 449 Hz *)
  let middle_c_scale = 4. in
  (* Reference note is C4 *)
  let n = float_of_int (semitones_above_middle_c p + a) in
  a_tuning *. Float.pow 2. (((n -. 9.) /. 12.) +. float_of_int s -. middle_c_scale)
;;

let play p s a d =
  if p = '.' then rest (d /. 1000.) else sox_beep [ freq_of_pitch p s a ] d
;;

let play_chord l d = sox_beep (List.map (fun (p, s, a) -> freq_of_pitch p s a) l) d
