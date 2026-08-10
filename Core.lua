local DISPEL_SPELL_IDS = {
    115450, -- detox (monk, heal)
    218164, -- detox (monk, non-heal)
    4987, -- cleanse (paladin, heal)
    213644, -- cleanse toxins (paladin, non-heal)
    527, -- purify (priest, heal)
    213634, -- purify disease (priest, non-heal)
    360823, -- naturalize (evoker, heal)
    365585, -- expunge (evoker, non-heal)
    88423, -- nature's cure (druid, heal)
    2782, -- remove corruption (druid, non-heal)
    77130, -- purify spirit (shaman, heal)
    51886, -- cleanse spirit (shaman, non-heal)
    475, -- remove curse (mage)
}
local TRACKED_SPELL_ID = nil

local frame = CreateFrame("Frame", "DispelOnCursor", UIParent)
frame:SetFrameStrata("TOOLTIP")

local cooldownFrame = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
cooldownFrame:SetSize(1, 1)
cooldownFrame:SetDrawSwipe(false)
cooldownFrame:SetDrawEdge(false)
cooldownFrame:SetDrawBling(false)
cooldownFrame:SetHideCountdownNumbers(false)

local cooldownText = nil
for _, region in ipairs({ cooldownFrame:GetRegions() }) do
    if region:GetObjectType() == "FontString" then
        cooldownText = region
        break
    end
end

if cooldownText then
    local fontName, fontSize, _ = cooldownText:GetFont()
    cooldownText:SetFont(fontName, fontSize * 1.5, "OUTLINE")
    cooldownText:SetTextColor(1, 1, 1, 1)
else
    cooldownText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    local fontName, fontSize, _ = cooldownText:GetFont()
    cooldownText:SetFont(fontName, fontSize * 1.5, "OUTLINE")
    cooldownText:SetTextColor(1, 1, 1, 1)
end

cooldownText:SetPoint("CENTER", UIParent, "BOTTOMLEFT", 0, 0)

local function UpdateCooldown()
    if not TRACKED_SPELL_ID then
        cooldownFrame:Clear()
        return
    end

    local duration = C_Spell.GetSpellCooldownDuration(TRACKED_SPELL_ID)
    if duration then
        cooldownFrame:SetCooldownFromDurationObject(duration, false)
    else
        cooldownFrame:Clear()
    end
end

frame:SetScript("OnUpdate", function(self, elapsed)
    local x, y = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()
    cooldownText:ClearAllPoints()
    cooldownText:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", (x / scale) + 10, (y / scale) + 10)
end)

local function DetectDispelSpell()
    for _, spellID in ipairs(DISPEL_SPELL_IDS) do
        if C_SpellBook.IsSpellInSpellBook(spellID) then
            TRACKED_SPELL_ID = spellID
            UpdateCooldown()
            return
        end
    end

    TRACKED_SPELL_ID = nil
    UpdateCooldown()
end

frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
frame:RegisterEvent("TRAIT_CONFIG_UPDATED")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" or event == "TRAIT_CONFIG_UPDATED" then
        DetectDispelSpell()
    elseif event == "SPELL_UPDATE_COOLDOWN" then
        UpdateCooldown()
    end
end)
