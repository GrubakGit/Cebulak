-- ====================================================================
-- Cebulak - Waylaid Crate Optimizer (WoW Forever)
-- Interfejs graficzny UI (Z filtrami posiadania na postaci i altach)
-- ====================================================================
local _, Cebulak = ...

local L = Cebulak.L

local ROW_HEIGHT = 30
local NUM_VISIBLE_ROWS = 10
local FRAME_WIDTH = 880
local FRAME_HEIGHT = 530

function Cebulak:CreateUI()
  if Cebulak.MainFrame then return end

  -- Główne okno
  local frame = CreateFrame("Frame", "CebulakMainFrame", UIParent)
  frame:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
  frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", frame.StartMoving)
  frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
  frame:SetClampedToScreen(true)
  frame:SetFrameStrata("HIGH")

  -- Tło i obramowanie
  frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 24,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
  })
  frame:SetBackdropColor(0.06, 0.06, 0.08, 0.95)

  -- Tytuł
  local titleBg = frame:CreateTexture(nil, "ARTWORK")
  titleBg:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
  titleBg:SetSize(360, 56)
  titleBg:SetPoint("TOP", frame, "TOP", 0, 12)

  local titleText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  titleText:SetPoint("TOP", titleBg, "TOP", 0, -14)
  titleText:SetText("|cffffcc00🧅 Cebulak|r — |cff00ff00Waylaid Optimizer|r")

  -- Przycisk zamknięcia
  local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
  closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)

  -- Pasek statusu (góra)
  local statusText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  statusText:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -32)
  statusText:SetText("|cff00ff00(●)|r " .. L["STATUS_READY"])
  frame.statusText = statusText

  -- Licznik posiadanych skrzynek w nagłówku
  local ownedSummaryText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  ownedSummaryText:SetPoint("LEFT", statusText, "RIGHT", 25, 0)
  ownedSummaryText:SetText("")
  frame.ownedSummaryText = ownedSummaryText

  -- Przycisk Odśwież
  local refreshBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  refreshBtn:SetSize(90, 22)
  refreshBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -38, -30)
  refreshBtn:SetText("🔄 " .. L["REFRESH_BTN"])
  refreshBtn:SetScript("OnClick", function()
    Cebulak:ScanBags()
    Cebulak:Calculate()
    Cebulak:UpdateUI()
    PlaySound(841)
  end)

  -- ==================================================================
  -- PASEK FILTRÓW: TRYB SKRZYNEK (Wszystkie / Moja postać / Alty)
  -- ==================================================================
  local filterY1 = -58

  local scopeLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  scopeLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, filterY1 - 4)
  scopeLabel:SetText(L["OWNED_FILTER_LABEL"])

  -- Radiobutton 1: Wszystkie
  local rbAll = CreateFrame("CheckButton", "CebulakScope_All", frame, "UIRadioButtonTemplate")
  rbAll:SetPoint("LEFT", scopeLabel, "RIGHT", 8, 0)
  _G[rbAll:GetName() .. "Text"]:SetText(L["OWNED_ALL"])
  
  -- Radiobutton 2: Posiadane (Ta postać)
  local rbCurrent = CreateFrame("CheckButton", "CebulakScope_Current", frame, "UIRadioButtonTemplate")
  rbCurrent:SetPoint("LEFT", _G[rbAll:GetName() .. "Text"], "RIGHT", 14, 0)
  _G[rbCurrent:GetName() .. "Text"]:SetText("|cff00ff00" .. L["OWNED_CURRENT_CHAR"] .. "|r")

  -- Radiobutton 3: Posiadane (Konto / Alty)
  local rbAccount = CreateFrame("CheckButton", "CebulakScope_Account", frame, "UIRadioButtonTemplate")
  rbAccount:SetPoint("LEFT", _G[rbCurrent:GetName() .. "Text"], "RIGHT", 14, 0)
  _G[rbAccount:GetName() .. "Text"]:SetText("|cffffff55" .. L["OWNED_ALL_CHARS"] .. "|r")

  local function UpdateScopeRadios()
    local mode = CebulakDB.ownedFilter or "ALL"
    rbAll:SetChecked(mode == "ALL")
    rbCurrent:SetChecked(mode == "CURRENT")
    rbAccount:SetChecked(mode == "ACCOUNT")
  end
  UpdateScopeRadios()

  rbAll:SetScript("OnClick", function()
    CebulakDB.ownedFilter = "ALL"
    UpdateScopeRadios()
    Cebulak:Calculate()
    Cebulak:UpdateUI()
  end)

  rbCurrent:SetScript("OnClick", function()
    CebulakDB.ownedFilter = "CURRENT"
    UpdateScopeRadios()
    Cebulak:Calculate()
    Cebulak:UpdateUI()
  end)

  rbAccount:SetScript("OnClick", function()
    CebulakDB.ownedFilter = "ACCOUNT"
    UpdateScopeRadios()
    Cebulak:Calculate()
    Cebulak:UpdateUI()
  end)

  -- Pole wyszukiwania
  local searchBox = CreateFrame("EditBox", "CebulakSearchBox", frame, "InputBoxTemplate")
  searchBox:SetSize(150, 20)
  searchBox:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -25, filterY1 - 2)
  searchBox:SetAutoFocus(false)
  searchBox:SetText(Cebulak.searchQuery or "")

  local searchLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  searchLabel:SetPoint("RIGHT", searchBox, "LEFT", -6, 0)
  searchLabel:SetText("Szukaj:")

  searchBox:SetScript("OnTextChanged", function(selfBox)
    Cebulak.searchQuery = selfBox:GetText()
    Cebulak:Calculate()
    Cebulak:UpdateUI()
  end)

  searchBox:SetScript("OnEscapePressed", function(selfBox)
    selfBox:SetText("")
    selfBox:ClearFocus()
  end)

  -- ==================================================================
  -- PASEK FILTRÓW: TIERY I JAKOŚĆ
  -- ==================================================================
  local filterY2 = filterY1 - 26

  local tierLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  tierLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, filterY2)
  tierLabel:SetText("Tiery:")

  local tiers = { "Apprentice", "Journeyman", "Expert", "Artisan" }
  local lastTierObj = tierLabel
  for _, tier in ipairs(tiers) do
    local cb = CreateFrame("CheckButton", "CebulakTierCheck_" .. tier, frame, "UICheckButtonTemplate")
    cb:SetPoint("LEFT", lastTierObj, "RIGHT", 6, 0)
    _G[cb:GetName() .. "Text"]:SetText(tier)
    cb:SetChecked(CebulakDB.selectedTiers[tier] == true)
    cb:SetScript("OnClick", function(selfCb)
      CebulakDB.selectedTiers[tier] = selfCb:GetChecked()
      Cebulak:Calculate()
      Cebulak:UpdateUI()
    end)
    lastTierObj = _G[cb:GetName() .. "Text"]
  end

  local qualLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  qualLabel:SetPoint("LEFT", lastTierObj, "RIGHT", 16, 0)
  qualLabel:SetText("Typ:")

  local cbWhite = CreateFrame("CheckButton", "CebulakQualCheck_White", frame, "UICheckButtonTemplate")
  cbWhite:SetPoint("LEFT", qualLabel, "RIGHT", 6, 0)
  _G[cbWhite:GetName() .. "Text"]:SetText("Białe (Surowce)")
  cbWhite:SetChecked(CebulakDB.selectedQualities["Biała"] == true)
  cbWhite:SetScript("OnClick", function(selfCb)
    CebulakDB.selectedQualities["Biała"] = selfCb:GetChecked()
    Cebulak:Calculate()
    Cebulak:UpdateUI()
  end)

  local cbGreen = CreateFrame("CheckButton", "CebulakQualCheck_Green", frame, "UICheckButtonTemplate")
  cbGreen:SetPoint("LEFT", _G[cbWhite:GetName() .. "Text"], "RIGHT", 10, 0)
  _G[cbGreen:GetName() .. "Text"]:SetText("Zielone (Craft)")
  cbGreen:SetChecked(CebulakDB.selectedQualities["Zielona"] == true)
  cbGreen:SetScript("OnClick", function(selfCb)
    CebulakDB.selectedQualities["Zielona"] = selfCb:GetChecked()
    Cebulak:Calculate()
    Cebulak:UpdateUI()
  end)

  -- Checkbox: Posiadam w torbie (0c) przy trybie "Wszystkie"
  local ownCrateCheck = CreateFrame("CheckButton", "CebulakOwnCrateCheck", frame, "UICheckButtonTemplate")
  ownCrateCheck:SetPoint("LEFT", _G[cbGreen:GetName() .. "Text"], "RIGHT", 14, 0)
  _G[ownCrateCheck:GetName() .. "Text"]:SetText("|cffaaaaaaKoszt skrzynki = 0c|r")
  ownCrateCheck:SetChecked(CebulakDB.ownCrate)
  ownCrateCheck:SetScript("OnClick", function(selfCheck)
    CebulakDB.ownCrate = selfCheck:GetChecked()
    Cebulak:Calculate()
    Cebulak:UpdateUI()
  end)

  -- ==================================================================
  -- NAGŁÓWEK TABELI
  -- ==================================================================
  local tableY = -118
  local headerFrame = CreateFrame("Frame", nil, frame)
  headerFrame:SetSize(FRAME_WIDTH - 36, 24)
  headerFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, tableY)

  local headerBg = headerFrame:CreateTexture(nil, "BACKGROUND")
  headerBg:SetAllPoints()
  headerBg:SetColorTexture(0.12, 0.12, 0.16, 0.8)

  local cols = {
    { text = L["COL_RANK"],       width = 34,  x = 6 },
    { text = L["COL_CRATE"],      width = 205, x = 44 },
    { text = L["COL_LOCATION"],   width = 110, x = 252 },
    { text = L["COL_TIER"],       width = 80,  x = 366 },
    { text = L["COL_FAVOR_COST"], width = 105, x = 450 },
    { text = L["COL_FILLING"],    width = 185, x = 560 },
    { text = L["COL_REFUND"],     width = 60,  x = 750 },
    { text = L["COL_BUY"],        width = 38,  x = 815 },
  }

  for _, c in ipairs(cols) do
    local fs = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    fs:SetPoint("LEFT", headerFrame, "LEFT", c.x, 0)
    fs:SetWidth(c.width)
    fs:SetJustifyH("LEFT")
    fs:SetText(c.text)
  end

  -- ==================================================================
  -- WIERSZE TABELI (LISTA Z PRZEWIJANIEM)
  -- ==================================================================
  frame.rows = {}
  local rowsContainer = CreateFrame("Frame", "CebulakRowsContainer", frame)
  rowsContainer:SetSize(FRAME_WIDTH - 36, NUM_VISIBLE_ROWS * ROW_HEIGHT)
  rowsContainer:SetPoint("TOPLEFT", headerFrame, "BOTTOMLEFT", 0, -2)

  for i = 1, NUM_VISIBLE_ROWS do
    local row = CreateFrame("Button", "CebulakRow_" .. i, rowsContainer)
    row:SetSize(FRAME_WIDTH - 55, ROW_HEIGHT)
    row:SetPoint("TOPLEFT", rowsContainer, "TOPLEFT", 0, -(i - 1) * ROW_HEIGHT)

    local highlight = row:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints()
    highlight:SetColorTexture(0.2, 0.4, 0.7, 0.3)

    local rowBg = row:CreateTexture(nil, "BACKGROUND")
    rowBg:SetAllPoints()
    if i % 2 == 0 then
      rowBg:SetColorTexture(0.08, 0.08, 0.12, 0.5)
    else
      rowBg:SetColorTexture(0.04, 0.04, 0.06, 0.5)
    end
    row.bg = rowBg

    -- 1. Ranga
    local rankText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    rankText:SetPoint("LEFT", row, "LEFT", 6, 0)
    rankText:SetWidth(32)
    rankText:SetJustifyH("CENTER")
    row.rankText = rankText

    -- 2. Ikona i nazwa skrzynki
    local crateIcon = row:CreateTexture(nil, "ARTWORK")
    crateIcon:SetSize(20, 20)
    crateIcon:SetPoint("LEFT", row, "LEFT", 42, 0)
    crateIcon:SetTexture("Interface\\Icons\\INV_Box_01")
    row.crateIcon = crateIcon

    local crateNameText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    crateNameText:SetPoint("LEFT", crateIcon, "RIGHT", 6, 0)
    crateNameText:SetWidth(175)
    crateNameText:SetJustifyH("LEFT")
    crateNameText:SetWordWrap(false)
    row.crateNameText = crateNameText

    -- 3. Lokalizacja / Stan posiadania (Torba, Bank, Poczta, Alty)
    local locationText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    locationText:SetPoint("LEFT", row, "LEFT", 252, 0)
    locationText:SetWidth(110)
    locationText:SetJustifyH("LEFT")
    locationText:SetWordWrap(false)
    row.locationText = locationText

    -- 4. Tier
    local tierText = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    tierText:SetPoint("LEFT", row, "LEFT", 366, 0)
    tierText:SetWidth(80)
    tierText:SetJustifyH("LEFT")
    row.tierText = tierText

    -- 5. Koszt 1 Favor
    local favorCostText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    favorCostText:SetPoint("LEFT", row, "LEFT", 450, 0)
    favorCostText:SetWidth(105)
    favorCostText:SetJustifyH("LEFT")
    row.favorCostText = favorCostText

    -- 6. Najtańsze napełnienie
    local fillingText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    fillingText:SetPoint("LEFT", row, "LEFT", 560, 0)
    fillingText:SetWidth(185)
    fillingText:SetJustifyH("LEFT")
    fillingText:SetWordWrap(false)
    row.fillingText = fillingText

    -- 7. Zwrot srebra
    local refundText = row:CreateFontString(nil, "OVERLAY", "GameFontGreenSmall")
    refundText:SetPoint("LEFT", row, "LEFT", 750, 0)
    refundText:SetWidth(60)
    refundText:SetJustifyH("LEFT")
    row.refundText = refundText

    -- 8. Przycisk Akcji "Szukaj 🔍"
    local buyBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    buyBtn:SetSize(36, 20)
    buyBtn:SetPoint("LEFT", row, "LEFT", 815, 0)
    buyBtn:SetText("🔍")
    buyBtn:SetScript("OnClick", function()
      if row.data and row.data.bestOption and row.data.bestOption.items[1] then
        Cebulak:SearchInAuctionator(row.data.bestOption.items[1].name)
      end
    end)
    buyBtn:SetScript("OnEnter", function(selfBtn)
      GameTooltip:SetOwner(selfBtn, "ANCHOR_RIGHT")
      GameTooltip:SetText(L["TOOLTIP_SEARCH_HINT"])
      GameTooltip:Show()
    end)
    buyBtn:SetScript("OnLeave", function()
      GameTooltip:Hide()
    end)
    row.buyBtn = buyBtn

    row:SetScript("OnEnter", function(selfRow)
      if not selfRow.data then return end
      Cebulak:ShowCrateTooltip(selfRow, selfRow.data)
    end)
    row:SetScript("OnLeave", function()
      GameTooltip:Hide()
    end)

    table.insert(frame.rows, row)
  end

  -- Pasek przewijania
  local scrollBar = CreateFrame("ScrollFrame", "CebulakScrollFrame", frame, "FauxScrollFrameTemplate")
  scrollBar:SetPoint("TOPLEFT", rowsContainer, "TOPLEFT", 0, 0)
  scrollBar:SetPoint("BOTTOMRIGHT", rowsContainer, "BOTTOMRIGHT", -2, 0)
  scrollBar:SetScript("OnVerticalScroll", function(selfScroll, offset)
    FauxScrollFrame_OnVerticalScroll(selfScroll, offset, ROW_HEIGHT, function()
      Cebulak:UpdateUI()
    end)
  end)
  frame.scrollFrame = scrollBar

  -- Podpis na dole
  local footerText = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  footerText:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 18, 14)
  footerText:SetText("|cff888888Wskazówka: Najedź na skrzynkę, by podejrzeć stan u altów oraz wszystkie warianty. Kliknij 🔍 aby szukać w AH.|r")

  Cebulak.MainFrame = frame
