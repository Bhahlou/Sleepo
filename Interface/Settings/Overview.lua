local L = Sleepo_L

---@type SP
local _, SP = ...;

SP.ScrollingTable = SP.ScrollingTable or LibStub("ScrollingTable");
local ScrollingTable = SP.ScrollingTable;

SP.AceGUI = SP.AceGUI or LibStub("AceGUI-3.0");

SP.Interface.Settings = SP.Interface.Settings or {};
---@class SettingsOverview
SP.Interface.Settings.Overview = {
    isVisible = false,
    activeSection = nil,
    previousSection = nil,
    defaultSection = "Welcome",
    Sections = {{"|c00A79EFFWELCOME|r", "Welcome"}, {"General", "General"}, {"Minimap Icon", "MinimapButton"}},
    SectionIndexes = nil
}

---@type SettingsOverview
local Overview = SP.Interface.Settings.Overview

SP.Interface.Settings.Overview.Sections = SP:tableValues(SP.Interface.Settings.Overview.Sections);

--- Draw a setting section
---
---@param section string|nil
---@param onCloseCallback function|nil What to do after closing the settings again
---@return nil
function Overview:draw(section, onCloseCallback)
    local AceGUI = SP.AceGUI or LibStub("AceGUI-3.0");

    if (self.isVisible) then
        return self:showSection(section);
    end

    self.isVisible = true;

    -- Fill the SectionIndexes table (only once per play session)
    if (not self.SectionIndexes) then
        self.SectionIndexes = {};

        for index, Entry in pairs(self.Sections) do
            if (not SP:empty(Entry[2])) then
                self.SectionIndexes[Entry[2]] = index;
            end
        end
    end

    -- Open a specific section based on the section identifier
    -- If no identifier is given we open the most recent one or open the homescreen
    if (type(section) ~= "string" or SP:empty(section) or not self.SectionIndexes[section]) then
        section = self.previousSection or self.defaultSection;
    end

    -- Create a container/parent frame
    local Window = AceGUI:Create("Frame");
    Window:SetTitle((L["Sleepo v%s"]):format(SP.version) .. " - Settings");
    Window:SetLayout("Flow");
    Window:SetWidth(800);
    Window:SetHeight(600);
    Window:EnableResize(false);
    Window.statustext:GetParent():Hide(); -- Hide the statustext bar
    SP.Interface:set(self, "Window", Window);
    Window:SetPoint(SP.Interface:getPosition("Settings"));

    Window:SetCallback("OnClose", function()
        self:close(onCloseCallback);
    end);

    -- Override the default close button behavior
    local CloseButton = SP:fetchCloseButtonFromAceGUIWidget(Window);
    if (CloseButton) then
        CloseButton:SetScript("OnClick", function()
            self:close(onCloseCallback);
        end);
    end

    -- Make sure the window can be closed by pressing the escape button
    _G["SLEEPO_SETTING_WINDOW"] = Window.frame;
    tinsert(UISpecialFrames, "SLEEPO_SETTING_WINDOW");

    --[[
        COLUMN SPACER
    ]]
    local ColumnSpacerOne = AceGUI:Create("SimpleGroup");
    ColumnSpacerOne:SetLayout("FILL")
    ColumnSpacerOne:SetWidth(6);
    ColumnSpacerOne:SetHeight(400);
    Window:AddChild(ColumnSpacerOne);

    --[[
        FIRST COLUMN
    ]]
    local FirstColumn = AceGUI:Create("SimpleGroup");
    FirstColumn:SetLayout("FILL")
    FirstColumn:SetWidth(180);
    FirstColumn:SetHeight(1);
    Window:AddChild(FirstColumn);

    self:drawSectionsTable(Window.frame, section);

    --[[
        COLUMN SPACER TWO
    ]]
    local ColumnSpacerTwo = AceGUI:Create("SimpleGroup");
    ColumnSpacerTwo:SetLayout("FILL")
    ColumnSpacerTwo:SetWidth(20);
    ColumnSpacerTwo:SetHeight(400);
    Window:AddChild(ColumnSpacerTwo);

    local SecondColumn = AceGUI:Create("SimpleGroup");
    SecondColumn:SetLayout("FLOW")
    SecondColumn:SetWidth(550);
    SP.Interface:set(self, "SecondColumn", SecondColumn);
    Window:AddChild(SecondColumn);

    local SectionTitle = AceGUI:Create("Label");
    SectionTitle:SetFontObject(_G["GameFontNormalLarge"]);
    SectionTitle:SetFullWidth(true);
    SectionTitle:SetText(" ");
    SecondColumn:AddChild(SectionTitle);

    local ScrollFrameHolder = AceGUI:Create("InlineGroup");
    ScrollFrameHolder:SetLayout("FILL")
    ScrollFrameHolder:SetWidth(556);
    ScrollFrameHolder:SetHeight(480);
    SecondColumn:AddChild(ScrollFrameHolder);

    SP.Interface:set(self, "Window", Window);
    SP.Interface:set(self, "Title", SectionTitle);
    SP.Interface:set(self, "SectionWrapper", ScrollFrameHolder);

    local HorizontalSpacer = AceGUI:Create("SimpleGroup");
    HorizontalSpacer:SetLayout("FILL");
    HorizontalSpacer:SetFullWidth(true);
    HorizontalSpacer:SetHeight(20);
    SecondColumn:AddChild(HorizontalSpacer);

    self:showSection(section);
