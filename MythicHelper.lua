local addonName = ...
local frame = CreateFrame("Frame", addonName.."Frame", UIParent)
local addonJustLoaded = true
frame:SetSize(260, 400) -- Startgröße für Eingabefenster
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

-- Create independent buff warning frame (stays visible when main window is closed)
local buffWarningFrame = CreateFrame("Frame", "MythicHelperBuffWarning", UIParent)
buffWarningFrame:SetSize(400, 50)
buffWarningFrame:SetPoint("TOP", UIParent, "TOP", 0, -100) -- Position at top center of screen
buffWarningFrame:SetFrameStrata("HIGH") -- Make sure it's visible above other UI elements
buffWarningFrame:SetFrameLevel(100) -- High frame level

-- Add background for better visibility
buffWarningFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 16, edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})
buffWarningFrame:SetBackdropColor(0, 0, 0, 0.8) -- Semi-transparent black background
buffWarningFrame:SetBackdropBorderColor(1, 0, 0, 1) -- Red border

-- Buff warning text
buffWarningFrame.text = buffWarningFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
buffWarningFrame.text:SetPoint("CENTER", buffWarningFrame, "CENTER", 0, 0)
buffWarningFrame.text:SetText("")
buffWarningFrame.text:SetTextColor(1, 0, 0, 1) -- Red color
buffWarningFrame:Hide() -- Start hidden

-- Make the frame draggable
buffWarningFrame:SetMovable(true)
buffWarningFrame:EnableMouse(true)
buffWarningFrame:RegisterForDrag("LeftButton")
buffWarningFrame:SetScript("OnDragStart", buffWarningFrame.StartMoving)
buffWarningFrame:SetScript("OnDragStop", buffWarningFrame.StopMovingOrSizing)

-- Add close button to the buff warning frame
local buffWarningCloseButton = CreateFrame("Button", nil, buffWarningFrame, "UIPanelCloseButton")
buffWarningCloseButton:SetSize(16, 16)
buffWarningCloseButton:SetPoint("TOPRIGHT", buffWarningFrame, "TOPRIGHT", -2, -2)
buffWarningCloseButton:SetScript("OnClick", function() 
    buffWarningFrame:Hide() 
end)

-- Store reference to the independent warning frame
frame.buffWarning = buffWarningFrame.text
frame.buffWarningFrame = buffWarningFrame

-- 2-Spalten-Layout für Auren (Passe Y-Offset an, damit Buttons unter der Überschrift starten)
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

-- Global variables for character selection buttons
mhnameButtons = {}

-- Global timer variables
heroismCastEnd = 0
heroismCD = 0
heroismCaster = ""
potionCastEnd = 0
potionCD = 0
potionCaster = ""

-- Utility Buttons: 3rd column (right of Potion)
local utilityButtons = {
    {
        name = "No Rest",
        icon = "Interface\\Icons\\inv_drink_24_sealwhey",
        message = "nc -food"
    },
    {
        name = "No Loot",
        icon = "Interface\\Icons\\inv_misc_bag_11",
        message = "nc -loot"
    },
    {
        name = "Don't Avoid AoE",
        icon = "Interface\\Icons\\ability_rogue_quickrecovery",
        message = "co -avoid aoe"
    },
    {
        name = "Flask",
        icon = "Interface\\Icons\\inv_alchemy_endlessflask_05",
        message = "SPECIAL_FLASK"  -- Spezialwert als Marker
    },
    {
        name = "Hunter AC",
        icon = "Interface\\Icons\\spell_shadow_summonfelhunter",
        message = "MANUAL_HUNTER_AC"  -- Spezialwert für manuelles Hunter Animal Companion
    },
    {
        name = "Tank Perk",
        icon = "Interface\\Icons\\inv_shield_32",
        message = "MANUAL_TANK_PERK"  -- Spezialwert für manuelle Tank Perks
    },
    {
        name = "Priest Holy",
        icon = "Interface\\Icons\\spell_holy_powerwordbarrier",
        message = "MANUAL_PRIEST_HOLY"  -- Spezialwert für Priest Holy Form Perk
    }
}

-- Function to remove old character selection buttons
local function RemoveOldButtons()
    for _, btn in ipairs(mhnameButtons) do
        btn:Hide()
        btn:SetParent(nil)
    end    wipe(mhnameButtons)
end

-- WotLK-compatible timer function (C_Timer.After replacement)
local function DelayedCallback(delay, func)
    local frame = CreateFrame("Frame")
    local elapsed = 0
    frame:SetScript("OnUpdate", function(self, delta)
        elapsed = elapsed + delta
        if elapsed >= delay then
            func()
            self:SetScript("OnUpdate", nil)
            frame:SetParent(nil) -- entfernt das Frame
        end
    end)
end

-- Button dimensions and spacing
local buttonWidth, buttonHeight, buttonSpacing = 70, 44, 6
local colSpacing = 10

-- Global buff target variable
local buffTarget = nil

-- Function to get current buff target (with fallback)
local function GetBuffTarget()
    return buffTarget or MythicHelperMainName
end

-- Function to set buff target
local function SetBuffTarget(name)
    buffTarget = name
    MythicHelperMainName = name
    if UpdateMainName then
        UpdateMainName()
    end
end

-- Main-Name-Anzeige und Update-Funktion (defined early)
mainNameText = nil  -- Will be created later
local function UpdateMainName()
    local target = GetBuffTarget()
    if mainNameText and target and target ~= "" then
        mainNameText:SetText("Main: " .. target)
        mainNameText:Show()
    elseif mainNameText then
        mainNameText:SetText("")
        mainNameText:Hide()
    end
end

