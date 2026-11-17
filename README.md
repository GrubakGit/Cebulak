# 🧅 Cebulak — Waylaid Crate Optimizer

> **Błyskawiczny optymalizator skrzyń Waylaid Crate i reputacji Merchant's Favor dla klienta World of Warcraft Forever (1.60.1 / Interface 16001).**

Addon współpracuje bezpośrednio z **Auctionatorem**, wykorzystując jego funkcję **Full Scan** do natychmiastowego znalezienia najtańszego napełnienia każdej skrzynki Waylaid w grze. 

Dodatkowo automatycznie skanuje i śledzi puste skrzynki Waylaid w **ekwipunku**, **banku** oraz **skrzynce pocztowej** – zarówno na aktywnej postaci, jak i na **wszystkich Twoich altach**!

---

## ✨ Główne Możliwości

- ⚡ **Błyskawiczne działanie (< 2 ms):** Baza 30 skrzyń oraz 126 surowców jest pre-indeksowana po unikalnych numerycznych `itemID`. Wyszukiwanie cen w pamięci Auctionatora odbywa się w $O(1)$ bez spadku FPS czy zacięć gry.
- 🔄 **Automatyczny Auto-Refresh:** Addon nasłuchuje na szynie zdarzeń `Auctionator.EventBus` na zdarzenie `ScanComplete`. Po zakończeniu Full Scanu w Auctionatorze ranking przelicza się samoczynnie.
- 📦 **Śledzenie toreb, banku i poczty (Cross-character / Alty):**
  - Automatycznie wykrywa posiadane skrzynki w torbach.
  - Skanuje skrytkę bankową oraz torby bankowe w momencie rozmowy z bankierem (`BANKFRAME_OPENED`).
  - Skanuje odebraną i nieodebraną pocztę z załącznikami przy otwarciu skrzynki pocztowej (`MAIL_SHOW`).
  - Zapamiętuje stan konta – na dowolnej postaci widzisz, które skrzynki leżą u altów w banku lub na poczcie!
- 🎯 **Tryb "Posiadane skrzynki":**
  - Opcja wyświetlania wyłącznie skrzynek, które masz w posiadaniu.
  - Automatycznie zeruje cenę samej skrzynki ($0\text{c}$) i wyszukuje najtańsze napełnienie z AH pomniejszone o nagrodę w srebrze:
    $$\text{Koszt 1 Favor} = \frac{\text{Koszt Najtańszego Wypełnienia} - \text{Zwrot Srebra}}{\text{Ilość Favor}}$$
- 🔍 **Kupno 1 kliknięciem:** Przycisk `🔍` w każdym wierszu tabeli natychmiast wyszukuje najtańszy surowiec w Auctionatorze.
- 📊 **Szczegółowy Tooltip:** Najechanie na dowolny wiersz wyświetla wszystkie alternatywne receptury napełnienia (np. 5 różnych ziół lub 3 przedmioty craftingu) z wyróżnieniem `★ NAJTAŃSZA OPCJA`, a także dokładną rozpiskę, u których altów i w jakiej ilości znajduje się dana skrzynka.

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

1. Otwórz **Dom Aukcyjny** u aukcjonera.
2. W Auctionatorze wykonaj **Full Scan** (pełny skan aukcji).
3. Kliknij przycisk **`🧅 Cebulak`** w prawym górnym rogu okna Domu Aukcyjnego lub wpisz komendę:
   ```text
   /cebulak
   lub
   /ceb
   ```
4. Wybierz filtr:
   - **Wszystkie skrzynki** – aby zobaczyć co opłaca się kupić z AH i złożyć.
   - **Posiadane (Ta postać)** – aby sprawdzić najtańsze napełnienie skrzyń, które masz przy sobie lub w banku/poczcie.
   - **Posiadane (Konto / Alty)** – aby zobaczyć skrzynki na wszystkich postaciach.
5. Kliknij **`🔍`** przy najlepszej ofercie, aby od razu wykupić brakujące materiały na aukcji!

---

## ⌨️ Komendy Czatowe

- `/cebulak` lub `/ceb` — otwiera / zamyka główne okno dodatku
- `/cebulak scan` — uruchamia Full Scan w Auctionatorze
- `/cebulak bags` — wymusza ponowne przeskanowanie toreb

---

## 📜 Licencja

Projekt objęty licencją MIT.
