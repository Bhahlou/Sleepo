local L = Sleepo_L

---@type SP
local _, SP = ...

--- Print a normal message (white)
---
---@vararg string
---@return nil
function SP:message(...)
    print("|TInterface/TARGETINGFRAME/UI-RaidTargetingIcon_3:12|t|cff8aecff Sleepo : |r" .. table.concat({...}, " "));
end

--- Print a colored message
---
---@param color string
---@vararg string
---@return nil
function SP:coloredMessage(color, ...)
    SP:message(string.format("|c00%s%s", color, string.join(" ", ...)));
end
--- Print a warning message (orange)
---
---@return nil
function SP:warning(...)
    SP:coloredMessage("F7922E", ...);
end

--- Print a error message (red)
---
---@return nil
function SP:error(...)
    SP:coloredMessage("BE3333", ...);
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