-- Helper function that needs to be defined early
local function AdjustFrameHeight()    if mainUI:IsShown() then
        local rows = 4
        local auraRows = math.ceil(#auren / 2)
        local utilRows = math.min(4, math.ceil(#utilityButtons / 2)) + 1  -- Max 4 Reihen für Utility + 1 für SpellBlocker
        local headerSpace = 28 + 26
        local aurasHeaderSpace = 26
        local dividerSpace = 24
        local cooldownHeader = 24
        local cooldownButtons = buttonHeight + 8
        local bottomButtons = 44
        local padding = 24

        -- Dynamische Zeilen für Spellblocks
        local groupSize = 0
        if GetNumRaidMembers() > 0 then
            groupSize = GetNumRaidMembers()
        elseif GetNumPartyMembers() > 0 then
            groupSize = GetNumPartyMembers() + 1 -- +1 für den Spieler selbst
        else
            groupSize = 1
        end
        local maxPerCol = 5
        local spellblockRows = math.min(maxPerCol, groupSize)

        local maxRowsAll = math.max(rows, spellblockRows, utilRows, auraRows)
        local buttonBlock = maxRowsAll * (buttonHeight + buttonSpacing)

        local totalHeight = headerSpace + aurasHeaderSpace + buttonBlock + dividerSpace + cooldownHeader + cooldownButtons + bottomButtons + padding

        -- Passe die Breite für 4 Spalten an:
        local totalWidth = 16 + 4*buttonWidth + 4*colSpacing + 16
        frame:SetWidth(totalWidth)
        frame:SetHeight(totalHeight)
    elseif inputFrame:IsShown() then
        frame:SetHeight(220)
        frame:SetWidth(360)
    else
        frame:SetHeight(80)
        frame:SetWidth(260)
    end
end

-- Function to show character selection buttons
local function ShowNameButtons()
    -- Vorherige Buttons entfernen
    RemoveOldButtons()

    -- Setze das Hauptfenster auf eine große, feste Größe für die Auswahl
    frame:SetWidth(280)
    frame:SetHeight(460)

    -- Erstelle eine Tabelle mit 10 leeren Feldern
    local names = {}
    for i = 1, 10 do
        names[i] = ""
    end
    
    -- Fülle die Tabelle mit den Namen der Gruppenmitglieder
    local count = 1
    if GetNumRaidMembers() > 0 then
        for i = 1, GetNumRaidMembers() do
            local name = GetRaidRosterInfo(i)
            if name and name ~= "" then
                names[count] = name
                count = count + 1
                if count > 10 then break end
            end
        end
    elseif GetNumPartyMembers() > 0 then
        for i = 1, GetNumPartyMembers() do
            local name = UnitName("party"..i)
            if name and name ~= "" then
                names[count] = name
                count = count + 1
                if count > 10 then break end
            end
        end
        -- Spieler selbst hinzufügen
        if count <= 10 then
            local playerName = UnitName("player")
            if playerName then
                names[count] = playerName
                count = count + 1
            end
        end
    else
        -- Solo - nur Spieler selbst
        local playerName = UnitName("player")
        if playerName then
            names[1] = playerName
        end
    end

    -- Jetzt enthält 'names' immer 10 Felder, die ersten sind ggf. mit Namen befüllt

    -- Buttons für alle 10 Felder anlegen
    local btnWidth, btnHeight = 120, 22
    local btnSpacingX, btnSpacingY = 16, 6
    local maxRows = 5 -- 5 Reihen pro Spalte
    
    for i = 1, 10 do
        local name = names[i]
        local btn = CreateFrame("Button", nil, inputFrame, "GameMenuButtonTemplate")
        btn:SetSize(btnWidth, btnHeight)
        
        -- Berechne Spalte und Reihe
        local col = math.floor((i-1) / maxRows)
        local row = (i-1) % maxRows
        
        btn:SetPoint(
            "TOPLEFT",
            inputLabel,
            "BOTTOMLEFT",
            col * (btnWidth + btnSpacingX),
            -20 - row * (btnHeight + btnSpacingY)
        )
          if name and name ~= "" then
            btn:SetText(name)
            btn:SetScript("OnClick", function()
                SetBuffTarget(name)
                mainUI:Show()
                inputFrame:Hide()
                AdjustFrameHeight()
            end)
            btn:Enable()
        else
            btn:SetText("-")
            btn:SetScript("OnClick", nil)
            btn:Disable()
        end
        btn:Show()
        table.insert(mhnameButtons, btn)
    end

    inputFrame:ClearAllPoints()
    inputFrame:SetAllPoints(frame)
end

-- Function to check if addon should be loaded
local function CanLoadMythicHelper()
    local inInstance, instanceType = IsInInstance()
    return inInstance and (instanceType == "party" or instanceType == "raid" or instanceType == "scenario" or instanceType == "pvp")
end

-- Diese Funktion muss vor einem Kampf ausgeführt werden!
local function GetSpecForHybrid(unit)
    if not UnitExists(unit) then 
        return nil 
    end
    
    -- Direktes Auslesen für den eigenen Charakter
    if unit == "player" then
        local tab1, tab2, tab3 = 0, 0, 0
        for i = 1, GetNumTalentTabs() do
            for j = 1, GetNumTalents(i) do
                local _, _, _, _, currRank = GetTalentInfo(i, j)
                if i == 1 then tab1 = tab1 + currRank
                elseif i == 2 then tab2 = tab2 + currRank
                else tab3 = tab3 + currRank end
            end
        end
        
        local _, class = UnitClass(unit)
        local maxPoints = math.max(tab1, tab2, tab3)
        
        -- Spezialisierung basierend auf Klasse und höchsten Talent-Punkten
        if class == "DRUID" then
            if maxPoints == tab1 then return "Balance"     -- Caster
            elseif maxPoints == tab2 then return "Feral"   -- Melee/Tank
            else return "Restoration" end                  -- Healer
        elseif class == "PALADIN" then
            if maxPoints == tab1 then return "Holy"        -- Healer
            elseif maxPoints == tab2 then return "Protection" -- Tank
            else return "Retribution" end                  -- Melee DPS
        elseif class == "WARRIOR" then
            if maxPoints == tab1 then return "Arms"        -- DPS
            elseif maxPoints == tab2 then return "Fury"    -- DPS
            else return "Protection" end                   -- Tank
        elseif class == "DEATHKNIGHT" then
            if maxPoints == tab1 then return "Blood"       -- Tank/DPS
            elseif maxPoints == tab2 then return "Frost"   -- DPS
            else return "Unholy" end                       -- DPS
        elseif class == "SHAMAN" then
            if maxPoints == tab1 then return "Elemental"   -- Caster DPS
            elseif maxPoints == tab2 then return "Enhancement" -- Melee DPS
            else return "Restoration" end                  -- Healer
        elseif class == "PRIEST" then
            if maxPoints == tab1 then return "Discipline"  -- Healer/Support
            elseif maxPoints == tab2 then return "Holy"    -- Healer
            else return "Shadow" end                       -- Caster DPS
        end
        
    -- Für andere Charaktere: Default-Werte nach Klasse verwenden
    else
        local _, class = UnitClass(unit)
        if class == "DRUID" then
            return "Balance"    -- Standard-Annahme für Druiden
        elseif class == "SHAMAN" then
            return "Elemental"  -- Standard-Annahme für Schamanen
        elseif class == "PRIEST" then
            return "Discipline" -- Standard-Annahme für Priester
        elseif class == "PALADIN" then
            return "Protection"       -- Standard-Annahme für Paladine
        elseif class == "DEATHKNIGHT" then
            return "Frost"      -- Standard-Annahme für Death Knights (DPS)
        elseif class == "WARRIOR" then
            return "Fury"       -- Standard-Annahme für Krieger (DPS)
        end
    end
    
    return nil
end

local function GetFlaskForClass(unit)
    local _, class = UnitClass(unit)
    
    -- Klare Melee/Physische DPS-Klassen
    if class == "WARRIOR" or 
       class == "ROGUE" or 
       class == "HUNTER" or 
       class == "DEATHKNIGHT" then
        return "Flask of Endless Rage"
    
    -- Klare Caster-Klassen
    elseif class == "MAGE" or 
           class == "WARLOCK" then
        return "Flask of the Frost Wyrm"
    
    -- Hybridklassen basierend auf Spec
    elseif class == "DRUID" or class == "SHAMAN" or class == "PALADIN" or class == "PRIEST" then
        local spec = GetSpecForHybrid(unit)

        -- Caster-Specs
        if spec == "Balance" or spec == "Elemental" or spec == "Shadow" then
            return "Flask of the Frost Wyrm"

        -- Melee-DPS-Specs
        elseif spec == "Feral" or spec == "Enhancement" or spec == "Retribution" then
            return "Flask of Endless Rage"

        -- Tank-Specs
        elseif spec == "Protection" or spec == "Blood" then
            return "Flask of Endless Rage" -- Tanks bekommen immer Endless Rage

        -- Heiler-Specs oder unbekannt
        else
            return "Flask of the Frost Wyrm"
        end
    end

    -- Fallback für alles andere (auch wenn Spec nil ist)
    return "Flask of Endless Rage"
end

local specCache = {}

local function GetCachedSpecForUnit(unit)
    local name = UnitName(unit)
    if name and specCache[name] then return specCache[name] end
    
    local spec = GetSpecForHybrid(unit)
    if spec and name then specCache[name] = spec end
    return spec

end

-- Mapping für kleine Klassenicons (WotLK 3.3.5)
local CLASS_ICON_TCOORDS = {
    WARRIOR     = {0, 0.25, 0, 0.25},
    MAGE        = {0.25, 0.49609375, 0, 0.25},
    ROGUE       = {0.49609375, 0.7421875, 0, 0.25},
    DRUID       = {0.7421875, 0.98828125, 0, 0.25},
    HUNTER      = {0, 0.25, 0.25, 0.5},
    SHAMAN      = {0.25, 0.49609375, 0.25, 0.5},
    PRIEST      = {0.49609375, 0.7421875, 0.25, 0.5},
    WARLOCK     = {0.7421875, 0.98828125, 0.25, 0.5},
    PALADIN     = {0, 0.25, 0.5, 0.75},
    DEATHKNIGHT = {0.25, 0.49609375, 0.5, 0.75},
}

local CLASS_ICONS = {
    DRUID = "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES_DRUID",
    HUNTER = "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES_HUNTER",
    MAGE = "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES_MAGE",
    PALADIN = "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES_PALADIN",
    PRIEST = "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES_PRIEST",
    ROGUE = "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES_ROGUE",
    SHAMAN = "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES_SHAMAN",
    WARLOCK = "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES_WARLOCK",
    WARRIOR = "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES_WARRIOR",
    DEATHKNIGHT = "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES_DEATHKNIGHT",
}

-- X-Button zum Schließen
local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
closeButton:SetSize(20, 20)
closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
closeButton:SetScript("OnClick", function() frame:Hide() end)

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

-- Überschrift über die Auren
local aurasHeader = mainUI:CreateFontString(nil, "OVERLAY", "GameFontNormal")
aurasHeader:SetPoint("TOPLEFT", mainUI, "TOPLEFT", 16, -54)
aurasHeader:SetText("Mythic Auras")

local auraButtons = {}
for i, aura in ipairs(auren) do
    local col = ((i-1) % 2)
    local row = math.floor((i-1)/2)
    local btn = CreateFrame("Button", nil, mainUI)
    btn:SetSize(buttonWidth, buttonHeight)
    btn:SetPoint("TOPLEFT", mainUI, "TOPLEFT", 16 + col*(buttonWidth+colSpacing), -74 - row*(buttonHeight+buttonSpacing))

    btn.icon = btn:CreateTexture(nil, "ARTWORK")
    btn.icon:SetSize(28, 28)
    btn.icon:SetPoint("TOP", btn, "TOP", 0, -2)
    btn.icon:SetTexture(aura.icon or "Interface\\Icons\\INV_Misc_QuestionMark")

    local shortName = aura.name:match("Mythic Aura of (.+)")
    btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    btn.text:SetPoint("TOP", btn.icon, "BOTTOM", 0, -1)
    btn.text:SetText(shortName or aura.name)
    btn.text:SetTextColor(1, 0.82, 0)    btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    btn:SetScript("OnClick", function()
        local target = GetBuffTarget()
        if target and target ~= "" then
            SendChatMessage("cast "..aura.name, "WHISPER", nil, target)
            print("Aura buff '"..aura.name.."' sent to "..target..".")
        else
            print("No target selected! Please choose a main character first.")
        end
    end)
    auraButtons[i] = btn
end

-- Trenner unter den Auren (nach 4 Reihen)
local dividerY = -28 - 4*(buttonHeight+buttonSpacing) - 8 - buttonHeight - 8
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

heroismButton.text = heroismButton:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
heroismButton.text:SetPoint("TOP", heroismButton.icon, "BOTTOM", 0, -1)
heroismButton.text:SetText("Heroism")
heroismButton.text:SetTextColor(1, 0.82, 0)

-- Balken unter den Text platzieren:
local barWidth, barHeight = 28, 8


-- Laufzeit-Balken (grün) direkt unter dem Button-Text
local heroismCastBar = CreateFrame("StatusBar", nil, heroismButton)
heroismCastBar:SetSize(barWidth, barHeight)
heroismCastBar:SetPoint("TOP", heroismButton.text, "BOTTOM", 0, -2)
heroismCastBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
heroismCastBar:SetStatusBarColor(0, 1, 0) -- Grün für Laufzeit
heroismCastBar:SetMinMaxValues(0, 40)
heroismCastBar:Hide()

-- Cooldown-Balken (rot) direkt unter dem Laufzeit-Balken
local heroismCDBar = CreateFrame("StatusBar", nil, heroismButton)
heroismCDBar:SetSize(barWidth, barHeight)
heroismCDBar:SetPoint("TOP", heroismButton.text, "BOTTOM", 0, -2)
heroismCDBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
heroismCDBar:SetStatusBarColor(1, 0, 0) -- Rot für CD
heroismCDBar:SetMinMaxValues(0, 600)
heroismCDBar:Hide()


-- Name des Casters ein paar Millimeter weiter nach unten
local heroismUserText = heroismButton:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
heroismUserText:SetPoint("TOP", heroismCDBar, "BOTTOM", 0, -4)
heroismUserText:SetText("")

local heroismCasterText = mainUI:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
heroismCasterText:SetPoint("LEFT", heroismCDBar, "LEFT", 2, 0)
heroismCasterText:SetText("")

-- Potion Button (direkt nach Heroism Button und vor den Potion-Balken)
local potionIconPath = "Interface\\Icons\\inv_potion_153"
local potionButton = CreateFrame("Button", nil, mainUI)
potionButton:SetSize(buttonWidth, buttonHeight)
potionButton:SetPoint("TOPLEFT", mainUI, "TOPLEFT", 16 + buttonWidth + colSpacing, dividerY - 38)

potionButton.icon = potionButton:CreateTexture(nil, "ARTWORK")
potionButton.icon:SetSize(28, 28)
potionButton.icon:SetPoint("TOP", potionButton, "TOP", 0, -2)
potionButton.icon:SetTexture(potionIconPath)

potionButton.text = potionButton:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
potionButton.text:SetPoint("TOP", potionButton.icon, "BOTTOM", 0, -1)
potionButton.text:SetText("Potion")
potionButton.text:SetTextColor(1, 0.82, 0)

-- Timer-Balken für Potion (3min CD, 1min Laufzeit) – jetzt wie das Icon und unter dem Namen
local potionBarWidth, potionBarHeight = 28, 8

local potionCDBar = CreateFrame("StatusBar", nil, potionButton)
potionCDBar:SetSize(potionBarWidth, potionBarHeight)
potionCDBar:SetPoint("TOP", potionButton.text, "BOTTOM", 0, -2)
potionCDBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
potionCDBar:SetStatusBarColor(1, 0, 0) -- Rot für CD
potionCDBar:SetMinMaxValues(0, 180)
potionCDBar:Hide()

local potionCastBar = CreateFrame("StatusBar", nil, potionButton)
potionCastBar:SetSize(potionBarWidth, potionBarHeight)
potionCastBar:SetPoint("TOP", potionButton.text, "BOTTOM", 0, -2)
potionCastBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
potionCastBar:SetStatusBarColor(0, 1, 0) -- Grün für Laufzeit
potionCastBar:SetMinMaxValues(0, 60)
potionCastBar:Hide()

-- Überschrift für die dritte Spalte (Bot Utilities) auf gleiche Höhe wie Auren
local botUtilsHeader = mainUI:CreateFontString(nil, "OVERLAY", "GameFontNormal")
botUtilsHeader:SetPoint("TOPLEFT", mainUI, "TOPLEFT", 16 + 2*(buttonWidth+colSpacing), -54)
botUtilsHeader:SetText("Bot Utilities")
-- Hilfsfunktion: Gibt alle potenziellen Tanks in der Gruppe zurück
local function GetPotentialTanks()
    local tanks = {}
    if GetNumRaidMembers() > 0 then
        for i = 1, GetNumRaidMembers() do
            local unit = "raid"..i
            local name = GetRaidRosterInfo(i)
            local _, class = UnitClass(unit)
            if name and class and (class == "PALADIN" or class == "WARRIOR" or class == "DEATHKNIGHT" or class == "DRUID") then
                table.insert(tanks, name)
            end
        end
    elseif GetNumPartyMembers() > 0 then
        for i = 1, GetNumPartyMembers() do
            local unit = "party"..i
            local name = UnitName(unit)
            local _, class = UnitClass(unit)
            if name and class and (class == "PALADIN" or class == "WARRIOR" or class == "DEATHKNIGHT" or class == "DRUID") then
                table.insert(tanks, name)
            end
        end
        -- Spieler selbst prüfen
        local playerName = UnitName("player")
        local _, playerClass = UnitClass("player")
        if playerName and playerClass and (playerClass == "PALADIN" or playerClass == "WARRIOR" or playerClass == "DEATHKNIGHT" or playerClass == "DRUID") then
            table.insert(tanks, playerName)
        end
    else
        -- Solo
        local playerName = UnitName("player")
        local _, playerClass = UnitClass("player")
        if playerName and playerClass and (playerClass == "PALADIN" or playerClass == "WARRIOR" or playerClass == "DEATHKNIGHT" or playerClass == "DRUID") then
            table.insert(tanks, playerName)
        end
    end
    return tanks
end

-- Utility Buttons: In 2 Spalten anordnen (max 4 pro Spalte)
for i, btnData in ipairs(utilityButtons) do
    local btn = CreateFrame("Button", nil, mainUI)
    btn:SetSize(buttonWidth, buttonHeight)
    
    -- Berechne Spalte und Reihe (max 4 pro Spalte)
    local col = math.floor((i-1) / 4)  -- 0 für erste Spalte, 1 für zweite Spalte
    local row = (i-1) % 4              -- 0-3 für die Reihen
    
    -- Position: Spalte 3 (col=0) oder Spalte 4 (col=1)
    local xPos = 16 + (2 + col) * (buttonWidth + colSpacing)
    local yPos = -74 - row * (buttonHeight + buttonSpacing)
    
    btn:SetPoint("TOPLEFT", mainUI, "TOPLEFT", xPos, yPos)

    btn.icon = btn:CreateTexture(nil, "ARTWORK")
    btn.icon:SetSize(28, 28)
    btn.icon:SetPoint("TOP", btn, "TOP", 0, -2)
    btn.icon:SetTexture(btnData.icon)
    btn:RegisterForClicks("AnyUp")

    btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    btn.text:SetPoint("TOP", btn.icon, "BOTTOM", 0, -1)    
    btn.text:SetText(btnData.name)
    btn.text:SetTextColor(1, 0.82, 0)

    btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        if btnData.message == "SPECIAL_FLASK" then
            GameTooltip:SetText("Class-Specific Flasks", 1, 1, 1)
            GameTooltip:AddLine("Sends appropriate flask to each player:", 0.7, 0.7, 1)
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Melee/Physical DPS: Flask of Endless Rage", 1, 0.8, 0.6)
            GameTooltip:AddLine("Caster DPS: Flask of the Frost Wyrm", 1, 0.8, 0.6)
            GameTooltip:AddLine("Healers: Flask of the Frost Wyrm", 1, 0.8, 0.6)
            GameTooltip:AddLine("Tanks: Flask of Endless Rage", 1, 0.8, 0.6)
        elseif btnData.message == "MANUAL_HUNTER_AC" then
            GameTooltip:SetText("Hunter Animal Companion", 1, 1, 1)
            GameTooltip:AddLine("Sends Animal Companion (81594) to all hunters", 0.7, 0.7, 1)
            GameTooltip:AddLine("Only sends to hunters who haven't received it yet", 1, 0.8, 0.6)
            GameTooltip:AddLine("Useful for manually distributing to all hunters", 0.8, 0.8, 1)
        elseif btnData.message == "MANUAL_TANK_PERK" then
            GameTooltip:SetText("Tank Perks", 1, 1, 1)
            GameTooltip:AddLine("Sends Shield of Destiny (81535) to all tanks", 0.7, 0.7, 1)
            GameTooltip:AddLine("Works for: Blood DK, Prot Warrior, Prot Paladin, Feral Druid", 0.8, 0.8, 1)
            GameTooltip:AddLine("Only sends to tanks who haven't received it yet", 1, 0.8, 0.6)
            GameTooltip:AddLine("|cff00ff00Right Klick: add Tank manual |r", 0.6, 1, 0.6)
        elseif btnData.message == "MANUAL_PRIEST_HOLY" then
            GameTooltip:SetText("Priest Holy Form", 1, 1, 1)
            GameTooltip:AddLine("Sends Holy Form (81099) to all priests", 0.7, 0.7, 1)
            GameTooltip:AddLine("Only sends to priests who haven't received it yet", 1, 0.8, 0.6)
            GameTooltip:AddLine("Useful for manually distributing to all priests", 0.8, 0.8, 1)
        elseif btnData.message == "nc -food" then
            GameTooltip:SetText("No Rest", 1, 1, 1)
            GameTooltip:AddLine("Disables automatic food consumption", 0.7, 0.7, 1)
            GameTooltip:AddLine("Prevents bots from eating unnecessarily", 1, 0.8, 0.6)
        elseif btnData.message == "nc -loot" then
            GameTooltip:SetText("No Loot", 1, 1, 1)
            GameTooltip:AddLine("Disables automatic looting", 0.7, 0.7, 1)
            GameTooltip:AddLine("Prevents bots from looting during combat", 1, 0.8, 0.6)
        elseif btnData.message == "co -avoid aoe" then
            GameTooltip:SetText("Don't Avoid AoE", 1, 1, 1)
            GameTooltip:AddLine("Disables AoE avoidance behavior", 0.7, 0.7, 1)
            GameTooltip:AddLine("Useful for stacking mechanics", 1, 0.8, 0.6)
        else
            GameTooltip:SetText(btnData.name, 1, 1, 1)
            GameTooltip:AddLine("Bot utility command", 0.7, 0.7, 1)
        end
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    btn:SetScript("OnClick", function(self, button)
        if btnData.message == "SPECIAL_FLASK" then
            -- Spezieller Fall: An jeden Spieler individuellen Flask senden
            if GetNumRaidMembers() > 0 then
                for i = 1, GetNumRaidMembers() do
                    local name = GetRaidRosterInfo(i)
                    local unit = "raid"..i
                    if name and UnitExists(unit) then
                        local flask = GetFlaskForClass(unit)
                        SendChatMessage("u " .. flask, "WHISPER", nil, name)
                    end
                end
            elseif GetNumPartyMembers() > 0 then
                for i = 1, GetNumPartyMembers() do
                    local unit = "party"..i
                    local name = UnitName(unit)
                    if name and UnitExists(unit) then
                        local flask = GetFlaskForClass(unit)
                        SendChatMessage("u " .. flask, "WHISPER", nil, name)
                    end
                end
                -- Auch dem Spieler selbst
                local flask = GetFlaskForClass("player")
                SendChatMessage("u " .. flask, "WHISPER", nil, UnitName("player"))
            end
        end    
        if btnData.message == "MANUAL_TANK_PERK" then
    if button == "RightButton" then
        -- Nur potenzielle Tanks anzeigen!
        local menu = {}
        local tanks = GetPotentialTanks()
        local selectedTank = GetSelectedTank()
            for _, name in ipairs(tanks) do
                table.insert(menu, {
                text = name .. (selectedTank == name and " |cff55ff55✓|r" or ""),
                func = function()
                 SetSelectedTank(name)
                MythicHelper_SetBuffWarning("Tank ausgewählt: " .. name)
                 DelayedCallback(2, MythicHelper_ClearBuffWarning)
            end,
        notCheckable = true
        })
        end
        table.insert(menu, { text = "Schließen", func = function() CloseDropDownMenus() end, notCheckable = true })
        if not MythicHelperTankMenuFrame then
            MythicHelperTankMenuFrame = CreateFrame("Frame", "MythicHelperTankMenuFrame", UIParent, "UIDropDownMenuTemplate")
        end
        EasyMenu(menu, MythicHelperTankMenuFrame, "cursor", 0, 0, "MENU")
    else
                local selected = GetSelectedTank()
                if selected then
                    -- SpellID 81535: Shield of Destiny
                    SendChatMessage("cast 81535", "WHISPER", nil, selected)
                    tankPerkSent[selected] = true
                    MythicHelper_SetBuffWarning("Tank Perk an "..selected.." gesendet")
                    DelayedCallback(3, MythicHelper_ClearBuffWarning)
                else
                    ManualSendTankPerks()
                end
            end
        elseif btnData.message == "MANUAL_HUNTER_AC" then
            ManualSendHunterAnimalCompanion()
        elseif btnData.message == "MANUAL_PRIEST_HOLY" then
            ManualSendPriestHolyPerks()
        else
            -- Standard-Button-Verhalten für andere Buttons
            local msg = type(btnData.message) == "function" 
                      and btnData.message("target")
                      or btnData.message
                      
            if GetNumRaidMembers() > 0 then
                SendChatMessage(msg, "RAID")
            elseif GetNumPartyMembers() > 0 then
                SendChatMessage(msg, "PARTY")
            end
        end
    end)
end

-- Change Main Button (unten in der Mitte)
local changeMainButton = CreateFrame("Button", nil, mainUI)
changeMainButton:SetSize(90, 18)
changeMainButton:SetPoint("BOTTOM", mainUI, "BOTTOM", 0, 8) -- zentriert
changeMainButton.text = changeMainButton:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
changeMainButton.text:SetPoint("CENTER", changeMainButton, "CENTER", 0, 0)
changeMainButton.text:SetText("Change Main")
changeMainButton.text:SetTextColor(1, 0.82, 0)
changeMainButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
changeMainButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Change Main Character", 1, 1, 1)
    GameTooltip:AddLine("Opens character selection window", 0.7, 0.7, 1)
    GameTooltip:AddLine("Choose who should receive aura buffs", 1, 0.8, 0.6)
    GameTooltip:Show()
end)
changeMainButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
changeMainButton:SetScript("OnClick", function()
    mainUI:Hide()
    inputFrame:Show()
    AdjustFrameHeight()
end)

-- Show/Hide Tracker Button (rechts neben Change Main)
local showTrackerButton = CreateFrame("Button", nil, mainUI)
showTrackerButton:SetSize(80, 18)
showTrackerButton:SetPoint("BOTTOM", mainUI, "BOTTOM", 90, 8) -- weiter rechts
showTrackerButton.text = showTrackerButton:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
showTrackerButton.text:SetPoint("CENTER", showTrackerButton, "CENTER", 0, 0)
showTrackerButton.text:SetText("Show Tracker")
showTrackerButton.text:SetTextColor(1, 0.82, 0)
showTrackerButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
showTrackerButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Mythic Trash Tracker", 1, 1, 1)
    GameTooltip:AddLine("Toggle visibility of the trash percentage tracker", 0.7, 0.7, 1)
    GameTooltip:AddLine("Shows progress bars for enemy forces in Mythic dungeons", 1, 0.8, 0.6)
    GameTooltip:AddLine("Helps track completion percentage for Mythic+ requirements", 0.7, 0.7, 1)
    GameTooltip:Show()
end)
showTrackerButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
local trackerVisible = false
showTrackerButton:SetScript("OnClick", function()
    if MythicTrashTracker_ToggleVisibility then
        MythicTrashTracker_ToggleVisibility()
        if MythicTrashTracker_IsVisible and MythicTrashTracker_IsVisible() then
            showTrackerButton.text:SetText("Hide Tracker")
        else
            showTrackerButton.text:SetText("Show Tracker")
        end
    else
        local frame = _G["MythicTrashTrackerProgressBarContainer"]
        if frame then
            if frame:IsShown() then
                frame:Hide()
                showTrackerButton.text:SetText("Show Tracker")
            else
                frame:Show()
                showTrackerButton.text:SetText("Hide Tracker")
            end
        else
            print("MythicTrashTracker not found!")
        end
    end
end)

-- Timer update function
local function UpdateBars()
    local now = GetTime()
    -- Heroism
    if heroismCastEnd and heroismCastEnd > now and heroismCaster and heroismCaster ~= "" then
        -- Laufzeit läuft (grüner Balken) UND Cooldown läuft (roter Balken)
        heroismCastBar:Show()
        heroismCastBar:SetMinMaxValues(0, 40)
        heroismCastBar:SetValue(heroismCastEnd - now)
        heroismCDBar:Show()
        heroismCDBar:SetMinMaxValues(0, 600)
        heroismCDBar:SetValue(heroismCastEnd + 600 - now)
        heroismButton:Disable()
        heroismUserText:SetText(heroismCaster)
    elseif heroismCastEnd and heroismCastEnd + 600 > now and heroismCaster and heroismCaster ~= "" then
        -- Nur Cooldown läuft (roter Balken)
        heroismCastBar:Hide()
        heroismCDBar:Show()
        heroismCDBar:SetMinMaxValues(0, 600)
        heroismCDBar:SetValue(heroismCastEnd + 600 - now)
        heroismButton:Enable()
        heroismUserText:SetText(heroismCaster)
    else
        -- Kein Balken, alles zurücksetzen
        heroismCastBar:Hide()
        heroismCDBar:Hide()
        heroismButton:Enable()
        heroismUserText:SetText("")
        heroismCastEnd = 0
        if heroismCaster and heroismCaster ~= "" then
            heroismUserText:SetText(heroismCaster)
        else
            heroismUserText:SetText("")
        end
    end

    -- Potion
    if potionCD and potionCD > now then
        if potionCDBar then
            potionCDBar:Show()
            potionCDBar:SetValue(potionCD - now)
        end
    else
        if potionButton then potionButton:Enable() end
        if potionCDBar then potionCDBar:Hide() end
    end
    if potionCastEnd and potionCastEnd > now then
        if potionCastBar then
            potionCastBar:Show()
            potionCastBar:SetValue(potionCastEnd - now)
        end
    else
        if potionCastBar then potionCastBar:Hide() end
    end
end

mainUI:SetScript("OnUpdate", UpdateBars)

-- Create main name text display
mainNameText = mainUI:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
mainNameText:SetPoint("TOP", mainUI, "TOP", 0, -28)
mainNameText:SetText("")

-- Timer variables (other supporting variables)
potionCDPending = false
heroismQueue = {}
heroismQueueIndex = 1

-- Heroism queue management
local function FillHeroismQueue()
    wipe(heroismQueue)
    if GetNumRaidMembers() > 0 then
        for i = 1, GetNumRaidMembers() do
            local name = GetRaidRosterInfo(i)
            if type(name) == "string" and name ~= "" then
                table.insert(heroismQueue, name)
            end
        end
    else
        -- Party oder Solo
        for i = 1, GetNumPartyMembers() do
            local name = UnitName("party"..i)
            if type(name) == "string" and name ~= "" then
                table.insert(heroismQueue, name)
            end
        end
        -- Spieler selbst hinzufügen, falls nicht schon drin
        local playerName = UnitName("player")
        local alreadyInQueue = false
        for _, n in ipairs(heroismQueue) do
            if n == playerName then alreadyInQueue = true break end
        end
        if not alreadyInQueue then
            table.insert(heroismQueue, playerName)
        end
    end
    if type(MythicHelper_HeroismQueue) == "table" and #MythicHelper_HeroismQueue > 0 then
        heroismQueue = {}
        for i, v in ipairs(MythicHelper_HeroismQueue) do heroismQueue[i] = v end
    end
    if type(MythicHelper_HeroismQueueIndex) == "number" and MythicHelper_HeroismQueueIndex >= 1 and MythicHelper_HeroismQueueIndex <= #heroismQueue then
        heroismQueueIndex = MythicHelper_HeroismQueueIndex
    else
        heroismQueueIndex = 1
    end
    if type(MythicHelper_LastHeroismCaster) == "string" and MythicHelper_LastHeroismCaster ~= "" then
        heroismCaster = MythicHelper_LastHeroismCaster
        heroismUserText:SetText(heroismCaster)
    end
end
-- Tooltip für Heroism Button
heroismButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Mythic Heroism", 1, 1, 1)
    GameTooltip:AddLine("Sends Heroism spell to next player in queue", 0.7, 0.7, 1)
    GameTooltip:AddLine("Duration: 40 seconds", 0, 1, 0)
    GameTooltip:AddLine("Cooldown: 10 minutes", 1, 0.5, 0)
    GameTooltip:AddLine("Auto-rotates through group members", 0.7, 0.7, 1)
    GameTooltip:Show()
end)
heroismButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- Set up button click handlers
heroismButton:SetScript("OnClick", function()
    if #heroismQueue == 0 then FillHeroismQueue() end
    local nextUser = heroismQueue[heroismQueueIndex]
    if nextUser then
        SendChatMessage("cast "..heroismSpell, "WHISPER", nil, nextUser)
        -- Heroism läuft jetzt NEU (immer überschreiben)
        heroismCastEnd = GetTime() + 40 -- 40 Sekunden Laufzeit
        heroismCaster = nextUser
        MythicHelper_LastHeroismCaster = nextUser
        heroismUserText:SetText(nextUser)
        heroismButton:Disable()
        heroismCastBar:SetMinMaxValues(0, 40)
        heroismCastBar:SetValue(40)
        heroismCastBar:Show()
        heroismCDBar:SetMinMaxValues(0, 600)
        heroismCDBar:SetValue(0)
        heroismCDBar:Show()
        UpdateBars() -- <<--- WICHTIG: UI sofort updaten!
        -- Zum nächsten Spieler in der Queue wechseln
        heroismQueueIndex = heroismQueueIndex + 1
        if heroismQueueIndex > #heroismQueue then heroismQueueIndex = 1 end
    end
end)

