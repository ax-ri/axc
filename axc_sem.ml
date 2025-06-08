type env =
  { mutable tempo : Axc_ast.rhythm * int
  ; mutable beat : int * Axc_ast.rhythm
  ; mutable default_scale : int
  ; mutable default_rhythm : Axc_ast.rhythm
  ; mutable transposition : int
  ; mutable identifiers : (string * Axc_ast.expr) list
  }

let init_env () =
  { tempo = Axc_ast.ERhythm 4, 60
  ; beat = 4, Axc_ast.ERhythm 4
  ; default_scale = 4
  ; default_rhythm = Axc_ast.ERhythm 4
  ; transposition = 0
  ; identifiers = []
  }
;;

let compute_duration rho r' =
  let r' = if r' = -1 then Utils.extract_rhythm rho.default_rhythm else r' in
  let r, d = rho.tempo in
  let r = Utils.extract_rhythm r in
  60000. *. float_of_int r /. (float_of_int d *. float_of_int r')
;;

let play_pitch rho p d =
  match p with
  | Axc_ast.ESimplePitch (p, s, a) ->
    Sound_engine.play
      p
      (if s = -1 then rho.default_scale else s)
      (a + rho.transposition)
      d
  | Axc_ast.EMultiplePitch l ->
    Sound_engine.play_chord
      (List.map
         (fun (p, s, a) ->
            p, (if s = -1 then rho.default_scale else s), a + rho.transposition)
         l)
      d
;;

let play_sound rho = function
  | Axc_ast.EBasicSound (Axc_ast.ERhythm r, p) ->
    play_pitch rho p (compute_duration rho r)
  | Axc_ast.ELongSound (Axc_ast.ERhythm r1, Axc_ast.ERhythm r2, p) ->
    play_pitch rho p (compute_duration rho r1 +. compute_duration rho r2)
;;

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