end

--- Draw the sections table (the left portion of the settings screen)
---
---@param Parent table
---@param section string
---@return nil
function Overview:drawSectionsTable(Parent, section)
    SP:debug("Overview:drawSectionsTable");

    local sectionIndex = self.SectionIndexes[section];

    -- The given section wasn't found
    if (not SP:higherThanZero(sectionIndex)) then
        return;
    end

    local columns = {{
        name = "",
        width = 145,
        colorargs = nil
    }};

    local Table = ScrollingTable:CreateST(columns, 27, 18, nil, Parent);
    Table:EnableSelection(true);
    Table:SetSelection(sectionIndex);
    Table:SetWidth(145);
    Table.frame:SetPoint("TOPLEFT", Parent, "TOPLEFT", 23, -40);

    Table:RegisterEvents{
        OnClick = function(_, _, _, _, _, realrow)
            -- Make sure something is actually selected, better safe than lua error
            if (not SP:higherThanZero(realrow)) then
                return;
            end

            self:showSection(self.Sections[realrow][2]);
        end
    };

    local TableData = {};
    for _, Entry in pairs(self.Sections) do
        tinsert(TableData, {Entry[1]});
    end

    -- The second argument refers to "isMinimalDataformat"
    -- For the full format see https://www.wowace.com/projects/lib-st/pages/set-data
    Table:SetData(TableData, true);
    SP.Interface:set(self, "Sections", Table);
end

---@return nil
function Overview:close(onCloseCallback)
    local Window = SP.Interface:get(self, "Window");

    -- Some sections require additional cleanup, check if that's the case here
    if (self.activeSection and type(SP.Interface.Settings[self.activeSection].onClose) == "function") then
        local result = SP.Interface.Settings[self.activeSection]:onClose();

        if (result == false) then
            return;
        end
    end

    -- The user can pass along a close handler if his own
    -- this allows us to open up a previous window after closing the settings for example
    if (type(onCloseCallback) == "function") then
        onCloseCallback();
    end

    self.isVisible = false;
    self.previousSection = self.activeSection;
    self.activeSection = nil;

    if (Window) then
        SP.Interface:storePosition(Window, "Settings");
        Window:Hide();
        PlaySound(799) -- SOUNDKIT.GS_TITLE_OPTION_EXIT
    end
end

