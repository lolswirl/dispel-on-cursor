local DISPEL_SPELL_IDS = {
    115450, -- detox (monk)
    4987, -- cleanse (paladin)
    527, -- purify (priest)
    360823, -- naturalize (evoker)
    88423, -- nature's cure (druid)
    77130, -- purify spirit (shaman)
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

    local cdInfo = C_Spell.GetSpellCooldown(TRACKED_SPELL_ID)
    if cdInfo and cdInfo.startTime and cdInfo.duration then
        cooldownFrame:SetCooldown(cdInfo.startTime, cdInfo.duration)
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

frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("SPELL_UPDATE_COOLDOWN")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
        for _, spellID in ipairs(DISPEL_SPELL_IDS) do
            if C_SpellBook.IsSpellInSpellBook(spellID) then
                TRACKED_SPELL_ID = spellID
                UpdateCooldown()
                return
            end
        end
    elseif event == "SPELL_UPDATE_COOLDOWN" then
        UpdateCooldown()
    end
end)
