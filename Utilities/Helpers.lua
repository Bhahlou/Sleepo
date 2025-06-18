local L = Sleepo_L

---@type SP
local _, SP = ...

--- Check whether the variable is empty
---@param variable any
---@return boolean
function SP:empty(variable)
    variable = variable or false

    ---@type string
    local varType = type(variable)

    if varType == "boolean" then
        return not variable
    end

    if varType == "string" then
        return strtrim(variable) == ""
    end

    if varType == "table" then
        for _, val in pairs(variable) do
            if (val ~= nil) then
                return false
            end
        end

        return true
    end

    if varType == "number" then
        return variable == 0
    end

    if varType == "function" or varType == "CFunction" or varType == "userdata" then
        return false
    end

    return true
end

--- Check whether the provided string starts with a given substring
---@param str string
---@param startStr string
---@param insensitive boolean
---@return boolean
function SP:strStartsWith(str, startStr, insensitive)
    str = tostring(str);
    startStr = tostring(startStr);

    if (insensitive ~= false) then
        str = strlower(str);
        startStr = strlower(startStr);
    end

    return string.sub(str, 1, string.len(startStr)) == startStr;
end

--- Generate a random uuid
--- @return string
function SP:uuid()
    local random = math.random
    local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"

    return (string.gsub(template, "[xy]", function(c)
        local v = (c == "x") and random(0, 0xf) or random(8, 0xb)
        return string.format("%x", v)
    end))
end

--- Split a string by a given delimiter
--- WoWLua already has a strsplit function, but it returns multiple arguments instead of a table
---@param string string
---@param delimiter string
---@return table
function SP:explode(string, delimiter)
    local Result = {};

    -- No delimiter is provided, split all characters
    if (not delimiter) then
        _ = string:gsub(".", function(character)
            table.insert(Result, character);
        end);
        return Result;
    end

    for match in (string .. delimiter):gmatch("(.-)%" .. delimiter) do
        tinsert(Result, strtrim(match));
    end

    return Result;
end

--- Overwrite/Compliment the original table (left) with the values from the right table
---@param left table
---@param right table
---@return table
function SP:tableMerge(left, right)
    if type(left) ~= "table" or type(right) ~= "table" then
        return {}
    end

    for key, value in pairs(right) do
        if type(value) == "table" then
            if type(left[key] or false) == "table" then
                self:tableMerge(left[key] or {}, right[key] or {})
            else
                left[key] = value
            end
        else
            left[key] = value
        end
    end

    return left
end

