local L = Sleepo_L
local LibDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0");

---@type SP
local _, SP = ...;

---@class Interface
local Interface = {
    resizeBoundsMethod = nil,
    Colors = {
        AQUA = "00FFFF",
        BLACK = 000000,
        COPPER = "B87333",
        GOLD = "FFD700",
        GRAY = 808080,
        LIGHT_GRAY = "D3D3D3",
        DIM_GRAY = 696969,
        PURPLE = "A335EE",
        SILVER = "C0C0C0",
        WHITE = "FFFFFF",
        WHITE_SMOKE = "F5F5F5",
        YELLOW = "FFF569",

        -- Statuses
        ERROR = "BE3333",
        NOTICE = "FFF569",
        SUCCESS = "92FF00",
        WARNING = "F7922E",

        -- Classes
        DRUID = "FF7D0A",
        HUNTER = "ABD473",
        MAGE = "69CCF0",
        PALADIN = "F58CBA",
        PRIEST = "FFFFFF",
        ROGUE = "FFF569",
        SHAMAN = "0070DE",
        WARLOCK = "9482C9",
        WARRIOR = "C79C6E",
        DEATHKNIGHT = "C41E3A",
        DEATH_KNIGHT = "C41E3A",
        ["DEATH KNIGHT"] = "C41E3A",
        DEMONHUNTER = "A330C9",
        DEMON_HUNTER = "A330C9",
        ["DEMON HUNTER"] = "A330C9",
        EVOKER = "33937F",
        MONK = "00FF98",

        -- Qualities
        POOR = "9d9d9d",
        COMMON = "FFFFFF",
        UNCOMMON = "1EFF00",
        RARE = "0070DD",
        EPIC = "A335EE",
        LEGENDARY = "FF8000",
        ARTIFACT = "E6CC80",
        HEIRLOOM = "00CCFF",
        ["WOW TOKEN"] = "00CCFF"
    },
    TypeDictionary = {
        InteractiveLabel = "Label",
        SimpleGroup = "Frame",
        InlineGroup = "Frame"
    }
};

---@type Settings
local Settings = SP.Settings

---@type Interface
SP.Interface = Interface

local MENU_DIVIDER = {
    text = "",
    hasArrow = false,
    dist = 0,
    isTitle = true,
    isUninteractable = true,
    notCheckable = true,
    iconOnly = true,
    icon = "Interface/Common/UI-TooltipDivider-Transparent",
    tCoordLeft = 0,
    tCoordRight = 1,
    tCoordTop = 0,
    tCoordBottom = 1,
    tSizeX = 0,
    tSizeY = 8,
    tFitDropDownSizeX = true,
    iconInfo = {
        tCoordLeft = 0,
        tCoordRight = 1,
        tCoordTop = 0,
        tCoordBottom = 1,
        tSizeX = 0,
        tSizeY = 8,
        tFitDropDownSizeX = true
    }
};

---@class CreateWindowOptions
---@field name string
---@field width number
---@field height number
---@field minWidth number?
---@field minHeight number?
---@field maxWidth number?
---@field maxHeight number?
---@field closeWithEscape boolean?
---@field OnClose fun()?
---@field hideMinimizeButton boolean?
---@field hideCloseButton boolean?
---@field hideResizeButton boolean?
---@field hideMoveButton boolean?
---@field hideAllButtons boolean?
---@field hideWatermark boolean?
---@field template string?
---@field Parent Frame?

