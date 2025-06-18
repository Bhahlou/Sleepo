local L = Sleepo_L

---@type SP
local _, SP = ...

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

---@param Table table
---@return table
function SP:tableValues(Table)
    local Values = {};
    for _, value in pairs(Table or {}) do
        tinsert(Values, value);
    end

    return Values;
end
