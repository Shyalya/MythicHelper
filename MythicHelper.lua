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
inputLabel:SetText("Character name with the highest Aura Ranks:")

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
    -- Allow letters including German umlauts and ß
    if name and name ~= "" and name:match("^[A-Za-zÄÖÜäöüß]+$") then
        buffTarget = name
        inputFrame:Hide()
        frame:SetSize(90, 18 + 9 * 46)
        mainUI:Show()
        AdjustFrameHeight()
        UpdateMainName()
    else
        print("Please enter a valid name!")
        inputBox:SetText("")
        inputBox:SetFocus()
    end
end)

-- Haupt-UI (wird erst nach Eingabe angezeigt)
mainUI = CreateFrame("Frame", nil, frame)
mainUI:SetAllPoints(frame)
mainUI:Hide()

-- Passe das Frame an die neue Höhe an

local buttonWidth, buttonHeight, buttonSpacing = 70, 44, 6
local colSpacing = 10


local function AdjustFrameHeight()
    if mainUI:IsShown() then
        local totalHeight = 28 + 4*(buttonHeight+buttonSpacing) + 8 + 18 + buttonHeight + 8 + 12 + 2 + 8 + 36
        frame:SetHeight(totalHeight)
    else
        frame:SetHeight(80) -- Höhe für Eingabefenster
    end
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
aurasHeader:SetPoint("TOPLEFT", mainUI, "TOPLEFT", 16, -8)
aurasHeader:SetText("Mythic Auras")

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
            print("Aura buff '"..aura.name.."' sent to "..buffTarget..".")
        else
            print("No target selected!")
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
heroismCastBar:SetMinMaxValues(0, 60)
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
        message = "u flask of the north"
    }
}

-- Überschrift für die dritte Spalte (Bot Utilities) auf gleiche Höhe wie Auren
local botUtilsHeader = mainUI:CreateFontString(nil, "OVERLAY", "GameFontNormal")
botUtilsHeader:SetPoint("TOPLEFT", mainUI, "TOPLEFT", 16 + 2*(buttonWidth+colSpacing), -8)
botUtilsHeader:SetText("Bot Utilities")

-- Utility Buttons: Starten auf gleicher Höhe wie die Auren
for i, btnData in ipairs(utilityButtons) do
    local btn = CreateFrame("Button", nil, mainUI)
    btn:SetSize(buttonWidth, buttonHeight)
    btn:SetPoint("TOPLEFT", mainUI, "TOPLEFT", 16 + 2*(buttonWidth+colSpacing), -28 - (i-1)*(buttonHeight+buttonSpacing))

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
        if GetNumRaidMembers() > 0 then
            SendChatMessage(btnData.message, "RAID")
        elseif GetNumPartyMembers() > 0 then
            SendChatMessage(btnData.message, "PARTY")
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
            local name = select(1, GetRaidRosterInfo(i))
            if type(name) == "string" and name ~= "" then
                table.insert(heroismQueue, name)
            end
        end
    elseif GetNumPartyMembers() > 0 then
        for i = 1, GetNumPartyMembers() do
            local name = UnitName("party"..i)
            if type(name) == "string" and name ~= "" and name ~= UnitName("player") then
                table.insert(heroismQueue, name)
            end
        end
        -- Nur hinzufügen, wenn du nicht schon in der Liste bist
        local playerName = UnitName("player")
        local alreadyInQueue = false
        for _, n in ipairs(heroismQueue) do
            if n == playerName then alreadyInQueue = true break end
        end
        if not alreadyInQueue then
            table.insert(heroismQueue, playerName)
        end
    else
        table.insert(heroismQueue, UnitName("player"))
    end
    heroismQueueIndex = 1
end

local function UpdateBars()
    local now = GetTime()
    -- Heroism
    if heroismCastEnd > now then
        -- Laufzeit läuft (grüner Balken)
        heroismCastBar:Show()
        heroismCastBar:SetMinMaxValues(0, 60)
        heroismCastBar:SetValue(heroismCastEnd - now)
        heroismCDBar:Show()
        heroismCDBar:SetMinMaxValues(0, 600)
        heroismCDBar:SetValue(heroismCastEnd + 600 - now)
        heroismButton:Disable()
        heroismUserText:SetText("Heroism: "..heroismCaster)
    elseif heroismCaster ~= "" and heroismCastEnd + 600 > now then
        -- Cooldown läuft (roter Balken)
        heroismCastBar:Hide()
        heroismCDBar:Show()
        heroismCDBar:SetMinMaxValues(0, 600)
        heroismCDBar:SetValue(heroismCastEnd + 600 - now)
        heroismButton:Enable()
        heroismUserText:SetText("Heroism: "..heroismCaster)
    else
        -- Kein Balken
        heroismCastBar:Hide()
        heroismCDBar:Hide()
        heroismButton:Enable()
        heroismUserText:SetText("")
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
    if #heroismQueue == 0 then FillHeroismQueue() end
    local nextUser = heroismQueue[heroismQueueIndex]
    if nextUser then
        SendChatMessage("cast "..heroismSpell, "WHISPER", nil, nextUser)
        print("Heroism sent to "..nextUser..".")
        heroismCastEnd = GetTime() + 60 -- 1min duration
        heroismCaster = nextUser
        heroismUserText:SetText("Heroism: "..nextUser)
        heroismButton:Disable()
        -- Sofort zum nächsten Spieler in der Queue wechseln
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
        potionCDPending = true
    else
        print("No group found!")
    end
end)

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
        local totalHeight = 28 + 4*(buttonHeight+buttonSpacing) + 8 + 18 + buttonHeight + 8 + 12 + 2 + 8 + 36
        frame:SetHeight(totalHeight)
    else
        frame:SetHeight(80) -- Höhe für Eingabefenster
    end
end

-- Main-Name-Anzeige ganz unten mittig
local mainNameText = mainUI:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
mainNameText:SetPoint("BOTTOM", mainUI, "BOTTOM", 0, 8)
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

-- ... jetzt erst confirmButton:SetScript(...), wo UpdateMainName() aufgerufen wird ...
confirmButton:SetScript("OnClick", function()
    local name = inputBox:GetText()
    -- Erlaubt Buchstaben inkl. deutscher Umlaute und ß
    if name and name ~= "" and name:match("^[A-Za-zÄÖÜäöüß]+$") then
        buffTarget = name
        inputFrame:Hide()
        mainUI:Show()
        AdjustFrameHeight()
        UpdateMainName()
    else
        print("Please Enter a valid Name!")
        inputBox:SetText("")
        inputBox:SetFocus()
    end
end)

inputBox:SetScript("OnEnterPressed", function(self)
    confirmButton:Click()
end)

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
        AdjustFrameHeight() -- Höhe anpassen, wenn das Fenster geöffnet wird
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

local function OnCombatEnd(self, event)
    if potionCDPending then
        potionCD = GetTime() + 180
        potionCDPending = false
        print("Potion cooldown starts now (after combat).")
    end
end

local combatEventFrame = CreateFrame("Frame")
combatEventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
combatEventFrame:SetScript("OnEvent", OnCombatEnd)
