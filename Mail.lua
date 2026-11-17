-- ====================================================================
-- Cebulak - Waylaid Crate Optimizer (WoW Forever)
-- Moduł wyszukiwania i filtrowania wiadomości w skrzynce pocztowej
-- ====================================================================
local addonName, Cebulak = ...

local L = Cebulak.L

Cebulak.isMailFiltered = false
Cebulak.mailMatches = {}
Cebulak.mailMatchDetails = {}
Cebulak.mailFilteredPage = 1
Cebulak.mailSearchQuery = ""

local INBOX_ITEMS_PER_PAGE = 7

-- ====================================================================
-- TWORZENIE PASKA WYSZUKIWANIA W SKRZYNCE POCZTOWEJ
-- ====================================================================
function Cebulak:SetupMailboxUI()
  if Cebulak.MailSearchBox or not InboxFrame then return end

  -- Kontener na pasek wyszukiwarki poczty
  local container = CreateFrame("Frame", "CebulakMailSearchContainer", InboxFrame)
  container:SetSize(280, 26)
  container:SetPoint("TOPLEFT", InboxFrame, "TOPLEFT", 45, -46)

  -- Etykieta "Szukaj:"
  local label = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  label:SetPoint("LEFT", container, "LEFT", 0, 0)
  label:SetText("|cffffcc00Przedmiot:|r")

  -- Pole tekstowe (InputBox)
  local searchBox = CreateFrame("EditBox", "CebulakMailSearchBox", container, "InputBoxTemplate")
  searchBox:SetSize(140, 20)
  searchBox:SetPoint("LEFT", label, "RIGHT", 6, 0)
  searchBox:SetAutoFocus(false)
  searchBox:SetMaxLetters(50)

  -- Placeholder / tekst podpowiedzi
  local placeholder = searchBox:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  placeholder:SetPoint("LEFT", searchBox, "LEFT", 4, 0)
  placeholder:SetText("Wpisz nazwę...")
  searchBox.placeholder = placeholder

  -- Przycisk wyczyszczenia [X]
  local clearBtn = CreateFrame("Button", nil, searchBox)
  clearBtn:SetSize(16, 16)
  clearBtn:SetPoint("RIGHT", searchBox, "RIGHT", -2, 0)
  clearBtn:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
  clearBtn:SetHighlightTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Highlight")
  clearBtn:SetPushedTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Down")
  clearBtn:Hide()

  clearBtn:SetScript("OnClick", function()
    searchBox:SetText("")
    searchBox:ClearFocus()
  end)

  -- Licznik trafień
  local countText = container:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  countText:SetPoint("LEFT", searchBox, "RIGHT", 8, 0)
  countText:SetText("")
  container.countText = countText

  -- Obsługa zdarzeń pola tekstowego
  searchBox:SetScript("OnTextChanged", function(selfBox)
    local text = selfBox:GetText() or ""
    Cebulak.mailSearchQuery = text

    if text ~= "" then
      placeholder:Hide()
      clearBtn:Show()
    else
      placeholder:Show()
      clearBtn:Hide()
    end

    Cebulak.mailFilteredPage = 1
    Cebulak:FilterAndRenderMail()
  end)

  searchBox:SetScript("OnEscapePressed", function(selfBox)
    selfBox:SetText("")
    selfBox:ClearFocus()
  end)

  searchBox:SetScript("OnEnterPressed", function(selfBox)
    selfBox:ClearFocus()
  end)

  Cebulak.MailSearchBox = searchBox
  Cebulak.MailSearchContainer = container

  -- Nakładki podświetlenia dla wierszy MailItem1..7
  Cebulak:SetupMailRowHighlights()

  -- Hookowanie przycisków stronicowania skrzynki pocztowej
  if InboxPrevPageButton then
    InboxPrevPageButton:HookScript("OnClick", function()
      if Cebulak.isMailFiltered then
        if Cebulak.mailFilteredPage > 1 then
          Cebulak.mailFilteredPage = Cebulak.mailFilteredPage - 1
          Cebulak:RenderFilteredPage()
        end
      end
    end)
  end

  if InboxNextPageButton then
    InboxNextPageButton:HookScript("OnClick", function()
      if Cebulak.isMailFiltered then
        local maxPages = math.max(1, math.ceil(#Cebulak.mailMatches / INBOX_ITEMS_PER_PAGE))
        if Cebulak.mailFilteredPage < maxPages then
          Cebulak.mailFilteredPage = Cebulak.mailFilteredPage + 1
          Cebulak:RenderFilteredPage()
        end
      end
    end)
  end

  -- Bezpieczny hook na InboxFrame_Update Blizzarda
  hooksecurefunc("InboxFrame_Update", function()
    if Cebulak.isMailFiltered and not Cebulak.isUpdatingInboxHook then
      Cebulak:RenderFilteredPage()
    end
  end)
end

-- ====================================================================
-- RAMKI PODŚWIETLENIA DLA WIERSZY WIADOMOŚCI
-- ====================================================================
function Cebulak:SetupMailRowHighlights()
  Cebulak.mailRowHighlights = {}
  Cebulak.mailRowBadges = {}

  for i = 1, INBOX_ITEMS_PER_PAGE do
    local mailRow = _G["MailItem" .. i]
    if mailRow then
      -- Złota/zielona ramka podświetlająca
      local glow = CreateFrame("Frame", nil, mailRow)
      glow:SetAllPoints(mailRow)
      glow:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
      })
      glow:SetBackdropBorderColor(0.1, 1.0, 0.2, 0.9) -- Wyrazista zieleń
      glow:Hide()
      Cebulak.mailRowHighlights[i] = glow

      -- Etykieta dopasowanego przedmiotu na wierszu
      local badge = mailRow:CreateFontString(nil, "OVERLAY", "GameFontGreenSmall")
      badge:SetPoint("BOTTOMRIGHT", mailRow, "BOTTOMRIGHT", -8, 6)
      badge:SetText("")
      badge:Hide()
      Cebulak.mailRowBadges[i] = badge

      -- Rozszerzenie tooltipa o listę znalezionych przedmiotów
      mailRow:HookScript("OnEnter", function(selfRow)
        if not selfRow.index then return end
        local details = Cebulak.mailMatchDetails[selfRow.index]
        if details and #details > 0 then
          GameTooltip:AddLine(" ")
          GameTooltip:AddLine("|cff00ff00[Cebulak] Znalezione przedmioty w tej paczce:|r", 1, 1, 1)
          for _, item in ipairs(details) do
            local countStr = item.count > 1 and (" x" .. item.count) or ""
            GameTooltip:AddLine("  • |cffffffff" .. item.name .. "|r" .. countStr, 0.2, 1.0, 0.2)
          end
          GameTooltip:Show()
        end
      end)
    end
  end
