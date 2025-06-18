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

--- LUA supports tostring, tonumber etc but no toboolean, let's fix that!
---@param var any
---@return boolean
function SP:toboolean(var)
    return not SP:empty(var);
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
