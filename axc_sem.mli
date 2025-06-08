type env

val init_env : unit -> env
val eval : Axc_ast.expr -> env -> unit