end

-- ====================================================================
-- WYŚWIETLANIE SZCZEGÓŁOWEGO TOOLTIPA (Warianty + Alty)
-- ====================================================================
function Cebulak:ShowCrateTooltip(parent, data)
  local crate = data.crate
  local rew = Cebulak.REWARDS[crate.tier] and Cebulak.REWARDS[crate.tier][crate.quality] or { favor = 5, refund = 0 }

  GameTooltip:SetOwner(parent, "ANCHOR_TOPLEFT", 0, 10)
  GameTooltip:ClearLines()

  local qColor = crate.quality == "Zielona" and "|cff1eff00" or "|cffffffff"
  GameTooltip:AddLine(qColor .. crate.name .. "|r (" .. crate.tier .. ")", 1, 1, 1)

  GameTooltip:AddDoubleLine(
    string.format(L["TOOLTIP_FAVOR"], rew.favor),
    string.format(L["TOOLTIP_REFUND"], Cebulak:FormatMoney(rew.refund)),
    1, 0.82, 0, 0.2, 1, 0.2
  )

  -- Informacja o posiadaniu na koncie / postaciach
  GameTooltip:AddLine(" ")
  GameTooltip:AddLine(L["TOOLTIP_OWNED_HEADER"], 1, 0.82, 0)
  if data.locations and #data.locations > 0 then
    for _, loc in ipairs(data.locations) do
      local charPrefix = loc.isCurrent and "|cff00ff00[Ta postać]|r " or ("|cffffff55[" .. loc.charName .. "]|r ")
      local details = {}
      if loc.bags > 0 then table.insert(details, L["LOC_BAG"] .. ": " .. loc.bags) end
      if loc.bank > 0 then table.insert(details, L["LOC_BANK"] .. ": " .. loc.bank) end
      if loc.mail > 0 then table.insert(details, L["LOC_MAIL"] .. ": " .. loc.mail) end

      local desc = table.concat(details, ", ")
      GameTooltip:AddDoubleLine("  " .. charPrefix .. desc, "|cffffd700Łącznie: " .. loc.total .. "|r")
    end
  else
    GameTooltip:AddLine("  " .. L["TOOLTIP_NOT_OWNED"], 0.7, 0.7, 0.7)
  end

  if not CebulakDB.ownCrate and (CebulakDB.ownedFilter == "ALL") then
    local cp = Cebulak:GetItemPrice(crate.itemID)
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(string.format(L["TOOLTIP_CRATE_PRICE"], Cebulak:FormatMoney(cp)), 0.7, 0.7, 0.7)
  end

  GameTooltip:AddLine(" ")
  GameTooltip:AddLine(L["TOOLTIP_TITLE"], 1, 0.82, 0)

  for _, opt in ipairs(data.allOptions) do
    local isBest = (opt == data.bestOption and opt.cost > 0)
    local itemsStr = ""
    for _, it in ipairs(opt.items) do
      if itemsStr ~= "" then itemsStr = itemsStr .. " + " end
      itemsStr = itemsStr .. string.format("%dx %s (%s)", it.count, it.name, Cebulak:FormatMoney(it.lineCost))
    end

    local prefix = isBest and "|cff00ff00★ |r" or "  "
    local optCostStr = Cebulak:FormatMoney(opt.cost)
    if isBest then
      GameTooltip:AddDoubleLine(prefix .. itemsStr, "|cff00ff00" .. optCostStr .. " [" .. L["TOOLTIP_CHEAPEST"] .. "]|r")
    else
      GameTooltip:AddDoubleLine(prefix .. itemsStr, optCostStr, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8)
    end
  end

  GameTooltip:AddLine(" ")
  GameTooltip:AddLine(L["TOOLTIP_SEARCH_HINT"], 0, 1, 0)
  GameTooltip:Show()
