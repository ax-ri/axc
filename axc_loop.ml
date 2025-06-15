let version = "1.0.0"

let usage () =
  Printf.sprintf
    "Usage: %s [options] [file]\n\
     \tRead and execute an AXC program from file (default is stdin)\n\
     %!"
    Sys.argv.(0)
;;

let main () =
  let spec_list =
    [ ( "--audio-backend"
      , Arg.Set_string Sound_engine.audio_backend
      , "Audio backend to use. This corresponds to the audio type used by Sox (-t \
         parameter). Default to 'alsa'" )
    ]
  in
  let input_file = ref "" in
  let anon_fun filename = input_file := filename in
  let () = Arg.parse spec_list anon_fun (usage ()) in
  let input_channel =
    match !input_file with
    | "" | "-" -> stdin
    | name ->
      (try open_in name with
       | _ ->
         Printf.eprintf "Opening %s failed\n%!" name;
         exit 1)
  in
  let _ = Printf.printf "        Welcome to AXC, version %s\n%!" version in
  let lexbuf = Lexing.from_channel input_channel in
  let rho = Axc_sem.init_env () in
  while true do
    try
      let _ = Printf.printf "> %!" in
      let e = Axc_parse.main Axc_lex.lex lexbuf in
      let _ = Printf.printf "Recognized: " in
      let _ = Axc_ast.print stdout e in
      let _ = Printf.fprintf stdout "\n%!" in
      let _ = Axc_sem.eval e rho in
      ()
    with
    | Axc_lex.Eoi ->
      Printf.printf "Farewell.\n%!";
      exit 0
    | Failure msg -> Printf.printf "Error: %s\n\n" msg
    | Parsing.Parse_error ->
      let sp = Lexing.lexeme_start_p lexbuf in
      let ep = Lexing.lexeme_end_p lexbuf in
      Format.printf
        "File %S, line %i, characters %i-%i: Syntax error.\n"
        sp.Lexing.pos_fname
        sp.Lexing.pos_lnum
        (sp.Lexing.pos_cnum - sp.Lexing.pos_bol)
        (ep.Lexing.pos_cnum - sp.Lexing.pos_bol)
    | Axc_lex.LexError (sp, ep) ->
      Printf.printf
        "File %S, line %i, characters %i-%i: Lexical error.\n"
        sp.Lexing.pos_fname
        sp.Lexing.pos_lnum
        (sp.Lexing.pos_cnum - sp.Lexing.pos_bol)
        (ep.Lexing.pos_cnum - sp.Lexing.pos_bol)
  done
;;

if !Sys.interactive then () else main ()
