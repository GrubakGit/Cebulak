-- ====================================================================
-- Cebulak - Waylaid Crate Optimizer (WoW Forever)
-- Główny moduł logiki, integracji z Auctionatorem, inwentarzem i altami
-- ====================================================================
local addonName, Cebulak = ...

_G["Cebulak"] = Cebulak

local L = Cebulak.L

Cebulak.isScanning = false
Cebulak.cachedResults = {}
Cebulak.searchQuery = ""

-- ====================================================================
-- POMOCNICZE BEZPIECZNE FUNKCJE API EKWIPUNKU (Forever / Classic)
-- ====================================================================
local function GetContainerNumSlotsSafe(bag)
  if C_Container and C_Container.GetContainerNumSlots then
    return C_Container.GetContainerNumSlots(bag) or 0
  elseif GetContainerNumSlots then
    return GetContainerNumSlots(bag) or 0
  end
  return 0
end

local function GetContainerItemIDSafe(bag, slot)
  if C_Container and C_Container.GetContainerItemID then
    return C_Container.GetContainerItemID(bag, slot)
  elseif GetContainerItemID then
    return GetContainerItemID(bag, slot)
  end
  return nil
end

local function GetContainerItemCountSafe(bag, slot)
  if C_Container and C_Container.GetContainerItemInfo then
    local info = C_Container.GetContainerItemInfo(bag, slot)
    return info and info.stackCount or 1
  elseif GetContainerItemInfo then
    local _, count = GetContainerItemInfo(bag, slot)
    return count or 1
  end
  return 1
end

