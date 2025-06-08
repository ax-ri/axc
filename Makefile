CAMLC=$(BINDIR)ocamlc
CAMLDEP=$(BINDIR)ocamldep
CAMLLEX=$(BINDIR)ocamllex
CAMLYACC=$(BINDIR)ocamlyacc
# COMPFLAGS=-w A-4-6-9 -warn-error A -g
COMPFLAGS=-I `ocamlfind query unix`
CAML_B_LFLAGS = `ocamlfind query -predicates byte -a-format unix`

EXEC = axc_loop

# Fichiers compilés, à produire pour fabriquer l'exécutable
SOURCES = sound_engine.ml axc_ast.ml axc_sem.ml axc_loop.ml 
GENERATED = axc_lex.ml axc_parse.ml axc_parse.mli
OBJS = utils.cmo $(GENERATED:.ml=.cmo) $(SOURCES:.ml=.cmo)

# Building the world
all: $(EXEC)

$(EXEC): $(OBJS)
	$(CAMLC) $(CAML_B_LFLAGS) $(COMPFLAGS) $(OBJS) -o $(EXEC)

.SUFFIXES:
.SUFFIXES: .ml .mli .cmo .cmi .cmx
.SUFFIXES: .mll .mly

.ml.cmo:
	$(CAMLC) $(COMPFLAGS) -c $<

.mli.cmi:
	$(CAMLC) $(COMPFLAGS) -c $<

.mll.ml:
	$(CAMLLEX) $<

.mly.ml:
	$(CAMLYACC) $<

# Clean up
clean:
	rm -f *.cm[io] *.cmx *~ .*~ *.o
	rm -f parser.mli
	rm -f $(GENERATED)
	rm -f $(EXEC)

# Dependencies
depend: utils.ml $(SOURCES) $(GENERATED)
	touch .depend
	$(CAMLDEP) utils.ml $(SOURCES) $(GENERATED) > .depend

include .depend

