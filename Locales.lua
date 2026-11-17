-- ====================================================================
-- Cebulak - Waylaid Crate Optimizer (WoW Forever)
-- Lokalizacja i teksty interfejsu (PL / EN fallback)
-- ====================================================================
local _, Cebulak = ...

local L = {}
Cebulak.L = L

-- Angielskie domyślne (fallback)
L["TITLE"] = "Cebulak — Waylaid Crate Optimizer"
L["SUBTITLE"] = "Optymalizator Merchant's Favor bazujący na cenach z Auctionatora"
L["STATUS_READY"] = "Baza zsynchronizowana"
L["STATUS_SCANNING"] = "Trwa skanowanie AH przez Auctionator..."
L["STATUS_NO_DATA"] = "Brak danych z Full Scan. Uruchom Full Scan w Auctionatorze!"
L["LAST_SCAN"] = "Ostatni skan: %s (%s aukcji)"
L["REFRESH_BTN"] = "Odśwież"
L["OPEN_AH_SCAN_BTN"] = "Full Scan AH"
L["CRATE_OWNED"] = "Posiadam w torbie (Koszt skrzynki = 0)"
L["CRATE_BUY_AH"] = "Kupuję skrzynkę z AH (dolicz cenę)"

-- Nowe filtry posiadanych skrzynek
L["OWNED_FILTER_LABEL"] = "Wyświetlaj:"
L["OWNED_ALL"] = "Wszystkie skrzynki"
L["OWNED_CURRENT_CHAR"] = "Posiadane (Ta postać)"
L["OWNED_ALL_CHARS"] = "Posiadane (Konto / Alty)"
L["COL_LOCATION"] = "Gdzie jest"
L["LOC_BAG"] = "Torba"
L["LOC_BANK"] = "Bank"
L["LOC_MAIL"] = "Poczta"
L["TOOLTIP_OWNED_HEADER"] = "📦 W POSIADANIU:"
L["TOOLTIP_NOT_OWNED"] = "|cff888888Brak w ekwipunku, banku i poczcie|r"

L["TIER_ALL"] = "Wszystkie Tiery"
L["TYPE_ALL"] = "Wszystkie Typy"
L["TYPE_WHITE"] = "Białe (Surowce)"
L["TYPE_GREEN"] = "Zielone (Crafting)"
L["SEARCH_PLACEHOLDER"] = "Szukaj skrzynki lub materiału..."
L["COL_RANK"] = "Poz."
L["COL_CRATE"] = "Skrzynka Waylaid"
L["COL_TIER"] = "Tier"
L["COL_FAVOR_COST"] = "Koszt 1 Favor"
L["COL_FILLING"] = "Najtańsze napełnienie"
L["COL_REFUND"] = "Zwrot"
L["COL_FAVOR"] = "Favor"
L["COL_BUY"] = "Kup"
L["NO_RESULTS"] = "Brak skrzynek spełniających wybrane kryteria filtrów."
L["TOOLTIP_TITLE"] = "Koszty alternatywnych wariantów napełnienia:"
L["TOOLTIP_CHEAPEST"] = "★ NAJTAŃSZA OPCJA"
L["TOOLTIP_CRATE_PRICE"] = "Cena rynkowa samej skrzynki: %s"
L["TOOLTIP_REFUND"] = "Nagroda za oddanie (zwrot): %s"
L["TOOLTIP_FAVOR"] = "Otrzymany Merchant's Favor: %d pkt"
L["TOOLTIP_SEARCH_HINT"] = "|cff00ff00Kliknij [Kup 🔍], aby otworzyć wyszukiwanie w Auctionatorze!|r"
L["AH_BUTTON_TEXT"] = "Cebulak"
L["AH_BUTTON_TOOLTIP"] = "Otwórz okno optymalizatora skrzyń Cebulak (Waylaid Optimizer)"
