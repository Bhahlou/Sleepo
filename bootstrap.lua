---@class SP
---@field Data Data
local SP

---@type string
local appName
appName, SP = ...

_G.Sleepo = SP
_G.Sleepo_L = {}

setmetatable(_G.Sleepo_L, {
    __index = function(_, key)
        return tostring(key)
    end
})

local GetAddOnMetadata = C_AddOns or C_AddOns.GetAddOnMetadata or GetAddOnMetadata;

SP.name = appName
SP.initialized = false;
SP.firstBoot = false;
SP.version = C_AddOns.GetAddOnMetadata(SP.name, "Version")
SP.loadedOn = 32503680000
SP.MRTLoaded = false

function SP:bootstrap(_, _, addOnName)

    -- The addon was already bootstrapped or this is not the correct event
    if (self.initialized) then
        return;
    end

    -- We only want to continue bootstrapping when it's this addon that's successfully loaded
    if (addOnName ~= self.name) then
        return;
    end

    -- The addon was loaded, we no longer need the event listener now
    self.EventFrame:UnregisterEvent("ADDON_LOADED");

    -- Initialize our classes / services
    self:initialize()
    self.initialized = true

    -- Add the minimap icon
    --

    -- Mark the add-on as fully loaded
    SP.loadedOn = GetServerTime()

    -- Initialize dependencies
    SP:after(1, nil, function()
        -- Check if MRT is loaded (for further MRT notes import)
        self.MRTLoaded = C_AddOns.IsAddOnLoaded("MRT")
    end)
end

function SP:initialize()
    self.Events:initialize(self.EventFrame);
    self.DB:initialize();
    self.Version:initialize();
    self.Settings:initialize();

    local L = Sleepo_L
    local langMatch = false;
    local chatLocale = SP.Settings:get("chatLocale")

    if chatLocale then
        for lang, translations in pairs(L.CHAT or {}) do
            if lang == chatLocale then
                L.CHAT = translations
                langMatch = true
                break
            end
        end
    end

    if not chatLocale or not langMatch then
        L.CHAT = {}
    end

    -- Make sure enUS fallbacks are available
    setmetatable(L.CHAT, {
        __index = function(_, key)
            return tostring(key)
        end
    });

    SP.Settings:onChange("chatLocale", function()
        if (SP.Settings:get("chatLocale") ~= chatLocale) then
            C_UI.Reload();
        end
    end);

    if self.Settings:get("welcomeMessage") then
        print((L["|c00%sSleepo Manager v%s by Bhahlou@Auberdine. Type |c00%s/sleepo to get started!"]):format(self.Data
                                                                                                                  .Constants
                                                                                                                  .addonHexColor,
            self.version, self.Data.Constants.addonHexColor, self.Data.Constants.addonHexColor))
    end

    self.Media:initialize();

end

SP.Ace = LibStub("AceAddon-3.0"):NewAddon(SP.name, "AceConsole-3.0", "AceComm-3.0", "AceTimer-3.0");

SP.Ace:RegisterChatCommand("sp", function(...)
    SP.Commands:dispatch(...);
end)

SP.Ace:RegisterChatCommand("sleepo", function(...)
    SP.Commands:dispatch(...);
end)

SP.EventFrame = CreateFrame("FRAME", "SleepoEventFrame");
SP.EventFrame:RegisterEvent("ADDON_LOADED");
SP.EventFrame:SetScript("OnEvent", function(...)
    SP:bootstrap(...);
end)

SP.TooltipFrame = CreateFrame("GameTooltip", "SleepoTooltipFrame", nil, "GameTooltipTemplate");
SP.TooltipFrame:SetOwner(WorldFrame, "ANCHOR_NONE")
