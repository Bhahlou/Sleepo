Bhahlou = Bhahlou or {}
local UnitAffectingCombat = UnitAffectingCombat

Bhahlou.SetButtonTemplate = function(aura_env, buttonName, type, context, context2)
    if WeakAuras.IsOptionsOpen() then
        return
    end
    if UnitAffectingCombat('player') then
        return
    end

    if not aura_env.button then
        local region = WeakAuras.GetRegion(aura_env.id)
        aura_env.button = CreateFrame("Button", buttonName, region, "SecureActionButtonTemplate")
    end

    aura_env.button:SetAllPoints()
    aura_env.button:RegisterForClicks("AnyUp")
    aura_env.button:SetAttribute("type", type)
    if type == "macro" then
        aura_env.button:SetAttribute('macrotext1', context)
    elseif type == 'item' then
        aura_env.button:SetAttribute('item', "item:" .. context)
    elseif type == 'spell' then
        local spell = (context2 and select(1, GetSpellInfo(context))) or context
        aura_env.button:SetAttribute("spell", spell)
    end
end