---@param options CreateWindowOptions
---@return Frame|boolean
function Interface:createWindow(options)

    if (type(options) ~= "table") then
        SP:error("Pass a table");
        return false;
    end

    local predefinedParent = options.Parent ~= nil;

    options.Parent = options.Parent or UIParent;
    if (options.Parent and options.closeWithEscape == nil) then
        options.closeWithEscape = false;
    end

    if (not options.name) then
        return SP:error("Sleepo windows requires a unique descriptive name!");
    end

    options.closeWithEscape = options.closeWithEscape ~= false;

    ---@type Frame
    local Window = CreateFrame("Frame", options.name, options.Parent,
        options.template == false and Frame or "BackdropTemplate");
    Window:SetSize(options.width or 200, options.height or 200);

    if not options.predefinedParent then
        Window:SetPoint("CENTER", UIParent, "CENTER")
    end

    if options.template ~= false then
        Window:SetBackdrop(_G.BACKDROP_DARK_DIALOG_32_32)
    end

    Window:SetClampedToScreen(true)
    Window:SetFrameStrata("FULLSCREEN_DIALOG")
    Window:SetFrameLevel(100)
    Window:EnableMouse(true)
    Window:SetToplevel(true)

    if type(options.OnClose) == "function" then
        Window:SetScript("OnHide", options.OnClose)
    end

    if not options.hideAllButtons and not options.hideMinimizeButton then
        self:addMinimizeButton(Window)
    end

    if not options.hideAllButtons and not options.hideCloseButton then
        self:addCloseButton(Window)
    end

    if not options.hideAllButtons and (not options.hideResizeButton or not options.hideMoveButton) then
        self:restorePosition(Window)
        self:restoreDimensions(Window)

        Interface:resizeBounds(Window, options.minWidth or 0, options.minHeight or 0);

        if (not options.hideResizeButton) then
            self:addResizer(Window);
        else
            -- This is to make sure we can update dimensions between patches
            -- without the restoreDimensions method overriding them with old SavedVariables data
            Window:SetSize(options.width or 200, options.height or 200);
        end

        if (not options.hideMoveButton) then
            Window:SetMovable(true);
            self:addMoveButton(Window);
            Window:SetUserPlaced(false);

            -- This sequence forces the window to be on top
            Window._Show = Window.Show;
            Window.Show = function()
                Window:_Show();
                Window:StartMoving();
                Window:StopMovingOrSizing();
            end;
        end

        Window:SetScript("OnSizeChanged", function()
            if (options.maxWidth) then
                local windowWidth = Window:GetWidth();
                Window:SetWidth(math.min(windowWidth, options.maxWidth));
            end

            if (options.maxHeight) then
                local windowHeight = Window:GetHeight();
                Window:SetHeight(math.min(windowHeight, options.maxHeight));
            end

            self:storeDimensions(Window);
            self:storePosition(Window);
        end);
    end

    if not options.hideWatermark then
        ---@type FontString
        local Watermark = Interface:createFontString(Window, SP.name .. " v" .. SP.version);
        Watermark:SetFont(0.8, "OUTLINE");
        Watermark:SetColor("GRAY");
        Watermark:SetPoint("BOTTOMLEFT", Window, "BOTTOMLEFT", 14, 13);
        Window.Watermark = Watermark;
    end

    if Window.MoveButton and (options.hideMinimizeButton or options.hideCloseButton) then
        if (options.hideCloseButton and options.hideMinimizeButton) then
            Window.MoveButton:SetPoint("TOPRIGHT", Window, "TOPRIGHT", 0, 0);
        else
            Window.MoveButton:SetPoint("TOPRIGHT", Window, "TOPRIGHT", -18, 0);
        end
    end

    if (Window.Minimize and options.hideCloseButton) then
        Window.Minimize:SetPoint("TOPRIGHT", Window, "TOPRIGHT", 8, 4);
    end

    _G[options.name] = Window;

    if (options.closeWithEscape) then
        tinsert(UISpecialFrames, options.name);
    end

    return Window;
end

---@param Element Frame
---@param title string|nil
---@return nil
function Interface:addMinimizeButton(Element, title)
    local minimizedName = Element:GetName() .. ".Minimized";

    ---@type Frame
    local MinimizedWindow = CreateFrame("Frame", minimizedName, UIParent, "BackdropTemplate");
    MinimizedWindow:SetMovable(true);
    MinimizedWindow:SetClampedToScreen(true);
    MinimizedWindow:SetSize(200, 50);
    MinimizedWindow:SetBackdrop(_G.BACKDROP_DARK_DIALOG_32_32);
    MinimizedWindow:SetFrameStrata("FULLSCREEN_DIALOG");
    MinimizedWindow:SetFrameLevel(100);
    MinimizedWindow:EnableMouse(true);
    MinimizedWindow:SetToplevel(true);
    MinimizedWindow:Hide();
    MinimizedWindow:SetUserPlaced(false);

    self:resizeBounds(MinimizedWindow, 80, 60)

