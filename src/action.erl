-module(action).
-export([get_action/1]).

-include("dream.hrl").
get_action("login") ->
    login;
get_action(_Ingore) ->
    ?DEBUG("~p:get_action ~p Data=~p~n",[?MODULE, ?LINE, _Ingore]),
    ingore.


