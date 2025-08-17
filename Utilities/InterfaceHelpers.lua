---@type SP
local _, SP = ...
local AceGUI = SP.AceGUI or LibStub("AceGUI-3.0");

--- Add an horizontal spacer to parent window
---@param Parent SimpleWindow
---@param fullwidth boolean
---@param height number
function SP:AddHorizontalSpacer(Parent, fullwidth, height)
    ---@type AceGUISimpleGroup
    local spacer = AceGUI:Create("SimpleGroup")
    spacer:SetLayout("Fill")
    spacer:SetFullWidth(fullwidth)
    spacer:SetHeight(height)
    Parent:AddChild(spacer)
end

--- func desc
---@param Parent SimpleWindow
---@param layout AceGUILayoutType
---@param fullwidth boolean
---@param height number
function SP:AddVerticalSpacer(Parent, layout, fullwidth, height)
    ---@type AceGUISimpleGroup
    local Spacer = SP.AceGUI:Create("SimpleGroup")
    Spacer:SetLayout(layout)
    Spacer:SetFullWidth(fullwidth)
    Spacer:SetHeight(height)
    Parent:AddChild(Spacer)
end

--- Add a label to parent window
---@param Parent SimpleWindow
---@param text string
---@param font FontObject
---@param fullwidth boolean
function SP:AddLabel(Parent, text, font, fullwidth)
    ---@type AceGUILabel
    local label = AceGUI:Create("Label")
    label:SetText(text)
    label:SetFontObject(font)
    label:SetFullWidth(fullwidth)
    Parent:AddChild(label)
end

--- Add an edit box to parent window
---@param Parent SimpleWindow
---@param disableButton boolean
---@param height number
---@param fullwidth boolean
---@param text string
---@param label? string
function SP:AddEditBox(Parent, disableButton, height, fullwidth, text, label)
    ---@type AceGUIEditBox
    local editBox = AceGUI:Create("EditBox")
    if label then
        editBox:SetLabel(label)
    end
    editBox:DisableButton(disableButton)
    editBox:SetHeight(height)
    editBox:SetFullWidth(fullwidth)
    editBox:SetText(text)
    Parent:AddChild(editBox)
end

--- Create a window
---@param title string
---@param layout AceGUILayoutType
---@param width number
---@param height number
---@param enableResize false
---@param onCloseCallback function
function SP:CreateWindow(title, layout, width, height, enableResize, onCloseCallback)

    ---@type AceGUIWindow
    local Window = SP.AceGUI:Create("Frame")

    Window:SetTitle(title)
    Window:SetLayout(layout)
    Window:SetWidth(width)
    Window:SetHeight(height)
    Window:EnableResize(enableResize)
    Window:SetCallback("onClose", onCloseCallback)

    return Window
end

--- Add a multi edit box to the parent window
---@param Parent SimpleWindow
---@param label string
---@param disableButton boolean
---@param setFocus boolean
---@param fullwidth boolean
---@param height number
---@param maxLetters number
---@param onEnterPressedCallback function
---@param onTextChangedCallBack function
function SP:AddMultiLineEditBox(Parent, label, disableButton, setFocus, fullwidth, height, maxLetters,
    onEnterPressedCallback, onTextChangedCallBack)
    ---@type AceGUIMultiLineEditBox
    local EditBox = SP.AceGUI:Create("MultiLineEditBox")
    EditBox:SetLabel(label)
    EditBox:DisableButton(disableButton)
    if setFocus then
        EditBox:SetFocus()
    end
    EditBox:SetFullWidth(fullwidth)
    EditBox:SetHeight(height)
    EditBox:SetMaxLetters(maxLetters)
    EditBox:SetCallback("OnEnterPressed", onEnterPressedCallback)
    EditBox:SetCallback("OnTexChanged", onTextChangedCallBack)

    Parent:AddChild(EditBox)
end

--- func desc
---@param Parent SimpleWindow
---@param text string
---@param width number
---@param point FramePoint
---@param onClickCallBack function
function SP:AddButton(Parent, text, width, point, onClickCallBack)
    ---@type AceGUIButton
    local Button = SP.AceGUI:Create("Button")
    Button:SetText(text)
    Button:SetWidth(width)
    Button:SetPoint(point)
    Button:SetCallback("OnClick", onClickCallBack)
    Parent:AddChild(Button)
end
