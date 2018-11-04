-- requires fs_functions.lua

SLASH_fs_main1 = "/fs";
function SlashCmdList.fs_main(cmd)
    if cmd == "test" then
        handle_test();
    elseif cmd == "show" then
        fs_print(farseer_dump["test"]);
    else
        fs_print(cmd);
    end
end

function handle_test()
    fs_print("function: handle_test");
    farseer_dump["test"] = "go to sleep man";
end