-- Tooltip für Potion Button
potionButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Mythic Endless Assault Potion", 1, 1, 1)
    GameTooltip:AddLine("Sends potion request to all group members", 0.7, 0.7, 1)
    GameTooltip:AddLine("Duration: 60 seconds", 0, 1, 0)
    GameTooltip:AddLine("Cooldown: 3 minutes", 1, 0.5, 0)
    GameTooltip:AddLine("Use for DPS boost during encounters", 0.7, 0.7, 1)
    GameTooltip:Show()
end)
potionButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

potionButton:SetScript("OnClick", function()
    local potionSpell = "Mythic Endless Assault Potion"
    local sent = false

    if GetNumRaidMembers() > 0 then
        SendChatMessage("u "..potionSpell, "RAID")
        sent = true
    elseif GetNumPartyMembers() > 0 then
        SendChatMessage("u "..potionSpell, "PARTY")
        sent = true
    else
        print("No group members found!")
    end

    if sent then
        print("Mythic Endless Assault Potion command sent to group.")
        -- Start timer
        potionCastEnd = GetTime() + 60  -- 60 Sekunden Laufzeit
        potionCD = GetTime() + 180      -- 180 Sekunden Cooldown
        potionCaster = "Group"
    end
end)

-- Formular-Frame für Charakternamen
inputFrame = CreateFrame("Frame", nil, frame)
inputFrame:SetAllPoints(frame)

