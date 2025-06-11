local addonName = ...
local frame = CreateFrame("Frame", addonName.."Frame", UIParent)
frame:SetSize(260, 80) -- Startgröße für Eingabefenster
frame:SetPoint("CENTER")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})

frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
frame.title:SetPoint("TOP", frame, "TOP", 0, -6)
frame.title:SetText("Mythic Helper")

-- X-Button zum Schließen
local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
closeButton:SetSize(20, 20)
closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
closeButton:SetScript("OnClick", function() frame:Hide() end)

local buffTarget = nil
local mainUI = nil

-- Formular-Frame für Charakternamen
local inputFrame = CreateFrame("Frame", nil, frame)
inputFrame:SetAllPoints(frame)

local inputLabel = inputFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
inputLabel:SetPoint("TOP", inputFrame, "TOP", 0, -22)
inputLabel:SetText("Charname with the highest Aura Ranks:")

local inputBox = CreateFrame("EditBox", nil, inputFrame, "InputBoxTemplate")
inputBox:SetSize(120, 18)
inputBox:SetPoint("TOP", inputLabel, "BOTTOM", 0, -6)
inputBox:SetAutoFocus(true)
inputBox:SetMaxLetters(20)
inputBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

local confirmButton = CreateFrame("Button", nil, inputFrame, "GameMenuButtonTemplate")
confirmButton:SetPoint("TOP", inputBox, "BOTTOM", 0, -6)
confirmButton:SetSize(60, 18)
confirmButton:SetText("OK")
confirmButton:SetScript("OnClick", function()
    local name = inputBox:GetText()
    if name and name ~= "" then
        buffTarget = name
        inputFrame:Hide()
        -- Nach Eingabe: Frame vergrößern und Haupt-UI zeigen
        frame:SetSize(90, 18 + 9 * 46) -- Passe Höhe an Anzahl Buttons an
        mainUI:Show()
    else
        print("Please enter a valid name!")
    end
end)

inputBox:SetScript("OnEnterPressed", function(self)
    confirmButton:Click()
end)

-- Haupt-UI (wird erst nach Eingabe angezeigt)
mainUI = CreateFrame("Frame", nil, frame)
mainUI:SetAllPoints(frame)
mainUI:Hide()

-- Trenner-Funktion
local function CreateDivider(parent, y)
    local line = parent:CreateTexture(nil, "ARTWORK")
    line:SetTexture(1, 1, 1, 0.3) -- RGBA für weiße Linie mit Transparenz
    line:SetSize(160, 1)
    line:SetPoint("TOP", parent, "TOP", 0, y)
    return line
end

-- 2-Spalten-Layout für Auren
local buttonWidth, buttonHeight, buttonSpacing = 70, 44, 6
local colSpacing = 10
local auren = {
    { name = "Mythic Aura of Resistance", icon = "Interface\\Icons\\ability_druid_naturalperfection" },
    { name = "Mythic Aura of Shielding", icon = "Interface\\Icons\\achievement_dungeon_ulduarraid_misc_04" },
    { name = "Mythic Aura of the Hammer", icon = "Interface\\Icons\\spell_nature_invisibilitytotem" },
    { name = "Mythic Aura of Preservation", icon = "Interface\\Icons\\spell_nature_rejuvenation" },
    { name = "Mythic Aura of Berserking", icon = "Interface\\Icons\\ability_warrior_bloodfrenzy" },
    { name = "Mythic Aura of Damage Orbs", icon = "Interface\\Icons\\ability_rogue_hungerforblood" },
    { name = "Mythic Aura of Devotion", icon = "Interface\\Icons\\spell_holy_revivechampion" },
    { name = "Mythic Aura of Healing Orbs", icon = "Interface\\Icons\\spell_arcane_portalshattrath" }
}
local auraButtons = {}
for i, aura in ipairs(auren) do
    local col = ((i-1) % 2)
    local row = math.floor((i-1)/2)
    local btn = CreateFrame("Button", nil, mainUI)
    btn:SetSize(buttonWidth, buttonHeight)
    btn:SetPoint("TOPLEFT", mainUI, "TOPLEFT", 16 + col*(buttonWidth+colSpacing), -28 - row*(buttonHeight+buttonSpacing))

    btn.icon = btn:CreateTexture(nil, "ARTWORK")
    btn.icon:SetSize(28, 28)
    btn.icon:SetPoint("TOP", btn, "TOP", 0, -2)
    btn.icon:SetTexture(aura.icon or "Interface\\Icons\\INV_Misc_QuestionMark")

    local shortName = aura.name:match("Mythic Aura of (.+)")
    btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    btn.text:SetPoint("TOP", btn.icon, "BOTTOM", 0, -1)
    btn.text:SetText(shortName or aura.name)
    btn.text:SetTextColor(1, 0.82, 0)

    btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    btn:SetScript("OnClick", function()
        if buffTarget then
            SendChatMessage("cast "..aura.name, "WHISPER", nil, buffTarget)
            print("Aura-Anfrage '"..aura.name.."' an "..buffTarget.." gesendet.")
        else
            print("No Target selected!")
        end
    end)
    auraButtons[i] = btn
