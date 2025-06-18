---@type SP
local _, SP = ...

---@type Events
local Events = SP.Events

---@class DB
local DB = {
    initialized = false,
    Tables = {"Settings", "LoadDetails"}
}

---@type DB
SP.DB = DB

function DB:initialize()
    if (self.initialized) then
        return;
    end

    if (not SleepoDB or not type(SleepoDB) == "table") then
        SleepoDB = {}
    end

    -- Prepare our saved variables and add a shortcut to each table
    for _, identifier in pairs(self.Tables or {}) do
        SleepoDB[identifier] = SleepoDB[identifier] or {};
        self[identifier] = SleepoDB[identifier];
    end

    -- Fire store before every logout/reload/exit
    Events:register("LogoutListerner", "PLAYER_LOGOUT", function()
        self:store()
    end)

    self.initialized = true;
end

--- Ensure database persists between sessions
function DB:store()
    for _, identifier in pairs(self.Tables or {}) do
        SleepoDB[identifier] = self[identifier]
    end
end

--- Return value from db or default
---@param keyString string
---@param default any
function DB:get(keyString, default)
    return SP:tableGet(self, keyString, default)
end

---@param keyString string
---@param value any
---@param ignoreIfExists ?boolean If the given final key exists then it will not be overwritten
---@return boolean
function DB:set(keyString, value, ignoreIfExists)
    return SP:tableSet(self, keyString, value, ignoreIfExists);
end

