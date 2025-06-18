---@type SP
local _, SP = ...

---@class Events
local Events = {
    ---@type boolean
    initialized = false,

    ---@type Frame
    Frame = nil,

    ---@type table
    Registry = {
        ---@type table
        EventListeners = {},

        ---@type table
        EventByIdentifier = {}
    }
}

---@type Events
SP.Events = Events

--- Prepare event Frame for future use
---@param eventFrame Frame
function Events:initialize(eventFrame)
    if self.initialized then
        return;
    end

    self.initialized = true;

    self.Frame = eventFrame;
    self.Frame:SetScript("OnEvent", self.listen)
end

--- Register an event listener
---@param identifier? string|table
---@param event string|function
---@param callback? function
---@return boolean
function Events:register(identifier, event, callback)
    if type(identifier) == "table" then
        return self:massRegister(identifier, event)
    end

    if (identifier == nil) then
        identifier = event .. "Listener" .. SP:uuid()
    end

    if SP:empty(event) or type(callback) ~= "function" then
        return false
    end

    if SP:empty(self.Registry.EventListeners[event]) then
        if not SP:strStartsWith(event, "SP.") then
            self.Frame:RegisterEvent(event)
        end

        self.Registry.EventListeners[event] = {}
    end

    identifier = identifier or string.format("%s.%s.%s", event, GetTime(), SP:uuid());

    self.Registry.EventByIdentifier[identifier] = event
    self.Registry.EventListeners[event][identifier] = callback

    return true
end

--- Fire the vent listeners whenever a registerd event comes in
---@param event string
---@param ... any
function Events:listen(event, ...)
    local args = {...}

    for _, listener in pairs(SP.Events.Registry.EventListeners[event] or {}) do
        pcall(function()
            listener(event, unpack(args))
        end)
    end
end

--- Register multiple event listeners
---@param events table
---@param callback function
---@return boolean
function Events:massRegister(events, callback)
    for _, entry in pairs(events) do
        local identifier, event

        if type(entry) == "table" then
            identifier = entry[1]
            event = entry[2]
        elseif type(entry) == "string" then
            event = entry
        else
            return false
        end

        self:register(identifier, event, callback)
    end

    return true
end

--- Fire an event manually (assuming ther's a listener for it)
--- 
---@param event string
---@param ... any
function Events:fire(event, ...)
    self:listen(event, ...)
end
