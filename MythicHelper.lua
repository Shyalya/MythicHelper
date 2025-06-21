local addonName = ...
local frame = CreateFrame("Frame", addonName.."Frame", UIParent)
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
        print("DEBUG Self: "..UnitName(unit).." - Talent Points: "..tab1.."/"..tab2.."/"..tab3)
        
        -- Rest der Funktion für die Klassen-Auswertung...
        if class == "DRUID" then
            if maxPoints == tab1 then return "Balance"     -- Caster
            elseif maxPoints == tab2 then return "Feral"   -- Melee/Tank
            else return "Restoration" end                  -- Healer
        -- usw. für andere Klassen...
        
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
            return "Holy"       -- Standard-Annahme für Paladine
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
        return "Flask of the Endless Rage"
    
    -- Klare Caster-Klassen
    elseif class == "MAGE" or 
           class == "WARLOCK" then
        return "Flask of the Frostwyrm"
    
    -- Hybridklassen basierend auf Spec
    elseif class == "DRUID" or class == "SHAMAN" or class == "PALADIN" or class == "PRIEST" then
        local spec = GetSpecForHybrid(unit)
        
        -- Caster-Specs
        if spec == "Balance" or spec == "Elemental" or spec == "Shadow" then
            return "Flask of the Frostwyrm"
        
        -- Melee-DPS-Specs
        elseif spec == "Feral" or spec == "Enhancement" or spec == "Retribution" then
            return "Flask of the Endless Rage"
        
        -- Tank-Specs
        elseif spec == "Protection" then
            return "Flask of the Endless Rage" -- Optional: Tanks
            
        -- Heiler-Specs oder unbekannt
        else
            return "Flask of the Frostwyrm" -- Für Heiler besser
        end
    end
    
    -- Fallback
    return "Flask of the North"
end

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
}
}

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

local buffTarget = nil
local mainUI = nil

-- Formular-Frame für Charakternamen
local inputFrame = CreateFrame("Frame", nil, frame)
inputFrame:SetAllPoints(frame)

local inputLabel = inputFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
inputLabel:SetPoint("TOP", inputFrame, "TOP", 0, -38)
inputLabel:SetText("Select Character with the highest Aura Ranks:")

-- Passe das Frame an die neue Höhe an

local buttonWidth, buttonHeight, buttonSpacing = 70, 44, 6
local colSpacing = 10

