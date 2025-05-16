let version = "0.01" ;;

let usage () =
  let _ =
    Printf.eprintf
      "Usage: %s [file]\n\tRead an AXC program from file (default is stdin)\n%!"
    Sys.argv.(0) in
  exit 1
;;

let main() =
  let input_channel =
    match Array.length Sys.argv with
      1 -> stdin
    | 2 ->
        begin match Sys.argv.(1) with
          "-" -> stdin
        | name ->
            begin try open_in name with
              _ -> Printf.eprintf "Opening %s failed\n%!" name; exit 1
            end
        end
    | n -> usage()
  in
  let _ = Printf.printf "        Welcome to AXC, version %s\n%!" version in
  let lexbuf = Lexing.from_channel input_channel in
  while true do
    try
      let _ = Printf.printf  "> %!" in
      let e = Axcparse.main Axclex.lex lexbuf in
      let _ = Printf.printf "Recognized: " in
      let _ = Axcast.print stdout e in
(*    let _ = Printf.fprintf stdout " =\n%!" in
      let _ = Axcsem.printval (Axcsem.eval e) in *)
      Printf.printf "\n%!"
    with
      Axclex.Eoi -> Printf.printf  "Bye bye.\n%!" ; exit 0
    | Failure msg -> Printf.printf "Erreur: %s\n\n" msg
    | Parsing.Parse_error ->
        let sp = Lexing.lexeme_start_p lexbuf in
        let ep = Lexing.lexeme_end_p lexbuf in
        Format.printf
          "File %S, line %i, characters %i-%i: Syntax error.\n"
          sp.Lexing.pos_fname
          sp.Lexing.pos_lnum
          (sp.Lexing.pos_cnum - sp.Lexing.pos_bol)
          (ep.Lexing.pos_cnum - sp.Lexing.pos_bol)
    | Axclex.LexError (sp, ep) ->
        Printf.printf
          "File %S, line %i, characters %i-%i: Lexical error.\n"
          sp.Lexing.pos_fname
          sp.Lexing.pos_lnum
          (sp.Lexing.pos_cnum - sp.Lexing.pos_bol)
          (ep.Lexing.pos_cnum - sp.Lexing.pos_bol)
  done
;;

if !Sys.interactive then () else main();;