end

--- Set resize bounds of given element
---
---@param Element Frame
---@return any
function Interface:resizeBounds(Element, ...)
    if (not self._resizeBoundsMethod) then
        if (SP.EventFrame.SetResizeBounds) then
            self.resizeBoundsMethod = "SetResizeBounds";
        else
            self.resizeBoundsMethod = "SetMinResize";
        end
    end

    if (Element.frame) then
        return Element.frame[self.resizeBoundsMethod](Element.frame, ...);
    end

    return Element[self.resizeBoundsMethod](Element, ...);
end

function Interface:addWindowOptions(Window, Menu, width)
    self:addOptionsButton(Window);

    local levels = 1;
    local Sanitized = {};
    do --[[ SANITIZE MENU ]]
        for _, Entry in pairs(Menu) do
            --[[ DIVIDER ]]
            if (Entry == "divider") then
                tinsert(Sanitized, MENU_DIVIDER);

                --[[ REGULAR ]]
            elseif (not Entry.SubMenu) then
                tinsert(Sanitized, Entry);

                --[[ MULTI-LEVEL ]]
            else
                levels = levels + 1;
                local SubMenu = Entry.SubMenu;
                Entry.SubMenu = nil;
                Entry.menuList = levels;
                Entry.hasArrow = true;
                Entry.notCheckable = true;
                tinsert(Sanitized, Entry);

                for _, SubEntry in pairs(SubMenu) do
                    SubEntry.level = levels;
                    tinsert(Sanitized, SubEntry);
                end
            end
        end
    end

    local DropDown = LibDD:Create_UIDropDownMenu(Window:GetName() .. ".OptionsDropdown", Window);
    DropDown:SetPoint("TOPLEFT", Window.OptionsButton, "BOTTOMLEFT", 0, 24);

    LibDD:UIDropDownMenu_SetWidth(DropDown, width or 200) -- Use in place of dropDown:SetWidth
    LibDD:UIDropDownMenu_JustifyText(DropDown, "LEFT");
    LibDD:UIDropDownMenu_Initialize(DropDown, function(_, level, menuList)
        local addEntry = function(Entry)
            menuList = menuList or 1;
            Entry.level = Entry.level or 1;
            Entry.isNotRadio = not Entry.isRadio;
            local isSubMenu = menuList > 1;

            if (not isSubMenu and Entry.level > 1) then
                return;
            end

            if (isSubMenu and menuList ~= Entry.level) then
                return;
            end

            if (type(Entry.text) == "function") then
                Entry.textFunc = Entry.text;
                Entry.text = Entry.text();
            elseif (Entry.textFunc) then
                Entry.text = Entry.textFunc();
            end

            if (type(Entry.checked) == "function") then
                Entry.checkFunc = Entry.checked;
                Entry.checked = Entry.checked();
            elseif (Entry.checkFunc) then
                Entry.checked = Entry.checkFunc();
            end

            -- Move text to the right if ElvUI is loaded
            if (not Entry.notCheckable and not Entry.isTitle and SP.elvUILoaded) then
                Entry.text = " " .. Entry.text;
            end

            if (Entry.setting) then
                Entry.checked = Settings:get(Entry.setting);

                if (not Entry.func) then
                    Entry.func = function(_, _, _, checked)
                        Settings:set(Entry.setting, checked);
                        Entry.checked = checked;
                    end;
                end
            end

            Entry.minWidth = DropDown:GetWidth() - 40;

            Entry.keepShownOnClick = true;
            if (Entry.hideOnClick) then
                Entry.keepShownOnClick = not Entry.hideOnClick;
            end

            LibDD:UIDropDownMenu_AddButton(Entry, level);
        end

        for _, Entry in pairs(Sanitized) do
            addEntry(Entry);
        end
    end, "MENU");

    Window.OptionsButton:SetScript("OnClick", function()
        LibDD:ToggleDropDownMenu(nil, nil, DropDown);
    end);

    -- We don't need these elements since we use
    -- our own frame to toggle the settings dropdown
    DropDown.Text:Hide();
    DropDown.Button:Hide();
