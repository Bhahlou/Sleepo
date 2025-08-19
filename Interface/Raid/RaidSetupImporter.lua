local L = Sleepo_L

---@type SP
local _, SP = ...

---@class RaidSetupImporter
---@field Draw fun(self: RaidSetupImporter)
---@field Close fun(self: RaidSetupImporter)
---@field ParseJSON fun(self: RaidSetupImporter, text:string, frame: SimpleWindow )
SP.Interface.RaidSetupImporter = {
    isVisible = false,
    textStore = ""
}

local VMRT = VMRT

SP.AceGUI = SP.AceGUI or LibStub("AceGUI-3.0");
local JSON = LibStub("LibJSON-1.0")

---@type RaidSetupImporter
local RaidSetupImporter = SP.Interface.RaidSetupImporter

--- Draw the import window
function RaidSetupImporter:Draw()
    SP:debug("RaidSetupImporter:draw")

    if not SP.MRTLoaded then
        SP:error("You must load MRT Addon to use MRT Note importer")
    end
    if self.isVisible then
        return
    end

    local Window = SP:CreateWindow((L["Sleepo v%s"]):format(SP.version) .. " - Raid Setup Importer", "Flow", 500, 550,
        false, function()
            self:Close();
        end)

    SP.Interface:set(self, "Window", Window);
    Window:SetPoint(SP.Interface:getPosition("RaidSetupImporter"));

    _G["SLEEPO_RAID_SETUP_IMPORTER"] = Window.frame;
    tinsert(UISpecialFrames, "SLEEPO_RAID_SETUP_IMPORTER");

    ---@type AceGUISimpleGroup
    local VerticalSpacer = SP.AceGUI:Create("SimpleGroup");
    VerticalSpacer:SetLayout("Fill");
    VerticalSpacer:SetFullWidth(true);
    VerticalSpacer:SetHeight(6);
    Window:AddChild(VerticalSpacer);

    ---@type AceGUIEditBox
    local WikiURL = SP.AceGUI:Create("EditBox");
    WikiURL:SetLabel(L["Check the Wiki to learn using Raid Setup Importer"])
    WikiURL:DisableButton(true);
    WikiURL:SetHeight(40);
    WikiURL:SetFullWidth(true);
    WikiURL:SetText("https://github.com/Bhahlou/Sleepo/wiki/Raid-Setup-Importer");
    Window:AddChild(WikiURL);

    ---@type AceGUISimpleGroup
    VerticalSpacer = SP.AceGUI:Create("SimpleGroup");
    VerticalSpacer:SetLayout("Fill");
    VerticalSpacer:SetFullWidth(true);
    VerticalSpacer:SetHeight(10);
    Window:AddChild(VerticalSpacer);

    ---@type AceGUIMultiLineEditBox
    local EditBox = SP.AceGUI:Create("MultiLineEditBox")
    EditBox:SetLabel(L["Insert your JSON here:"])
    EditBox:DisableButton(true)
    EditBox:SetFocus()
    EditBox:SetFullWidth(true)
    EditBox:SetHeight(360)
    EditBox:SetMaxLetters(99999999)
    EditBox:SetCallback("OnEnterPressed", function(_, _, text)
        self.textStore = text
    end)
    EditBox:SetCallback("OnTextChanged", function(_, _, text)
        self.textStore = text
    end)
    Window:AddChild(EditBox)

    ---@type AceGUIButton
    local SetButton = SP.AceGUI:Create("Button")
    SetButton:SetText(L["Import raid setup"])
    SetButton:SetWidth(150)
    SetButton:SetPoint("BOTTOMRIGHT")
    SetButton:SetCallback("OnClick", function()
        self:ParseJSON(self.textStore, Window)
    end)
    Window:AddChild(SetButton)
end