inputLabel = inputFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
inputLabel:SetPoint("TOP", inputFrame, "TOP", 0, -38)
inputLabel:SetText("Select Character with the highest Aura Ranks:")

-- Set up inputFrame event handler
inputFrame:HookScript("OnShow", function()
    ShowNameButtons()
    AdjustFrameHeight()
end)

-- Initial addon load check and setup
-- Initialize variables after loading saved data
if MythicHelperMainName then
    SetBuffTarget(MythicHelperMainName)
    mainUI:Show()
    inputFrame:Hide()
    -- Delayed call to ensure mainNameText is created
    DelayedCallback(0.1, function()
        UpdateMainName()
    end)
else
    mainUI:Hide()
    inputFrame:Show()
    ShowNameButtons()
end

-- Initial check when addon loads - only show if in instance
if CanLoadMythicHelper() then
    frame:Show()
    AdjustFrameHeight()
    print("|cff55ff55MythicHelper: Addon loaded!|r")
else
    frame:Hide()  -- Hide frame if not in instance
end

-- Mapping: Klasse -> Spellname für Flüstern
classWhisperSpells = {
    PALADIN = { "cast Avenging Wrath" },
    SHAMAN = { "cast Bloodlust", "cast Heroism" },
    WARRIOR = { "cast Death Wish" },
    MAGE = { "cast Combustion", "cast Arcane Power" },
    PRIEST = { "cast Power Infusion" },
    ROGUE = { "cast Adrenaline Rush" },
    HUNTER = { "cast Rapid Fire" },
    WARLOCK = { "cast Metamorphosis" },
    DRUID = { "cast Berserk" },
    DEATHKNIGHT = { "cast Unbreakable Armor" },
}

