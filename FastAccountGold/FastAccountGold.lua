-- Titan [FastAccountGold] - WoW: The War Within
-- Zeigt Gold des aktuellen Charakters, Warband-Bank & Gildenbank im Tooltip.
-- Minimaler Titan-Text, Details im Tooltip.

local ADDON = "FastAccountGold"
local REALM = GetRealmName()
local CHAR  = UnitName("player")

FastAccountGoldDB = FastAccountGoldDB or { chars = {}, guild = {last=0, ts=0} }

-- #### Sprachpaket ####
local L = {}
local locale = GetLocale()
if locale == "deDE" then
  L.TITLE = "Titan [FastAccountGold]"
  L.CURCHAR = "Aktueller Charakter"
  L.WARBAND = "Kriegsmeuten-Bank"
  L.GUILDBANK = "Gildenbank"
  L.ALLCHARS = "Alle Charaktere:"
  L.TOTAL = "Gesamt"
  L.RESET = "Datenbank zurückgesetzt."
  L.SESSIONRESET = "Sitzung zurückgesetzt."
  L.HELP1 = "Befehle:"
  L.HELP2 = "/fag reset - Setzt die Datenbank zurück."
  L.HELP3 = "/fag session - Setzt nur die aktuelle Sitzung zurück."
  L.CLICK = "Rechtsklick für Befehle."
  L.SHIFTRESET = "Shift+Rechtsklick: Sitzung zurücksetzen"
  L.ALTRESET = "Alt+Rechtsklick: Alles zurücksetzen"
  L.SESSION = "Sitzung"
  L.GAINED = "Eingenommen"
  L.SPENT = "Ausgegeben"
elseif locale == "ruRU" then
  L.TITLE = "Titan [FastAccountGold]"
  L.CURCHAR = "Текущий персонаж"
  L.WARBAND = "Банк отряда"
  L.GUILDBANK = "Банк гильдии"
  L.ALLCHARS = "Все персонажи:"
  L.TOTAL = "Всего"
  L.RESET = "База данных сброшена."
  L.SESSIONRESET = "Сеанс сброшен."
  L.HELP1 = "Команды:"
  L.HELP2 = "/fag reset - сбросить базу данных."
  L.HELP3 = "/fag session - сбросить только сеанс."
  L.CLICK = "ПКМ: отобразить команды."
  L.SHIFTRESET = "Shift+ПКМ: сброс сеанса"
  L.ALTRESET = "Alt+ПКМ: сбросить все"
  L.SESSION = "Сеанс"
  L.GAINED = "Получено"
  L.SPENT = "Потрачено"
elseif locale == "frFR" then
  L.TITLE = "Titan [FastAccountGold]"
  L.CURCHAR = "Personnage actuel"
  L.WARBAND = "Banque de cohorte"
  L.GUILDBANK = "Banque de guilde"
  L.ALLCHARS = "Tous les personnages :"
  L.TOTAL = "Total"
  L.RESET = "Base de données réinitialisée."
  L.SESSIONRESET = "Session réinitialisée."
  L.HELP1 = "Commandes :"
  L.HELP2 = "/fag reset - Réinitialise la base de données."
  L.HELP3 = "/fag session - Réinitialise uniquement la session actuelle."
  L.CLICK = "Clic droit pour commandes."
  L.SHIFTRESET = "Shift+Clic droit : Réinitialiser la session"
  L.ALTRESET = "Alt+Clic droit : Tout réinitialiser"
  L.SESSION = "Session"
  L.GAINED = "Gagné"
  L.SPENT = "Dépensé"
elseif locale == "esES" or locale == "esMX" then
  L.TITLE = "Titan [FastAccountGold]"
  L.CURCHAR = "Personaje actual"
  L.WARBAND = "Banco de cohorte"
  L.GUILDBANK = "Banco de hermandad"
  L.ALLCHARS = "Todos los personajes:"
  L.TOTAL = "Total"
  L.RESET = "Base de datos reiniciada."
  L.SESSIONRESET = "Sesión reiniciada."
  L.HELP1 = "Comandos:"
  L.HELP2 = "/fag reset - Restablece la base de datos."
  L.HELP3 = "/fag session - Restablece solo la sesión actual."
  L.CLICK = "Clic derecho para comandos."
  L.SHIFTRESET = "Shift+Clic derecho: Reiniciar sesión"
  L.ALTRESET = "Alt+Clic derecho: Reiniciar todo"
  L.SESSION = "Sesión"
  L.GAINED = "Ganado"
  L.SPENT = "Gastado"