end

---@param Element Frame
---@return nil
function Interface:addOptionsButton(Element)
    ---@type Button
    local Options = CreateFrame("Button", nil, Element);
    Options:SetPoint("TOPLEFT", Element, "TOPLEFT", 2, -2);
    Options:SetSize(16, 16);
    self:addTooltip(Options, L["Settings"]);
    Element.OptionsButton = Options;

    Options.normalTexture = Options:CreateTexture(nil, "BACKGROUND");
    Options.normalTexture:SetTexture("Interface/AddOns/Sleepo/Assets/Buttons/panel-cogwheel-up");
    Options.normalTexture:SetTexCoord(0.21875, 0.75, 0.234375, 0.765625);
    Options.normalTexture:SetAllPoints(Options);
    Options:SetNormalTexture(Options.normalTexture);

    Options.pushedTexture = Options:CreateTexture(nil, "BACKGROUND");
    Options.pushedTexture:SetTexture("Interface/AddOns/Sleepo/Assets/Buttons/panel-cogwheel-down");
    Options.pushedTexture:SetTexCoord(0.21875, 0.75, 0.234375, 0.765625);
    Options.pushedTexture:SetAllPoints(Options);
    Options:SetPushedTexture(Options.pushedTexture);

    Options:SetHighlightTexture("Interface/BUTTONS/UI-Panel-MinimizeButton-Highlight", "ADD");

    Element.OptionsButton = Options;

    -- Make sure the movebutton doesn't overlap the options button
    if (Element.MoveButton) then
        Element.MoveButton:SetPoint("TOPLEFT", Element, "TOPLEFT", 20, 0);
    end
end

--- Add tooltip
---@param Owner Frame
---@param Lines table|string
---@param anchor string|nil
function Interface:addTooltip(Owner, Lines, anchor)
    local isItemLink = false;
    local isFunction = type(Lines) == "function";

    if (SP:empty(Lines)) then
        return;
    end

    if (type(Owner) ~= "table") then
        return;
    end

    if (not anchor) then
        anchor = "TOP";
    end

    if (type(Lines) == "string") then
        if (SP:getItemIDFromLink(Lines)) then
            isItemLink = true;
        else
            Lines = {Lines};
        end
    end

    local Target = Owner.frame and Owner.frame or Owner;

    -- Make sure mouse events are enabled
    if (Target.EnableMouse) then
        Target:EnableMouse(true);
    end

    Target:HookScript("OnEnter", function()
        if (Target.GetEffectiveAlpha and Target:GetEffectiveAlpha() == 0) then
            return;
        end

        GameTooltip:SetOwner(Target, "ANCHOR_" .. anchor);

        if (isItemLink) then
            GameTooltip:SetHyperlink(Lines);
        elseif (isFunction) then
            local LineResult = Lines();
            if (not LineResult) then
                return;
            end

            if (type(LineResult) == "string") then
                LineResult = {LineResult};
            end

            for _, line in pairs(LineResult) do
                if (SP:getItemIDFromLink(line)) then
                    GameTooltip:SetHyperlink(line);
                else
                    GameTooltip:AddLine(line);
                end
            end
        else
            for _, line in pairs(Lines) do
                GameTooltip:AddLine(line);
            end
        end

        GameTooltip:Show();
    end);

    Target:HookScript("OnLeave", function()
        GameTooltip:Hide();
    end);
end

---@param Element Frame
---@return nil
function Interface:addCloseButton(Element)
    ---@type Button
    local Close = CreateFrame("Button", Element:GetName() .. ".Close", Element, "UIPanelCloseButton");
    Close:SetPoint("TOPRIGHT", Element, "TOPRIGHT", 8, 5);
    Close:SetSize(30, 30);
    self:addTooltip(Close, L["Close"]);

    -- Override the default onclick since it taints in combat
    Close:SetScript("OnClick", function()
        Element:Hide();
    end);

    Element.CloseButton = Close;