-- Special Class Whisper Icon-Button (rechts neben Potion)
local specialWhisperIcon = "Interface\\Icons\\achievement_pvp_o_h" -- Wähle ein beliebiges Icon

-- Calculate dividerY if not available
local dividerY = dividerY or (-28 - 4*(buttonHeight+buttonSpacing) - 8 - buttonHeight - 8)

local specialWhisperButton = CreateFrame("Button", nil, mainUI)
specialWhisperButton:SetSize(buttonWidth, buttonHeight)
specialWhisperButton:SetPoint("TOPLEFT", mainUI, "TOPLEFT", 16 + 2*(buttonWidth+colSpacing), dividerY - 38)

specialWhisperButton.icon = specialWhisperButton:CreateTexture(nil, "ARTWORK")
specialWhisperButton.icon:SetSize(28, 28)
specialWhisperButton.icon:SetPoint("TOP", specialWhisperButton, "TOP", 0, -2)
specialWhisperButton.icon:SetTexture(specialWhisperIcon)

specialWhisperButton.text = specialWhisperButton:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
specialWhisperButton.text:SetPoint("TOP", specialWhisperButton.icon, "BOTTOM", 0, -1)
specialWhisperButton.text:SetText("Special")
specialWhisperButton.text:SetTextColor(1, 0.82, 0)

specialWhisperButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")

-- Tooltip für Special Button
specialWhisperButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Special Class Cooldowns", 1, 1, 1)
    GameTooltip:AddLine("Left Click: Sends class-specific cooldown spells to all group members", 0, 1, 0)
    GameTooltip:AddLine("Right Click: Blocks class-specific cooldown spells for all group members", 1, 0.5, 0)
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("Paladin: Avenging Wrath", 1, 0.8, 0.6)
    GameTooltip:AddLine("Shaman: Bloodlust/Heroism", 1, 0.8, 0.6)
    GameTooltip:AddLine("Warrior: Death Wish", 1, 0.8, 0.6)
    GameTooltip:AddLine("Mage: Combustion/Arcane Power", 1, 0.8, 0.6)
    GameTooltip:AddLine("Priest: Power Infusion", 1, 0.8, 0.6)
    GameTooltip:AddLine("Rogue: Adrenaline Rush", 1, 0.8, 0.6)
    GameTooltip:AddLine("Hunter: Rapid Fire", 1, 0.8, 0.6)
    GameTooltip:AddLine("Warlock: Metamorphosis", 1, 0.8, 0.6)
    GameTooltip:AddLine("Druid: Berserk", 1, 0.8, 0.6)
    GameTooltip:AddLine("Death Knight: Unbreakable Armor", 1, 0.8, 0.6)
    GameTooltip:Show()
end)
specialWhisperButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
specialWhisperButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
specialWhisperButton:SetScript("OnClick", function(self, button)
    local sentCount = 0

    -- Deine Special-Spells (nur diese IDs werden verschickt)
    local specialSpells = {
        PALADIN = 31884,      -- Avenging Wrath
        SHAMAN = 2825,        -- Bloodlust
        WARRIOR = 1719,       -- Recklessness
        MAGE = 11129,         -- Combustion
        PRIEST = 10060,       -- Power Infusion
        ROGUE = 13750,        -- Adrenaline Rush
        HUNTER = 3045,        -- Rapid Fire
        WARLOCK = 47241,      -- Metamorphosis
        DRUID = 50334,        -- Berserk
        DEATHKNIGHT = 51271,  -- Unbreakable Armor
    }

    local function SendSpecialSS(name, class)
        local spellId = specialSpells[class]
        if spellId then
            local command = "ss +"..spellId
            SendChatMessage(command, "WHISPER", nil, name)
            sentCount = sentCount + 1
        end
    end

    local function SendClassSpells(name, class)
        local spells = classWhisperSpells[class]
        if spells and #spells > 0 then
            for _, spell in ipairs(spells) do
                SendChatMessage(spell, "WHISPER", nil, name)
                sentCount = sentCount + 1
            end
        end
    end

    if button == "RightButton" then
        -- RAID
        if GetNumRaidMembers() > 0 then
            for i = 1, GetNumRaidMembers() do
                local unit = "raid"..i
                local name = GetRaidRosterInfo(i)
                local _, class = UnitClass(unit)
                if name and class then
                    SendSpecialSS(name, class)
                end
            end
        -- PARTY
        elseif GetNumPartyMembers() > 0 then
            for i = 1, GetNumPartyMembers() do
                local unit = "party"..i
                local name = UnitName(unit)
                local _, class = UnitClass(unit)
                if name and class then
                    SendSpecialSS(name, class)
                end
            end
            -- Auch an den Spieler selbst
            local playerName = UnitName("player")
            local _, playerClass = UnitClass("player")
            if playerName and playerClass then
                SendSpecialSS(playerName, playerClass)
            end
        end
        print("Sent "..sentCount.." special ss +<SpellID> commands.")
        return
    end

    -- Linksklick: wie bisher
    if GetNumRaidMembers() > 0 then
        for i = 1, GetNumRaidMembers() do
            local unit = "raid"..i
            local name = GetRaidRosterInfo(i)
            local _, class = UnitClass(unit)
            if name and class then
                SendClassSpells(name, class)
            end
        end
    elseif GetNumPartyMembers() > 0 then
        for i = 1, GetNumPartyMembers() do
            local unit = "party"..i
            local name = UnitName(unit)
            local _, class = UnitClass(unit)
            if name and class then
                SendClassSpells(name, class)
            end
        end
        local playerName = UnitName("player")
        local _, playerClass = UnitClass("player")
        if playerName and playerClass then
            SendClassSpells(playerName, playerClass)
        end
    else
        print("No group found!")
        return
    end

    if sentCount > 0 then
        print("Sent " .. sentCount .. " class-specific cooldown spells to group members.")
    else
        print("No spells sent - check if classWhisperSpells table is defined.")
    end
end)

-- SpellBlocker Options Button (unterhalb des Special Buttons)
local spellBlockerIcon = "Interface\\Icons\\spell_chargenegative" -- Wähle ein passendes Icon

local spellBlockerButton = CreateFrame("Button", nil, mainUI)
spellBlockerButton:SetSize(buttonWidth, buttonHeight)
spellBlockerButton:SetPoint("TOPLEFT", specialWhisperButton, "BOTTOMLEFT", 0, -buttonSpacing)

spellBlockerButton.icon = spellBlockerButton:CreateTexture(nil, "ARTWORK")
spellBlockerButton.icon:SetSize(28, 28)
spellBlockerButton.icon:SetPoint("TOP", spellBlockerButton, "TOP", 0, -2)
spellBlockerButton.icon:SetTexture(spellBlockerIcon)

spellBlockerButton.text = spellBlockerButton:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
spellBlockerButton.text:SetPoint("TOP", spellBlockerButton.icon, "BOTTOM", 0, -1)
spellBlockerButton.text:SetText("SpellBlock")
spellBlockerButton.text:SetTextColor(1, 0.82, 0)

spellBlockerButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")

-- Tooltip für SpellBlocker Button
spellBlockerButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("SpellBlocker Control", 1, 1, 1)
    GameTooltip:AddLine("Manages spell blocking for group members:", 0.7, 0.7, 1)
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("Left Click: Send current blocks to group", 0, 1, 0)
    GameTooltip:AddLine("Right Click: Open SpellBlocker options", 0, 1, 0)
    GameTooltip:AddLine("Shift + Left Click: Reset all blocks", 1, 0.5, 0)
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("Configure which spells each class should block", 0.7, 0.7, 1)
    GameTooltip:AddLine("to prevent accidental casting in Mythic dungeons.", 0.7, 0.7, 1)
    GameTooltip:Show()
end)
spellBlockerButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

spellBlockerButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
spellBlockerButton:SetScript("OnClick", function(self, button)
    if button == "LeftButton" then
        if IsShiftKeyDown() then
            -- Shift+LeftClick: Reset all blocks
            if ResetAllBlockLists then
                ResetAllBlockLists()
                print("All spell blocks have been reset.")
            else
                print("SpellBlocker not loaded!")
            end        else
            -- LeftClick: Send all current blocks to group
            if SendBlockCommandsToGroup then
                SendBlockCommandsToGroup()
                print("Current spell blocks sent to group.")
            else
                print("SpellBlocker not loaded!")
            end
        end
    elseif button == "RightButton" then
        -- RightClick: Open SpellBlocker options
        local optionsFrame = _G["SpellBlockerOptions"]
        if optionsFrame then
            if optionsFrame:IsShown() then
                optionsFrame:Hide()
            else
                optionsFrame:Show()
            end
        else
            print("SpellBlocker addon not loaded or options frame not found!")
        end
    end
end)