local function AdjustFrameHeight()
    if mainUI:IsShown() then
        local rows = 4
        local auraRows = math.ceil(#auren / 2)
        local utilRows = #utilityButtons
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
        local totalWidth = 16 + 3*buttonWidth + 3*colSpacing + 16
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

-- Haupt-UI (wird erst nach Eingabe angezeigt)
mainUI = CreateFrame("Frame", nil, frame)
mainUI:SetAllPoints(frame)
mainUI:Hide()

-- Main-Name-Anzeige ganz oben unter dem Fenstertitel
local mainNameText = nil
mainNameText = mainUI:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
mainNameText:SetPoint("TOP", mainUI, "TOP", 0, -28)
mainNameText:SetText("")

-- Funktion zum Aktualisieren des Main-Namens
local function UpdateMainName()
    if buffTarget and buffTarget ~= "" then
        mainNameText:SetText("Main: " .. buffTarget)
        mainNameText:Show()
    else
        mainNameText:SetText("")
        mainNameText:Hide()
    end
end


-- Passe ShowNameButtons an:
local mhnameButtons = {}
local function ShowNameButtons()
    -- Vorherige Buttons entfernen
    for _, btn in ipairs(mhnameButtons) do
        btn:Hide()
        btn:SetParent(nil)
    end
    wipe(mhnameButtons)

    -- Setze das Hauptfenster auf eine große, feste Größe für die Auswahl
    frame:SetWidth(180)
    frame:SetHeight(420)

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
            end
        end
    elseif GetNumPartyMembers() > 0 then
        for i = 1, GetNumPartyMembers() do
            local name = UnitName("party"..i)
            if name and name ~= "" then
                names[count] = name
                count = count + 1
            end
        end
        names[count] = UnitName("player")
    elseif UnitName("player") then
        names[count] = UnitName("player")
    end

    -- Jetzt enthält 'names' immer 10 Felder, die ersten sind ggf. mit Namen befüllt

    -- Beispiel: Buttons für alle 10 Felder anlegen
    local btnWidth, btnHeight = 120, 22
    local btnSpacingX, btnSpacingY = 16, 6
    local maxRows = 5 -- oder 10, je nach gewünschtem Layout
    for i = 1, 10 do
        local name = names[i]
        local btn = CreateFrame("Button", nil, inputFrame, "GameMenuButtonTemplate")
        btn:SetSize(btnWidth, btnHeight)
        -- Passe die Positionierung ggf. an
        local col = math.floor((i-1) / maxRows)
        local row = (i-1) % maxRows
        btn:SetPoint(
            "TOPLEFT",
            inputLabel,
            "BOTTOMLEFT",
            col * (btnWidth + btnSpacingX),
            -8 - row * (btnHeight + btnSpacingY)
        )
        if name ~= "" then
            btn:SetText(name)
            btn:SetScript("OnClick", function()
                buffTarget = name
                MythicHelperMainName = name
                frame:SetWidth(260)
                frame:SetHeight(80)
                mainUI:Show()
                AdjustFrameHeight()
                UpdateMainName()
                inputFrame:Hide()   
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
    btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    btn.text:SetPoint("TOP", btn.icon, "BOTTOM", 0, -1)
    btn.text:SetText(shortName or aura.name)
    btn.text:SetTextColor(1, 0.82, 0)

    btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    btn:SetScript("OnClick", function()
        if buffTarget then
            SendChatMessage("cast "..aura.name, "WHISPER", nil, buffTarget)
            print("Aura buff '"..aura.name.."' sent to "..buffTarget..".")
        else
            print("No target selected!")
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

heroismButton.text = heroismButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
heroismButton.text:SetPoint("TOP", heroismButton.icon, "BOTTOM", 0, -1)
heroismButton.text:SetText("Heroism")
heroismButton.text:SetTextColor(1, 0.82, 0)

-- Balken unter den Text platzieren:
local barWidth, barHeight = 28, 8

local heroismCDBar = CreateFrame("StatusBar", nil, heroismButton)
heroismCDBar:SetSize(barWidth, barHeight)
heroismCDBar:SetPoint("TOP", heroismButton.text, "BOTTOM", 0, -2) -- <- jetzt unter dem Namen
heroismCDBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
heroismCDBar:SetStatusBarColor(1, 0, 0) -- Rot für CD
heroismCDBar:SetMinMaxValues(0, 600)
heroismCDBar:Hide()

local heroismCastBar = CreateFrame("StatusBar", nil, heroismButton)
heroismCastBar:SetSize(barWidth, barHeight)
heroismCastBar:SetPoint("TOP", heroismButton.text, "BOTTOM", 0, -2) -- <- jetzt unter dem Namen
heroismCastBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
heroismCastBar:SetStatusBarColor(0, 1, 0) -- Grün für Laufzeit
heroismCastBar:SetMinMaxValues(0, 40)
heroismCastBar:Hide()

local heroismUserText = heroismButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
heroismUserText:SetPoint("TOP", heroismCDBar, "BOTTOM", 0, -2)
heroismUserText:SetText("")

local heroismCasterText = mainUI:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
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

potionButton.text = potionButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
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

local potionCasterText = mainUI:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
potionCasterText:SetPoint("LEFT", potionCDBar, "LEFT", 2, 0)
potionCasterText:SetText("")


-- Überschrift für die dritte Spalte (Bot Utilities) auf gleiche Höhe wie Auren
local botUtilsHeader = mainUI:CreateFontString(nil, "OVERLAY", "GameFontNormal")
botUtilsHeader:SetPoint("TOPLEFT", mainUI, "TOPLEFT", 16 + 2*(buttonWidth+colSpacing), -54)
botUtilsHeader:SetText("Bot Utilities")

-- Utility Buttons: Starten auf gleicher Höhe wie die Auren
for i, btnData in ipairs(utilityButtons) do
    local btn = CreateFrame("Button", nil, mainUI)
    btn:SetSize(buttonWidth, buttonHeight)
    btn:SetPoint("TOPLEFT", mainUI, "TOPLEFT", 16 + 2*(buttonWidth+colSpacing), -74 - (i-1)*(buttonHeight+buttonSpacing))

    btn.icon = btn:CreateTexture(nil, "ARTWORK")
    btn.icon:SetSize(28, 28)
    btn.icon:SetPoint("TOP", btn, "TOP", 0, -2)
    btn.icon:SetTexture(btnData.icon)

    btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    btn.text:SetPoint("TOP", btn.icon, "BOTTOM", 0, -1)
    btn.text:SetText(btnData.name)
    btn.text:SetTextColor(1, 0.82, 0)

    btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    btn:SetScript("OnClick", function()
        if btnData.message == "SPECIAL_FLASK" then
            -- Spezieller Fall: An jeden Spieler individuellen Flask senden
            if GetNumRaidMembers() > 0 then
                for i = 1, GetNumRaidMembers() do
                    local name = GetRaidRosterInfo(i)
                    local unit = "raid"..i
                    if name and UnitExists(unit) then
                        local flask = GetFlaskForClass(unit)
                        SendChatMessage("u " .. flask, "WHISPER", nil, name)
                        print("Sent to " .. name .. ": use " .. flask)
                    end
                end
            elseif GetNumPartyMembers() > 0 then
                for i = 1, GetNumPartyMembers() do
                    local unit = "party"..i
                    local name = UnitName(unit)
                    if name and UnitExists(unit) then
                        local flask = GetFlaskForClass(unit)
                        SendChatMessage("u " .. flask, "WHISPER", nil, name)
                        print("Sent to " .. name .. ": use " .. flask)
                    end
                end
                -- Auch dem Spieler selbst
                local flask = GetFlaskForClass("player")
                SendChatMessage("u " .. flask, "WHISPER", nil, UnitName("player"))
                print("Self: use " .. flask)
            end
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

-- Nach dem Erstellen aller Buttons und Balken:
mainUI:Show()
mainUI:SetScript("OnShow", function()
    AdjustFrameHeight()
end)

-- Timer-Logik
local heroismCastEnd, heroismCaster = 0, ""
local potionCD, potionCastEnd, potionCaster = 0, 0, ""
local potionCDPending = false

-- Heroism-Queue-Logik
local heroismQueue = {}
local heroismQueueIndex = 1

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
    heroismQueueIndex = 1
end

local function UpdateBars()
    local now = GetTime()
    -- Heroism
    if heroismCastEnd > now then
        -- Laufzeit läuft (grüner Balken)
        heroismCastBar:Show()
        heroismCastBar:SetMinMaxValues(0, 40)
        heroismCastBar:SetValue(heroismCastEnd - now)
        heroismCDBar:Show()
        heroismCDBar:SetMinMaxValues(0, 600)
        heroismCDBar:SetValue(heroismCastEnd + 600 - now)
        heroismButton:Disable()
        heroismUserText:SetText("Heroism: "..heroismCaster)
    elseif heroismCaster ~= "" and heroismCastEnd + 600 > now then
        -- Cooldown läuft (roter balken)
        heroismCastBar:Hide()
        heroismCDBar:Show()
        heroismCDBar:SetMinMaxValues(0, 600)
        heroismCDBar:SetValue(heroismCastEnd + 600 - now)
        heroismButton:Enable()
        heroismUserText:SetText("Heroism: "..heroismCaster)
    else
        -- Kein balken
        heroismCastBar:Hide()
        heroismCDBar:Hide()
        heroismButton:Enable()
        heroismUserText:SetText("")
    end
    -- Potion
    if potionCD > now then
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
    if #heroismQueue == 0 then FillHeroismQueue() end
    local nextUser = heroismQueue[heroismQueueIndex]
    if nextUser then
        SendChatMessage("cast "..heroismSpell, "WHISPER", nil, nextUser)
        print("Heroism sent to "..nextUser..".")
        -- Heroism läuft jetzt NEU (immer überschreiben)
        heroismCastEnd = GetTime() + 40 -- 30 Sekunden Laufzeit (anpassen falls nötig)
        heroismCaster = nextUser
        heroismUserText:SetText("Heroism: "..nextUser)
        heroismButton:Disable()
        -- Balken sofort neu anzeigen
        heroismCastBar:SetMinMaxValues(0, 40)
        heroismCastBar:SetValue(0)
        heroismCastBar:Show()
        heroismCDBar:SetMinMaxValues(0, 600)
        heroismCDBar:SetValue(0)
        heroismCDBar:Show()
        -- Zum nächsten Spieler in der Queue wechseln
        heroismQueueIndex = heroismQueueIndex + 1
        if heroismQueueIndex > #heroismQueue then heroismQueueIndex = 1 end
    end
end)

potionButton:SetScript("OnClick", function()
    local sent = false
    if GetNumRaidMembers() > 0 then
        SendChatMessage("u Mythic Endless Assault Potion", "RAID")
        sent = true
    elseif GetNumPartyMembers() > 0 then
        SendChatMessage("u Mythic Endless Assault Potion", "PARTY")
        sent = true
    end
    if sent then
        print("Potion request sent to your group.")
        potionCastEnd = GetTime() + 60
        potionCD = GetTime() + 180 -- << Cooldown startet SOFORT!
    else
        print("No group found!")
    end
end)


-- Mapping: Klasse -> Spellname für Flüstern
local classWhisperSpells = {
    PALADIN = { "cast Avenging Wrath" },
    SHAMAN = { "cast Bloodlust", "cast Heroism" },
    WARRIOR = { "cast Death Wish", "cast Recklessness" },
    MAGE = { "cast Combustion" },
    PRIEST = { "cast Power Infusion" },
    ROGUE = { "cast Adrenaline Rush" },
    HUNTER = { "cast Rapid Fire" },
    WARLOCK = { "cast Metamorphosis" },
    DRUID = { "cast Berserk" },
    DEATHKNIGHT = { "cast Unbreakable Armor", "cast Army of the Dead" },
}

-- Special Class Whisper Icon-Button (rechts neben Potion)
local specialWhisperIcon = "Interface\\Icons\\achievement_pvp_o_h" -- Wähle ein beliebiges Icon

local specialWhisperButton = CreateFrame("Button", nil, mainUI)
specialWhisperButton:SetSize(buttonWidth, buttonHeight)
specialWhisperButton:SetPoint("TOPLEFT", mainUI, "TOPLEFT", 16 + 2*(buttonWidth+colSpacing), dividerY - 38)

specialWhisperButton.icon = specialWhisperButton:CreateTexture(nil, "ARTWORK")
specialWhisperButton.icon:SetSize(28, 28)
specialWhisperButton.icon:SetPoint("TOP", specialWhisperButton, "TOP", 0, -2)
specialWhisperButton.icon:SetTexture(specialWhisperIcon)

specialWhisperButton.text = specialWhisperButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
specialWhisperButton.text:SetPoint("TOP", specialWhisperButton.icon, "BOTTOM", 0, -1)
specialWhisperButton.text:SetText("Special")
specialWhisperButton.text:SetTextColor(1, 0.82, 0)

specialWhisperButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
specialWhisperButton:SetScript("OnClick", function()
    local members = {}
    if GetNumRaidMembers() > 0 then
        for i = 1, GetNumRaidMembers() do
            local name = GetRaidRosterInfo(i)
            local unit = "raid"..i
            local _, class = UnitClass(unit)
            if name and class then
                table.insert(members, { name = name, class = class })
            end
        end
    else
        for i = 1, GetNumPartyMembers() do
            local unit = "party"..i
            local name = UnitName(unit)
            local _, class = UnitClass(unit)
            if name and class then
                table.insert(members, { name = name, class = class })
            end
        end
        local playerName = UnitName("player")
        local _, playerClass = UnitClass("player")
        table.insert(members, { name = playerName, class = playerClass })
    end

    for _, member in ipairs(members) do
        local msgs = classWhisperSpells[member.class]
        if type(msgs) == "table" then
            for _, msg in ipairs(msgs) do
                SendChatMessage(msg, "WHISPER", nil, member.name)
                print("Sent to "..member.name..": "..msg)
            end
        elseif type(msgs) == "string" then
            SendChatMessage(msgs, "WHISPER", nil, member.name)
            print("Sent to "..member.name..": "..msgs)
        end
    end
end)

specialWhisperButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Special Class Whisper\nPower your Cooldowns!", 1, 1, 1)
    GameTooltip:Show()
end)
specialWhisperButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- Überprüfen, ob das Addon geladen werden soll
local function CanLoadMythicHelper()
    local inInstance, instanceType = IsInInstance()
    local raidMembers = GetNumRaidMembers()
    local partyMembers = GetNumPartyMembers()
    local groupSize = (raidMembers > 0 and raidMembers) or (partyMembers + 1) -- +1 für den Spieler selbst

    return inInstance and (instanceType == "party" or instanceType == "raid") and groupSize > 1
end

-- Ereignis-Handler für Instanzwechsel
local function OnEvent(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
        if CanLoadMythicHelper() then
            frame:Show()
            inputFrame:Show()
            mainUI:Hide()
            AdjustFrameHeight()
            print("|cff55ff55MythicHelper: Addon loaded!|r")
        else
            frame:Hide()
            print("|cffff5555MythicHelper: Available only in Raids or Instance!|r")
            -- Potion-Timer zurücksetzen, wenn Instanz verlassen wird
            potionCD = 0
            potionCastEnd = 0
            potionCaster = ""
            potionCDPending = false
        end
    end
end

-- Frame für Ereignisse registrieren
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
eventFrame:SetScript("OnEvent", OnEvent)

-- Initialer Check beim Laden des Addons
if CanLoadMythicHelper() then
    frame:Show()
    inputFrame:Show()
    mainUI:Hide()
    AdjustFrameHeight()
    print("|cff55ff55MythicHelper: Addon loaded!|r")
else
    frame:Hide()
    print("|cffff5555MythicHelper: Available only in Raids or Instance!|r")
end

frame:Hide()
inputFrame:Show()
mainUI:Hide()

-- Passe das Frame an die neue Höhe an
local function AdjustFrameHeight()
    if mainUI:IsShown() then
        local rows = 4
        local auraRows = math.ceil(#auren / 2)
        local utilRows = #utilityButtons
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
        local totalWidth = 16 + 4*buttonWidth + 3*colSpacing + 16
        frame:SetWidth(totalWidth)
        frame:SetHeight(totalHeight)
    elseif inputFrame:IsShown() then
        frame:SetHeight(220) -- Feste Höhe für das Auswahlfenster, ggf. anpassen!
        frame:SetWidth(360)  -- Feste Breite für das Auswahlfenster, ggf. anpassen!
    else
        frame:SetHeight(80)
        frame:SetWidth(260)
    end
end


-- Ganz oben (nach den lokalen Variablen)
if MythicHelperMainName then
    buffTarget = MythicHelperMainName
end

-- Slash Command: /mhelper zum Öffnen/Schließen des Addons
SLASH_MHELPER1 = "/mhelper"
SlashCmdList["MHELPER"] = function()
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
minimapButton:SetSize(24, 24)
minimapButton:SetFrameStrata("MEDIUM")
minimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)
minimapButton:SetNormalTexture("Interface\\AddOns\\MythicHelper\\icon")
minimapButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

minimapButton:SetScript("OnClick", function()
    if not CanLoadMythicHelper() then
        print("|cffff5555MythicHelper: Available only in Raids or Instance!|r")
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

-- Nach dem Heroism-Bereich, z.B. nach heroismUserText:
local heroismResetButton = CreateFrame("Button", nil, mainUI, "GameMenuButtonTemplate")
heroismResetButton:SetSize(60, 18)
heroismResetButton:SetPoint("TOP", heroismUserText, "BOTTOM", 0, -4)
heroismResetButton:SetText("Reset Heroism")
heroismResetButton:SetScript("OnClick", function()
    heroismCastEnd = 0
    heroismCaster = ""
    heroismButton:Enable()
    heroismUserText:SetText("")
    heroismCastBar:Hide()
    heroismCDBar:Hide()
    print("Heroism timer has been reset.")
end)

local function OnChatMsgSystem(self, event, msg)
    if msg and msg:find("Unknown spell Mythic Heroism") then
        heroismQueueIndex = heroismQueueIndex + 1
        if heroismQueueIndex > #heroismQueue then heroismQueueIndex = 1 end
        print("Mythic Heroism: Player skipped (spell not known).")
        heroismCastEnd = 0
        heroismCaster = ""
        heroismButton:Enable()
        heroismUserText:SetText("")
        heroismCastBar:Hide()
        heroismCDBar:Hide()
    end
end

local chatEventFrame = CreateFrame("Frame")
chatEventFrame:RegisterEvent("CHAT_MSG_SYSTEM")
chatEventFrame:SetScript("OnEvent", OnChatMsgSystem)


-- Zeige die Buttons immer, wenn das Eingabefeld angezeigt wird:
inputFrame:HookScript("OnShow", function()
    ShowNameButtons()
    AdjustFrameHeight()
end)

-- Tabelle für die Buttons, damit wir sie später entfernen können
mhnameButtons = mhnameButtons or {}

-- Funktion zum Entfernen aller alten Buttons
local function RemoveOldButtons()
    for _, btn in ipairs(mhnameButtons) do
        btn:Hide()
        btn:SetParent(nil)
    end
    wipe(mhnameButtons)
end

-- Funktion zum Aktualisieren der Buttons
function UpdateMythicHelperButtons()
    RemoveOldButtons()

    local btnWidth, btnHeight = 120, 22
    local btnSpacingX, btnSpacingY = 16, 6
    local maxRows = 5

    -- Erstelle eine Tabelle mit 10 Feldern
    local names = {}
    for i = 1, 10 do names[i] = "" end

    local count = 1
    if GetNumRaidMembers() > 0 then
        for i = 1, GetNumRaidMembers() do
            local name = GetRaidRosterInfo(i)
            if name and name ~= "" then
                names[count] = name
                count = count + 1
            end
        end
    elseif GetNumPartyMembers() > 0 then
        for i = 1, GetNumPartyMembers() do
            local name = UnitName("party"..i)
            if name and name ~= "" then
                names[count] = name
                count = count + 1
            end
        end
        names[count] = UnitName("player")
    elseif UnitName("player") then
        names[count] = UnitName("player")
    end

    for i = 1, 10 do
        local name = names[i]
        local btn = CreateFrame("Button", nil, inputFrame, "GameMenuButtonTemplate")
        btn:SetSize(btnWidth, btnHeight)
        local col = math.floor((i-1) / maxRows)
        local row = (i-1) % maxRows
        btn:SetPoint(
            "TOPLEFT",
            inputLabel,
            "BOTTOMLEFT",
            col * (btnWidth + btnSpacingX),
            -8 - row * (btnHeight + btnSpacingY)
        )
        if name ~= "" then
            btn:SetText(name)
            btn:SetScript("OnClick", function()
                buffTarget = name
                MythicHelperMainName = name
                frame:SetWidth(260)
                frame:SetHeight(80)
                mainUI:Show()
                AdjustFrameHeight()
                UpdateMainName()
                inputFrame:Hide()
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
end

-- Event-Handler für Gruppenänderungen
local f = CreateFrame("Frame")
f:RegisterEvent("RAID_ROSTER_UPDATE")
f:RegisterEvent("PARTY_MEMBERS_CHANGED")
f:SetScript("OnEvent", function(self, event, ...)
    if mainUI:IsShown() then
        UpdateMythicHelperButtons()
    end
end)

-- Beispielwerte, ggf. anpassen:
local HEROISM_DURATION = 40   -- Laufzeit in Sekunden
local HEROISM_COOLDOWN = 600  -- Cooldown in Sekunden

local function StartHeroismBars()
    -- Heroism Laufzeit-Balken (CastBar)
    heroismCastBar:SetMinMaxValues(0, HEROISM_DURATION)
    heroismCastBar:SetValue(HEROISM_DURATION) -- Start: ganz voll
    heroismCastBar:Show()
    heroismCastBar.startTime = GetTime()
    heroismCastBar:SetScript("OnUpdate", function(self)
    local elapsed = GetTime() - self.startTime
    local remaining = HEROISM_DURATION - elapsed
    if remaining > 0 then
        self:SetValue(remaining)
    else
        self:SetValue(0)
        self:Hide()
        self:SetScript("OnUpdate", nil)
    end
end)

    -- Heroism Cooldown-Balken (CDBar)
    heroismCDBar:SetMinMaxValues(0, HEROISM_COOLDOWN)
    heroismCDBar:SetValue(HEROISM_COOLDOWN) -- Start: voll gefüllt
    heroismCDBar:Show()
    heroismCDBar.startTime = GetTime()
    heroismCDBar:SetScript("OnUpdate", function(self)
    local elapsed = GetTime() - self.startTime
    local remaining = HEROISM_COOLDOWN - elapsed
    if remaining > 0 then
        self:SetValue(remaining)
    else
        self:SetValue(0)
        self:Hide()
        self:SetScript("OnUpdate", nil)
        heroismButton:Enable()
    end
end)
end
-- Im Heroism-Button-OnClick-Handler:
heroismButton:SetScript("OnClick", function()
    if #heroismQueue == 0 then FillHeroismQueue() end
    local nextUser = heroismQueue[heroismQueueIndex]
    if nextUser then
        SendChatMessage("cast "..heroismSpell, "WHISPER", nil, nextUser)
        print("Heroism sent to "..nextUser..".")
        -- Heroism läuft jetzt NEU (immer überschreiben)
        heroismCastEnd = GetTime() + HEROISM_DURATION -- 30 Sekunden Laufzeit (anpassen falls nötig)
        heroismCaster = nextUser
        heroismUserText:SetText("Heroism: "..nextUser)
        heroismButton:Disable()
        StartHeroismBars()
        -- Balken sofort neu anzeigen
        heroismCastBar:SetMinMaxValues(0, HEROISM_DURATION)
        heroismCastBar:SetValue(HEROISM_DURATION)
        heroismCastBar:Show()
        heroismCDBar:SetMinMaxValues(0, 600)
        heroismCDBar:SetValue(0)
        heroismCDBar:Show()
        -- Zum nächsten Spieler in der Queue wechseln
        heroismQueueIndex = heroismQueueIndex + 1
        if heroismQueueIndex > #heroismQueue then heroismQueueIndex = 1 end
    end
end)

-- Nach der Definition von mainNameText:
local changeMainButton = CreateFrame("Button", nil, mainUI, "GameMenuButtonTemplate")
changeMainButton:SetSize(90, 18)
changeMainButton:SetPoint("BOTTOM", mainUI, "BOTTOM", 0, 8) -- etwas über dem Main-Namen
changeMainButton:SetText("Change Main")
changeMainButton:SetScript("OnClick", function()
    mainUI:Hide()
    inputFrame:Show()
    AdjustFrameHeight()
end)

-- Eventuell hilfreich: Cache-System für Klassen-Specs
local specCache = {}

local function GetCachedSpecForUnit(unit)
    local name = UnitName(unit)
    if name and specCache[name] then return specCache[name] end
    
    local spec = GetSpecForHybrid(unit)
    if spec and name then specCache[name] = spec end
    return spec
end





