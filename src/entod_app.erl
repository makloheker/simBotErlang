%%%-------------------------------------------------------------------
%% @doc botchat public API
%% @end
%%%-------------------------------------------------------------------
% nih banyak bug na

-module(entod_app).

-export([start/0, send_request/1, stop/1,loop/0]).

-define(SIMSIMI_URL, "https://api.simsimi.vn/v1/simtalk").

stop(_State) ->
    ok.

start() ->
    inets:start(),
    ssl:start(),
    loop().

loop() ->
    io:format("you>: "),
    Input = io:get_line(""),
    Text = string:strip(Input, right, $\n),
    case Text of
        "exit" ->
            io:format("byby...~n"),
            ok;
        _ ->
            Response = send_request(Text),
            io:format("bot>: ~s~n", [Response]),
            loop()
    end.

send_request(Text) ->
    URL = ?SIMSIMI_URL,
    Headers = [{"Content-Type", "application/x-www-form-urlencoded"}],
    Body = lists:flatten(io_lib:format("text=~s&lc=id", [Text])),
    case httpc:request(post, {URL, Headers, "application/x-www-form-urlencoded", Body}, [], []) of
        {ok, {{_, 200, _}, _, ResponseBody}} ->
            Json = jiffy:decode(ResponseBody, [return_maps]),
            case maps:get(<<"message">>, Json, <<"fail">>) of
                <<"fail">> ->
                    "fail";
                Message ->
                    binary_to_list(Message)
            end;
        {ok, {{_, StatusCode, _}, _, _}} ->
            io:format("error code:: ~p~n", [StatusCode]),
            "fail";
        {error, Reason} ->
            io:format("Request failed: ~p~n", [Reason]),
            "fail"
    end.
%% internal functions