--- Get a table value by a given key. Use dot notation to traverse multiple levels e.g:
--- Settings.UI.Auctioneer.offsetX can be fetched using SP:tableGet(myTable, "Settings.UI.Auctioneer.offsetX", 0)
--- without having to worry about tables or keys existing along the way.
--- This helper is absolutely invaluable for writing error-free code!
---
---@param Table table
---@param keyString string
---@param default any
---@return any
function SP:tableGet(Table, keyString, default)
    if (type(keyString) ~= "string" or self:empty(keyString)) then
        return default;
    end

    local keys = SP:explode(keyString, ".");
    local numberOfKeys = #keys;
    local firstKey = keys[1];

    if (not numberOfKeys or not firstKey) then
        return default;
    end

    if (type(Table) == "table") then
        if (type(Table[firstKey]) == "nil") then
            firstKey = tonumber(firstKey);

            -- Make sure we're not looking for a numeric key instead of a string
            if (not firstKey or type(Table[firstKey]) == "nil") then
                return default;
            end
        end

        Table = Table[firstKey];
    else
        return Table or default;
    end

    -- Changed if (#keys == 1) then to below, saved this just in case we get weird behavior
    if (numberOfKeys == 1) then
        default = nil;
        return Table;
    end

    tremove(keys, 1);
    return self:tableGet(Table, strjoin(".", unpack(keys)), default);
end

--- Set a table value by a given key and value. Use dot notation to traverse multiple levels e.g:
--- Settings.UI.Auctioneer.offsetX can be set using SP:tableSet(myTable, "Settings.UI.Auctioneer.offsetX", myValue)
--- without having to worry about tables or keys existing along the way.
---
---@param Table table
---@param keyString string
---@param value any
---@param ignoreIfExists ?boolean If the given final key exists then it will not be overwritten
---@return boolean
function SP:tableSet(Table, keyString, value, ignoreIfExists)
    if (not keyString or type(keyString) ~= "string" or keyString == "") then
        SP:warning("Invalid key provided in GL:tableSet");
        return false;
    end

    ignoreIfExists = SP:toboolean(ignoreIfExists);
    local keys = SP:explode(keyString, ".");
    local firstKey = keys[1];

    if (#keys == 1) then
        if (Table[firstKey] ~= nil or not ignoreIfExists) then
            Table[firstKey] = value;
        end

        return true;
    elseif (not Table[firstKey]) then
        Table[firstKey] = {};
    end

    tremove(keys, 1);

    Table = Table[firstKey];
    return self:tableSet(Table, strjoin(".", unpack(keys)), value);
end

--- Print a warning message (orange)
---
---@return nil
function SP:warning(...)
    SP:coloredMessage("F7922E", ...);
end

--- Print a colored message
---
---@param color string
---@vararg string
---@return nil
function SP:coloredMessage(color, ...)
    SP:message(string.format("|c00%s%s", color, string.join(" ", ...)));
end

--- Print a normal message (white)
---
---@vararg string
---@return nil
function SP:message(...)
    print("|TInterface/TARGETINGFRAME/UI-RaidTargetingIcon_3:12|t|cff8aecff Sleepo : |r" .. table.concat({...}, " "));
end

--- LUA supports tostring, tonumber etc but no toboolean, let's fix that!
---@param var any
---@return boolean
function SP:toboolean(var)
    return not SP:empty(var);
end

--- Add the realm name to a player name
---
---@param name string
---@param realm string
---@return string, string?
function SP:addRealm(name, realm, fromGroup)
    realm = not self:empty(realm) and realm or nil;
    fromGroup = fromGroup ~= false;
    name = tostring(name);

    if (self:empty(name)) then
        return "";
    end

    local separator = name:match("-");

    -- A realm separator was found, return the original message
    if (separator) then
        return name;
    end

    -- Fetch the realm name from a group member if possible
    if (fromGroup and not realm and SP.User:unitInGroup(name)) then
        if (SP:nameIsUnique(name)) then
            local playerId = UnitGUID(name);

            if (playerId) then
                realm = select(7, GetPlayerInfoByGUID(playerId));

                -- Realm can be an empty string on same-realm players
                realm = realm ~= "" and realm or SP.User.realm;
            end
        end
    end

    realm = realm or SP.User.realm;
    return ("%s-%s"):format(name, realm), realm;
end

--- Check whether the given player name occurs more than once in the player's group
--- (only possible in case of cross-realm support)
---
---@param playerName string
---@return boolean
function SP:nameIsUnique(playerName)
    playerName = self:stripRealm(playerName);
    local nameEncountered = false;
    for _, groupMemberName in pairs(SP.User:groupMemberNames()) do
        if (self:iEquals(playerName, groupMemberName)) then
            -- We already encountered this name before, NOT UNIQUE!
            if (nameEncountered) then
                return false;
            end

            nameEncountered = true;
        end
    end

    return true;
end

--- Strip the realm off of a player name
---
---@param playerName string
---@return string, string?
function SP:stripRealm(playerName)
    playerName = tostring(playerName);

    if (self:empty(playerName)) then
        return "";
    end

    local separator = playerName:match("-");

    -- No realm separator was found, return the original message
    if (not separator) then
        return playerName;
    end

    local Parts = self:explode(playerName, separator);
    return Parts[1], Parts[2];
end

--- Check whether a given value exists within a table
---
---@param array table
---@param value any
function SP:inTable(array, value)
    if (type(value) == "string") then
        value = strtrim(string.lower(value));
    end

    for _, val in pairs(array) do
        if (type(val) == "string") then
            val = strtrim(string.lower(val));
        end

        if value == val then
            return true
        end
    end

    return false
end

--- Print a error message (red)
---
---@return nil
function SP:error(...)
    SP:coloredMessage("BE3333", ...);
end

--- Return an item's ID from an item link, false if invalid itemlink is provided
---
---@param itemLink string
---@return number|boolean
function SP:getItemIDFromLink(itemLink)
    if (not itemLink or type(itemLink) ~= "string" or itemLink == "") then
        return false;
    end

    local itemID = string.match(itemLink, "Hitem:(%d+):");
    itemID = tonumber(itemID);

    if (not itemID) then
        return false;
    end

    return itemID;
end

--- Check whether a given variable is a number that's higher than zero
---
---@param numericValue number
---@return boolean
function SP:higherThanZero(numericValue)
    return type(numericValue) == "number" and numericValue > 0
end

local fontSize;
--- rem stands for “root em”, a unit of measurement that represents the font size of the root element
--- In our case that equals GL.Settings:get("fontSize") which defaults to 11
---
--- This means that rem(1) returns the default font size, whereas rem(.75) returns 8
---
---@param scale number
---@return number
function SP:rem(scale)
    scale = scale or 1;
    fontSize = fontSize or SP.Settings:get("fontSize");

    return scale == 1 and fontSize or self:round(fontSize * scale);
end

---@param var number
---@param precision? number
---@return number
function SP:round(var, precision)
    var = tonumber(var);

    if (not var) then
        return 0;
    end

    if (precision and precision > 0) then
        local mult = 10 ^ precision;
        return math.floor(var * mult + .5) / mult;
    end

    return math.floor(var + .5);
end

---@param Table table
---@return table
function SP:tableValues(Table)
    local Values = {};
    for _, value in pairs(Table or {}) do
        tinsert(Values, value);
    end

    return Values;
end

--- In some very rare cases we need to manipulate the close button on AceGUI elements
---
---@param Widget table
---@return table?
function SP:fetchCloseButtonFromAceGUIWidget(Widget)
    SP:debug("SP:fetchCloseButtonFromAceGUIWidget");

    if (not Widget or not Widget.frame) then
        return;
    end

    -- Try to locate the Close button and hide it
    for _, Child in pairs({Widget.frame:GetChildren()}) do
        if (Child.GetText and Child:GetText() == CLOSE) then
            return Child;
        end
    end
end

--- Print a debug message (orange)
---
---@return nil
function SP:debug(...)
    if (not SP.Settings or not SP.Settings.Active or SP.Settings.Active.debugModeEnabled ~= true) then
        return;
    end

    SP:coloredMessage("F7922E", ...);
end

SP.Timers = {};
---@param seconds number
---@param identifier string
---@param func function
---@param cancel boolean Cancel any running existing timer with using the same identifier
---@return table
function SP:after(seconds, identifier, func, cancel)
    identifier = identifier or GetTime() .. SP:uuid();
    SP:debug("Schedule " .. identifier);

    cancel = cancel ~= false;
    SP:cancelTimer(identifier);

    SP.Timers[identifier] = SP.Ace:ScheduleTimer(function()
        SP:debug("Run once " .. identifier);

        func();
    end, seconds);
    return SP.Timers[identifier];
end

---@param identifier string
function SP:cancelTimer(identifier)
    if (not SP.Timers[identifier]) then
        return;
    end

    SP:debug("Cancelling " .. identifier);
    SP.Ace:CancelTimer(SP.Timers[identifier]);
end

--- Check whether the string is a JSON object
---@param text string
---@return boolean
function SP:isJson(text)
    if string.sub(text, 1, 1) == "{" and string.sub(text, -1, -1) == "}" then
        return true
    else
        return false
    end
end
