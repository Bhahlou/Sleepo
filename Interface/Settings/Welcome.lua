---@type SP
local _, SP = ...;

---@type Data
local Constants = SP.Data.Constants;

local AceGUI = SP.AceGUI or LibStub("AceGUI-3.0");

---@class WelcomeSettings
---@field draw fun(self: WelcomeSettings, parent: SimpleWindow)
SP.Interface.Settings.Welcome = {
    description = "Welcome on Sleepo addon! On the left menu, you'll find various features that will help you to ease your raiding life!"
};
---@type WelcomeSettings
local Welcome = SP.Interface.Settings.Welcome;

---@return nil
function Welcome:draw(Parent)
    SP:AddHorizontalSpacer(Parent, true, 10)
    SP:AddLabel(Parent, "Can't find something? Have a look on our Wiki!\n", _G["GameFontNormal"], true)
    SP:AddEditBox(Parent, true, 20, true, "https://github.com/Bhahlou/Sleepo/wiki")
end