--- Convert input to MRT notes
---@param text any
---@param frame any
function RaidSetupImporter:ParseJSON(text, frame)
    if not SP:isJson(text) then
        frame:SetStatusText(L["Invalid input"])
    end

    -- Parse the JSON input
    local status = false
    local parsedTable = {}
    status, parsedTable = pcall(JSON.Deserialize, text)
    if not status then
        frame:SetStatusText(L["Invalid input"])
        return
    end

    -- Loop over the JSON entries
    local MRTNotes = parsedTable["MRTNotes"]
    if MRTNotes then
        ImportMRTNotes(MRTNotes)
    end

    local MRTGRoups = parsedTable["RaidGroups"]

    if MRTGRoups then
        ImportMRTGroups(MRTGRoups)
    end

    local rotationTable = {}
    local StormlashRotation = parsedTable["StormlashRotation"]
    if StormlashRotation then
        local stormlashTable = BuildStormlashRotation(StormlashRotation)
        if stormlashTable then
            tinsert(rotationTable, stormlashTable)
        end
    end

    local BannerRotation = parsedTable["BannerRotation"]
    if BannerRotation then
        local bannerTable = BuildBannerRotation(BannerRotation)
        if bannerTable then
            tinsert(rotationTable, bannerTable)
        end
    end

    Sleepo.DB:set("StormlashBannerRotation", rotationTable)
    WeakAuras.ScanEvents("WA_SLEEPO_NEW_SB_ROTATION")
    SP:message("Stormlash and Banner rotation saved")
end

--- Close the import window
function RaidSetupImporter:Close()
    local Window = SP.Interface:get(self, "Window");
    self.isVisible = false
    Window:Hide()
end

--- Parse MRT Notes and create or update notes in MRT
---@param MRTNotesJson any
function ImportMRTNotes(MRTNotesJson)
    local notesOverwritten = 0
    local notesAdded = 0
    if MRTNotesJson then
        for index, noteTitle in pairs(VMRT.Note.BlackNames) do
            local updatedNote = MRTNotesJson[noteTitle]
            if updatedNote ~= nil then
                VMRT.Note.Black[index] = updatedNote
                MRTNotesJson[noteTitle] = nil
                notesOverwritten = notesOverwritten + 1
            end
        end

        -- Add new notes
        for noteTitle, note in pairs(MRTNotesJson) do
            if not VMRT.Note.BlackNames[noteTitle] then
                table.insert(VMRT.Note.BlackNames, noteTitle)
                table.insert(VMRT.Note.Black, note)
                notesAdded = notesAdded + 1
            end
        end

        SP:message(notesOverwritten .. " MRT note(s) overwritten and " .. notesAdded .. " MRT note(s) added")
        -- dump:SetStatusText(notesOverwritten .. " MRT note(s) overwritten and " .. notesAdded .. " MRT note(s) added")
    end
end

--- Parse raid group and update the first MRT raid group accordingly
---@param MRTGroupsJson table
function ImportMRTGroups(MRTGroupsJson)

    VMRT.RaidGroups.profiles[1] = {}
    VMRT.RaidGroups.profiles[1].name = "sleepo"
    for key, value in pairs(MRTGroupsJson) do
        VMRT.RaidGroups.profiles[1][key] = value
    end
    SP:message("Raid group Sleepo created")

end

--- Parse stormlash rotations
---@param StormlashRotation table
---@return table
function BuildStormlashRotation(StormlashRotation)
    local rotation = {}

    rotation.class = "SHAMAN"
    rotation.spell = 120668
    rotation.player = {}

    for key, value in pairs(StormlashRotation) do
        rotation.player[key] = value
    end

    return rotation
end

--- Parse banner rotations
---@param BannerRotation table
function BuildBannerRotation(BannerRotation)
    local rotation = {}

    rotation.class = "WARRIOR"
    rotation.spell = 114207
    rotation.player = {}

    for key, value in pairs(BannerRotation) do
        rotation.player[key] = value
    end

    return rotation
end
