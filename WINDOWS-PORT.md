# Badgertop → Windows: zadání pro port

Tahle složka je hotová macOS verze (Swift, AppKit). Zdrojáky jsou specifikace chování –
Windows verze se má chovat stejně. Tenhle soubor shrnuje, co z kódu není na první pohled vidět.

## Doporučený stack
- **C# / .NET 8, WinForms + Win32 P/Invoke**, publikovat jako jeden self-contained `.exe`
  (`dotnet publish -c Release -r win-x64 -p:PublishSingleFile=true --self-contained`).
- Překryvná okna: `WS_EX_LAYERED | WS_EX_TOOLWINDOW | WS_EX_TOPMOST | WS_EX_NOACTIVATE`,
  kreslit přes `UpdateLayeredWindow` (per-pixel alfa). Klikatelnost přepínat `WS_EX_TRANSPARENT`
  podle toho, jestli je kurzor nad medojedem (na Macu `ignoresMouseEvents` s hover zpožděním).
- **Jedno malé okno na každý objekt** (medojed, bublina, předmět, rekvizita, nora) – ne jedno
  přes celou obrazovku (na Macu to žralo CPU, celoobrazovkové vrstvy byly nahrazeny pruhy).
- Ikona v oznamovací oblasti (`NotifyIcon`) = ekvivalent 🦡 v menu baru; menu stejné jako na Macu.
- Instalátor: Inno Setup nebo jen zip s exe. Bez podpisu SmartScreen hlásí „Neznámý vydavatel“ →
  v instalačních pokynech vysvětlit „Další informace → Přesto spustit“ (obdoba Gatekeeperu na Macu).

## Mapování systémových věcí
| macOS | Windows |
|---|---|
| `CGWindowListCopyWindowInfo` (okna, pořadí, obdélníky) | `EnumWindows` (pořadí = z-order), `IsWindowVisible`, `DwmGetWindowAttribute(DWMWA_EXTENDED_FRAME_BOUNDS)` (bez neviditelných okrajů), vynechat `DWMWA_CLOAKED`, tool windows, minimalizovaná, vlastní okna |
| Dock (`CoreDockGetRect`) | Hlavní panel: `SHAppBarMessage(ABM_GETTASKBARPOS)`; automatické skrývání `ABM_GETSTATE & ABS_AUTOHIDE` → ignorovat, chodit po spodku obrazovky. Na Win11 jsou ikony uprostřed, ale lézt se dá po celém panelu (je přes celou šířku) |
| menu bar (zakázaná zóna nahoře) | na Windows není → strop = horní hrana pracovní plochy (`Screen.WorkingArea`) |
| NSScreen, visibleFrame | `Screen.AllScreens`, `WorkingArea`; pozor na DPI (Per-Monitor V2 v manifestu) a na Y osu (Windows má Y dolů – Mac nahoru!) |
| fullscreen app → schovat | okno popředí pokrývá celý monitor → schovat (jako `autoHidden`) |
| frontmost app | `GetForegroundWindow` |
| UserDefaults | `%APPDATA%\Badgertop\settings.json` |
| CryptoKit SHA256 | `System.Security.Cryptography.SHA256` |

## Co musí zůstat (zpětná vazba autora – důležité!)
- Mluví **jen medojedi**, žádný komentátor/vypravěč.
- Lezou hodně, skáčou málo a nízko (malé hopy, přeskok na blízké okno do ~190 px), nespí moc.
- Nikdy po horní liště ani pod ní (na Windows: nad pracovní plochou).
- Na hlavním panelu **po něm**, nikdy za ním/pod ním; na konci plošiny radši spadnout dřív než šlapat vzduch.
- **Žádné přešlapování tam a zpátky** – v kódu je víc pojistek: `blockMarks/markBlock`, `noTransferUntil`,
  `giveUp/badWin`, look-ahead u rohů a hlavně `stuckCheck()` (7 s na místě < 70 px → pustit se / otočit,
  okno 25 s ignorovat). Tohle přenést 1:1, autora to strašně štvalo.
- Rohy: přelézt animací (`cornerAnim` – vyhoupnutí přes vypouklý roh / šplhání do vnitřního), ne otočit o 90°.
- Stavění (větev, žebřík, kláda, lávka mezi okny), naštvání když rekvizita spadne po posunu okna, tunely.
- Nora: přetahovatelná, jde vypnout (`homeOn`), když by byla pod panelem → stojí na něm.
- Velikost „Automaticky“: jen vestavěný displej notebooku → 0,75×.
- **Úvodní show při prvním spuštění** (`Engine.showcase()`): hned vylézt, stavět, tunel, med, rvačka.
- Lístečky v tlamě (připomínky), med (zkratka), jídlo z přírody, kakání/zvracení – vše mizí časem.

## Free vs. podporovatel (stejně jako Mac)
- Free: 2 medojedi, lezení, stavění, tunely, nora, med, lístečky „Občas“, angličtina, 2 barvy.
- Podporovatel / 3denní trial: 14 barev, mládě, jídlo z přírody + hovínka, otravnost „Hodně“,
  lístečky Často/Pořád, jazyky (CS, DE, ES, FR), posuvníky chování, vlastní jména.
- Odemčení licenčním klíčem (Lemon Squeezy `/v1/licenses/activate` nebo Gumroad), stejný klíč
  by měl fungovat na obou platformách. Testovací promo kód je v `Store.swift` (hash) – před vydáním smazat.
- Jednou týdně růžový lísteček s prosbou o podporu (jen nepodporovatelé, až po 3 dnech).

## Soubory
- `main.swift` – svět (okna, Dock, obrazovky), Pet (pohyb, navigace, cíle, stavění, tunely), Engine, menu.
- `Pixel.swift` – procedurální pixel art (pózy medojeda, skiny, předměty, nora, emoce) – dá se přenést skoro mechanicky.
- `Lines*.swift`, `Lang.swift`, `UIText.swift` – hlášky a překlady (mechanicky převést na C#).
- `Store.swift`, `Settings.swift` – podpora/licence a okno Nastavení.
- Ladění: env `ZV_DEBUG`, `ZV_NOIDLE`, `ZV_FAST`, `ZV_SUPPORTER`, `ZV_SHOWCASE`.
