local L = Sleepo_L

---@type SP
local _, SP = ...

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
