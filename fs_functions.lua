function fs_print(text)
    DEFAULT_CHAT_FRAME:AddMessage("<fs> " .. text);
end

function fs_init_farseer_dump()
    if farseer_dump == nil then
        farseer_dump = {};
        fs_print("Initializing new farseer_dump file.");
    else
        fs_print("Using non-empty farseer_dump file.");
    end 
end

function fs_onload()
    this:RegisterEvent("CHAT_PLAYER_ENTERING_WORLD");
    this:RegisterEvent("AUCTION_ITEM_LIST_UPDATE");
    this:RegisterEvent("CHAT_MSG_CHANNEL");
    fs_print("FarSeer 0.1 loaded.");
end

function fs_eventhandler(event, arg1, arg2, arg3, arg4)
    if event == "CHAT_PLAYER_ENTERING_WORLD" then
        fs_init_farseer_dump();
    end
end