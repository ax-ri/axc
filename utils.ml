let sum_rhythm r =
  let rec aux r acc =
    match r with
    | Axc_ast.SimpleRhythm r -> r + acc
    | Axc_ast.ComposedRhythm (r1, r2) -> aux r1 (aux r2 acc)
  in
  aux r 0
;;

let rec dot_to_tie = function
  | Axc_ast.SimpleRhythm r -> Axc_ast.ComposedRhythm (SimpleRhythm r, SimpleRhythm (r * 2))
  | Axc_ast.ComposedRhythm (r1, r2) -> ComposedRhythm (dot_to_tie r1, dot_to_tie r2)
;;
