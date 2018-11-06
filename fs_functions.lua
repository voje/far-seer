_fsf = {};

local function pprint(text)
    DEFAULT_CHAT_FRAME:AddMessage("<fs> " .. text);
end
_fsf.pprint = pprint;

local function dbg_print(text)
	if _fsv.debug then
		DEFAULT_CHAT_FRAME:AddMessage("<fs_dbg> " .. text);
	end
end
_fsf.dbg_print = dbg_print;

local function init_farseer_dump()
    if farseer_dump == nil then	--farseer_dump defined in far-seer.toc
        farseer_dump = {};
        pprint("Initializing new farseer_dump file.");
    else
        pprint("Using non-empty farseer_dump file.");
    end 
end
_fsf.init_farseer_dump = init_farseer_dump;

local function tick()
	dbg_print("Tick");
	if _fsv.ah_automaton_on then
		_fsa.ah_automaton();
	end
end
_fsf.tick = tick;

local function increment_chat_counter()
	dbg_print("Incrementing chat counter. [" .. _fsv.chat_counter .. "]");
	_fsv.chat_counter = _fsv.chat_counter + 1;
	-- a % b
	if (_fsv.chat_counter - math.floor(_fsv.chat_counter/_fsv.tick_module)*_fsv.tick_module) == 0 then
		tick();
	end
end
_fsf.increment_chat_counter = increment_chat_counter;

local function handle_test()
    dbg_print("function: handle_test");
    farseer_dump["test"] = "go to sleep man";
end
_fsf.handle_test = handle_test;

local function set_start_time()
	local t = date();
	dbg_print("Setting start time: " .. t);
	_fsv.start_time = t;
end
_fsf.set_start_time = set_start_time;

local function set_end_time()
	local t = date();
	dbg_print("Setting end time: " .. t);
	_fsv.end_time = t;
end
_fsf.set_end_time = set_end_time;


local function scrape_auction_item_list()
	dbg_print("Scraping auction item list.");
end
_fsf.scrape_auction_item_list = scrape_auction_item_list;

local function test1()
	dbg_print("test1");
	set_start_time();
end
_fsf.test1 = test1;

local function test2()
	dbg_print("test2");
	_fsa.auction_query("", nil, 0);
end
_fsf.test2 = test2;




-- automaton, because I don't know how to handle out of file dependencies
_fsa = {};

local state = "inactive";
local item_name = ""; -- blank queries for all items
local class_idx = 9; -- 9 is reagents ... experiment a bit
local query_page = 0;

local function ah_dbg_print(text)
	if _fsv.dbg_print then
		_fsf.pprint("<ah: " .. state .. ">" .. text);
	end
end

local function auction_query(itemName, classIndex, page)
	-- need to manually open an auction window first

	local canQuery = CanSendAuctionQuery("list")
	if not canQuery then
		dbg_print("canQuery wait ended, continuing.");
		return false;
	end
	
	--[[
	QueryAuctionItems(["name" [, minLevel [, maxLevel [, invTypeIndex [,
	classIndex [, subClassIndex [, page [, isUsable [, minQuality [, getAll
	]]
	-- you need to have AH window open.
	-- local classIndex = 3; -- bags, containers
	local classIndex = 9; -- reagents
	dbg_print("[ * ] auction_query( classIndex=" .. classIndex .. ", page=" .. page .. " )");
	QueryAuctionItems(itemName, nil, nil, nil, classIndex, nil, page);
	return true;
end
_fsa.auction_query = auction_query;

local function ah_automaton()
	-- todo: failsafe for when we're away from the vender / window closes
	ah_dbg_print("ah_automaton");
	if state == "inactive" then
		if _fsv.ah_automaton_on then
			ah_dbg_print("Starting ah_automaton.");
			state = "query";
		end
	elseif state == "query" then
		if CanSendAuctionQuery("list") then
			ah_dbg_print("Next page available.");
			auction_query(item_name, class_idx, query_page);
			query_page = query_page + 1;
			state = "scrape_item_list";
		end
	elseif state == "scrape_item_list" then
		ah_dbg_print("TODO: scrape items");
		-- if end of item list (hit null), state = end
		state = "query"
	elseif state == "end" then
		query_page = 0;
		_fsv.ah_automaton_on = false;
	end
end
_fsa.ah_automaton = ah_automaton;