elseif locale == "itIT" then
  L.TITLE = "Titan [FastAccountGold]"
  L.CURCHAR = "Personaggio attuale"
  L.WARBAND = "Banca coorte"
  L.GUILDBANK = "Banca di gilda"
  L.ALLCHARS = "Tutti i personaggi:"
  L.TOTAL = "Totale"
  L.RESET = "Database ripristinato."
  L.SESSIONRESET = "Sessione reimpostata."
  L.HELP1 = "Comandi:"
  L.HELP2 = "/fag reset - Ripristina il database."
  L.HELP3 = "/fag session - Ripristina solo la sessione corrente."
  L.CLICK = "Clic destro per comandi."
  L.SHIFTRESET = "Shift+Clic destro: Reimposta sessione"
  L.ALTRESET = "Alt+Clic destro: Reimposta tutto"
  L.SESSION = "Sessione"
  L.GAINED = "Guadagnato"
  L.SPENT = "Speso"
else
  L.TITLE = "Titan [FastAccountGold]"
  L.CURCHAR = "Current Character"
  L.WARBAND = "Warband Bank"
  L.GUILDBANK = "Guild Bank"
  L.ALLCHARS = "All Characters:"
  L.TOTAL = "Total"
  L.RESET = "Database reset."
  L.SESSIONRESET = "Session reset."
  L.HELP1 = "Commands:"
  L.HELP2 = "/fag reset - Reset the database."
  L.HELP3 = "/fag session - Reset session only."
  L.CLICK = "Right-click for commands."
  L.SHIFTRESET = "Shift+Right-click: Reset session"
  L.ALTRESET = "Alt+Right-click: Reset all"
  L.SESSION = "Session"
  L.GAINED = "Gained"
  L.SPENT = "Spent"
end

-- #### Symbole (eingebettete Texturen) ####
local ICON_GAIN  = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4:14:14:0:0|t" -- grünes Dreieck
local ICON_SPENT = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7:14:14:0:0|t" -- rotes X

-- #### Hilfsfunktionen ####
local function formatWithSeparators(num)
  local formatted = tostring(num)
  while true do
    local k
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1.%2")
    if k == 0 then break end
  end
  return formatted
end

local function MoneyToString(copper)
  copper = copper or 0
  local gold = floor(copper / (100*100))
  local silver = floor((copper / 100) % 100)
  local copperOnly = copper % 100
  gold = formatWithSeparators(gold)
  return string.format("|cffffd700%sg|r |cffc7c7cf%02ds|r |cffeda55f%02dc|r", gold, silver, copperOnly)
end

local function GetWarbandMoney()
  if C_Bank and C_Bank.FetchDepositedMoney and Enum and Enum.BankType and Enum.BankType.Account then
    local ok, value = pcall(C_Bank.FetchDepositedMoney, Enum.BankType.Account)
    if ok and type(value)=="number" then return value end
  end
  return 0
end

local function GetGuildMoneyCached()
  if IsInGuild() and GetGuildBankMoney then return GetGuildBankMoney() or 0 end
  return 0
end

local function ensureCharEntry()
  FastAccountGoldDB.chars[REALM] = FastAccountGoldDB.chars[REALM] or {}
  FastAccountGoldDB.chars[REALM][CHAR] = FastAccountGoldDB.chars[REALM][CHAR] or { money = 0, class = select(2, UnitClass("player")) }
end

local function ensureSession()
  FastAccountGoldDB.session = FastAccountGoldDB.session or { gain=0, spent=0, lastLogin=0 }
end

local function updateCharMoney()
  ensureCharEntry()
  FastAccountGoldDB.chars[REALM][CHAR].money = GetMoney() or 0
end

local function CalculateTotal()
  local sum = 0
  for _, chars in pairs(FastAccountGoldDB.chars) do
    for _, data in pairs(chars) do sum = sum + (data.money or 0) end
  end
  sum = sum + GetWarbandMoney() + (FastAccountGoldDB.guild.last or 0)
  return sum
end

local previousGold = 0
local function trackSession()
  ensureSession()
  local current = GetMoney()
  if previousGold > 0 then
    local diff = current - previousGold
    if diff > 0 then FastAccountGoldDB.session.gain = (FastAccountGoldDB.session.gain or 0) + diff
    elseif diff < 0 then FastAccountGoldDB.session.spent = (FastAccountGoldDB.session.spent or 0) + abs(diff) end
  end
  previousGold = current
end

local function resetSession()
  ensureSession()
  FastAccountGoldDB.session.gain = 0
  FastAccountGoldDB.session.spent = 0
  FastAccountGoldDB.session.lastLogin = time()
end

