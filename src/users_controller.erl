-module(users_controller).
-export([login/2]).
-include("dream.hrl").

login(#state{socket=From, tp=Tp}, Data) ->
    ?DEBUG("~p:login  ~p Data=~p~n",[?MODULE, ?LINE, Data]),
    Tp:send(From, mochijson2:encode({struct, Data})),
    ok.


