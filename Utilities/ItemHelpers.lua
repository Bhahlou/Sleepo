local L = Sleepo_L

---@type SP
local _, SP = ...

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
