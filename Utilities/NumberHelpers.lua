local L = Sleepo_L

---@type SP
local _, SP = ...

--- Check whether a given variable is a number that's higher than zero
---
---@param numericValue number
---@return boolean
function SP:higherThanZero(numericValue)
    return type(numericValue) == "number" and numericValue > 0
end

---@param var number
---@param precision? number
---@return number
function SP:round(var, precision)
    var = tonumber(var);

    if (not var) then
        return 0;
    end

    if (precision and precision > 0) then
        local mult = 10 ^ precision;
        return math.floor(var * mult + .5) / mult;
    end

    return math.floor(var + .5);
end
