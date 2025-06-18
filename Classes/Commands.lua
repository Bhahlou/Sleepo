local _, SP = ...

---@type Settings
local Settings = SP.Settings

---@class Commands
---@field dispatch fun(self: Commands, string: string)
SP.Commands = SP.Commands or {
    CommandDescriptions = {
        settings = "Open the settings menu"
    },
    Dictionnary = {
        -- Open the locale selector
        locale = function(...)
            SP.Interface.Locale:open()
        end,

        -- Open the settings menu
        settings = function(...)
            Settings:draw()
        end
    }
}

---@type Commands
local Commands = SP.Commands

---Dispatch slash commands to their destination
---@param commandString string
---@return any
function Commands:dispatch(commandString)
    local command = commandString:match("^(%S+)");
    local argumentString = "";

    if (command) then
        argumentString = strsub(commandString, strlen(command) + 2)
    end

    -- If nothing after "/sleepo" or "/sp" then open localization or settings window
    if (not commandString or #commandString < 1) then
        command = SP.Settings:get("chatLocale") and "settings" or "locale";
    end

    -- Make sure commands are case insensitive
    command = string.lower(command);

    -- Some commands allow itemlinks, some don't. Items can contain spaces
    -- at which point we need to make sure the item itself isn't split up.
    -- We do that by specifying the number of (expected) arguments per command
    local arguments = {};
    local numberOfArguments;

    if (SP:inTable({"rolloff", "auction"}, command)) then
        numberOfArguments = 1;
    elseif (SP:inTable({"award"}, command)) then
        numberOfArguments = 2;
    elseif (SP:inTable({"awardondate"}, command)) then
        numberOfArguments = 3;
    end

    arguments = {strsplit(" ", argumentString, numberOfArguments)}

    if command and self.Dictionnary[command] and type(self.Dictionnary[command]) == "function" then
        return self.Dictionnary[command](unpack(arguments))
    end
end

