-- requires fs_functions.lua

SLASH_fs_main1 = "/fs";
function SlashCmdList.fs_main(cmd)
	if cmd == "test1" then
		_fsf.test1();
	elseif cmd == "test2" then
		_fsf.test2();
	elseif cmd == "ah_on" then
		_fsv.ah_automaton_on = true;
	else
		_fsf.pprint(cmd);
	end
end

SLASH_fs_ah1 = "/fsah";
function SlashCmdList.fs_ah(cmd)
	_fsf.auction_query("", nil, cmd);
end