-- Focus Button (rechts neben Special)
local focusButton = CreateFrame("Button", nil, mainUI)
focusButton:SetSize(buttonWidth, buttonHeight)
focusButton:SetPoint("TOPLEFT", specialWhisperButton, "TOPRIGHT", colSpacing, 0)

focusButton.icon = focusButton:CreateTexture(nil, "ARTWORK")
focusButton.icon:SetSize(28, 28)
focusButton.icon:SetPoint("TOP", focusButton, "TOP", 0, -2)
focusButton.icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_8") -- Totenkopf

focusButton.text = focusButton:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
focusButton.text:SetPoint("TOP", focusButton.icon, "BOTTOM", 0, -1)
focusButton.text:SetText("Focus")
focusButton.text:SetTextColor(1, 0.2, 0.2)

focusButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")

focusButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Focus on Singletarget", 1, 0, 0) -- Rote Überschrift
    GameTooltip:AddLine("ATTENTION Bots will attack immediately", 1, 0, 0)
    GameTooltip:Show()
end)
focusButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

focusButton:SetScript("OnClick", function()
    -- Markiere das aktuelle Target mit Totenkopf
    SetRaidTarget("target", 8)
    -- Flüstere allen Gruppenmitgliedern "focus"
    if GetNumRaidMembers() > 0 then
        for i = 1, GetNumRaidMembers() do
            local name = GetRaidRosterInfo(i)
            if name and name ~= UnitName("player") then
                SendChatMessage("focus", "WHISPER", nil, name)
            end
        end
    elseif GetNumPartyMembers() > 0 then
        for i = 1, GetNumPartyMembers() do
            local name = UnitName("party"..i)
            if name and name ~= UnitName("player") then
                SendChatMessage("focus", "WHISPER", nil, name)
            end
        end
    end
end)

-- Combined dropdown menu for minimap button
function CreateCombinedDropdownMenu()
    local menuFrame = CreateFrame("Frame", "MythicHelperCombinedMenu", UIParent, "UIDropDownMenuTemplate")
    
    local menuItems = {
        {
            text = "|cff55ff55MythicHelper|r",
            isTitle = true,
            notCheckable = true
        },
        {
            text = "Toggle MythicHelper Window",
            func = function()
                if not CanLoadMythicHelper() then
                    print("|cffff5555MythicHelper: Available only in Raids or Instance!|r")
                    frame:Hide()
                    return
                end
                if frame:IsShown() then
                    frame:Hide()
                else
                    frame:Show()
                    AdjustFrameHeight()
                end
                CloseDropDownMenus()
            end,
            notCheckable = true
        },
        {
            text = " ",
            isTitle = true,
            notCheckable = true
        },
        {
            text = "|cffffa500MythicTrashTracker|r",
            isTitle = true,
            notCheckable = true
        }
    }
    
    -- Add TrashTracker menu items directly
    if MythicTrashTracker_IsVisible then
        table.insert(menuItems, {
            text = "Show/Hide Tracker",
            func = function()
                if MythicTrashTracker_ToggleVisibility then
                    MythicTrashTracker_ToggleVisibility()
                end
                CloseDropDownMenus()
            end,
            notCheckable = true
        })
        
        -- Add all tracker options directly to the main menu
        table.insert(menuItems, {
            text = "Toggle All Buffs",
            func = function()
                -- Call the function from MythicTrashTracker if available
                if _G["OPTIONS"] and _G["RequiredBuffGroups"] and _G["UpdateBuffGroupButtons"] then
                    local allEnabled = true
                    for i = 1, #_G["RequiredBuffGroups"] do
                        if not _G["OPTIONS"].buffGroups[i] then
                            allEnabled = false
                            break
                        end
                    end
                    
                    for i = 1, #_G["RequiredBuffGroups"] do
                        _G["OPTIONS"].buffGroups[i] = not allEnabled
                    end
                    
                    _G["UpdateBuffGroupButtons"]()
                    local lang = _G["OPTIONS"].language or "en"
                    print("|cFFFFA500[MythicTrashTracker]: " .. (lang == "de" and "Alle Buff-Gruppen " or "All Buff Groups ") .. (allEnabled and (lang == "de" and "deaktiviert." or "disabled.") or (lang == "de" and "aktiviert." or "enabled.")))
                end
                CloseDropDownMenus()
            end,
            notCheckable = true
        })
        
        table.insert(menuItems, {
            text = "Sound on/off",
            isNotRadio = true,
            checked = function() 
                return _G["OPTIONS"] and _G["OPTIONS"].soundEnabled or false
            end,
            func = function()
                if _G["OPTIONS"] then
                    _G["OPTIONS"].soundEnabled = not _G["OPTIONS"].soundEnabled
                    local lang = _G["OPTIONS"].language or "en"
                    print("|cFFFFA500[MythicTrashTracker]: " .. (lang == "de" and "Sound " or "Sound ") .. (_G["OPTIONS"].soundEnabled and (lang == "de" and "aktiviert." or "enabled.") or (lang == "de" and "deaktiviert." or "disabled.")))
                end
                CloseDropDownMenus()
            end
        })
        
        table.insert(menuItems, {
            text = "Buff-Tracking on/off",
            isNotRadio = true,
            checked = function() 
                return _G["OPTIONS"] and _G["OPTIONS"].trackBuffs or false
            end,
            func = function()
                if _G["OPTIONS"] then
                    _G["OPTIONS"].trackBuffs = not _G["OPTIONS"].trackBuffs
                    if _G["OPTIONS"].trackBuffs then
                        if _G["EnableBuffChecker"] then _G["EnableBuffChecker"]() end
                    else
                        if _G["DisableBuffChecker"] then _G["DisableBuffChecker"]() end
                    end
                    if _G["UpdateBuffTrackingUI"] then _G["UpdateBuffTrackingUI"]() end
                end
                CloseDropDownMenus()
            end
        })
        
        table.insert(menuItems, {
            text = "Advanced Tracker Options...",
            func = function()
                if _G["OpenOptionsWindow"] then
                    _G["OpenOptionsWindow"]()
                else
                    print("|cFFFF0000[MythicTrashTracker]: OpenOptionsWindow is not available.")
                end
                CloseDropDownMenus()
            end,
            notCheckable = true
        })
    end
    
    table.insert(menuItems, {
        text = " ",
        isTitle = true,
        notCheckable = true
    })
    
    table.insert(menuItems, {
        text = "Close",
        func = function()
            CloseDropDownMenus()
        end,
        notCheckable = true
    })
    
    EasyMenu(menuItems, menuFrame, "cursor", 0, 0, "MENU")
end

-- Ereignis-Handler für Instanzwechsel
local function OnEvent(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED" then
        if CanLoadMythicHelper() then
            frame:Show()
            if inputFrame then
                inputFrame:Show()
            end
            if mainUI then
                mainUI:Hide()
            end
            if AdjustFrameHeight then
                AdjustFrameHeight()
            end
            -- Tank-Perk-Tracking beim Betreten einer neuen Instanz zurücksetzen
            if ResetTankPerkTracking then
                ResetTankPerkTracking()
            end
        else
            frame:Hide()
            -- Potion-Timer zurücksetzen, wenn Instanz verlassen wird
            potionCD = 0
            potionCastEnd = 0
            potionCaster = ""
            potionCDPending = false
            -- Hunter-Tracking beim Verlassen der Instanz zurücksetzen
            if ResetHunterAnimalCompanionTracking then
                ResetHunterAnimalCompanionTracking()
            end
            -- Tank-Perk-Tracking beim Verlassen der Instanz zurücksetzen
            if ResetTankPerkTracking then
                ResetTankPerkTracking()
            end
            -- Priest-Holy-Perk-Tracking beim Verlassen der Instanz zurücksetzen
            if ResetPriestHolyPerkTracking then
                ResetPriestHolyPerkTracking()
            end
            -- Hide buff warning when leaving instance
            if MythicHelper_ClearBuffWarning then
                MythicHelper_ClearBuffWarning()
            end
            -- Suppress "available only in Raids or Instance" message here!
        end
    end
end

-- Frame für Ereignisse registrieren
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
-- Add event for immediate instance exit detection
eventFrame:RegisterEvent("ZONE_CHANGED")
eventFrame:SetScript("OnEvent", OnEvent)

-- Slash Command: /mhelper zum Öffnen/Schließen des Addons
SLASH_MHELPER1 = "/mhelper"
SLASH_MHELPER2 = "/mh"
SlashCmdList["MHELPER"] = function(msg)
    if msg == "reset" then
        ResetHunterAnimalCompanionTracking()
        ResetTankPerkTracking()
        ResetPriestHolyPerkTracking()
        return
    elseif msg == "resethunter" then
        ResetHunterAnimalCompanionTracking()
        return
    elseif msg == "resettank" then
        ResetTankPerkTracking()
        return
    elseif msg == "resetpriest" then
        ResetPriestHolyPerkTracking()
        return
    elseif msg == "tanksend" or msg == "tankperks" then
        ManualSendTankPerks()
        return
    elseif msg == "huntersend" or msg == "animalcompanion" then
        AutoSendHunterAnimalCompanion()
        return
    elseif msg == "priestsend" or msg == "holyform" then
        ManualSendPriestHolyPerks()
        return
    end

    if not CanLoadMythicHelper() then
        print("|cffff5555MythicHelper: Available only in Raids or Instance!|r")
        frame:Hide()
        return
    end
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
        AdjustFrameHeight()
    end
end

-- Minimap Button
local minimapButton = CreateFrame("Button", "MythicHelperMinimapButton", Minimap)
minimapButton:SetSize(32, 32)
minimapButton:SetFrameStrata("MEDIUM")
minimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -15, 15)

-- Create a circular background
minimapButton.background = minimapButton:CreateTexture(nil, "BACKGROUND")
minimapButton.background:SetSize(32, 32)
minimapButton.background:SetPoint("CENTER")
minimapButton.background:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