end

-- Trenner unter den Auren (nach 4 Reihen)
local dividerY = -28 - 4*(buttonHeight+buttonSpacing) - 8
CreateDivider(mainUI, dividerY)

-- Cooldown-Bereich
local cdHeader = mainUI:CreateFontString(nil, "OVERLAY", "GameFontNormal")
cdHeader:SetPoint("TOP", mainUI, "TOP", 0, dividerY - 18)
cdHeader:SetText("Cooldowns")

-- Heroism Button
local heroismSpell = "Mythic Heroism"
local heroismIconPath = "Interface\\Icons\\ability_shaman_heroism"
local heroismButton = CreateFrame("Button", nil, mainUI)
heroismButton:SetSize(buttonWidth, buttonHeight)
heroismButton:SetPoint("TOPLEFT", mainUI, "TOPLEFT", 16, dividerY - 38)

heroismButton.icon = heroismButton:CreateTexture(nil, "ARTWORK")
heroismButton.icon:SetSize(28, 28)
heroismButton.icon:SetPoint("TOP", heroismButton, "TOP", 0, -2)
heroismButton.icon:SetTexture(heroismIconPath)

heroismButton.text = heroismButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
heroismButton.text:SetPoint("TOP", heroismButton.icon, "BOTTOM", 0, -1)
heroismButton.text:SetText("Heroism")
heroismButton.text:SetTextColor(1, 0.82, 0)

-- Potion Button
local potionIconPath = "Interface\\Icons\\inv_potion_153"
local potionButton = CreateFrame("Button", nil, mainUI)
potionButton:SetSize(buttonWidth, buttonHeight)
potionButton:SetPoint("TOPLEFT", mainUI, "TOPLEFT", 16+buttonWidth+colSpacing, dividerY - 38)

potionButton.icon = potionButton:CreateTexture(nil, "ARTWORK")
potionButton.icon:SetSize(28, 28)
potionButton.icon:SetPoint("TOP", potionButton, "TOP", 0, -2)
potionButton.icon:SetTexture(potionIconPath)

potionButton.text = potionButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
potionButton.text:SetPoint("TOP", potionButton.icon, "BOTTOM", 0, -1)
potionButton.text:SetText("Potion")
potionButton.text:SetTextColor(1, 0.82, 0)

-- Timer-Balken für Heroism (10min CD, 1min Laufzeit)
local heroismCDBar = CreateFrame("StatusBar", nil, mainUI)
heroismCDBar:SetSize(150, 12)
heroismCDBar:SetPoint("TOPLEFT", mainUI, "TOPLEFT", 16, dividerY - 38 - buttonHeight - 8)
heroismCDBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
heroismCDBar:SetMinMaxValues(0, 600)
heroismCDBar:Hide()

local heroismCastBar = CreateFrame("StatusBar", nil, mainUI)
heroismCastBar:SetSize(150, 8)
heroismCastBar:SetPoint("TOPLEFT", heroismCDBar, "BOTTOMLEFT", 0, -2)
heroismCastBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
heroismCastBar:SetStatusBarColor(0, 0.8, 1)
heroismCastBar:SetMinMaxValues(0, 60)
heroismCastBar:Hide()

local heroismCasterText = mainUI:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
heroismCasterText:SetPoint("LEFT", heroismCDBar, "LEFT", 2, 0)
heroismCasterText:SetText("")

-- Timer-Balken für Potion (3min CD, 1min Laufzeit)
local potionCDBar = CreateFrame("StatusBar", nil, mainUI)
potionCDBar:SetSize(150, 12)
potionCDBar:SetPoint("TOPLEFT", mainUI, "TOPLEFT", 16, dividerY - 38 - buttonHeight - 36)
potionCDBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
potionCDBar:SetMinMaxValues(0, 180)
potionCDBar:Hide()

local potionCastBar = CreateFrame("StatusBar", nil, mainUI)
potionCastBar:SetSize(150, 8)
potionCastBar:SetPoint("TOPLEFT", potionCDBar, "BOTTOMLEFT", 0, -2)
potionCastBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
potionCastBar:SetStatusBarColor(0.2, 1, 0.2)
potionCastBar:SetMinMaxValues(0, 60)
potionCastBar:Hide()