end

--- Restore an element's position from the settings table
---
---@param Item Frame
---@param identifier string|nil The name under which the settings should be stored
---@return boolean
function Interface:restorePosition(Item, identifier)
    identifier = identifier or Item:GetName();

    if (not identifier) then
        return false;
    end

    Item:ClearAllPoints();
    Item:SetPoint(self:getPosition(identifier));
    return true;
end

--- Restore an element's position from the settings table
---
---@param Item Frame
---@param identifier? string|nil The name under which the settings should be stored
---@param defaultWidth? number The default width if no width is stored yet
---@param defaultHeight? number The default height if no height is stored yet
---@param defaultScale? number The default scale if no scale is stored yet
---@return nil
function Interface:restoreDimensions(Item, identifier, defaultWidth, defaultHeight, defaultScale)
    identifier = identifier or Item:GetName();

    if (not identifier) then
        return false;
    end

    local width, height, scale = self:getDimensions(identifier);
    width = width or defaultWidth;
    height = height or defaultHeight;
    scale = scale or defaultScale;

    if (SP:higherThanZero(width)) then
        Item:SetWidth(width or defaultWidth);
    end

    if (SP:higherThanZero(height)) then
        Item:SetHeight(height or defaultHeight);
    end

    if (SP:higherThanZero(scale)) then
        if (Item.frame) then
            Item.frame:SetScale(scale);
        else
            Item:SetScale(scale);
        end
    end
end

--- Get an element's stored dimensions
---
---@param identifier string|nil
---@return number|nil, number|nil, number|nil
function Interface:getDimensions(identifier)
    if (type(identifier) == "table" and identifier.GetName) then
        identifier = identifier:GetName();
    end

    if not (identifier) then
        return nil;
    end

    identifier = string.format("UI.%s.Dimensions", identifier);

    local Dimensions = Settings:get(identifier, {});
    return Dimensions.width, Dimensions.height, Dimensions.scale;
end

---@param Element Frame
---@return nil
function Interface:addResizer(Element)
    Element:SetResizable(true);

    ---@type Button
    local Resize = CreateFrame("Button", Element:GetName() .. ".Resize", Element);
    Resize:SetPoint("BOTTOMRIGHT", Element, "BOTTOMRIGHT", -11, 10);
    Resize:SetSize(16, 16);

    local NormalTexture = Resize:CreateTexture();
    NormalTexture:SetTexture("Interface/ChatFrame/UI-ChatIM-SizeGrabber-Down");
    NormalTexture:ClearAllPoints();
    NormalTexture:SetPoint("CENTER", Resize, "CENTER", 0, 0);
    NormalTexture:SetSize(16, 16);
    Resize.NormalTexture = NormalTexture;
    Resize:SetNormalTexture(NormalTexture);

    local HighlightTexture = Resize:CreateTexture();
    HighlightTexture:SetTexture("Interface/ChatFrame/UI-ChatIM-SizeGrabber-Highlight");
    HighlightTexture:ClearAllPoints();
    HighlightTexture:SetPoint("CENTER", Resize, "CENTER", 0, 0);
    HighlightTexture:SetSize(16, 16);
    Resize.HighlightTexture = HighlightTexture;
    Resize:SetHighlightTexture(HighlightTexture);

    local PushedTexture = Resize:CreateTexture();
    PushedTexture:SetTexture("Interface/ChatFrame/UI-ChatIM-SizeGrabber-Pushed");
    PushedTexture:ClearAllPoints();
    PushedTexture:SetPoint("CENTER", Resize, "CENTER", 0, 0);
    PushedTexture:SetSize(16, 16);
    Resize.PushedTexture = PushedTexture;
    Resize:SetPushedTexture(PushedTexture);

    Resize:SetScript("OnMouseDown", function()
        Element:StartSizing("BOTTOMRIGHT");
    end);
    Resize:SetScript("OnMouseUp", function()
        Element:StopMovingOrSizing()
    end);

    -- Make the clickable are larger
    Resize:SetHitRectInsets(-6, -6, -6, -6);

    Element.Resize = Resize;
end