-- #### LDB-Datenquelle ####
local LDB = LibStub and LibStub:GetLibrary("LibDataBroker-1.1", true)
local broker
if LDB then
  broker = LDB:NewDataObject("FastAccountGold", {
    type = "data source",
    text = "Account Gold",
    icon = 134327,
    OnTooltipShow = function(tt)
      ensureSession()
      tt:AddLine(L.TITLE, 1, 0.82, 0)
      tt:AddLine(" ")

      local currentCharGold = FastAccountGoldDB.chars[REALM][CHAR].money or 0
      local warband = GetWarbandMoney()
      local guild = FastAccountGoldDB.guild.last or 0

      tt:AddDoubleLine("|cff00ff00"..L.CURCHAR.."|r", MoneyToString(currentCharGold))
      tt:AddLine(" ")
      tt:AddDoubleLine("|cffffff00"..L.WARBAND.."|r", MoneyToString(warband))

      local guildDate = ""
      if FastAccountGoldDB.guild.ts and FastAccountGoldDB.guild.ts > 0 then
        guildDate = " ("..date("%d.%m.%Y %H:%M", FastAccountGoldDB.guild.ts)..")"
      end
      tt:AddDoubleLine("|cffffff00"..L.GUILDBANK.."|r", MoneyToString(guild)..guildDate)

      tt:AddLine(" ")
      tt:AddLine("|cffffd700"..L.ALLCHARS.."|r")
      for realm, chars in pairs(FastAccountGoldDB.chars) do
        tt:AddLine("  " .. realm)
        for char, data in pairs(chars) do
          local classColor = RAID_CLASS_COLORS[data.class] and RAID_CLASS_COLORS[data.class].colorStr or "ffffffff"
          tt:AddDoubleLine(("    |c%s%s|r"):format(classColor, char), MoneyToString(data.money or 0))
        end
      end

      tt:AddLine(" ")
      tt:AddDoubleLine("|cffffd700"..L.TOTAL.."|r", "|cffffff00"..MoneyToString(CalculateTotal()).."|r")
      tt:AddLine(" ")
      tt:AddLine("|cffffff00"..L.SESSION.."|r")
      tt:AddDoubleLine(ICON_GAIN.." |cff00ff00"..L.GAINED.."|r:", "|cff00ff00"..MoneyToString(FastAccountGoldDB.session.gain).."|r")
      tt:AddDoubleLine(ICON_SPENT.." |cffff0000"..L.SPENT.."|r:", "|cffff0000"..MoneyToString(FastAccountGoldDB.session.spent).."|r")
      tt:AddLine(" ")
      tt:AddLine("|cffaaaaaa"..L.SHIFTRESET.."|r")
      tt:AddLine("|cffaaaaaa"..L.ALTRESET.."|r")
    end,
    OnClick = function(_, button)
      if button == "RightButton" then
        if IsAltKeyDown() then
          FastAccountGoldDB = { chars={}, guild={last=0, ts=0}, session={gain=0, spent=0, lastLogin=time()} }
          ensureCharEntry()
          updateCharMoney()
          print("|cffffcc00FastAccountGold:|r "..L.RESET)
        elseif IsShiftKeyDown() then
          resetSession()
          print("|cffffcc00FastAccountGold:|r "..L.SESSIONRESET)
        else
          print("|cffffcc00FastAccountGold:|r "..L.HELP1)
          print("  "..L.HELP2)
          print("  "..L.HELP3)
        end
      end
    end,
  })
end

-- #### Events ####
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_MONEY")
f:RegisterEvent("PLAYER_LOGOUT")
f:RegisterEvent("GUILDBANKFRAME_OPENED")
f:RegisterEvent("GUILDBANK_UPDATE_MONEY")

f:SetScript("OnEvent", function(_, event)
  if event == "PLAYER_LOGIN" then
    ensureCharEntry()
    ensureSession()
    updateCharMoney()

    if IsInGuild() then
      local guildGold = GetGuildMoneyCached()
      if guildGold > 0 then
        FastAccountGoldDB.guild.last = guildGold
        FastAccountGoldDB.guild.ts = time()
      end
    end

    if not FastAccountGoldDB.session.lastLogin or (time() - FastAccountGoldDB.session.lastLogin) > 300 then
      resetSession()
    end

    previousGold = GetMoney()

  elseif event == "PLAYER_MONEY" then
    trackSession()
    updateCharMoney()

  elseif event == "PLAYER_LOGOUT" then
    updateCharMoney()

  elseif event == "GUILDBANKFRAME_OPENED" or event == "GUILDBANK_UPDATE_MONEY" then
    FastAccountGoldDB.guild.last = GetGuildMoneyCached()
    FastAccountGoldDB.guild.ts = time()
  end

  if broker then
    local currentCharGold = FastAccountGoldDB.chars[REALM][CHAR].money or 0
    broker.text = MoneyToString(currentCharGold)
  end
end)

-- #### Slash-Befehl ####
SLASH_FAG1 = "/fag"
SlashCmdList["FAG"] = function(msg)
  msg = (msg or ""):lower()
  if msg == "reset" then
    FastAccountGoldDB = { chars={}, guild={last=0, ts=0}, session={gain=0, spent=0, lastLogin=time()} }
    ensureCharEntry()
    updateCharMoney()
    if broker then
      broker.text = MoneyToString(FastAccountGoldDB.chars[REALM][CHAR].money)
    end
    print("|cffffcc00FastAccountGold:|r "..L.RESET)
  elseif msg == "session" then
    resetSession()
    print("|cffffcc00FastAccountGold:|r "..L.SESSIONRESET)
  else
    print("|cffffcc00FastAccountGold:|r "..L.HELP1)
    print("  "..L.HELP2)
    print("  "..L.HELP3)
  end
end
