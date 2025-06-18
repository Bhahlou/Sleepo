local L = Sleepo_L

---@type SP
local _, SP = ...

---@class MRTNoteImporter
---@
SP.Interface.MRTNoteImporter = {
    isVisible = false,
    textStore = ""
}

local VMRT = VMRT

SP.AceGUI = SP.AceGUI or LibStub("AceGUI-3.0");
local LibBase64 = LibStub('LibBase64-1.0')
local JSON = LibStub("LibJSON-1.0")

---@type MRTNoteImporter
local MRTImporter = SP.Interface.MRTNoteImporter

function MRTImporter:draw()
    SP:debug("MRTImporter:draw")

    if not SP.MRTLoaded then
        SP:error("You must load MRT Addon to use MRT Note importer")
    end
    if self.isVisible then
        return
    end

    local Window = SP.AceGUI:Create("Frame")
    Window:SetTitle((L["Sleepo v%s"]):format(SP.version) .. " - MRT Note Importer");
    Window:SetLayout("Flow");
    Window:SetWidth(500);
    Window:SetHeight(550);
    Window:EnableResize(false);
    Window.statustext:GetParent():Show(); -- Explicitly show the statustext bar
    Window:SetCallback("OnClose", function()
        self:close();
    end);

    SP.Interface:set(self, "Window", Window);

    Window:SetPoint(SP.Interface:getPosition("MRTImporter"));

    _G["SLEEPO_MRT_IMPORTER"] = Window.frame;
    tinsert(UISpecialFrames, "SLEEPO_MRT_IMPORTER");

    local VerticalSpacer = SP.AceGUI:Create("SimpleGroup");
    VerticalSpacer:SetLayout("FILL");
    VerticalSpacer:SetFullWidth(true);
    VerticalSpacer:SetHeight(6);
    Window:AddChild(VerticalSpacer);

    local WikiURL = SP.AceGUI:Create("EditBox");
    WikiURL:SetLabel(L["Check the Wiki to learn using MRT Note Importer"])
    WikiURL:DisableButton(true);
    WikiURL:SetHeight(40);
    WikiURL:SetFullWidth(true);
    WikiURL:SetText("https://github.com/Bhahlou/Sleepo/wiki/MRT-Note-Importer");
    Window:AddChild(WikiURL);

    VerticalSpacer = SP.AceGUI:Create("SimpleGroup");
    VerticalSpacer:SetLayout("FILL");
    VerticalSpacer:SetFullWidth(true);
    VerticalSpacer:SetHeight(10);
    Window:AddChild(VerticalSpacer);

    local EditBox = SP.AceGUI:Create("MultiLineEditBox")
    EditBox:SetLabel(L["Insert your JSON / Base64 here:"])
    EditBox:DisableButton(true)
    EditBox:SetFocus(true)
    EditBox:SetFullWidth(true)
    EditBox:SetHeight(360)
    EditBox:SetMaxLetters(99999999)
    EditBox:SetCallback("OnEnterPressed", function(widget, event, text)
        self.textStore = text
    end)
    EditBox:SetCallback("OnTextChanged", function(widget, event, text)
        self.textStore = text
    end)
    Window:AddChild(EditBox)

    local SetButton = SP.AceGUI:Create("Button")
    SetButton:SetText(L["Import notes"])
    SetButton:SetWidth(150)
    SetButton:SetPoint("BOTTOMRIGHT")
    SetButton:SetCallback("OnClick", function()
        self:convertInputToMRTNotes(self.textStore, Window)
    end)
    Window:AddChild(SetButton)
end

function MRTImporter:convertInputToMRTNotes(text, frame)

    -- Check if we got a JSON note or not
    local base64 = true
    if SP:isJson(text) then
        base64 = false
    end

    -- Make the new notes
    local status = false
    local parsedTable = {}
    local notesOverwritten = 0
    local notesAdded = 0

    if base64 then
        local decoded_base64 = LibBase64:Decode(text)
        status, parsedTable = pcall(JSON.Deserialize, decoded_base64)
    else
        status, parsedTable = pcall(JSON.Deserialize, text)
    end

    if not status then
        frame:SetStatusText(L["Invalid input"])
    else
        -- Loop over existing notes and update them
        for index, noteTitle in pairs(VMRT.Note.BlackNames) do
            local updatedNote = parsedTable[noteTitle]

            if updatedNote ~= nil then
                VMRT.Note.Black[index] = updatedNote
                parsedTable[noteTitle] = nil
                notesOverwritten = notesOverwritten + 1
            end
        end

        -- Add new notes
        for noteTitle, note in pairs(parsedTable) do
            if not VMRT.Note.BlackNames[noteTitle] then
                table.insert(VMRT.Note.BlackNames, noteTitle)
                table.insert(VMRT.Note.Black, note)
                notesAdded = notesAdded + 1
            end
        end

        frame:SetStatusText(notesOverwritten .. " note(s) overwritten and " .. notesAdded .. " note(s) added")
    end
end