---@param Element Frame
---@return nil
function Interface:addMoveButton(Element)
    ---@type Button
    local Move = CreateFrame("Button", Element:GetName() .. ".Move", Element);
    Move:SetSize(15, 15);

    Move.normalTexture = Move:CreateTexture(nil, "BACKGROUND");
    Move.normalTexture:SetTexture("Interface/AddOns/Sleepo/Assets/Buttons/panel-move-up");
    Move.normalTexture:SetTexCoord(0.21875, 0.75, 0.234375, 0.765625);
    Move.normalTexture:SetPoint("TOPRIGHT", Move, "TOPRIGHT", 0, -3);
    Move.normalTexture:SetSize(15, 15);
    Move:SetNormalTexture(Move.normalTexture);

    Move.pushedTexture = Move:CreateTexture(nil, "BACKGROUND");
    Move.pushedTexture:SetTexture("Interface/AddOns/Sleepo/Assets/Buttons/panel-move-down");
    Move.pushedTexture:SetTexCoord(0.21875, 0.75, 0.234375, 0.765625);
    Move.pushedTexture:SetPoint("TOPRIGHT", Move, "TOPRIGHT", 0, -3);
    Move.pushedTexture:SetSize(15, 15);
    Move:SetPushedTexture(Move.pushedTexture);

    Move.highlightTexture = Move:CreateTexture(nil, "BACKGROUND");
    Move.highlightTexture:SetTexture("Interface/BUTTONS/UI-Panel-MinimizeButton-Highlight");
    Move.highlightTexture:SetTexCoord(0.21875, 0.75, 0.234375, 0.765625);
    Move.highlightTexture:SetPoint("TOPRIGHT", Move, "TOPRIGHT", 0, -3);
    Move.highlightTexture:SetSize(15, 15);
    Move:SetHighlightTexture(Move.highlightTexture, "ADD");

    Move:SetPoint("TOPRIGHT", Element, "TOPRIGHT", -40, 0);
    Move:SetPoint("TOPLEFT", Element, "TOPLEFT", 0, 0);

    do
        self:addTooltip(Move, L["Move"], "CURSOR");
        Move:EnableMouse(true);
        Move:RegisterForDrag("LeftButton");
        Move:SetScript("OnDragStart", function()
            Element:StartMoving();
            Move:SetButtonState("PUSHED");
        end);
        Move:SetScript("OnDragStop", function()
            Element:StopMovingOrSizing();
            self:storePosition(Element);
            Move:SetButtonState("NORMAL");
        end);
    end

    Element.MoveButton = Move;
end

--- Store an element's position in the settings table
---
---@param Item Frame
---@param identifier string|nil The name under which the settings should be stored
---@return boolean
function Interface:storePosition(Item, identifier)
    identifier = identifier or Item:GetName();

    if not (identifier) then
        return false;
    end

    identifier = string.format("UI.%s.Position", identifier);

    local point, _, relativePoint, offsetX, offsetY = Item:GetPoint();

    Settings:set(identifier .. ".point", point);
    Settings:set(identifier .. ".relativePoint", relativePoint);
    Settings:set(identifier .. ".offsetX", offsetX);
    Settings:set(identifier .. ".offsetY", offsetY);

    return true;
end

--- Store an element's position in the settings table
---
---@param Item table
---@param identifier string|nil The name under which the settings should be stored
---@return nil
function Interface:storeDimensions(Item, identifier)
    identifier = identifier or Item:GetName();

    if (not identifier) then
        return false;
    end

    identifier = string.format("UI.%s.Dimensions", identifier);

    if (Item.frame) then
        Settings:set(identifier .. ".width", Item.frame:GetWidth());
        Settings:set(identifier .. ".height", Item.frame:GetHeight());
        Settings:set(identifier .. ".scale", Item.frame:GetScale());
        return;
    end

    Settings:set(identifier .. ".width", Item:GetWidth());
    Settings:set(identifier .. ".height", Item:GetHeight());
    Settings:set(identifier .. ".scale", Item:GetScale());
end