end

-- ====================================================================
-- SKANOWANIE I FILTROWANIE WIADOMOŚCI
-- ====================================================================
function Cebulak:FilterAndRenderMail()
  local numMessages = GetInboxNumItems and GetInboxNumItems() or (GetNumInboxMessages and GetNumInboxMessages() or 0)
  local query = strtrim(Cebulak.mailSearchQuery or "")

  Cebulak.mailMatches = {}
  Cebulak.mailMatchDetails = {}

  if query == "" then
    Cebulak.isMailFiltered = false
    if Cebulak.MailSearchContainer then
      Cebulak.MailSearchContainer.countText:SetText(string.format("|cff888888Łącznie: %d|r", numMessages))
    end
    Cebulak:HideAllMailHighlights()
    -- Przywróć standardowy widok Blizzarda
    if InboxFrame and InboxFrame:IsShown() then
      InboxFrame_Update()
    end
    return
  end

  Cebulak.isMailFiltered = true
  query = string.lower(query)

  -- Skanuj wszystkie wiadomości w skrzynce
  for msgIndex = 1, numMessages do
    local matchedItems = {}
    local hasMatch = false

    -- Skanuj załączniki
    for attachIndex = 1, (ATTACHMENTS_MAX_RECEIVE or 16) do
      local itemName, itemID, itemTexture, count
      if GetInboxItem then
        itemName, itemID, itemTexture, count = GetInboxItem(msgIndex, attachIndex)
      end

      if not itemName and GetInboxItemLink then
        local link = GetInboxItemLink(msgIndex, attachIndex)
        if link then
          itemName = link:match("%[(.-)%]")
        end
      end

      if itemName and string.find(string.lower(itemName), query, 1, true) then
        hasMatch = true
        table.insert(matchedItems, {
          name = itemName,
          count = count or 1,
          texture = itemTexture,
          attachIndex = attachIndex,
        })
      end
    end

    -- Skanuj temat wiadomości jako uzupełnienie
    if not hasMatch and GetInboxHeaderInfo then
      local _, _, _, subject = GetInboxHeaderInfo(msgIndex)
      if subject and string.find(string.lower(subject), query, 1, true) then
        hasMatch = true
      end
    end

    if hasMatch then
      table.insert(Cebulak.mailMatches, msgIndex)
      Cebulak.mailMatchDetails[msgIndex] = matchedItems
    end
  end

  if Cebulak.MailSearchContainer then
    if #Cebulak.mailMatches > 0 then
      Cebulak.MailSearchContainer.countText:SetText(
        string.format("|cff00ff00Trafień: %d / %d|r", #Cebulak.mailMatches, numMessages)
      )
    else
      Cebulak.MailSearchContainer.countText:SetText("|cffff4444Brak wyników|r")
    end
  end

  Cebulak:RenderFilteredPage()
end

-- ====================================================================
-- RENDEROWANIE PRZEFILTROWANEJ STRONY W INBOXFRAME
-- ====================================================================
function Cebulak:RenderFilteredPage()
  if not Cebulak.isMailFiltered or not InboxFrame or not InboxFrame:IsShown() then return end

  Cebulak.isUpdatingInboxHook = true

  local totalMatches = #Cebulak.mailMatches
  local maxPages = math.max(1, math.ceil(totalMatches / INBOX_ITEMS_PER_PAGE))
  if Cebulak.mailFilteredPage > maxPages then
    Cebulak.mailFilteredPage = maxPages
  elseif Cebulak.mailFilteredPage < 1 then
    Cebulak.mailFilteredPage = 1
  end

  local startIndex = (Cebulak.mailFilteredPage - 1) * INBOX_ITEMS_PER_PAGE

  for i = 1, INBOX_ITEMS_PER_PAGE do
    local mailRow = _G["MailItem" .. i]
    local glow = Cebulak.mailRowHighlights and Cebulak.mailRowHighlights[i]
    local badge = Cebulak.mailRowBadges and Cebulak.mailRowBadges[i]

    local matchIdx = startIndex + i
    if matchIdx <= totalMatches then
      local realMsgIndex = Cebulak.mailMatches[matchIdx]
      mailRow.index = realMsgIndex

      -- Pobierz nagłówek oryginalnej wiadomości
      local packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, hasItem, wasRead, wasReturned, textCreated, canReply, isGM = GetInboxHeaderInfo(realMsgIndex)

      local btn = _G["MailItem" .. i .. "Button"]
      local senderText = _G["MailItem" .. i .. "Sender"]
      local subjectText = _G["MailItem" .. i .. "Subject"]
      local expireTime = _G["MailItem" .. i .. "ExpireTime"]

      if senderText then senderText:SetText(sender or UNKNOWN) end
      if subjectText then subjectText:SetText(subject or "") end

      if btn then
        local icon = packageIcon or stationeryIcon or "Interface\\Icons\\INV_Misc_Note_01"
        btn:SetNormalTexture(icon)
        if btn.hasItem then
          btn.hasItem = hasItem
        end
        if btn.itemCount then
          btn.itemCount = hasItem or 0
        end
      end

      if expireTime and daysLeft then
        local days = math.floor(daysLeft)
        local hours = math.floor((daysLeft - days) * 24)
        if days >= 1 then
          expireTime:SetText(string.format("%dd", days))
        else
          expireTime:SetText(string.format("%dh", hours))
        end
      end

      -- Włącz podświetlenie i plakietkę
      if glow then glow:Show() end
      if badge then
        local details = Cebulak.mailMatchDetails[realMsgIndex]
        if details and #details > 0 then
          local firstName = details[1].name
          if #details > 1 then
            badge:SetText(string.format("★ %s (+%d)", firstName, #details - 1))
          else
            badge:SetText("★ " .. firstName)
          end
          badge:Show()
        else
          badge:Hide()
        end
      end

      mailRow:Show()
    else
      if glow then glow:Hide() end
      if badge then badge:Hide() end
      mailRow:Hide()
    end
  end

  -- Aktualizacja przycisków stronicowania
  if InboxPrevPageButton then
    if Cebulak.mailFilteredPage > 1 then
      InboxPrevPageButton:Enable()
    else
      InboxPrevPageButton:Disable()
    end
  end

  if InboxNextPageButton then
    if Cebulak.mailFilteredPage < maxPages then
      InboxNextPageButton:Enable()
    else
      InboxNextPageButton:Disable()
    end
  end

  if InboxPageText then
    InboxPageText:SetText(string.format("%d / %d", Cebulak.mailFilteredPage, maxPages))
  end

  Cebulak.isUpdatingInboxHook = false
end

function Cebulak:HideAllMailHighlights()
  if Cebulak.mailRowHighlights then
    for _, glow in pairs(Cebulak.mailRowHighlights) do
      glow:Hide()
    end
  end
  if Cebulak.mailRowBadges then
    for _, badge in pairs(Cebulak.mailRowBadges) do
      badge:Hide()
    end
  end
end

-- ====================================================================
-- REJESTRACJA ZDARZEŃ POCZTY
-- ====================================================================
local mailEventFrame = CreateFrame("Frame", "CebulakMailEventFrame")
mailEventFrame:RegisterEvent("MAIL_SHOW")
mailEventFrame:RegisterEvent("MAIL_INBOX_UPDATE")
mailEventFrame:RegisterEvent("MAIL_CLOSED")

mailEventFrame:SetScript("OnEvent", function(self, event)
  if event == "MAIL_SHOW" then
    C_Timer.After(0.1, function()
      Cebulak:SetupMailboxUI()
      if Cebulak.MailSearchBox and Cebulak.mailSearchQuery ~= "" then
        Cebulak:FilterAndRenderMail()
      elseif Cebulak.MailSearchContainer then
        local num = GetInboxNumItems and GetInboxNumItems() or (GetNumInboxMessages and GetNumInboxMessages() or 0)
        Cebulak.MailSearchContainer.countText:SetText(string.format("|cff888888Łącznie: %d|r", num))
      end
    end)
  elseif event == "MAIL_INBOX_UPDATE" then
    if Cebulak.isMailFiltered and Cebulak.mailSearchQuery ~= "" then
      Cebulak:FilterAndRenderMail()
    end
  elseif event == "MAIL_CLOSED" then
    Cebulak:HideAllMailHighlights()
    Cebulak.isMailFiltered = false
    if Cebulak.MailSearchBox then
      Cebulak.MailSearchBox:SetText("")
      Cebulak.mailSearchQuery = ""
    end
  end
end)