-- Set an appropriate icon (skull with crossed swords for mythic content)
minimapButton:SetNormalTexture("Interface\\Icons\\Achievement_PVP_A_A")
minimapButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

-- Make the icon fit properly
local normalTexture = minimapButton:GetNormalTexture()
if normalTexture then
    normalTexture:SetSize(20, 20)
    normalTexture:SetPoint("CENTER")
end

-- Make it movable around the minimap
minimapButton:SetMovable(true)
minimapButton:EnableMouse(true)
minimapButton:RegisterForDrag("LeftButton")

-- Add drag functionality with minimap clamping
minimapButton:SetScript("OnDragStart", function(self)
    if IsShiftKeyDown() then
        self:StartMoving()
    end
end)

minimapButton:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    -- Clamp to minimap using the function from MythicTrashTracker
    if _G["ClampToMinimap"] then
        _G["ClampToMinimap"](self)
    end
end)

-- Enable both left and right click
minimapButton:RegisterForClicks("AnyUp")

minimapButton:SetScript("OnClick", function(self, button)
    if button == "LeftButton" and not IsShiftKeyDown() then
        -- Original MythicHelper functionality
        if not CanLoadMythicHelper() then
            print("|cffff5555MythicHelper: Available only in Raids or Instance!|r")
            frame:Hide()
            return
        end
        if frame:IsShown() then
            frame:Hide()
        else
            frame:Show()
            AdjustFrameHeight()
        end
    elseif button == "RightButton" then
        -- Show combined dropdown menu
        CreateCombinedDropdownMenu()
    end
end)

minimapButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("MythicHelper", 1, 1, 1)
    GameTooltip:AddLine("Left Click: Open/Close MythicHelper", 0.8, 0.8, 0.8)
    GameTooltip:AddLine("Right Click: Show Menu", 0.8, 0.8, 0.8)
    GameTooltip:AddLine("Shift + Drag: Move Button", 0.6, 0.6, 0.6)
    GameTooltip:Show()
end)
minimapButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

-- Nach dem Heroism-Bereich, z.B. nach heroismUserText:
local heroismResetButton = CreateFrame("Button", nil, mainUI)
heroismResetButton:SetSize(60, 18)
heroismResetButton:SetPoint("BOTTOM", mainUI, "BOTTOM", -120, 8) -- weiter nach links

-- Add text to reset button
heroismResetButton.text = heroismResetButton:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
heroismResetButton.text:SetPoint("CENTER", heroismResetButton, "CENTER", 0, 0)
heroismResetButton.text:SetText("Reset Heroism")
heroismResetButton.text:SetTextColor(1, 0.82, 0)
heroismResetButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")

-- Tooltip für Reset Heroism Button
heroismResetButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Reset Heroism Timer", 1, 1, 1)
    GameTooltip:AddLine("Clears the current Heroism cooldown", 0.7, 0.7, 1)
    GameTooltip:AddLine("Use if timer is stuck or incorrect", 1, 0.8, 0.6)
    GameTooltip:Show()
end)
heroismResetButton:SetScript("OnLeave", function() 
    GameTooltip:Hide() end)

heroismResetButton:SetScript("OnClick", function()
    heroismCastEnd = 0
    heroismCaster = ""
    heroismButton:Enable()
    heroismUserText:SetText("")
    heroismCastBar:SetMinMaxValues(0, 40)
    heroismCastBar:SetValue(0)
    heroismCastBar:Hide()
    heroismCDBar:Hide()
    UpdateBars()
end)

local function OnChatMsgSystem(self, event, msg)
    if msg and msg:find("Unknown spell Mythic Heroism") then
        heroismQueueIndex = heroismQueueIndex + 1
        if heroismQueueIndex > #heroismQueue then heroismQueueIndex = 1 end
        MythicHelper_HeroismQueue = {}
            for i, v in ipairs(heroismQueue) do MythicHelper_HeroismQueue[i] = v end
            MythicHelper_HeroismQueueIndex = heroismQueueIndex
        heroismCastEnd = 0
        heroismCaster = ""
        heroismButton:Enable()
        heroismUserText:SetText("")
        heroismCastBar:Hide()
        heroismCDBar:Hide()
        UpdateBars()
    end
end

local chatEventFrame = CreateFrame("Frame")
chatEventFrame:RegisterEvent("CHAT_MSG_SYSTEM")
chatEventFrame:SetScript("OnEvent", OnChatMsgSystem)


-- Tabelle für die Buttons, damit wir sie später entfernen können
-- mhnameButtons bereits oben definiert

-- Funktion zum Entfernen aller alten Buttons

-- Event-Handler für Gruppenänderungen
local f = CreateFrame("Frame")
f:RegisterEvent("RAID_ROSTER_UPDATE")
f:RegisterEvent("PARTY_MEMBERS_CHANGED")



-- Tracking für bereits gesendete Hunter-Animal Companions
local hunterAnimalCompanionSent = {}

-- Tracking für bereits gesendete Tank-Perk: Shield of Destiny
local tankPerkSent = {}

-- Tracking für bereits gesendete Priest Holy Form Perks
local priestHolyPerkSent = {}

-- Tracking für Gruppenmitglieder (um Joins vs. Leaves zu erkennen)
local currentGroupMembers = {}

-- Funktion zur Erkennung von Tank-Specs/Rollen (verwendet die gleiche Logik wie Flask-Verteilung)
local function IsTankClass(unit)
    if not UnitExists(unit) then 
        return false
    end

    local _, class = UnitClass(unit)

    -- Tank-fähige Klassen: Paladine, Krieger, Todesritter und Druiden
    if class == "PALADIN" or class == "WARRIOR" or class == "DEATHKNIGHT" or class == "DRUID" then
        -- Verwende die gleiche Spec-Erkennung wie bei Flask-Verteilung
        local spec = GetSpecForHybrid(unit)

        -- Debug: Ausgabe für bessere Diagnostik
        -- print("DEBUG: IsTankClass: unit="..unit..", class="..(class or "nil")..", spec="..(spec or "nil"))

        -- Spezifische Tank-Spezialisierungen
        if (class == "PALADIN" and spec == "Protection") or
           (class == "WARRIOR" and spec == "Protection") or
           (class == "DEATHKNIGHT" and spec == "Blood") or
           (class == "DRUID" and spec == "Feral") then
            return true
        end

        -- Fallback: Wenn Spec nicht bestimmbar ist oder für andere Charaktere
        if not spec or spec == "" then
            -- Zusätzliche Prüfung: Ist der Spieler in einer Tank-Rolle?
            local role = UnitGroupRolesAssigned and UnitGroupRolesAssigned(unit)
            if role == "TANK" then
                return true
            end

            -- Fallback für kleinere Gruppen: Tank-fähige Klassen bekommen Tank Perks
            local groupSize = 0
            if GetNumRaidMembers() > 0 then
                groupSize = GetNumRaidMembers()
            elseif GetNumPartyMembers() > 0 then
                groupSize = GetNumPartyMembers() + 1
            else
                groupSize = 1
            end

            -- In kleineren Gruppen (≤5) sind Tank-fähige Klassen wahrscheinlich Tanks
            if groupSize <= 5 then
                -- print("DEBUG: Small group (" .. groupSize .. "), assuming " .. class .. " is tank")
                return true
            end

            -- In größeren Gruppen: konservativere Annahme
            if class == "PALADIN" or class == "WARRIOR" then
                -- print("DEBUG: Large group, but " .. class .. " likely tank")
                return true
            end
        end
    end

    return false
end

-- Funktion zum Aktualisieren der Gruppenmitglieder-Liste
local function UpdateGroupMembersList()
    local newMembers = {}
    local joinedMembers = {}

    -- Sammle aktuelle Gruppenmitglieder
    if GetNumRaidMembers() > 0 then
        for i = 1, GetNumRaidMembers() do
            local unit = "raid"..i
            local name = GetRaidRosterInfo(i)
            local _, class = UnitClass(unit)
            if name and class and (class == "PALADIN" or class == "WARRIOR" or class == "DEATHKNIGHT" or class == "DRUID") then
                newMembers[name] = true
                if not currentGroupMembers[name] then
                    table.insert(joinedMembers, {name = name, unit = unit})
                end
            end
        end
    elseif GetNumPartyMembers() > 0 then
        for i = 1, GetNumPartyMembers() do
            local unit = "party"..i
            local name = UnitName(unit)
            local _, class = UnitClass(unit)
            if name and class and (class == "PALADIN" or class == "WARRIOR" or class == "DEATHKNIGHT" or class == "DRUID") then
                newMembers[name] = true
                if not currentGroupMembers[name] then
                    table.insert(joinedMembers, {name = name, unit = unit})
                end
            end
        end
        -- Spieler selbst prüfen
        local playerName = UnitName("player")
        local _, playerClass = UnitClass("player")
        if playerName and playerClass and (playerClass == "PALADIN" or playerClass == "WARRIOR" or playerClass == "DEATHKNIGHT" or playerClass == "DRUID") then
            newMembers[playerName] = true
            if not currentGroupMembers[playerName] then
                table.insert(joinedMembers, {name = playerName, unit = "player"})
            end
        end
    else
        -- Solo
        local playerName = UnitName("player")
        local _, playerClass = UnitClass("player")
        if playerName and playerClass and (playerClass == "PALADIN" or playerClass == "WARRIOR" or playerClass == "DEATHKNIGHT" or playerClass == "DRUID") then
            newMembers[playerName] = true
            if not currentGroupMembers[playerName] then
                table.insert(joinedMembers, {name = playerName, unit = "player"})
            end
        end
    end

    if addonJustLoaded then
        addonJustLoaded = false
        currentGroupMembers = newMembers
        return
    end

    currentGroupMembers = newMembers
      -- Sende Tank-Perks, Hunter Animal Companion und Priest Holy Form nur an neue Mitglieder (mit 5 Sekunden Verzögerung)
    local newHunters = 0
    local newPriests = 0
    for _, member in ipairs(joinedMembers) do
    -- Nur noch an den ausgewählten Tank senden!
    local selectedTank = GetSelectedTank()
   if selectedTank and member.name == selectedTank and not tankPerkSent[member.name] then
        DelayedCallback(5, function()
            AutoSendTankPerkToPlayer(member.name)
        end)
    end
        
        -- Prüfe ob es sich um einen neuen Hunter handelt
        local _, class = UnitClass(member.unit)
        if class == "HUNTER" then
            -- Hunter Animal Companion mit 5 Sekunden Verzögerung senden
            DelayedCallback(5, function()
                AutoSendHunterAnimalCompanionToPlayer(member.name)
            end)
            newHunters = newHunters + 1
        elseif class == "PRIEST" then
            -- Priest Holy Form mit 5 Sekunden Verzögerung senden
            DelayedCallback(5, function()
                AutoSendPriestHolyToPlayer(member.name)
            end)
            newPriests = newPriests + 1
        end
    end    
    -- Feedback für neue Hunter und Priester
    if newHunters > 0 and newPriests > 0 then
        MythicHelper_SetBuffWarning("Will auto-send Animal Companion to " .. newHunters .. " Hunter(s) and Holy Form to " .. newPriests .. " Priest(s) in 5 seconds")
        DelayedCallback(8, function()
            MythicHelper_ClearBuffWarning()
        end)
    elseif newHunters > 0 then
        MythicHelper_SetBuffWarning("Will auto-send Animal Companion to " .. newHunters .. " Hunter(s) in 5 seconds")
        DelayedCallback(8, function()
            MythicHelper_ClearBuffWarning()
        end)
    elseif newPriests > 0 then
        MythicHelper_SetBuffWarning("Will auto-send Holy Form to " .. newPriests .. " Priest(s) in 5 seconds")
        DelayedCallback(8, function()
            MythicHelper_ClearBuffWarning()
        end)
    end
