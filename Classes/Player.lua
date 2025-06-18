local _, SP = ...;

---@class Player
---@field cacheClass fun(self: Player, playerName: string, class: string)
SP.Player = {
    playerClassByName = {}
}
SP.Player.__index = SP.Player

---@type Player
local Player = SP.Player

setmetatable(Player, {
    __call = function(cls, ...)
        return cls.new(...)
    end
})

--- Cache a player's class
---@param playerName string
---@param class string
---@return nil
function Player:cacheClass(playerName, class)
    if type(class) ~= "string" then
        return
    end

    class = string.lower(class)

    if (SP:empty(class)) then
        return;
    end

    self.playerClassByName[string.lower(playerName)] = class
end