local potionCasterText = mainUI:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
potionCasterText:SetPoint("LEFT", potionCDBar, "LEFT", 2, 0)
potionCasterText:SetText("")

-- Nach dem Erstellen aller Buttons und Balken:
mainUI:Show()
mainUI:SetScript("OnShow", function()
    -- Automatische Rahmenhöhe berechnen
    local totalHeight = 28 + 4*(buttonHeight+buttonSpacing) + 8 + 18 + buttonHeight + 8 + 12 + 2 + 8 + 36
    frame:SetHeight(totalHeight)
end)

-- Timer-Logik
local heroismCastEnd, heroismCaster = 0, ""
local potionCD, potionCastEnd, potionCaster = 0, 0, ""

local function UpdateBars()
    local now = GetTime()
    -- Heroism
    if heroismCastEnd > now then
        heroismButton:Disable()
        heroismCastBar:Show()
        heroismCastBar:SetValue(heroismCastEnd - now)
    else
        heroismButton:Enable()
        heroismCastBar:Hide()
    end
    -- Heroism CD-Balken bleibt als Info sichtbar
    if heroismCaster ~= "" and heroismCastEnd + 540 > now then
        heroismCDBar:Show()
        heroismCDBar:SetMinMaxValues(0, 600)
        heroismCDBar:SetValue(heroismCastEnd + 600 - now)
        heroismCasterText:SetText(heroismCaster)
    else
        heroismCDBar:Hide()
        heroismCasterText:SetText("")
    end
    -- Potion
    if potionCD > now then
        potionButton:Disable()
        potionCDBar:Show()
        potionCDBar:SetValue(potionCD - now)
        potionCasterText:SetText(potionCaster)
    else
        potionButton:Enable()
        potionCDBar:Hide()
        potionCasterText:SetText("")
    end
    if potionCastEnd > now then
        potionCastBar:Show()
        potionCastBar:SetValue(potionCastEnd - now)
    else
        potionCastBar:Hide()
    end
end

mainUI:SetScript("OnUpdate", UpdateBars)

heroismButton:SetScript("OnClick", function()
    if buffTarget then
        -- Anfrage senden
        SendChatMessage("cast "..heroismSpell, "WHISPER", nil, buffTarget)
        print("Heroism-Anfrage an "..buffTarget.." gesendet.")
        -- Timer starten
        heroismCastEnd = GetTime() + 60 -- 1min Laufzeit
        heroismCaster = buffTarget
    else
        print("Kein Ziel ausgewählt!")
    end
end)

potionButton:SetScript("OnClick", function()
    if buffTarget then
        -- Anfrage senden
        SendChatMessage("use Potion", "WHISPER", nil, buffTarget)
        print("Potion-Anfrage an "..buffTarget.." gesendet.")
        -- Timer starten
        potionCD = GetTime() + 180 -- 3min CD
        potionCastEnd = GetTime() + 60 -- 1min Laufzeit
        potionCaster = buffTarget
    else
        print("Kein Ziel ausgewählt!")
    end
end)

-- Passe das Frame an die neue Höhe an
frame:SetSize(2*buttonWidth+colSpacing+32, math.abs(dividerY - 38 - buttonHeight - 36 - 60))

-- Fenster beim Laden verstecken
frame:Hide()

-- Slash Command: /mhelper zum Öffnen/Schließen des Addons
SLASH_MHELPER1 = "/mhelper"
SlashCmdList["MHELPER"] = function()
    if not CanShowMythicHelper() then
        print("|cffff5555MythicHelper: Nur in einer Instanzgruppe verfügbar!|r")
        frame:Hide()
        return
    end
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end

-- Minimap Button
local minimapButton = CreateFrame("Button", "MythicHelperMinimapButton", Minimap)
minimapButton:SetSize(24, 24)
minimapButton:SetFrameStrata("MEDIUM")
minimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)
minimapButton:SetNormalTexture("Interface\\AddOns\\MythicHelper\\icon")
minimapButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

minimapButton:SetScript("OnClick", function()
    if not CanShowMythicHelper() then
        print("|cffff5555MythicHelper: Nur in einer Instanzgruppe verfügbar!|r")
        frame:Hide()
        return
    end
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end)

minimapButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("MythicHelper\nClick to Open/Close", 1, 1, 1)
    GameTooltip:Show()
end)
minimapButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

if not minimapButton:GetNormalTexture() then
    minimapButton:SetNormalTexture("Interface\\Icons\\INV_Misc_QuestionMark")
end

frame:Show()