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
  L.WARBAND = "Warband-Bank"
  L.GUILDBANK = "Gildenbank"
  L.ALLCHARS = "Alle Charaktere:"
  L.TOTAL = "Gesamt"
  L.RESET = "Datenbank zurückgesetzt."
  L.HELP1 = "Befehle:"
  L.HELP2 = "/fag reset - Setzt die Datenbank zurück."
  L.CLICK = "Rechtsklick für Befehle."
elseif locale == "frFR" then
  L.TITLE = "Titan [FastAccountGold]"
  L.CURCHAR = "Personnage actuel"
  L.WARBAND = "Banque de la cohorte"
  L.GUILDBANK = "Banque de guilde"
  L.ALLCHARS = "Tous les personnages :"
  L.TOTAL = "Total"
  L.RESET = "Base de données réinitialisée."
  L.HELP1 = "Commandes :"
  L.HELP2 = "/fag reset - Réinitialise la base de données."
  L.CLICK = "Clic droit pour les commandes."
elseif locale == "esES" or locale == "esMX" then
  L.TITLE = "Titan [FastAccountGold]"
  L.CURCHAR = "Personaje actual"
  L.WARBAND = "Banco de hermandad"
  L.GUILDBANK = "Banco de hermandad"
  L.ALLCHARS = "Todos los personajes:"
  L.TOTAL = "Total"
  L.RESET = "Base de datos reiniciada."
  L.HELP1 = "Comandos:"
  L.HELP2 = "/fag reset - Restablece la base de datos."
  L.CLICK = "Clic derecho para comandos."
elseif locale == "itIT" then
  L.TITLE = "Titan [FastAccountGold]"
  L.CURCHAR = "Personaggio attuale"
  L.WARBAND = "Banca della coorte"
  L.GUILDBANK = "Banca di gilda"
  L.ALLCHARS = "Tutti i personaggi:"
  L.TOTAL = "Totale"
  L.RESET = "Database ripristinato."
  L.HELP1 = "Comandi:"
  L.HELP2 = "/fag reset - Ripristina il database."
  L.CLICK = "Clic destro per comandi."
else
  L.TITLE = "Titan [FastAccountGold]"
  L.CURCHAR = "Current Character"
  L.WARBAND = "Warband Bank"
  L.GUILDBANK = "Guild Bank"
  L.ALLCHARS = "All Characters:"
  L.TOTAL = "Total"
  L.RESET = "Database reset."
  L.HELP1 = "Commands:"
  L.HELP2 = "/fag reset - Reset the database."
  L.CLICK = "Right-click for commands."
end

local function MoneyToString(copper)
    copper = copper or 0
    local gold = floor(copper / (100*100))
    local silver = floor((copper / 100) % 100)
    local copperOnly = copper % 100

    local goldStr   = string.format("|cffffd700%dg|r", gold)    -- Gold gelb
    local silverStr = string.format("|cffc7c7cf%02ds|r", silver) -- Silber hellgrau
    local copperStr = string.format("|cffeda55f%02dc|r", copperOnly) -- Kupfer orange/braun

    return goldStr.." "..silverStr.." "..copperStr
end

local function GetWarbandMoney()
  if C_Bank and C_Bank.FetchDepositedMoney and Enum and Enum.BankType and Enum.BankType.Account then
    local ok, value = pcall(C_Bank.FetchDepositedMoney, Enum.BankType.Account)
    if ok and type(value)=="number" then
      return value
    end
  end
  return 0
end

local function GetGuildMoneyCached()
  if IsInGuild() and GetGuildBankMoney then
    return GetGuildBankMoney() or 0
  end
  return 0
end

local function ensureCharEntry()
  FastAccountGoldDB.chars[REALM] = FastAccountGoldDB.chars[REALM] or {}
  FastAccountGoldDB.chars[REALM][CHAR] = FastAccountGoldDB.chars[REALM][CHAR] or { money = 0, class = select(2, UnitClass("player")) }
end

local function updateCharMoney()
  ensureCharEntry()
  FastAccountGoldDB.chars[REALM][CHAR].money = GetMoney() or 0
end

local function CalculateTotal()
  local sum = 0
  for _, chars in pairs(FastAccountGoldDB.chars) do
    for _, data in pairs(chars) do
      sum = sum + (data.money or 0)
    end
  end
  sum = sum + GetWarbandMoney() + (FastAccountGoldDB.guild.last or 0)
  return sum
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
      tt:AddLine(L.TITLE, 1, 0.82, 0)
      tt:AddLine(" ")

      local currentCharGold = FastAccountGoldDB.chars[REALM] and FastAccountGoldDB.chars[REALM][CHAR] and FastAccountGoldDB.chars[REALM][CHAR].money or 0
      local warband = GetWarbandMoney()
      local guild = FastAccountGoldDB.guild.last or 0

      tt:AddDoubleLine("|cff00ff00"..L.CURCHAR.."|r", MoneyToString(currentCharGold))
      tt:AddLine(" ")
      tt:AddDoubleLine("|cffffff00"..L.WARBAND.."|r", MoneyToString(warband))
      tt:AddDoubleLine("|cffffff00"..L.GUILDBANK.."|r", MoneyToString(guild))
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
      tt:AddDoubleLine("|cffffd700"..L.TOTAL.."|r", MoneyToString(CalculateTotal()))

      tt:AddLine(" ")
      tt:AddLine("|cffaaaaaa" .. L.CLICK .. "|r")
    end,
    OnClick = function(_, button)
      if button == "RightButton" then
        print("|cffffcc00FastAccountGold:|r " .. L.HELP1)
        print("  " .. L.HELP2)
      end
    end,
  })
else
  print("|cffff0000FastAccountGold: LibDataBroker-1.1 fehlt.|r")
end

-- #### Events ####
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_MONEY")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_LOGOUT")
f:RegisterEvent("GUILDBANKFRAME_OPENED")
f:RegisterEvent("GUILDBANK_UPDATE_MONEY")

f:SetScript("OnEvent", function(_, event)
  if event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
    ensureCharEntry()
    updateCharMoney()
    if IsInGuild() then
      FastAccountGoldDB.guild.last = GetGuildMoneyCached()
      FastAccountGoldDB.guild.ts = time()
    end
  elseif event == "PLAYER_MONEY" then
    updateCharMoney()
  elseif event == "PLAYER_LOGOUT" then
    updateCharMoney()
  elseif event == "GUILDBANKFRAME_OPENED" or event == "GUILDBANK_UPDATE_MONEY" then
    FastAccountGoldDB.guild.last = GetGuildMoneyCached()
    FastAccountGoldDB.guild.ts = time()
  end

  if broker then
    local currentCharGold = FastAccountGoldDB.chars[REALM] and FastAccountGoldDB.chars[REALM][CHAR] and FastAccountGoldDB.chars[REALM][CHAR].money or 0
    broker.text = MoneyToString(currentCharGold)
  end
end)

-- #### Slash-Befehl ####
SLASH_FAG1 = "/fag"
SlashCmdList["FAG"] = function(msg)
  msg = (msg or ""):lower()
  if msg == "reset" then
    FastAccountGoldDB = { chars = {}, guild = {last=0, ts=0} }
    ensureCharEntry()
    updateCharMoney()
    if broker then
      local currentCharGold = FastAccountGoldDB.chars[REALM][CHAR].money or 0
      broker.text = MoneyToString(currentCharGold)
    end
    print("|cffffcc00FastAccountGold:|r " .. L.RESET)
  else
    print("|cffffcc00FastAccountGold:|r " .. L.HELP1)
    print("  " .. L.HELP2)
  end
end
