#!/bin/sh
#erl -pa ebin deps/*/ebin -s dream \
#	-eval "io:format(\"Run: telnet localhost 5555~n\")."
erl -pa ebin deps/*/ebin -s dream 
