type env = { 
  mutable tempo: Axc_ast.rhythm * int;
  mutable beat: int * Axc_ast.rhythm
}

let init_env () = {
  tempo = (Axc_ast.ERhythm 4, 60);
  beat = (4, Axc_ast.ERhythm 4) 
}
;;

let compute_duration rho r' = 
  let r, d = rho.tempo in
  let r = match r with Axc_ast.ERhythm(r'') -> r'' in
  (60000. *. (float_of_int r)) /. ((float_of_int d) *. (float_of_int r'))
;;

let play_sound rho (r, p) = 
  let r = match r with Axc_ast.ERhythm(r') -> r' in
  let d = compute_duration rho r in
  match p with
  | Axc_ast.ESimplePitch(p, s, a) -> Sound_engine.play p s a d
  | Axc_ast.EMultiplePitch l -> ()
;;

let eval e rho = match e with 
  | Axc_ast.ENone -> ()
  | Axc_ast.ETempo(r, d) -> rho.tempo <- (r, d)
  | Axc_ast.EBeat(c, r) -> rho.beat <- (c, r)
  | Axc_ast.ESound l -> List.iter (play_sound rho) l
  | _ -> ()
;;