--- Besides static string value we also support closures with an optional "updateOn" value
--- You can use this to automatically update a string whenever an event is fired for example
---
---@example
---
-- local CurrentPotLabel = Interface:createFontString(Window, {
--     text = function (self)
--         self:SetText(Pot:total());
--     end,
--     updateOn = "GL.GDKP_AUCTION_CHANGED",
-- });
---
---@param Parent Frame
---@param text string|table|nil
---@param template string|nil
---@param name string|nil
---@param layer string|nil
---@return FontString
function Interface:createFontString(Parent, text, template, name, layer)
    ---@type FontString
    local FontString = Parent:CreateFontString(name, layer or "ARTWORK", template or "GameFontWhite");
    FontString:SetJustifyH("LEFT");

    FontString._SetFont = FontString.SetFont;
    FontString.SetFont = function(_, rem, flags)
        FontString:_SetFont(SP.FONT, SP:rem(rem), flags or "");
    end

    FontString.SetColor = function(_, color)
        color = self.Colors[color] or color;
        FontString:SetText(("|c00%s%s|r"):format(color, FontString:GetText() or ""));

        FontString._lastColor = color;
    end

    FontString:SetFont(1, "OUTLINE");

    if (type(text) == "table") then
        FontString.update = text.text;

        if (text.updateOn) then
            if (type(text.updateOn) ~= "table") then
                text.updateOn = {text.updateOn};
            end

            for _, event in pairs(text.updateOn) do
                SP.Events:register(nil, event, function()
                    FontString:update(FontString);
                end);
            end
        end

        FontString:update(FontString);
    else
        FontString:SetText(text or "");
    end

    return FontString;
end

--- Get an element's stored position (defaults to center of screen)
---
---@param identifier string|nil
---@param default? table
---@return table
function Interface:getPosition(identifier, default)
    identifier = string.format("UI.%s.Position", identifier);

    -- There's a default, return it if no position points are available
    if (default ~= nil and not Settings:get(identifier .. ".point")) then
        return default;
    end

    return unpack({Settings:get(identifier .. ".point", "CENTER"), UIParent,
                   Settings:get(identifier .. ".relativePoint", "CENTER"), Settings:get(identifier .. ".offsetX", 0),
                   Settings:get(identifier .. ".offsetY", 0)});
end

---@param args table Contains: Parent (Frame), name (string), value (string|number), Options (table), sorter (function|boolean), callback (function)
---@return Frame|boolean
function Interface:createDropdown(args)
    local Parent = args.Parent
    local name = args.name or nil
    local value = args.value
    local Options = args.Options or {}
    local sorter = args.sorter or false
    local callback = args.callback or function()
    end

    if type(Parent) ~= "table" then
        SP:error("createDropdown: 'Parent' must be a table (Frame).")
        return false
    end

    local Dropdown = CreateFrame("Frame", name, Parent, "UIDropDownMenuTemplate")
    Dropdown.value = value
    Dropdown.Options = Options

    UIDropDownMenu_SetWidth(Dropdown, Parent:GetWidth() - 70)
    UIDropDownMenu_SetText(Dropdown, " ")

    UIDropDownMenu_Initialize(Dropdown, function()
        local Option = UIDropDownMenu_CreateInfo()
        Option.func = function(self)
            Dropdown:SetValue(self.value)
        end

        local FauxOptions = {}

        if not sorter or type(sorter) == "boolean" then
            for v, t in pairs(Dropdown.Options) do
                table.insert(FauxOptions, {
                    v = v,
                    t = t
                })
            end
            table.sort(FauxOptions, function(a, b)
                return a.v < b.v
            end)
        elseif type(sorter) == "function" then
            FauxOptions = sorter(Dropdown.Options)
        end

        for _, Details in ipairs(FauxOptions) do
            Option.text = Details.t
            Option.value = Details.v
            Option.checked = Dropdown.value == Details.v
            UIDropDownMenu_AddButton(Option)
        end
    end)

    function Dropdown:SetOptions(newOptions)
        self.Options = newOptions
    end

    function Dropdown:SetWidth(width)
        UIDropDownMenu_SetWidth(self, width)
    end

    function Dropdown:SetText(text)
        UIDropDownMenu_SetText(self, text)
    end

    function Dropdown:SetValue(val)
        self:SetText(self.Options[val] or "")

        if val ~= self.value then
            callback(self, val)
        end

        self.value = val
    end

    function Dropdown:GetValue()
        return self.value
    end

    Dropdown:SetValue(value)

    return Dropdown
