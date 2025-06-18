local L = Sleepo_L

---@type SP
local _, SP = ...

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
