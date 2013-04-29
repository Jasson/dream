%% Feel free to use, reuse and abuse the code in this file.

-module(dream_protocol).
-export([start_link/4, init/4]).
-include("dream.hrl").
start_link(Ref, Socket, Transport, Opts) ->
	Pid = spawn_link(?MODULE, init, [Ref, Socket, Transport, Opts]),
	{ok, Pid}.

init(Ref, Socket, Transport, _Opts = []) ->
	ok = ranch:accept_ack(Ref),
	loop(#state{socket=Socket, connect="connecting", tp=Transport}).
loop(#state{socket=Socket, tp=Transport, connect="connecting"}=State) ->
    ?DEBUG("~p:loop ~p State=~p ~n",[?MODULE, ?LINE, State]),
    case Transport:recv(Socket, 0, 60000) of
        {ok, Data} ->
            {struct, JsonData} = mochijson2:decode(Data),
            ?DEBUG("~p:loop ~p Data=~p~n",[?MODULE, ?LINE, JsonData]),
            Action = get_value("action", JsonData) ,
            case parse_author(Action, State, JsonData) of
                ok -> 
                    loop(State#state{connect="connected"});
                _->
                    loop(State)
            end;
        _ ->
            ok = Transport:close(Socket)
    end;

loop(#state{socket=Socket, tp=Transport, connect="connected"}=State) ->
    ?DEBUG("~p:loop ~p State=~p ~n",[?MODULE, ?LINE, State]),
    case Transport:recv(Socket, 0, 60000) of
        {ok, Data} ->
            {struct, JsonData} = mochijson2:decode(Data),
            ?DEBUG("~p:loop ~p Data=~p~n",[?MODULE, ?LINE, JsonData]),
            Action = get_value("action", JsonData) ,
            parse(Action, State, JsonData),
            loop(State);
        _ ->
            ok = Transport:close(Socket)
    end.

parse_author("users/login", State, Data) ->
    ?DEBUG("~p:parse  ~p Data=~p~n",[?MODULE, ?LINE, {"users/login", Data}]),
    users_controller:login(State, Data).


parse("users/"++ActionStr, State, Data) ->
    ?DEBUG("~p:parse  ~p Data=~p~n",[?MODULE, ?LINE, Data]),
    Action = action:get_action(ActionStr),
    ?DEBUG("~p:parse  ~p Action=~p~n",[?MODULE, ?LINE, Action]),
    %%users_controller:Action(State, Data);
    users_controller:login(State, Data);
parse(_Ignore, State, Data) ->
    ?DEBUG("~p:parse  ~p _Ignore=~p state=~p ~n",[?MODULE, ?LINE, _Ignore, State]),
    ?DEBUG("~p:parse  ~p Data=~p~n",[?MODULE, ?LINE, Data]).
    


get_value(Name, List) when is_list(Name)->
    get_value(list_to_binary(Name), List);
get_value(Name, List) ->
    proplists:get_value(Name, List, "").
     
      



