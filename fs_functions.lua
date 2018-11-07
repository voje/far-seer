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
	if (_fsv.automaton_state ~= "inactive" and _fsv.automaton_state ~= "scrape_item_list") then
		_fsa.ah_automaton();
	end
end
_fsf.tick = tick;

local function increment_chat_counter()
	-- dbg_print("Incrementing chat counter. [" .. _fsv.chat_counter .. "]");
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

local item_name = "elemental earth"; -- blank queries for all items
local class_idx = 9; -- 9 is reagents ... experiment a bit
local query_page = 0;

local function ah_dbg_print(text)
	if _fsv.debug then
		_fsf.pprint("<ah: " .. _fsv.automaton_state .. ">" .. text);
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

local function scrape_auction_item_list()
	if _fsv.automaton_state ~= "scrape_item_list" then
		return
	end
	ah_dbg_print("Scraping auction item list.");
	local ah_index = 1;
	for ah_index = 1, 50 do
		-- ah_dbg_print("Scraping item [" .. ah_index .. "]");
		
		local name, texture, count, quality, canUse, level, minBid, minIncrement, buyoutPrice, bidAmount, highestBidder, owner, sold = GetAuctionItemInfo("list", ah_index);
		if (name == nil) then
			ah_dbg_print("Item list ended. Ending query.");
			_fsv.automaton_state = "end";
			return;
		else
			local res_string = name .. "," .. texture .. "," .. count .. "," .. quality .. "," .. canUse .. "," .. level .. "," .. minBid .. "," .. minIncrement .. "," .. buyoutPrice .. "," .. bidAmount .. "," .. highestBidder .. "," .. owner .. "," .. sold;
			-- local res_string = _fsv.start_time .. "," .. name .. "," .. buyoutPrice;
			table.insert(farseer_dump, res_string);
		end
	end
	_fsv.automaton_state = "query"
end
_fsa.scrape_auction_item_list = scrape_auction_item_list;

local function ah_automaton()
	-- todo: failsafe for when we're away from the vender / window closes
	if _fsv.automaton_state == "inactive" then
		return
	elseif _fsv.automaton_state == "start" then
		ah_dbg_print("Starting ah_automaton.");
		_fsf.init_farseer_dump();
		_fsf.set_start_time();
		ah_page = 0;
		_fsv.automaton_state = "query";
	elseif _fsv.automaton_state == "query" then
		if CanSendAuctionQuery("list") then
			-- auction item list update event will trigger the scraper
			-- scraper needs to set automaton back to query mode (or end mode if end of list)
			_fsv.automaton_state = "scrape_item_list"; -- dummy state, a function is actually catching this
			ah_dbg_print("Next page available.");
			auction_query(item_name, class_idx, query_page);
			query_page = query_page + 1;
		end
	elseif _fsv.automaton_state == "end" then
		ah_dbg_print("Stopping ah_automaton.");
		_fsv.automaton_state = "inactive";
		_fsv.ah_automaton_on = false;
		query_page = 0;
		
		_fsf.set_end_time();
		table.insert(farseer_dump, _fsv.end_time);
	end
end
_fsa.ah_automaton = ah_automaton;