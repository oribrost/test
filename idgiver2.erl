-module(idgiver2).
-behaviour(gen_server).
-export([start/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
		code_change/3]).
-export([get/0]).


init(_) ->
	crypto:start(),
	{ok, sets:new()}.

start() ->
	gen_server:start_link({local,idgiver2}, idgiver2, [], []).

rand() -> crypto:rand_uniform(0, 27852785).

get_random_not_in_set(Set, X) ->
	case sets:is_element(X, Set) of
		true -> get_random_not_in_set(Set, rand());
		false -> X
	end.




get_random_not_in_set(Set) -> get_random_not_in_set(Set, rand()).

handle_call({get}, _From, Set) ->
	X = get_random_not_in_set(Set),
	{reply, X, sets:add_element(X, Set)}.

handle_cast(_Msg, State) -> {noreply, State}.
handle_info(_Msg, State) -> {noreply, State}.
terminate(_,_) -> ok.
code_change(_,State,_) -> {ok, State}.

host_name() ->
	{_, X} = inet:gethostname(), 
	X.

get() ->
	gen_server:call({idgiver2, list_to_atom("idgiver2@" ++ host_name())}, {get}).