--- Show a specific setting section
---
---@param section string
---@return boolean
function Overview:showSection(section)
    section = string.trim(section or "");
    local sectionIndex = self.SectionIndexes[section];

    if (not SP:higherThanZero(sectionIndex)) then
        return false;
    end

    -- Determine which setting object we should render based on the user's selection
    local SectionEntry = self.Sections[sectionIndex] or {};
    local sectionClassIdentifier = SectionEntry[2];

    -- Make sure the requested section actually exists
    if (not sectionClassIdentifier or sectionClassIdentifier == self.activeSection) then
        return false;
    end

    local SectionClass = SP.Interface.Settings[sectionClassIdentifier] or {};

    -- Make sure the provided section has the required "draw" method
    if (type(SectionClass.draw) ~= "function") then
        return false;
    end

    -- Some sections require additional cleanup, check if that's the case here
    if (self.activeSection and type(SP.Interface.Settings[self.activeSection].onClose) == "function") then
        SP.Interface.Settings[self.activeSection]:onClose();
    end

    self.activeSection = sectionClassIdentifier;

    -- Set the Title of the section (shown top-right)
    SP.Interface:get(self, "Label.Title"):SetText(" " .. strtrim(SectionEntry[1]));

    -- Prepare a new ScrollFrame for the section we're about to draw
    local ScrollFrame = SP.Interface:get(self, "ScrollFrame.ScrollFrame") or SP.AceGUI:Create("ScrollFrame");
    local Parent = SP.Interface:get(self, "Frame.SectionWrapper");
    ScrollFrame:SetLayout("Flow");

    -- Clean the ScrollFrame in case it still holds old data
    SP.Interface:releaseChildren(ScrollFrame);

    Parent:AddChild(ScrollFrame);

    -- Store the ScrollFrame so that we can clean/release it later
    SP.Interface:set(self, "ScrollFrame", ScrollFrame);

    -- Add a description to the section if available
    if (not SP:empty(SectionClass.description)) then
        local SectionDescription = SP.AceGUI:Create("Label");
        SectionDescription:SetText(SectionClass.description .. "\n\n");
        SectionDescription:SetFontObject(_G["GameFontNormal"]);
        SectionDescription:SetFullWidth(true);
        ScrollFrame:AddChild(SectionDescription);
    end

    -- Add a link to our wiki when available
    if (not SP:empty(SectionClass.wikiUrl)) then
        local MoreInfoLabel = SP.AceGUI:Create("Label");
        MoreInfoLabel:SetText("\nVisit our Wiki for more info:\n");
        MoreInfoLabel:SetFontObject(_G["GameFontNormal"]);
        MoreInfoLabel:SetFullWidth(true);
        ScrollFrame:AddChild(MoreInfoLabel);

        local WikiUrlBox = SP.AceGUI:Create("EditBox");
        WikiUrlBox:DisableButton(true);
        WikiUrlBox:SetHeight(20);
        WikiUrlBox:SetFullWidth(true);
        WikiUrlBox:SetText(SectionClass.wikiUrl);
        ScrollFrame:AddChild(WikiUrlBox);

        local HorizontalSpacer = SP.AceGUI:Create("SimpleGroup");
        HorizontalSpacer:SetLayout("FILL");
        HorizontalSpacer:SetFullWidth(true);
        HorizontalSpacer:SetHeight(20);
        ScrollFrame:AddChild(HorizontalSpacer);
    end

    SectionClass:draw(ScrollFrame, SP.Interface:get(self, "Window"));

    -- Highlight the correct section in the table on the left
    -- This delay is necessary because of how lib-st handles click and selection events
    SP.Ace:ScheduleTimer(function()
        local Table = SP.Interface:get(self, "Table.Sections");
        if (Table and Table:GetSelection() ~= sectionIndex) then
            Table:SetSelection(sectionIndex);
        end
    end, .1);

    return true;
end

