# 🧅 Cebulak — Waylaid Crate Optimizer & Mailbox Item Filter

> **Błyskawiczny optymalizator skrzyń Waylaid Crate i reputacji Merchant's Favor oraz zaawansowany filtr poczty dla klienta World of Warcraft Forever (1.60.1 / Interface 16001).**

Addon współpracuje bezpośrednio z **Auctionatorem**, wykorzystując jego funkcję **Full Scan** do natychmiastowego znalezienia najtańszego napełnienia każdej skrzynki Waylaid w grze. 

Dodatkowo automatycznie skanuje i śledzi puste skrzynki Waylaid w **ekwipunku**, **banku** oraz **skrzynce pocztowej** (na wszystkich Twoich altach!), a także oferuje **wyszukiwarkę przedmiotów bezpośrednio w panelu skrzynki pocztowej**.

---

## ✨ Główne Możliwości

### 1. Optymalizator Skrzyń Waylaid (Cebulak Core)
- ⚡ **Błyskawiczne działanie (< 2 ms):** Baza 30 skrzyń oraz 126 surowców jest pre-indeksowana po unikalnych numerycznych `itemID`. Wyszukiwanie cen w pamięci Auctionatora odbywa się w $O(1)$ bez spadku FPS czy zacięć gry.
- 🔄 **Automatyczny Auto-Refresh:** Addon nasłuchuje na szynie zdarzeń `Auctionator.EventBus` na zdarzenie `ScanComplete`. Po zakończeniu Full Scanu w Auctionatorze ranking przelicza się samoczynnie.
- 📦 **Śledzenie toreb, banku i poczty (Cross-character / Alty):**
  - Automatycznie wykrywa posiadane skrzynki w torbach.
  - Skanuje skrytkę bankową oraz torby bankowe w momencie rozmowy z bankierem (`BANKFRAME_OPENED`).
  - Skanuje pocztę przy otwarciu skrzynki pocztowej (`MAIL_SHOW`).
  - Zapamiętuje stan konta – na dowolnej postaci widzisz, które skrzynki leżą u altów w banku lub na poczcie!
- 🎯 **Tryb "Posiadane skrzynki":**
  - Opcja wyświetlania wyłącznie skrzynek, które masz w posiadaniu.
  - Automatycznie zeruje cenę samej skrzynki ($0\text{c}$) i wyszukuje najtańsze napełnienie z AH pomniejszone o nagrodę w srebrze:
    $$\text{Koszt 1 Favor} = \frac{\text{Koszt Najtańszego Wypełnienia} - \text{Zwrot Srebra}}{\text{Ilość Favor}}$$
- 🔍 **Kupno 1 kliknięciem:** Przycisk `🔍` w każdym wierszu tabeli natychmiast wyszukuje najtańszy surowiec w Auctionatorze.
- 📊 **Szczegółowy Tooltip:** Najechanie na dowolny wiersz wyświetla wszystkie alternatywne receptury napełnienia z wyróżnieniem `★ NAJTAŃSZA OPCJA`, a także dokładną rozpiskę posiadania na koncie.

### 2. Wyszukiwarka i Filtr Poczty (Mailbox Item Filter)
- ✉️ **Pole wyszukiwania w panelu poczty:** W oknie skrzynki pocztowej gry pojawia się pasek `Przedmiot: [ Wpisz nazwę... ][✕]`.
- 🔎 **Filtrowanie wieloprzesyłkowych listów:**
  - Gdy wpiszesz np. `Iron Ore`, `Lesser Magic Essence` czy `Waylaid`, lista wiadomości **natychmiast ukrywa niepasujące listy i wyświetla wyłącznie te zawierające szukany przedmiot**!
  - Addon przeszukuje od 1 do kilkunastu załączników w każdej pojedynczej wiadomości.
- 🌟 **Zielone podświetlenie i plakietki:**
  - Wiadomości z pasującymi przedmiotami otrzymują zieloną ramkę i plakietkę z nazwą znalezionego przedmiotu.
  - Najechanie kursorem na list w skrzynce wyświetla w tooltipie listę wszystkich znalezionych w nim przedmiotów.
- 📄 **Inteligentne stronicowanie:** Licznik stron poczty dostosowuje się do liczby pasujących wyników (np. `Trafień: 4 / 28`).
- ✕ **Szybkie czyszczenie:** Przycisk `[✕]` lub klawisz `Escape` natychmiast przywraca pełną skrzynkę pocztową.

---

## 📥 Instalacja

1. Pobierz repozytorium (lub archiwum ZIP).
2. Umieść folder `Cebulak` w katalogu dodatków gry:
   ```text
   World of Warcraft/Interface/AddOns/Cebulak
   ```
3. Upewnij się, że w folderze `AddOns` zainstalowany jest również **Auctionator**.
4. Włącz dodatek w menu postaci w grze.

---

## 🎮 Jak Używać w Grze

### Waylaid Optimizer:
1. Otwórz **Dom Aukcyjny** i wykonaj **Full Scan** w Auctionatorze.
2. Kliknij przycisk **`🧅 Cebulak`** w prawym górnym rogu okna Domu Aukcyjnego lub wpisz `/cebulak`.
3. Wybierz filtr (Wszystkie / Posiadane na tej postaci / Posiadane na altach).
4. Kliknij **`🔍`**, aby od razu kupić najtańsze materiały!

### Filtr Poczty (Mailbox):
1. Otwórz dowolną **Skrzynkę Pocztową** w grze.
2. W górnym pasku skrzynki pocztowej wpisz fragment nazwy szukanego przedmiotu.
3. Skrzynka natychmiast pokaże wyłącznie listy zawierające ten przedmiot!

---

## ⌨️ Komendy Czatowe

- `/cebulak` lub `/ceb` — otwiera / zamyka główne okno dodatku
- `/cebulak scan` — uruchamia Full Scan w Auctionatorze
- `/cebulak bags` — wymusza ponowne przeskanowanie toreb

---

## 📜 Licencja

Projekt objęty licencją MIT.
