%% This module performs the modules idgiver and idgiver2. 
%% Run with parameter "random" starts the program as idgiver, run with parameter "sequential" starts the program as idgiver2.

-module(idgiver3).
-behaviour(gen_server).
-export([start/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
		code_change/3]).
-export([get/0]).
init(Mode) ->
    case Mode of
	sequential->
	    crypto:start(),
	    {ok, {sequential, crypto:rand_uniform(0, 10000)}};
	random->
	    crypto:start(),
	    {ok, {random, sets:new()}}
    end.
 

start(Mode) ->
    net_kernel:start([idgiver3, shortnames]),
    case Mode of
	random ->
	    gen_server:start_link({local,idgiver3}, idgiver3, Mode, []);
	sequential ->
	    gen_server:start_link({local,idgiver3}, idgiver3, Mode, []);
	_ ->
	    io:format("Bad argument to start function, enter 'random' for idgiver mode or 'sequential' for idgiver2 mode.")
    end.

host_name() ->
    {_, X} = inet:gethostname(), 
    X.

rand() ->
    crypto:rand_uniform(20, 27852785).

get_random_not_in_set(Set, X) ->
    case sets:is_element(X, Set) of
	true -> 
	    get_random_not_in_set(Set, rand());
	false ->
	    X
    end.

get_random_not_in_set(Set) -> 
    get_random_not_in_set(Set, rand()).

handle_call({get}, From, {Mode, State}) ->
   case Mode of
	random->
	    X = get_random_not_in_set(State),
	    {reply, X, {Mode, sets:add_element(X, State)}};
	sequential->
	   proc_lib:spawn_link(fun() -> 
				   %    timer:sleep(4000), 
				       gen_server:reply(From, State)
      end),
	    {noreply, {Mode, State + 1}}	   
    end.

handle_cast(_Msg, State) -> {noreply, State}.
handle_info(_Msg, State) -> {noreply, State}.
terminate(_,_) -> ok.
code_change(_,State,_) -> {ok, State}.


get() ->
    gen_server:call({idgiver3,list_to_atom("idgiver3@" ++ host_name())}, {get}).
