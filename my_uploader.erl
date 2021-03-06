%%%-------------------------------------------------------------------
%%% @author Aleksandr Vinokurov <aleksandr.vin@gmail.com>
%%% @copyright (C) 2012
%%% @doc
%%% Uploader worker
%%% @end
%%% Created : 12 Mar 2012 by Aleksandr Vinokurov <aleksandr.vin@gmail.com>
%%%-------------------------------------------------------------------
-module(my_uploader).

-behaviour(gen_uploader).

-define(make_server_name, misc:make_ref_atom(?MODULE)).

%% API
-export([start_link/2, start_link/3, start_child/2, start_child/3]).

%% gen_uploader callbacks
-export([make_producer/3, make_uploader/1]).

-include("workers_conf.hrl").

%%%
%%%  Public API
%%%

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @spec start_link(Tid, Config) -> {ok, Pid} | ignore | {error, Error}
%% @end
%%--------------------------------------------------------------------
start_link(Tid, Config) ->
    start_link({local, ?make_server_name}, Tid, Config).

start_link(Name, Tid, Config) ->
    gen_uploader:start_link(Name, ?MODULE, Tid, Config, []).


start_child(Tid, Config) ->
    start_child(?make_server_name, Tid, Config).

start_child(Name, Tid, Config) ->
    ChildSpec = {Name,
                 {?MODULE, start_link, [{local, Name}, Tid, Config]},
                 temporary,
                 brutal_kill,
                 worker,
                 [?MODULE]},
    supervisor:start_child(?WORKERS_SUP, ChildSpec).

%%%===================================================================
%%% gen_uploader callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Returns the Key-Value producer function
%%
%% @spec make_producer(Seed, Quantity, ValueSize) ->
%%                                 function/1 | {error, Error}
%% @end
%%--------------------------------------------------------------------
make_producer(Seed, Quantity, ValueSize) ->
    kv_producers:make_succeeding_kv_producer(Seed, Quantity, ValueSize).

%%--------------------------------------------------------------------
%% @doc
%% Returns a function to perform actual Key-Value uploads
%%
%% @spec make_uploader(Connection) -> function/2 | {error, Error}
%% @end
%%--------------------------------------------------------------------
make_uploader(Connection) ->
    info_uploader(Connection).


%%
%% Internal functions
%%

info_uploader(Connection) ->
    fun (K,V) ->
            Ks = lists:flatten(K),
            Vs = lists:flatten(V),
            error_logger:info_msg("info_uploader (~p connection):"
                                  " ~p key, ~p value~n", [Connection, Ks, Vs]),
            ok
    end.