end

f:SetScript("OnEvent", function(self, event, ...)
    if inputFrame:IsShown() then
        ShowNameButtons()
    end
    
    -- Aktualisiere Gruppenmitglieder und sende Tank-Perks an neue Tanks
    UpdateGroupMembersList()
end)


-- Funktion zum automatischen Senden von Animal Companion an einen spezifischen Hunter
function AutoSendHunterAnimalCompanionToPlayer(name)
    -- Sende nur wenn noch nicht gesendet
    if not hunterAnimalCompanionSent[name] then
        SendChatMessage("cast 81594", "WHISPER", nil, name)
        hunterAnimalCompanionSent[name] = true
    end
end

-- Funktion zum manuellen Senden von Animal Companion an alle Hunter (für manuellen Aufruf)
function ManualSendHunterAnimalCompanion()
    local hunterCount = 0
    local newHunters = 0
    local alreadySentHunters = 0

    -- Funktion zum Senden an einen Hunter (nur wenn noch nicht gesendet)
    local function SendToHunter(name, unit)
        local _, class = UnitClass(unit)
        if class == "HUNTER" then
            if not hunterAnimalCompanionSent[name] then
                SendChatMessage("cast 81594", "WHISPER", nil, name)
                hunterAnimalCompanionSent[name] = true
                hunterCount = hunterCount + 1
                newHunters = newHunters + 1
            else
                hunterCount = hunterCount + 1
                alreadySentHunters = alreadySentHunters + 1
            end
        end
    end

    if GetNumRaidMembers() > 0 then
        for i = 1, GetNumRaidMembers() do
            local name = GetRaidRosterInfo(i)
            if name then
                SendToHunter(name, "raid"..i)
            end
        end
    elseif GetNumPartyMembers() > 0 then
        for i = 1, GetNumPartyMembers() do
            local unit = "party"..i
            local name = UnitName(unit)
            if name then
                SendToHunter(name, unit)
            end
        end
        local playerName = UnitName("player")
        if playerName then
            SendToHunter(playerName, "player")
        end
    else
        local playerName = UnitName("player")
        if playerName then
            SendToHunter(playerName, "player")
        end
    end

    if hunterCount > 0 then
        if newHunters > 0 then
            MythicHelper_SetBuffWarning("Manually sent Animal Companion to " .. newHunters .. " Hunter(s)")
            DelayedCallback(5, function()
                MythicHelper_ClearBuffWarning()
            end)
        else
            MythicHelper_SetBuffWarning("Animal Companion already active for all " .. hunterCount .. " Hunter(s)")
            DelayedCallback(3, function()
                MythicHelper_ClearBuffWarning()
            end)
        end
    else
        MythicHelper_SetBuffWarning("No hunters found in group")
        DelayedCallback(3, function()
            MythicHelper_ClearBuffWarning()
        end)
    end
end
-- Funktion zum Senden an einen Hunter (nur wenn noch nicht gesendet)
function AutoSendTankPerkToPlayer(name)
    -- Sende nur wenn noch nicht gesendet (für automatische Verteilung)
    if not tankPerkSent[name] then
        SendChatMessage("cast 81535", "WHISPER", nil, name)
        tankPerkSent[name] = true

        -- UI feedback
        MythicHelper_SetBuffWarning("Auto-sent Tank Perk to " .. name)
        -- Clear UI feedback after 5 seconds
        DelayedCallback(5, function()
            MythicHelper_ClearBuffWarning()
        end)

        print("Tank Perk (81535) sent to " .. name)
    end
end

-- Funktion zum manuellen Senden von Tank-Perk an alle Tanks
function ManualSendTankPerks()
    local tankCount = 0
    local newTanks = 0
    local function SendToTank(name, unit)
        if IsTankClass(unit) then
            if not tankPerkSent[name] then
                SendChatMessage("cast 81535", "WHISPER", nil, name)
                tankPerkSent[name] = true
                tankCount = tankCount + 1
                newTanks = newTanks + 1
            else
                tankCount = tankCount + 1
            end
        end
    end

    if GetNumRaidMembers() > 0 then
        for i = 1, GetNumRaidMembers() do
            local name = GetRaidRosterInfo(i)
            if name then
                SendToTank(name, "raid"..i)
            end
        end
    elseif GetNumPartyMembers() > 0 then
        for i = 1, GetNumPartyMembers() do
            local unit = "party"..i
            local name = UnitName(unit)
            if name then
                SendToTank(name, unit)
            end
        end
        local playerName = UnitName("player")
        if playerName then
            SendToTank(playerName, "player")
        end
    else
        local playerName = UnitName("player")
        if playerName then
            SendToTank(playerName, "player")
        end
    end

    if tankCount > 0 then
        if newTanks > 0 then
            MythicHelper_SetBuffWarning("Manually sent Tank Perks to " .. newTanks .. " new Tank(s)")
            DelayedCallback(5, function()
                MythicHelper_ClearBuffWarning()
            end)
        else
            MythicHelper_SetBuffWarning("All " .. tankCount .. " Tank(s) already have perks")
            DelayedCallback(3, function()
                MythicHelper_ClearBuffWarning()
            end)
        end
    else
        MythicHelper_SetBuffWarning("No tanks found in group")
        DelayedCallback(3, function()
            MythicHelper_ClearBuffWarning()
        end)
    end
end

-- Funktion zum automatischen Senden von Priest Holy Form an einen spezifischen Priester
function AutoSendPriestHolyToPlayer(name)
    -- Sende nur wenn noch nicht gesendet (für automatische Verteilung)
    if not priestHolyPerkSent[name] then
        SendChatMessage("cast 81099", "WHISPER", nil, name)
        priestHolyPerkSent[name] = true
        
        -- UI feedback
        MythicHelper_SetBuffWarning("Auto-sent Holy Form to " .. name)
        -- Clear UI feedback after 5 seconds
        DelayedCallback(5, function()
            MythicHelper_ClearBuffWarning()
        end)
        
        print("Priest Holy Form (81099) sent to " .. name)
    end
end


-- Persistent tank selection using SavedVariable
function GetSelectedTank()
    if type(MythicHelper_SelectedTank) == "string" and MythicHelper_SelectedTank ~= "" then
        return MythicHelper_SelectedTank
    end
    return nil
end

function SetSelectedTank(name)
    if name and name ~= "" then
        MythicHelper_SelectedTank = name
    else
        MythicHelper_SelectedTank = nil
    end
end

-- Global functions for buff warning system
function MythicHelper_SetBuffWarning(text)
    if buffWarningFrame and buffWarningFrame.text then
        buffWarningFrame.text:SetText(text)
        buffWarningFrame:Show()
    end
end

function MythicHelper_ClearBuffWarning()
    if buffWarningFrame then
        buffWarningFrame:Hide()
        if buffWarningFrame.text then
            buffWarningFrame.text:SetText("")
        end
    end
end

-- Funktion zum manuellen Senden von Priest Holy Form Perks an alle Priester
function ManualSendPriestHolyPerks()
    local priestCount = 0
    local newPriests = 0
    local alreadySentPriests = 0
    
    -- Funktion zum Senden an einen Priester (nur wenn noch nicht gesendet)
    local function SendToPriest(name, unit)
        local _, class = UnitClass(unit)
        if class == "PRIEST" then
            if not priestHolyPerkSent[name] then
                SendChatMessage("cast 81099", "WHISPER", nil, name)
                priestHolyPerkSent[name] = true
                priestCount = priestCount + 1
                newPriests = newPriests + 1
            else
                priestCount = priestCount + 1
                alreadySentPriests = alreadySentPriests + 1
            end
        end
    end
    
    -- Überprüfe Raid-Mitglieder
    if GetNumRaidMembers() > 0 then
        for i = 1, GetNumRaidMembers() do
            local name = GetRaidRosterInfo(i)
            if name then
                SendToPriest(name, "raid"..i)
            end
        end
    -- Überprüfe Party-Mitglieder
    elseif GetNumPartyMembers() > 0 then
        for i = 1, GetNumPartyMembers() do
            local unit = "party"..i
            local name = UnitName(unit)
            if name then
                SendToPriest(name, unit)
            end
        end
        -- Überprüfe den Spieler selbst
        local playerName = UnitName("player")
        if playerName then
            SendToPriest(playerName, "player")
        end
    end
    
    -- Feedback
    if priestCount > 0 then
        if newPriests > 0 then
            -- UI feedback
            MythicHelper_SetBuffWarning("Sent Holy Form to " .. newPriests .. " Priest(s)")
            -- Clear UI feedback after 5 seconds
            DelayedCallback(5, function()
                MythicHelper_ClearBuffWarning()
            end)
        else
            -- Alle Priester haben bereits Holy Form
            MythicHelper_SetBuffWarning("Holy Form already active for all " .. priestCount .. " Priest(s)")
            DelayedCallback(3, function()
                MythicHelper_ClearBuffWarning()
            end)
        end
    else
        -- Keine Priester gefunden
        MythicHelper_SetBuffWarning("No priests found in group")
        DelayedCallback(3, function()
            MythicHelper_ClearBuffWarning()
        end)
    end
end