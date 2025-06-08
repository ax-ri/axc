type env =
  { mutable tempo : Axc_ast.rhythm * int
  ; mutable beat : int * Axc_ast.rhythm
  ; mutable default_scale : int
  ; mutable default_rhythm : Axc_ast.rhythm
  ; mutable transposition : int
  ; mutable identifiers : (string * Axc_ast.expr) list
  }

let init_env () =
  { tempo = Axc_ast.SimpleRhythm 4, 60
  ; beat = 4, Axc_ast.SimpleRhythm 4
  ; default_scale = 4
  ; default_rhythm = Axc_ast.SimpleRhythm 4
  ; transposition = 0
  ; identifiers = []
  }
;;

let compute_duration rho r' =
  let r = Utils.sum_rhythm (fst rho.tempo)
  and d = snd rho.tempo in
  let compute r' = 60000. *. float_of_int r /. (float_of_int d *. float_of_int r') in
  let rec aux acc r' =
    match r' with
    | Axc_ast.SimpleRhythm r' ->
      acc +. if r' = -1 then aux acc rho.default_rhythm else compute r'
    | Axc_ast.ComposedRhythm (r1, r2) -> aux (aux acc r1) r2
  in
  aux 0. r'
;;

let play_pitch rho p d =
  match p with
  | Axc_ast.SimplePitch (p, s, a) ->
    Sound_engine.play
      p
      (if s = -1 then rho.default_scale else s)
      (a + rho.transposition)
      d
  | Axc_ast.MultiplePitch l ->
    Sound_engine.play_chord
      (List.map
         (fun (p, s, a) ->
            p, (if s = -1 then rho.default_scale else s), a + rho.transposition)
         l)
      d
;;

let play_sound rho (r, p) = play_pitch rho p (compute_duration rho r)

let add_to_env ids id e =
  let rec aux acc = function
    | [] -> (id, e) :: acc
    | (id', e') :: q -> aux (if id = id' then acc else (id', e') :: acc) q
  in
  aux [] ids
;;

let find_expr_in_env ids id = snd (List.find (fun (id', _) -> id = id') ids)

let rec eval e rho =
  match e with
  | Axc_ast.ENone -> ()
  | Axc_ast.ETempo (r, d) -> rho.tempo <- r, d
  | Axc_ast.EBeat (c, r) -> rho.beat <- c, r
  | Axc_ast.ESound l -> List.iter (play_sound rho) l
  | Axc_ast.EDefaultScale s -> rho.default_scale <- s
  | Axc_ast.EDefaultRhythm r -> rho.default_rhythm <- r
  | Axc_ast.ETranspose n -> rho.transposition <- n
  | Axc_ast.EAssign (id, e) -> rho.identifiers <- add_to_env rho.identifiers id e
  | Axc_ast.EExec id ->
    (try
       let e' = find_expr_in_env rho.identifiers id in
       eval e' rho
     with
     | Not_found -> failwith (Printf.sprintf "Unbound identifier %s" id))
;;
