-- Initiating event handlers and global variables.

_fsv = {};
_fsv.debug = true;
_fsv.chat_counter = 0;
_fsv.tick_module = 2;
_fsv.start_time = nil;
_fsv.end_time = nil;
-- make ah query a state automata.
-- tick() funcion progresses the state.
_fsv.automaton_state = "inactive";

function fs_onload()
    this:RegisterEvent("CHAT_PLAYER_ENTERING_WORLD");
    this:RegisterEvent("AUCTION_ITEM_LIST_UPDATE");
    this:RegisterEvent("CHAT_MSG_CHANNEL");
    _fsf.pprint("FarSeer 0.1 loaded.");
end

function fs_eventhandler(event, arg1, arg2, arg3, arg4)
    if event == "CHAT_MSG_CHANNEL" then
		_fsf.increment_chat_counter();
	elseif event == "AUCTION_ITEM_LIST_UPDATE" then
		_fsa.scrape_auction_item_list();
	end
end