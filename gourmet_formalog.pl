:- ensure_loaded('/var/lib/myfrdcsa/codebases/minor/gourmet-formalog/scripts/gourmet/gourmet.pl').
:- ensure_loaded('/var/lib/myfrdcsa/codebases/minor/cyc-common/frdcsa/sys/flp/autoload/cyc_api.pl').

:- prolog_consult('/var/lib/myfrdcsa/codebases/minor/formalog-pengines/formalog_pengines/formalog_pengines_client').
:- prolog_consult('/var/lib/myfrdcsa/codebases/minor/formalog-pengines/formalog_pengines/formalog_pengines_server').
:- start_agent(gourmet).