end

-- ====================================================================
-- AKTUALIZACJA WIDOKU UI (FauxScrollFrame)
-- ====================================================================
function Cebulak:UpdateUI()
  if not Cebulak.MainFrame or not Cebulak.MainFrame:IsShown() then return end

  local results = Cebulak.cachedResults or {}
  local numResults = #results
  local offset = FauxScrollFrame_GetOffset(Cebulak.MainFrame.scrollFrame)

  FauxScrollFrame_Update(Cebulak.MainFrame.scrollFrame, numResults, NUM_VISIBLE_ROWS, ROW_HEIGHT)

  -- Podlicz łączne skrzynki w posiadaniu
  local totalCurrentOwned = 0
  local totalAccountOwned = 0
  for _, crate in ipairs(Cebulak.CRATES) do
    local _, allCount, curCount = Cebulak:GetCrateLocations(crate.itemID)
    totalAccountOwned = totalAccountOwned + allCount
    totalCurrentOwned = totalCurrentOwned + curCount
  end
  Cebulak.MainFrame.ownedSummaryText:SetText(
    string.format("|cff888888Posiadane:|r |cff00ff00%d|r (Ta postać) / |cffffff55%d|r (Konto)", totalCurrentOwned, totalAccountOwned)
  )

  for i = 1, NUM_VISIBLE_ROWS do
    local row = Cebulak.MainFrame.rows[i]
    local dataIndex = offset + i

    if dataIndex <= numResults then
      local data = results[dataIndex]
      row.data = data
      row:Show()

      -- Ranga
      if dataIndex == 1 then
        row.rankText:SetText("|cffffd700🥇 1|r")
      elseif dataIndex == 2 then
        row.rankText:SetText("|cffc7c7cf🥈 2|r")
      elseif dataIndex == 3 then
        row.rankText:SetText("|cffeda55f🥉 3|r")
      else
        row.rankText:SetText(tostring(dataIndex) .. ".")
      end

      -- Ikona przedmiotu
      local _, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(data.crate.itemID)
      if itemTexture then
        row.crateIcon:SetTexture(itemTexture)
      else
        row.crateIcon:SetTexture("Interface\\Icons\\INV_Box_01")
      end

      -- Nazwa skrzynki
      local qColor = data.crate.quality == "Zielona" and "|cff1eff00" or "|cffffffff"
      row.crateNameText:SetText(qColor .. data.crate.name .. "|r")

      -- Kolumna Lokalizacji (Stan posiadania)
      if data.totalOwnedAll and data.totalOwnedAll > 0 then
        local locStr = ""
        local firstLoc = data.locations and data.locations[1]
        if firstLoc then
          local parts = {}
          if firstLoc.bags > 0 then table.insert(parts, "T:" .. firstLoc.bags) end
          if firstLoc.bank > 0 then table.insert(parts, "B:" .. firstLoc.bank) end
          if firstLoc.mail > 0 then table.insert(parts, "P:" .. firstLoc.mail) end

          local prefix = firstLoc.isCurrent and "|cff00ff00" or ("|cffffff55[" .. firstLoc.charName .. "] ")
          locStr = prefix .. table.concat(parts, " ") .. "|r"

          if #data.locations > 1 then
            locStr = locStr .. " |cff888888(+" .. (#data.locations - 1) .. ")|r"
          end
        end
        row.locationText:SetText(locStr)
      else
        row.locationText:SetText("|cff555555-|r")
      end

      -- Tier
      row.tierText:SetText(data.crate.tier)

      -- Koszt 1 Favor
      if data.fillingCost == 0 then
        row.favorCostText:SetText("|cffff4444Brak cen AH|r")
      else
        row.favorCostText:SetText(Cebulak:FormatMoney(data.costPerFavor) .. " |cff888888/pkt|r")
      end

      -- Najtańsze napełnienie
      if data.bestOption and #data.bestOption.items > 0 then
        local fillDesc = ""
        for _, it in ipairs(data.bestOption.items) do
          if fillDesc ~= "" then fillDesc = fillDesc .. " + " end
          fillDesc = fillDesc .. string.format("%dx %s", it.count, it.name)
        end
        row.fillingText:SetText(fillDesc .. " (" .. Cebulak:FormatMoney(data.fillingCost) .. ")")
      else
        row.fillingText:SetText("|cff888888Brak danych|r")
      end

      -- Zwrot
      if data.refund > 0 then
        row.refundText:SetText("+" .. Cebulak:FormatMoney(data.refund))
      else
        row.refundText:SetText("|cff666666-0c|r")
      end

      row.buyBtn:Show()
    else
      row:Hide()
      row.data = nil
    end
  end

  Cebulak:RefreshUIStatus()
end

function Cebulak:RefreshUIStatus()
  if not Cebulak.MainFrame then return end

  if Cebulak.isScanning then
    Cebulak.MainFrame.statusText:SetText("|cffffcc00(⏳) " .. L["STATUS_SCANNING"] .. "|r")
  elseif CebulakDB.lastScanTime and CebulakDB.lastScanTime > 0 then
    local timeStr = date("%H:%M:%S", CebulakDB.lastScanTime)
    local countStr = BreakUpLargeNumbers(CebulakDB.lastScanCount or 0)
    Cebulak.MainFrame.statusText:SetText("|cff00ff00(●) " .. L["STATUS_READY"] .. "|r — " .. string.format(L["LAST_SCAN"], timeStr, countStr))
  else
    Cebulak.MainFrame.statusText:SetText("|cffff9900(⚠) " .. L["STATUS_NO_DATA"] .. "|r")
  end
end

-- ====================================================================
-- TOGGLE OTWARCIA/ZAMKNIĘCIA OKNA
-- ====================================================================
function Cebulak:ToggleUI()
  if not Cebulak.MainFrame then
    Cebulak:CreateUI()
  end

  if Cebulak.MainFrame:IsShown() then
    Cebulak.MainFrame:Hide()
  else
    Cebulak:ScanBags()
    Cebulak:Calculate()
    Cebulak.MainFrame:Show()
    Cebulak:UpdateUI()
  end
end
