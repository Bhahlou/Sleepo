local L = Sleepo_L;

---@type SP
local _, SP = ...

---@type DB
local DB = SP.DB

---@type Events
local Events = SP.Events

---@class Settings
local Settings = {
    ---@type boolean
    initialized = false,

    ---@type table
    ActiveSettings = {},

    ---@type table
    Defaults = SP.Data.DefaultSettings
}
SP.Settings = Settings

function Settings:initialize()
    if self.initialized then
        return
    end

    -- Clear old settings and adjust discrepancies
    self:sanitize()

    -- Combine defaults and user settings
    self:overrideDefaultsWithUserSettings()

    local Frame = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
    Frame.name = L["Sleepo"]
    Frame:SetScript("OnShow", function()
        print("showSettingsMenu")
        -- self:showSettingsMenu(Frame)
    end)

    if (InterfaceOptions_AddCategory) then
        InterfaceOptions_AddCategory(Frame)
    else
        Category = _G.Settings.RegisterCanvasLayoutCategory(Frame, L["Sleepo"]);
        _G.Settings.RegisterAddOnCategory(Category);
    end

    self.initialized = true;
end

--- Make sure the settings adhere to our rules
function Settings:sanitize()
    self:enforceTempSettings()
end

-- These settings are version specific and will be removed over time
function Settings:enforceTempSettings()
    if SP.firstBoot or not SP.Version.firstBoot then
        return
    end
end

-- Override the addon's default settings with the user's custom settings
function Settings:overrideDefaultsWithUserSettings()
    self.ActiveSettings = {}

    -- Combine the default and user's settings ot one settings table
    Settings = SP:tableMerge(Settings.Defaults, DB:get("Settings"));

    -- Set the values of the settings table directly on the SP.Settings table
    for key, value in pairs(Settings) do
        self.ActiveSettings[key] = value
    end

    DB:set("Settings", self.ActiveSettings)
end

--- Get a setting by a given key. Use dot notation to traverse multiple levels e.g:
--- Settings.UI.Auctioneer.offsetX can be fetched using Settings:get("Settings.UI.Auctioneer.offsetX")
--- without having to worry about tables or keys existing yes or no.
---@param keyString string
---@param default any
---@return any
function Settings:get(keyString, default)
    -- Just in case something went wrong with merging the default settings
    if (type(default) == "nil") then
        default = SP:tableGet(SP.Data.DefaultSettings, keyString);
    end

    return SP:tableGet(self.ActiveSettings, keyString, default);
end

---@param setting string
---@param func function
function Settings:onChange(setting, func)
    Events:register(nil, "SP.SETTING_CHANGED." .. setting, func);
end

--- Set a setting by a given key and value. Use dot notation to traverse multiple levels e.g:
--- Settings.UI.Auctioneer.offsetX can be set using Settings:set("Settings.UI.Auctioneer.offsetX", myValue)
--- without having to worry about tables or keys existing yes or no.
---@param keyString string
---@param value any
---@param quiet? boolean Should trigger event?
---@return boolean
function Settings:set(keyString, value, quiet)
    local success = SP:tableSet(self.ActiveSettings, keyString, value);

    if (success and not quiet) then
        SP.Events:fire("SP.SETTING_CHANGED." .. keyString, value);
        SP.Events:fire("SP.SETTING_CHANGED", keyString, value);
    end

    return success
end

--- Draw a setting section
---@param section string|nil
---@param onCloseCallback function|nil What to do after closing the settings again
function Settings:draw(section, onCloseCallback)
    SP.Interface.Settings.Overview:draw(section, onCloseCallback);
end

function Settings:close()
    SP.Interface.Settings.Overview:close();
end

