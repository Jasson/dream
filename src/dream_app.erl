%% Feel free to use, reuse and abuse the code in this file.

%% @private
-module(dream_app).
-behaviour(application).

%% API.
-export([start/2]).
-export([stop/1]).

%% API.

start(_Type, _Args) ->
	{ok, _} = ranch:start_listener(dream_app, 1,
		ranch_tcp, [{port, 8000}], dream_protocol, []),
	dream_sup:start_link().

stop(_State) ->
	ok.