-- ====================================================================
-- INICJALIZACJA I ZDARZENIA
-- ====================================================================
local eventFrame = CreateFrame("Frame", "CebulakEventFrame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("AUCTION_HOUSE_SHOW")
eventFrame:RegisterEvent("BAG_UPDATE")
if eventFrame.RegisterUnitEvent then
  eventFrame:RegisterEvent("BAG_UPDATE_DELAYED")
end
eventFrame:RegisterEvent("BANKFRAME_OPENED")
eventFrame:RegisterEvent("MAIL_SHOW")
eventFrame:RegisterEvent("MAIL_INBOX_UPDATE")

eventFrame:SetScript("OnEvent", function(self, event, arg1, ...)
  if event == "ADDON_LOADED" and arg1 == addonName then
    Cebulak:InitializeDB()
    Cebulak:InitializeSlashCommands()
    Cebulak:SetupAuctionatorHooks()
  elseif event == "PLAYER_ENTERING_WORLD" then
    C_Timer.After(2, function()
      Cebulak:ScanBags()
    end)
  elseif event == "AUCTION_HOUSE_SHOW" then
    Cebulak:SetupAuctionatorHooks()
    Cebulak:CreateAHButton()
  elseif event == "BAG_UPDATE" or event == "BAG_UPDATE_DELAYED" then
    -- Opóźnienie aby nie obciążać przy masowym przenoszeniu przedmiotów
    if not Cebulak.bagScanTimer then
      Cebulak.bagScanTimer = C_Timer.After(1.0, function()
        Cebulak:ScanBags()
        Cebulak.bagScanTimer = nil
        if Cebulak.MainFrame and Cebulak.MainFrame:IsShown() and CebulakDB.ownedFilter ~= "ALL" then
          Cebulak:Calculate()
          Cebulak:UpdateUI()
        end
      end)
    end
  elseif event == "BANKFRAME_OPENED" then
    Cebulak:ScanBank()
    if Cebulak.MainFrame and Cebulak.MainFrame:IsShown() and CebulakDB.ownedFilter ~= "ALL" then
      Cebulak:Calculate()
      Cebulak:UpdateUI()
    end
  elseif event == "MAIL_SHOW" or event == "MAIL_INBOX_UPDATE" then
    Cebulak:ScanMailbox()
    if Cebulak.MainFrame and Cebulak.MainFrame:IsShown() and CebulakDB.ownedFilter ~= "ALL" then
      Cebulak:Calculate()
      Cebulak:UpdateUI()
    end
  end
end)

function Cebulak:InitializeDB()
  if not CebulakDB then
    CebulakDB = {
      ownCrate = true, -- domyślnie: posiadam skrzynkę (koszt = 0)
      ownedFilter = "ALL", -- "ALL", "CURRENT", "ACCOUNT"
      selectedTiers = {
        Apprentice = true,
        Journeyman = true,
        Expert = true,
        Artisan = true,
      },
      selectedQualities = {
        ["Biała"] = true,
        ["Zielona"] = true,
      },
      lastScanTime = 0,
      lastScanCount = 0,
      characters = {}, -- [charKey] = { bags = {}, bank = {}, mail = {}, lastUpdate = 0 }
    }
  end

  if CebulakDB.ownCrate == nil then CebulakDB.ownCrate = true end
  if not CebulakDB.ownedFilter then CebulakDB.ownedFilter = "ALL" end
  if not CebulakDB.selectedTiers then
    CebulakDB.selectedTiers = { Apprentice = true, Journeyman = true, Expert = true, Artisan = true }
  end
  if not CebulakDB.selectedQualities then
    CebulakDB.selectedQualities = { ["Biała"] = true, ["Zielona"] = true }
  end
  if not CebulakDB.characters then
    CebulakDB.characters = {}
  end
end

-- ====================================================================
-- IDENTYFIKATOR POSTACI I DANYCH
-- ====================================================================
function Cebulak:GetCharKey()
  local name = UnitName("player")
  if not name or name == "" or name == UNKNOWN then return nil end
  local realm = GetRealmName() or "Unknown"
  return name .. " - " .. realm
end

function Cebulak:GetCharData(charKey)
  charKey = charKey or Cebulak:GetCharKey()
  if not charKey then return {} end

  if not CebulakDB.characters[charKey] then
    CebulakDB.characters[charKey] = {
      bags = {},
      bank = {},
      mail = {},
      lastUpdate = time(),
    }
  end
  return CebulakDB.characters[charKey]
end

-- ====================================================================
-- SKANOWANIE EKWIPUNKU, BANKU ORAZ POCZTY
-- ====================================================================
function Cebulak:ScanBags()
  local charKey = Cebulak:GetCharKey()
  if not charKey then return end
  local charData = Cebulak:GetCharData(charKey)
  charData.bags = {}

  for bag = 0, (NUM_BAG_SLOTS or 4) do
    local numSlots = GetContainerNumSlotsSafe(bag)
    for slot = 1, numSlots do
      local itemID = GetContainerItemIDSafe(bag, slot)
      if itemID and Cebulak.CRATES_BY_ID[itemID] then
        local count = GetContainerItemCountSafe(bag, slot)
        charData.bags[itemID] = (charData.bags[itemID] or 0) + count
      end
    end
  end
  charData.lastUpdate = time()
end

function Cebulak:ScanBank()
  local charKey = Cebulak:GetCharKey()
  if not charKey then return end
  local charData = Cebulak:GetCharData(charKey)
  charData.bank = {}

  -- Główna skrytka bankowa (-1 / BANK_CONTAINER)
  local mainBankID = BANK_CONTAINER or -1
  local mainSlots = GetContainerNumSlotsSafe(mainBankID)
  for slot = 1, mainSlots do
    local itemID = GetContainerItemIDSafe(mainBankID, slot)
    if itemID and Cebulak.CRATES_BY_ID[itemID] then
      local count = GetContainerItemCountSafe(mainBankID, slot)
      charData.bank[itemID] = (charData.bank[itemID] or 0) + count
    end
  end

  -- Dodatkowe torby w banku (5 do 11)
  local startBag = (NUM_BAG_SLOTS or 4) + 1
  local endBag = startBag + (NUM_BANKBAGSLOTS or 7) - 1
  for bag = startBag, endBag do
    local numSlots = GetContainerNumSlotsSafe(bag)
    for slot = 1, numSlots do
      local itemID = GetContainerItemIDSafe(bag, slot)
      if itemID and Cebulak.CRATES_BY_ID[itemID] then
        local count = GetContainerItemCountSafe(bag, slot)
        charData.bank[itemID] = (charData.bank[itemID] or 0) + count
      end
    end
  end
  charData.lastBankUpdate = time()
end

function Cebulak:ScanMailbox()
  local charKey = Cebulak:GetCharKey()
  if not charKey then return end
  local charData = Cebulak:GetCharData(charKey)
  charData.mail = {}

  local numMessages = GetInboxNumItems and GetInboxNumItems() or (GetNumInboxMessages and GetNumInboxMessages() or 0)
  for msgIdx = 1, numMessages do
    for attachIdx = 1, (ATTACHMENTS_MAX_RECEIVE or 16) do
      local itemID = nil
      local count = 1

      if GetInboxItem then
        local _, iid, _, cnt = GetInboxItem(msgIdx, attachIdx)
        itemID = iid
        count = cnt or 1
      end
      if not itemID and GetInboxItemLink then
        local link = GetInboxItemLink(msgIdx, attachIdx)
        if link then
          itemID = tonumber(link:match("item:(%d+)"))
        end
      end

      if itemID and Cebulak.CRATES_BY_ID[itemID] then
        charData.mail[itemID] = (charData.mail[itemID] or 0) + count
      end
    end
  end
  charData.lastMailUpdate = time()
end

-- ====================================================================
-- ODCZYT LOKALIZACJI I ILOŚCI SKRZYNKI (Bieżąca postać + Alty)
-- ====================================================================
function Cebulak:GetCrateLocations(itemID)
  local locations = {}
  local totalAll = 0
  local totalCurrent = 0
  local currentCharKey = Cebulak:GetCharKey()

  if CebulakDB and CebulakDB.characters then
    for charKey, data in pairs(CebulakDB.characters) do
      local bCount = data.bags and data.bags[itemID] or 0
      local bkCount = data.bank and data.bank[itemID] or 0
      local mCount = data.mail and data.mail[itemID] or 0
      local total = bCount + bkCount + mCount

      if total > 0 then
        totalAll = totalAll + total
        local isCur = (charKey == currentCharKey)
        if isCur then
          totalCurrent = totalCurrent + total
        end

        local name, realm = strsplit(" - ", charKey)
        table.insert(locations, {
          charKey = charKey,
          charName = name or charKey,
          realm = realm or "",
          isCurrent = isCur,
          bags = bCount,
          bank = bkCount,
          mail = mCount,
          total = total,
        })
      end
    end
  end

  -- Sortowanie: najpierw bieżąca postać, potem alty
  table.sort(locations, function(a, b)
    if a.isCurrent ~= b.isCurrent then
      return a.isCurrent
    end
    return a.charName < b.charName
  end)

  return locations, totalAll, totalCurrent
end

-- ====================================================================
-- INTEGRACJA Z AUCTIONATOREM (EventBus & Database)
-- ====================================================================
local registeredWithAuctionator = false

function Cebulak:SetupAuctionatorHooks()
  if registeredWithAuctionator then return end

  if Auctionator and Auctionator.EventBus and Auctionator.FullScan and Auctionator.FullScan.Events then
    local listener = {
      ReceiveEvent = function(selfListener, eventName, ...)
        if eventName == Auctionator.FullScan.Events.ScanStart then
          Cebulak:OnScanStart()
        elseif eventName == Auctionator.FullScan.Events.ScanComplete then
          local scanData = ...
          Cebulak:OnScanComplete(scanData)
        elseif eventName == Auctionator.FullScan.Events.ScanFailed then
          Cebulak.isScanning = false
          Cebulak:RefreshUIStatus()
        end
      end
    }

    Auctionator.EventBus:Register(listener, {
      Auctionator.FullScan.Events.ScanStart,
      Auctionator.FullScan.Events.ScanComplete,
      Auctionator.FullScan.Events.ScanFailed,
    })

    registeredWithAuctionator = true
  end

  if Auctionator and Auctionator.Database and not Cebulak.databaseHooked then
    hooksecurefunc(Auctionator.Database, "ProcessScan", function(selfDb, itemIndexes, callback)
      C_Timer.After(0.5, function()
        Cebulak:OnScanComplete()
      end)
    end)
    Cebulak.databaseHooked = true
  end
end

function Cebulak:OnScanStart()
  Cebulak.isScanning = true
  Cebulak:RefreshUIStatus()
end

function Cebulak:OnScanComplete(scanData)
  Cebulak.isScanning = false
  CebulakDB.lastScanTime = time()
  if scanData and type(scanData) == "table" then
    CebulakDB.lastScanCount = #scanData
  elseif Auctionator and Auctionator.Database then
    CebulakDB.lastScanCount = Auctionator.Database:GetItemCount()
  end

  Cebulak:Calculate()
  if Cebulak.MainFrame and Cebulak.MainFrame:IsShown() then
    Cebulak:UpdateUI()
  end
end

-- ====================================================================
-- ODCZYT CEN Z AUCTIONATORA (Błyskawiczny O(1))
-- ====================================================================
function Cebulak:GetItemPrice(itemID)
  if not itemID or itemID == 0 then return 0 end

  local strID = tostring(itemID)

  if Auctionator and Auctionator.Database and Auctionator.Database.db then
    local entry = Auctionator.Database.db[strID]
    if entry and entry.m and entry.m > 0 then
      return entry.m
    end
  end

  if Auctionator and Auctionator.API and Auctionator.API.v1 and Auctionator.API.v1.GetAuctionPriceByItemID then
    local price = Auctionator.API.v1.GetAuctionPriceByItemID("Cebulak", itemID)
    if price and price > 0 then
      return price
    end
  end

  if AUCTIONATOR_PRICE_DATABASE and AUCTIONATOR_PRICE_DATABASE[strID] then
    local entry = AUCTIONATOR_PRICE_DATABASE[strID]
    if entry and entry.m and entry.m > 0 then
      return entry.m
    end
  end

  return 0
end

-- ====================================================================
-- SILNIK KALKULACJI (Z uwzględnieniem posiadanych skrzynek)
-- ====================================================================
function Cebulak:Calculate()
  local results = {}
  local ownedMode = CebulakDB.ownedFilter or "ALL" -- "ALL", "CURRENT", "ACCOUNT"
  local isOwn = (ownedMode ~= "ALL") or CebulakDB.ownCrate
  local filterTiers = CebulakDB.selectedTiers
  local filterQualities = CebulakDB.selectedQualities
  local query = Cebulak.searchQuery and string.lower(Cebulak.searchQuery) or ""

  for _, crate in ipairs(Cebulak.CRATES) do
    if filterTiers[crate.tier] and filterQualities[crate.quality] then
      local locations, totalOwnedAll, totalOwnedCurrent = Cebulak:GetCrateLocations(crate.itemID)

      -- Sprawdź filtr posiadania:
      local passOwnedFilter = true
      if ownedMode == "CURRENT" then
        passOwnedFilter = (totalOwnedCurrent > 0)
      elseif ownedMode == "ACCOUNT" then
        passOwnedFilter = (totalOwnedAll > 0)
      end

      if passOwnedFilter then
        local cratePrice = isOwn and 0 or Cebulak:GetItemPrice(crate.itemID)
        local rew = Cebulak.REWARDS[crate.tier] and Cebulak.REWARDS[crate.tier][crate.quality] or { favor = 5, refund = 0 }
        local favor = rew.favor
        local refund = rew.refund

        local bestCost = 1e12
        local bestOption = nil
        local allOptions = {}

        for _, opt in ipairs(crate.options) do
          local optCost = 0
          local optItems = {}
          local hasAllPrices = true

          for _, item in ipairs(opt) do
            local unitPrice = Cebulak:GetItemPrice(item.itemID)
            if unitPrice == 0 then
              hasAllPrices = false
            end
            local lineCost = unitPrice * item.count
            optCost = optCost + lineCost

            table.insert(optItems, {
              itemID = item.itemID,
              name = item.name,
              count = item.count,
              unitPrice = unitPrice,
              lineCost = lineCost,
            })
          end

          local optData = {
            cost = optCost,
            items = optItems,
            hasAllPrices = hasAllPrices,
          }
          table.insert(allOptions, optData)

          if optCost < bestCost and optCost > 0 then
            bestCost = optCost
            bestOption = optData
          end
        end

        if bestCost == 1e12 then
          bestCost = allOptions[1] and allOptions[1].cost or 0
          bestOption = allOptions[1]
        end

        -- Koszt 1 Favor: (Cena skrzynki + Koszt surowców - Zwrot srebra) / Favor
        local netCost = cratePrice + bestCost - refund
        local costPerFavor = netCost / favor

        -- Filtr wyszukiwarki
        local match = true
        if query ~= "" then
          match = false
          if string.find(string.lower(crate.name), query, 1, true) then
            match = true
          else
            if bestOption then
              for _, it in ipairs(bestOption.items) do
                if string.find(string.lower(it.name), query, 1, true) then
                  match = true
                  break
                end
              end
            end
          end
        end

        if match then
          table.insert(results, {
            crate = crate,
            cratePrice = cratePrice,
            fillingCost = bestCost,
            bestOption = bestOption,
            allOptions = allOptions,
            refund = refund,
            favor = favor,
            netCost = netCost,
            costPerFavor = costPerFavor,
            locations = locations,
            totalOwnedAll = totalOwnedAll,
            totalOwnedCurrent = totalOwnedCurrent,
          })
        end
      end
    end
  end

  -- Sortowanie rosnąco wg kosztu 1 Favor (najtańsze na górze)
  table.sort(results, function(a, b)
    if a.fillingCost == 0 and b.fillingCost > 0 then return false end
    if b.fillingCost == 0 and a.fillingCost > 0 then return true end
    return a.costPerFavor < b.costPerFavor
  end)

  Cebulak.cachedResults = results
  return results
end

-- ====================================================================
-- FORMATOWANIE MONET WOW
-- ====================================================================
function Cebulak:FormatMoney(copper)
  if not copper or copper == 0 then
    return "|cff8888880c|r"
  end

  local prefix = ""
  if copper < 0 then
    prefix = "|cffff3333-|r"
    copper = -copper
  end

  local g = math.floor(copper / 10000)
  local s = math.floor((copper % 10000) / 100)
  local c = math.floor(copper % 100)

  local str = ""
  if g > 0 then
    str = str .. string.format("|cffffd700%d|rg ", g)
  end
  if s > 0 or g > 0 then
    str = str .. string.format("|cffc7c7cf%02d|rs ", s)
  end
  str = str .. string.format("|cffeda55f%02d|rc", c)

  return prefix .. str
end

-- ====================================================================
-- WYSZUKIWANIE W AUCTIONATORZE
-- ====================================================================
function Cebulak:SearchInAuctionator(searchTerm)
  if not searchTerm or searchTerm == "" then return end

  if not AuctionFrame or not AuctionFrame:IsShown() then
    print("|cff00ff00[Cebulak]|r " .. "Otwórz Dom Aukcyjny u aukcjonera, aby wyszukać: " .. searchTerm)
    return
  end

  if Auctionator and Auctionator.API and Auctionator.API.v1 and Auctionator.API.v1.MultiSearch then
    Auctionator.API.v1.MultiSearch("Cebulak", { searchTerm })
    return
  end

  if BrowseName and BrowseSearchButton then
    BrowseName:SetText(searchTerm)
    BrowseSearchButton:Click()
  end
end

-- ====================================================================
-- PRZYCISK W OKNIE DOMU AUKCYJNEGO
-- ====================================================================
function Cebulak:CreateAHButton()
  if Cebulak.AHButton or not AuctionFrame then return end

  local btn = CreateFrame("Button", "CebulakAHButton", AuctionFrame, "UIPanelButtonTemplate")
  btn:SetSize(80, 22)
  btn:SetPoint("TOPRIGHT", AuctionFrame, "TOPRIGHT", -25, -12)
  btn:SetText("🧅 Cebulak")
  btn:SetScript("OnClick", function()
    Cebulak:ToggleUI()
  end)

  btn:SetScript("OnEnter", function(selfBtn)
    GameTooltip:SetOwner(selfBtn, "ANCHOR_RIGHT")
    GameTooltip:SetText("|cff00ff00Cebulak|r — Waylaid Crate Optimizer")
    GameTooltip:AddLine("Kliknij, aby otworzyć kalkulator najtańszych skrzyń.", 1, 1, 1)
    GameTooltip:Show()
  end)
  btn:SetScript("OnLeave", function()
    GameTooltip:Hide()
  end)

  Cebulak.AHButton = btn
end

-- ====================================================================
-- KOMENDY SLASH (/cebulak, /ceb)
-- ====================================================================
function Cebulak:InitializeSlashCommands()
  SLASH_CEBULAK1 = "/cebulak"
  SLASH_CEBULAK2 = "/ceb"
  SlashCmdList["CEBULAK"] = function(msg)
    msg = strtrim(msg or "")
    if msg == "scan" then
      if Auctionator and Auctionator.FullScan and Auctionator.FullScan.Frame then
        Auctionator.FullScan.Frame:InitiateScan()
      else
        print("|cff00ff00[Cebulak]|r Otwórz Dom Aukcyjny, aby rozpocząć Full Scan.")
      end
    elseif msg == "calc" then
      Cebulak:Calculate()
      print("|cff00ff00[Cebulak]|r Przeliczono " .. #Cebulak.cachedResults .. " skrzyń.")
    elseif msg == "bags" then
      Cebulak:ScanBags()
      print("|cff00ff00[Cebulak]|r Zeskanowano ekwipunek.")
    else
      Cebulak:ToggleUI()
    end
  end
end
