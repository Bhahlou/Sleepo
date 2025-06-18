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

    -- local OpenSoftRes = AceGUI:Create("Button");
    -- OpenSoftRes:SetText("SoftRes");
    -- OpenSoftRes:SetCallback("OnClick", function()
    --     SP.Settings:close();
    --     SP.Commands:call("softreserves");
    -- end);
    -- OpenSoftRes:SetWidth(120);
    -- Parent:AddChild(OpenSoftRes);

    -- local OpenTMB = AceGUI:Create("Button");
    -- OpenTMB:SetText("TMB / DFT");
    -- OpenTMB:SetCallback("OnClick", function()
    --     SP.Settings:close();
    --     SP.Commands:call("tmb");
    -- end);
    -- OpenTMB:SetWidth(120);
    -- Parent:AddChild(OpenTMB);

    -- if (SP.GDKPIsAllowed) then
    --     local OpenGDKP = SP.AceGUI:Create("Button");
    --     OpenGDKP:SetText("GDKP");
    --     OpenGDKP:SetCallback("OnClick", function()
    --         SP.Settings:close();
    --         SP.Commands:call("gdkp");
    --     end);
    --     OpenGDKP:SetWidth(120);
    --     Parent:AddChild(OpenGDKP);
    -- end

    -- local OpenPackMule = AceGUI:Create("Button");
    -- OpenPackMule:SetText("Autolooting");
    -- OpenPackMule:SetCallback("OnClick", function()
    --     SP.Settings:draw("PackMule");
    -- end);
    -- OpenPackMule:SetWidth(120);
    -- Parent:AddChild(OpenPackMule);

    -- local OpenBonusFeatures = AceGUI:Create("Button");
    -- OpenBonusFeatures:SetText("Bonus Features");
    -- OpenBonusFeatures:SetCallback("OnClick", function()
    --     SP.Settings:close();
    --     SP.Interface.BonusFeatures:open();
    -- end);
    -- OpenBonusFeatures:SetFullWidth(true);
    -- Parent:AddChild(OpenBonusFeatures);

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

    local DiscordURL = AceGUI:Create("EditBox");
    DiscordURL:DisableButton(true);
    DiscordURL:SetHeight(20);
    DiscordURL:SetFullWidth(true);
    DiscordURL:SetText("wiki link to come");
    Parent:AddChild(DiscordURL);
end
