-module(idgiver).
-behaviour(gen_server).
-export([start/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
		code_change/3]).
-export([get/0]).


init(_) ->
	crypto:start(),
	{ok, 0}.

start() ->
	gen_server:start_link({local,idgiver}, idgiver, [], []).

handle_call({get}, From, Counter) ->
	Reply = Counter + crypto:rand_uniform(0, 19401940194) * 27852785, 
	io:format("Counter is ~p~n", [Counter]),
	case Counter rem 2 of 
		0 -> proc_lib:spawn_link(fun() -> 
										 timer:sleep(4000), 
										 gen_server:reply(From, Reply)
								 end);
		1 -> proc_lib:spawn_link(fun() -> 
										 timer:sleep(2000),
										 gen_server:reply(From, Reply)
								 end)
	end,
	{noreply, Counter + 1}.

handle_cast(_Msg, State) -> {noreply, State}.
handle_info(_Msg, State) -> {noreply, State}.
terminate(_,_) -> ok.
code_change(_,State,_) -> {ok, State}.

host_name() ->
    {_, X} = inet:gethostname(),
    io:format("~nhost_name~n~p nodes ~p~n",[X,node()]), 
    X.

get() ->
	gen_server:call({idgiver, list_to_atom("idgiver@" ++ host_name())}, {get}).

