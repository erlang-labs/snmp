%%
%% %CopyrightBegin%
%% 
%% Copyright Ericsson AB 1996-2013. All Rights Reserved.
%% 
%% The contents of this file are subject to the Erlang Public License,
%% Version 1.1, (the "License"); you may not use this file except in
%% compliance with the License. You should have received a copy of the
%% Erlang Public License along with this software. If not, it can be
%% retrieved online at http://www.erlang.org/.
%% 
%% Software distributed under the License is distributed on an "AS IS"
%% basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
%% the License for the specific language governing rights and limitations
%% under the License.
%% 
%% %CopyrightEnd%
%%
-module(snmpa_mib_data).

-include_lib("snmp/include/snmp_types.hrl").

%%%-----------------------------------------------------------------
%%% This is the behaviour for the MIB server backend internal 
%%% data storage. 
%%%-----------------------------------------------------------------

%% These types should really be defined elsewhere...
-export_type([
	      mib_storage/0, 
	      mib_storage_opt/0, 
	      mib_storage_module/0, 
	      mib_storage_options/0, 
	      mib_view/0, 
	      mib_view_elem/0, 
	      mib_view_mask/0, 
	      mib_view_inclusion/0
	     ]).

-type mib_storage() :: [mib_storage_opt()].
-type mib_storage_opt() :: {module,  mib_storage_module()} | 
                           {options, mib_storage_options()}.

%% Module implementing the snmpa_mib_storage behaviour
-type mib_storage_module()  :: atom(). 
%% Options specific to the above module
-type mib_storage_options() :: list().

-type mib_view()           :: [mib_view_elem()].
-type mib_view_elem()      :: {SubTree :: snmp:oid(), 
			       Mask :: [non_neg_integer()], 
			       Inclusion :: mib_view_inclusion()}.
-type mib_view_mask()      :: [non_neg_integer()]. 
-type mib_view_inclusion() :: 1 | 2. % 1 = included, 2 = excluded

-type filename() :: file:filename().


-callback new(MibStorage :: mib_storage()) -> State :: term().

-callback close(State :: term()) -> ok.

-callback sync(State :: term()) -> ok.

-callback load_mib(State :: term(), FileName :: string(), 
		   MeOverride :: boolean(), 
		   TeOverride :: boolean()) -> 
    {ok, NewState :: term()} | {error, Reason :: already_loaded | term()}.

-callback unload_mib(State :: term(), FileName :: string(), 
		   MeOverride :: boolean(), 
		   TeOverride :: boolean()) -> 
    {ok, NewState :: term()} | {error, Reason :: not_loaded | term()}.

-callback lookup(State :: term(), Oid :: snmp:oid()) -> 
    {false, Reason :: term()} | 
    {variable, MibEntry :: snmpa:me()} |
    {table_column, MibEntry :: snmpa:me(), TableEntryOid :: snmp:oid()} |
    {subagent, SubAgentPid :: pid(), SAOid :: snmp:oid()}.

-callback next(State :: term(), Oid :: snmp:oid(), MibView :: mib_view()) -> 
    endOfView | false | 
    {subagent, SubAgentPid :: pid(), SAOid :: snmp:oid()} |
    {variable, MibEntry :: snmpa:me(), VarOid :: snmp:oid()} |
    {table, TableOid :: snmp:oid(), TableRestOid :: snmp:oid(), MibEntry :: snmpa:me()}.

-callback register_subagent(State :: term(), 
			    Oid   :: snmp:oid(), 
			    Pid   :: pid()) -> 
    {ok, NewState :: term()} | {error, Reason :: term()}.

-callback unregister_subagent(State :: term(), 
			      PidOrOid :: pid() | snmp:oid()) -> 
    {ok, NewState :: term()}               | % When second arg was a pid()
    {ok, NewState :: term(), Pid :: pid()} | % When second arg was a oid()
    {error, Reason :: term()}.

-callback dump(State :: term(), Destination :: io | filename()) -> 
    ok | {error, Reason :: term()}.

-callback which_mib(State :: term(), Oid :: snmp:oid()) -> 
    {ok, Mib :: string()} | {error, Reason :: term()}.

-callback which_mibs(State :: term()) -> 
    [{MibName :: atom(), Filename :: string()}].

-callback whereis_mib(State :: term(), MibName :: atom()) -> 
    {ok, Filename :: string()} | {error, Reason :: term()}.

-callback info(State :: term()) -> list().

-callback backup(State :: term(), BackupDir :: string()) -> 
    ok |  {error, Reason :: term()}.

-callback code_change(Direction :: up | down, 
		      Vsn :: term(), 
		      Extra :: term(), 
		      State :: term()) -> 
    NewState :: term().



