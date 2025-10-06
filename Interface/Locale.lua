local L = Sleepo_L

---@type SP
local _, SP = ...;

---@type Interface
local Interface = SP.Interface

---@type Settings
local Settings = SP.Settings

---@class LocaleInterface
---@field open fun(self: LocaleInterface, forwardToSettings: boolean): table
---@field close fun(self: LocaleInterface): nil
---@field build fun(self: LocaleInterface): table
SP.Interface.Locale = {
    forwardToSettings = false,
    isVisible = false,
    windowName = "Sleepo.Interface.Locale.Window"
}

---@type LocaleInterface
local Locale = SP.Interface.Locale

---Open the locale Window
---@param forwardToSettings boolean
---@return table
function Locale:open(forwardToSettings)
    self.forwardToSettings = forwardToSettings ~= nil
    self.isVisible = true

    local Window = _G[self.windowName] or self:build()

    Window:Show()
    return Window
end

--- Close the locale Window
--- @return nil
function Locale:close()
    self.isVisible = false;
    return _G[self.windowName] and _G[self.windowName]:Hide()
end

--- Build the Locale Window
--- @return table
function Locale:build()
    if (_G[self.windowName]) then
        return _G[self.windowName];
    end

    ---@type Frame
    local Window = Interface:createWindow({
        name = self.windowName,
        width = 375,
        height = 240,
        hideMinimizeButton = true,
        hideResizeButton = true
    });

    Window:ClearAllPoints();
    Window:SetPoint("CENTER", UIParent, "CENTER");

    ---@type FontString
    local Title = Interface:createFontString(Window, ("|c00%s%s|r"):format(SP.Data.Constants.addonHexColor,
        L["Choose a chat language for Sleepo"]));
    Title:SetPoint("TOPLEFT", Window, "TOPLEFT", 20, -30);
    Title:SetPoint("TOPRIGHT", Window, "TOPRIGHT", -20, 0);
    Title:SetJustifyH("CENTER");

    ---@type FontString
    local Intro = Interface:createFontString(Window,
        (L["\nSleepo will post chat messages in English by default\nYou can select a different language in the dropdown below\n\nYour current chat language is '%s'.\nEnabling a different language will cause a /reload!\n"]):format(
            ("|c00%s%s|r"):format(SP.Data.Constants.addonHexColor, SP.Settings:get("chatLocale", "enUS"))));
    Intro:SetPoint("TOP", Title, "BOTTOM", 0, -6);
    Intro:SetPoint("LEFT", Window, "LEFT", 20, -30);
    Intro:SetPoint("RIGHT", Window, "RIGHT", -20, 0);
    Intro:SetJustifyH("CENTER");

    ---@type Frame
    local Locales = Interface:createDropdown({
        Parent = Window,
        Options = {
            enUS = L["enUS"], -- English (United States)
            frFR = L["frFR"] -- French (France)
        },
        value = Settings:get("chatLocale", "enUS")
    });

    Locales:SetPoint("TOP", Intro, "BOTTOM", 0, -16);
    Locales:SetPoint("CENTER", Window, "CENTER");

    ---@type FontString
    local Note = Interface:createFontString(Window,
        (L["Note: you can change the locale at any time in the settings or via |c00%s/sleepo locale"]):format(
            SP.Data.Constants.addonHexColor));
    Note:SetPoint("TOP", Locales, "BOTTOM", 0, -6);
    Note:SetPoint("LEFT", Window, "LEFT", 20, -30);
    Note:SetPoint("RIGHT", Window, "RIGHT", -20, 0);
    Note:SetJustifyH("CENTER");

    local OkButton = Interface:dynamicPanelButton(Window, L["Ok"]);
    OkButton:SetPoint("BOTTOMLEFT", Window, "BOTTOMLEFT", 20, 30);
    OkButton:SetScript("OnClick", function()
        Settings:set("chatLocale", Locales:GetValue() or "enUS");
        self:close();

        if (self.forwardToSettings) then
            self.forwardToSettings = false;
            SP.Settings:draw();
        end
    end);

    local CancelButton = Interface:dynamicPanelButton(Window, L["Cancel"]);
    CancelButton:SetPoint("TOPLEFT", OkButton, "TOPRIGHT", 2, 0);
    CancelButton:SetScript("OnClick", function()
        self:close();
    end);

    _G[self.windowName] = Window;
    return Window;
end
