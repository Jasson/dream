-module(client).

-export([client/0, 
         get_socket/0, 
         send/2,
         close/1]).
% f(S),S=client:get_socket(), client:send(S,1).
-include("dream.hrl").
client() ->
    Host = "localhost",
    {ok, Sock} = gen_tcp:connect(Host, 5000, [binary, {packet, 0}, {reuseaddr, true}]),
    ok = gen_tcp:send(Sock, "Some Data"),
    ok = gen_tcp:close(Sock).

get_socket() ->
    Host = "127.0.0.1",
    {ok, Sock} = gen_tcp:connect(Host, 8000, [binary, {packet, raw}, {reuseaddr, true}]),
    Sock.

send(Socket, N) when is_integer(N)->
    Msg = mochijson2:encode({struct, [{"id", N},
                                      {"action", "users/login"},
                                      {"username", "langxw"},
                                      {"password", "123456"},
                                      {"server", "number1"},
                                      {"user_type", "qq"}
                                      ]}),
    gen_tcp:send(Socket, Msg),
    receive 
        _Any when N==10->  
            finish;
        {tcp, Socket, Any}->
            %Data = binary_to_term(Any),
            Data = Any,
            ?DEBUG("~p:send ~p receive Any=~p~n", [?MODULE, ?LINE, Data]),
            ?DEBUG("~p:send ~p receive Msg=~p~n",
                       [?MODULE, ?LINE, mochijson2:decode(Data)]),
            send(Socket, N+1)
            
        after 2000->
        timeout 
    end;
send(Socket, Msg) ->
    gen_tcp:send(Socket, Msg),
    receive 
        Any->
            ?DEBUG("~p:send ~p receive Any=~p~n", [?MODULE, ?LINE, Any])
        after 2000->timeout 
    end.

close(Sock) ->
    ok = gen_tcp:close(Sock).
