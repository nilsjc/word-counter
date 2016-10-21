-module(wordcount).
-export([print_word_counts/1]).

words(String) ->
	{match, Captures} = re:run(String, "\\b\\w+\\b", [global,{capture,first,list}]),
	[hd(C) || C<-Captures].
	
process_each_line(IoDevice, Dict) ->
	case io:get_line(IoDevice, "") of
		eof ->
			file:close(IoDevice),
			Dict;
		{error, Reason} ->
			file:close(IoDevice),
			throw(Reason);
		Data ->
			NewDict = lists:foldl(
				fun(W, D) -> dict:update(W, fun(C) -> C + 1 end, 1, D)end,
				dict:new(),
				words(Data)),
			process_each_line(IoDevice, NewDict)
		end.
		
print_dict(Dict) ->
	%dict:map(fun (K,V) -> io:fwrite("~s ~p~n", [K,V]) end, Dict). %%"~s ~p~n"
	
	dict:fold(fun(Word, Count, AccIn) ->
		io:format("~s: ~w~n", [Word,Count]), AccIn end, void, Dict).
		
print_word_counts(Filename) ->
	case file:open(Filename, read) of
		{ok, IoDevice} ->
			Dict = process_each_line(IoDevice, dict:new()),
			print_dict(Dict)
	end.
	
				
				