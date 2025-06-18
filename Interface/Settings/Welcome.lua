---@type SP
local _, SP = ...;

---@type Data
local Constants = SP.Data.Constants;

local AceGUI = SP.AceGUI or LibStub("AceGUI-3.0");

---@class WelcomeSettings
SP.Interface.Settings.Welcome = {
    description = "\n Welcome on Sleepo addon! On the left menu, you'll find various features that will help you to ease your raiding life!"
};
---@type WelcomeSettings
local Welcome = SP.Interface.Settings.Welcome;

---@return nil
function Welcome:draw(Parent)
    local HorizontalSpacer;

    HorizontalSpacer = AceGUI:Create("SimpleGroup");
    HorizontalSpacer:SetLayout("FILL");
    HorizontalSpacer:SetFullWidth(true);
    HorizontalSpacer:SetHeight(10);
    Parent:AddChild(HorizontalSpacer);

    local MoreInfoLabel = AceGUI:Create("Label");
    MoreInfoLabel:SetText("Can't find something? Have a look on our Wiki!\n");
    MoreInfoLabel:SetFontObject(_G["GameFontNormal"]);
    MoreInfoLabel:SetFullWidth(true);
    Parent:AddChild(MoreInfoLabel);

    local WikiURL = AceGUI:Create("EditBox");
    WikiURL:DisableButton(true);
    WikiURL:SetHeight(20);
    WikiURL:SetFullWidth(true);
    WikiURL:SetText("https://github.com/Bhahlou/Sleepo/wiki");
    Parent:AddChild(WikiURL);
end
