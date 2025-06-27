local L = Sleepo_L

---@type SP
local _, SP = ...

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
