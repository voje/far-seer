-- requires fs_functions.lua

SLASH_fs_main1 = "/fs";
function SlashCmdList.fs_main(cmd)
	if cmd == "test1" then
		_fsf.test1();
	elseif cmd == "test2" then
		_fsf.test2();
	elseif cmd == "scan" then
		_fsa.automaton_state = "start";
	elseif cmd == "stop" then
		_fsa.automaton_state = "end";
	else
		_fsf.pprint(cmd);
	end
end

SLASH_fs_ah1 = "/fsset";
function SlashCmdList.fs_ah(cmd)
	if cmd == nil then
		cmd = "";
	end
	_fsa.search_query = cmd;
end
