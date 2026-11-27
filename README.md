<p align="center"><img src="docs/icon.png" width="160" alt="Badgertop"></p>

# Badgertop 🦡
### Two honey badgers. Zero cares.

Two pixel-art honey badgers move onto your Mac. They climb your windows and the Dock, build ladders out of sticks,
dig tunnels, wrestle, chase your cursor, bring you reminder notes, eat whatever grows on your desktop –
and they really, truly do not care.

<p align="center"><img src="docs/animace-1.png" width="420"> <img src="docs/animace-2.png" width="420"></p>

## Free
- **Two badgers** that climb window edges, sides and undersides, swing over corners and leap between windows
- They **play together**: tag, dust-cloud fights, head bonks, hide and seek, little conversations
- A **burrow** in the corner of your screen (drag it anywhere) – they sleep there when tired or when you're away
- **Honey** (⌘B), petting, picking them up and throwing them, chasing a fast-moving cursor
- **Reminder notes** delivered in their mouths (drink water, stretch…)
- They **build** ladders, branches and bridges between windows (move the window and the badger *loses it*)
- **Tunnels** – they dig into one window and pop out of another
- Hundreds of lines – they comment on the app you're using, the time of day, your typing marathons
- 30+ pixel animations, English UI

## Supporter bonuses ❤️ – any amount, starting at one espresso
- **14 fur colors** per badger (golden, albino, panda, zombie, night with glowing eyes…)
- **The cub** – follows its parents and copies everything they do
- **Food from nature** – apple trees that grow, worms, moles that sometimes escape (plus the gross stuff)
- **“A lot” annoyance** and more frequent notes
- **More languages**: Czech, German, Spanish, French
- **Settings for almost everything**: speed, climbing, jumping, tunnels, talking, sleeping, playing, custom names

A pink note once a week politely asks for support (only if you haven't).

## Install
1. Download `Badgertop-x.y.z.dmg` from **Releases**, open it and drag Badgertop into **Applications**.
2. Launch it once – macOS will block it. Then go to *System Settings → Privacy & Security*, scroll down and click **Open Anyway**.
   Badgertop isn't notarized (Apple charges $99/year for that), so this is the only way to start it the first time. The install window in the DMG shows this too.
3. Look for 🦡 in the menu bar. Settings: **⌘,**

Requires macOS 13 Ventura or newer, Apple Silicon or Intel.

### Privacy
- Reads only window **positions** and the name of the active app – never window contents or what you type.
- Sends **nothing** to the internet, except a one-time license key check when you enter a key.
- No special permissions needed. Optional **Accessibility** is only a fallback source for the Dock's shape.

## Build from source
Only Xcode Command Line Tools are needed (`xcode-select --install`):

```bash
./build.sh        # build into ~/Applications and launch
./release.sh      # dist/Badgertop-<version>.zip + .dmg
```

| File | What's inside |
|---|---|
| `main.swift` | behaviour, physics, windows, burrow, items, menu |
| `Pixel.swift` | procedural pixel-art sprites, fur colors, critters |
| `Lang.swift`, `Lines*.swift`, `UIText.swift` | lines and UI in 5 languages |
| `Settings.swift` | settings window (SwiftUI) |
| `Store.swift` | supporter unlock – **set `storeURL` and `productId` before release** |

Debug output: `ZV_DEBUG=1 ZV_NOIDLE=1 ~/Applications/Badgertop.app/Contents/MacOS/Badgertop`

## Česky
Dva pixeloví medojedi na tvém Macu – lezou po oknech a Docku, staví si žebříky, prohrabávají se tunely a je jim všechno u prdele.
Zdarma v angličtině; čeština a další bonusy pro podporovatele (od ceny jednoho espressa).

## License
MIT – see [LICENSE](LICENSE). Inspired by a certain viral honey badger video; all texts and graphics are original.
