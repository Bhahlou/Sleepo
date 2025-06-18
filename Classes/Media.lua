---@type SP
local _, SP = ...

---@class Media
---@field initialized boolean
---@field initialize fun(self: Media)
---@field registerSounds fun(self: Media, LSM: table)
---@field registerFonts fun(self:Media, LSM: table)
SP.Media = {
    initialized = false
};

---@type Media
local Media = SP.Media

function Media:initialize()
    if (self.initialized) then
        return;
    end

    local LSM = LibStub("LibSharedMedia-3.0");
    self:registerSounds(LSM);
    self:registerFonts(LSM);

    self.initialized = true;
end

--- Register sounds
---@param LSM table
function Media:registerSounds(LSM)
    LSM:Register("sound", "Sleepo: Feast", [[Interface\Addons\Sleepo\Assets\Sounds\Feast.ogg]])
    LSM:Register("sound", "Sleepo: Cauldron", [[Interface\Addons\Sleepo\Assets\Sounds\Cauldron.ogg]])
    LSM:Register("sound", "Sleepo: Repair", [[Interface\Addons\Sleepo\Assets\Sounds\Repair.ogg]])
    LSM:Register("sound", "Sleepo: Soulwell", [[Interface\Addons\Sleepo\Assets\Sounds\Soulwell.ogg]])
    LSM:Register("sound", "Sleepo: Summon", [[Interface\Addons\Sleepo\Assets\Sounds\Summon.ogg]])
    LSM:Register("sound", "Sleepo: Table", [[Interface\Addons\Sleepo\Assets\Sounds\Table.ogg]])
end

--- Register fonts
---@param LSM table
function Media:registerFonts(LSM)
    LSM:Register("font", "SFUIDisplayCondensed-Semibold",
        "Interface/Addons/Sleepo/Assets/Fonts/SFUIDisplayCondensed-Semibold.otf")
    SP.FONT = LSM:Fetch("font", "SFUIDisplayCondensed-Semibold")
end