end

--- Create a UIPanelButtonTemplate that changes it's width dynamically based on its contents
---
---@param Parent Frame
---@param text string|nil
---@param template string|nil
---@return Button
function Interface:dynamicPanelButton(Parent, text, template)
    template = template or "UIPanelButtonTemplate";
    local minOffset = 33;

    ---@type Button
    local Button = CreateFrame("Button", nil, Parent, template);

    ---@type FontString
    local Text = Button:GetFontString()
    Text:ClearAllPoints();
    Text:SetPoint("TOPLEFT", 15, -1)
    Text:SetPoint("BOTTOMRIGHT", -15, 1)
    Text:SetJustifyV("MIDDLE")

    Text._SetFont = Text.SetFont;
    Text.SetFont = function(_, rem, flags)
        Text:_SetFont(SP.FONT, SP:rem(rem), flags or "");
    end

    Text:SetFont();

    -- Make sure the button changes in size whenever we change its contents
    Button.SetText = function(_, ...)
        local scale = Button:GetScale();

        if (scale < 1) then
            scale = math.min(scale * 1.2, 1);
        end

        Text:SetText(...);
        local textWidth = Text:GetUnboundedStringWidth();
        Button:SetSize((Text:GetUnboundedStringWidth() + math.max(minOffset, textWidth * .44)) * scale, 21 * scale);
    end

    Button:SetText(text or "");

    return Button;
end

--- Set an interface item on a given scope (either an object or string reference to an interface class)
---
---@param scope table|string
---@param identifier string
---@param Item Frame
---@param prefixWithType boolean Defaults to true
---@return boolean
function Interface:set(scope, identifier, Item, prefixWithType)
    prefixWithType = prefixWithType ~= false;

    local widgetType = "";
    if (prefixWithType) then
        widgetType = "." .. self:determineItemType(Item);
    end

    local path = "";
    if (type(scope) == "table") then
        path = string.format("InterfaceItems%s.%s", widgetType, identifier);
        return SP:tableSet(scope, path, Item);
    end

    path = string.format("SP.Interface.%s.InterfaceItems%s.%s", scope, widgetType, identifier);
    return SP:tableSet(path, identifier);
end

--- Determine the given Item's type (e.g: Frame, Table, Button etc)
---
---@param Item Frame
---@return string
function Interface:determineItemType(Item)
    if (type(Item.GetCell) == "function") then
        return "Table";
    end

    if (type(Item.type) == "string") then
        local itemType = Item.type;

        return self.TypeDictionary[itemType] or itemType;
    end

    return "Frame";
end

--- Fetch an interface item from a given scope (either an object or string reference to an interface class)
---
---@param scope table|string
---@param identifier string
---@return any
function Interface:get(scope, identifier)
    if (identifier == "Window") then
        identifier = "Frame.Window";
    end

    if (type(scope) == "table") then
        return SP:tableGet(scope, "InterfaceItems." .. identifier), identifier;
    end

    return SP:tableGet(SP.Interface, scope .. ".InterfaceItems." .. identifier), identifier;
end

--- Release the children of an element (and their children recursively)
---
---@param Element table
---@return nil
function Interface:releaseChildren(Element)
    if (type(Element) ~= "table") then
        return;
    end

    -- This is an AceGUI element
    if (Element.frame) then
        local Children = Element.children or {};
        for i = 1, #Children do
            self:releaseChildren(Children[i]);
            Children[i].frame:Hide();

            Children[i] = nil;
        end

        return;
    end

    local Children = {Element:GetChildren()};
    for i = 1, #Children do
        self:releaseChildren(Children[i]);
        Children[i]:SetFrameLevel(1);
        Children[i]:SetSize(1, 1);
        Children[i]:Hide();
        Children[i] = nil;
    end
end
