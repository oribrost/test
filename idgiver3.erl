%% This module performs the modules idgiver and idgiver2. 
%% Run with parameter "0" starts the program as idgiver, run with parameter "1" starts the program as idgiver2.

-module(idgiver3).
-behaviour(gen_server).
-export([start/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
		code_change/3]).
-export([get/0]).

init(Mode) ->
    case Mode of
	mode1->
	    crypto:start(),
	    %io:format("init - mode1~n"),
	    {ok, 0};
	mode2->
	    crypto:start(),
	    %io:format("init - mode2~n"),
	    {ok, sets:new()}
    end.
 

start(Mode) ->
    case Mode of
	0 ->
	    %io:format("start - mode1~n"),
	    gen_server:start_link({local,idgiver3_mode1}, idgiver3, mode1, []);
	1 ->
	    %io:format("start - mode2~n"),
	    gen_server:start_link({local,idgiver3_mode2}, idgiver3, mode2, []);
	_ ->
	    io:format("Bad argument to start function, enter 0 for idgiver mode or 1 for idgiver2 mode.")
    end.

host_name() ->
    {_, X} = inet:gethostname(), 
    X.

rand() ->
    crypto:rand_uniform(0, 27852785).

get_random_not_in_set(Set, X) ->
    case sets:is_element(X, Set) of
	true -> get_random_not_in_set(Set, rand());
	false -> X
    end.

get_random_not_in_set(Set) -> 
    get_random_not_in_set(Set, rand()).

handle_call({Mode}, From, Set) ->
    case Mode of
	get1->
	    %io:format("handle_call - mode1~n"),
	    X = get_random_not_in_set(Set),
	    {reply, X, sets:add_element(X, Set)};
	get2->
	    %io:format("handle_call - mode2~n"),
	    Reply = Set + crypto:rand_uniform(0, 19401940194) * 27852785, 
	    io:format("Counter is ~p~n", [Set]),
	    case Set rem 2 of 
		0 -> proc_lib:spawn_link(fun() -> 
						 timer:sleep(4000), 
						 gen_server:reply(From, Reply)
					 end);
		1 -> proc_lib:spawn_link(fun() -> 
						 timer:sleep(2000),
						 gen_server:reply(From, Reply)
					 end)
	    end,
	    {noreply, Set + 1}	
    end.

handle_cast(_Msg, State) -> {noreply, State}.
handle_info(_Msg, State) -> {noreply, State}.
terminate(_,_) -> ok.
code_change(_,State,_) -> {ok, State}.


get() ->
    case lists:member(idgiver3_mode1, registered()) of 
	true->
	    %io:format("get - mode1~n"),  
	    gen_server:call({idgiver3, list_to_atom("idgiver3@" ++ host_name())}, {get1});
	false ->
	    %io:format("get - mode2~n"),
	    gen_server:call({idgiver3, list_to_atom("idgiver3@" ++ host_name())}, {get2})
    end.
