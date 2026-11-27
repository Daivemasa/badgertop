// Okno Nastavení: vzhled (barvy, jména), jazyk a bonusové posuvníky chování.

import SwiftUI

@MainActor enum Knobs {
    static let keys = ["speedMul", "climbMul", "jumpMul", "tunnelMul", "talkMul", "sleepMul", "playMul"]
    /// násobitel z nastavení (bez podpory vždy 1)
    static func v(_ key: String) -> Double {
        guard Supporter.unlocked else { return 1 }
        return UserDefaults.standard.object(forKey: key) as? Double ?? 1
    }
}

@MainActor enum SettingsWindow {
    static var win: NSWindow?
    static func show() {
        NSApp.activate(ignoringOtherApps: true)
        if win == nil {
            let w = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 560, height: 640), styleMask: [.titled, .closable, .resizable], backing: .buffered, defer: false)
            w.isReleasedWhenClosed = false
            w.center()
            win = w
        }
        win?.contentViewController = NSHostingController(rootView: SettingsView())
        win?.title = tx("Nastavení…").replacingOccurrences(of: "…", with: "")
        win?.makeKeyAndOrderFront(nil)
    }
}

struct SkinSwatch: View {
    let skin: Int
    let selected: Bool
    let locked: Bool
    var body: some View {
        let img = NSImage(cgImage: Badger.image(.idle, 0, blink: false, skin: skin), size: NSSize(width: 32, height: 24))
        ZStack(alignment: .topTrailing) {
            Image(nsImage: img).interpolation(.none).resizable().frame(width: 48, height: 36)
                .padding(4)
                .background(RoundedRectangle(cornerRadius: 6).fill(Color.gray.opacity(0.15)))
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(selected ? Color.accentColor : Color.clear, lineWidth: 2))
                .opacity(locked ? 0.45 : 1)
            if locked { Text("🔒").font(.system(size: 10)) }
        }
    }
}

struct SettingsView: View {
    @State private var tick = 0
    @AppStorage("lang") private var lang = "en"
    @AppStorage("speedMul") private var speedMul = 1.0
    @AppStorage("climbMul") private var climbMul = 1.0
    @AppStorage("jumpMul") private var jumpMul = 1.0
    @AppStorage("tunnelMul") private var tunnelMul = 1.0
    @AppStorage("talkMul") private var talkMul = 1.0
    @AppStorage("sleepMul") private var sleepMul = 1.0
    @AppStorage("playMul") private var playMul = 1.0

    var body: some View {
        let unlocked = Supporter.unlocked
        let _ = tick
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // podpora: co lidi dostanou
                if !Supporter.paid {
                    GroupBox(label: Text(tx("Podpora") + " ❤️").bold()) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(Supporter.perks()).font(.system(size: 12)).fixedSize(horizontal: false, vertical: true)
                            HStack {
                                Button(tx("Upgradovat nebo podpořit jakoukoli částkou ☕")) { Supporter.openStore() }.keyboardShortcut(.defaultAction)
                                Button(tx("Mám klíč")) { Supporter.askKey(); tick += 1 }
                            }
                        }.padding(6)
                    }
                }
                // rodina: věk, zdraví, statistiky, nora, série, vzpomínky
                GroupBox(label: Text(tx("Rodina") + " 🦡").bold()) {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(E.adults.indices, id: \.self) { k in
                            let p = E.adults[k]
                            VStack(alignment: .leading, spacing: 3) {
                                HStack {
                                    Text(p.name).font(.headline)
                                    Text(Life.ageText(p.idx) + " · " + Life.stageName(p.idx)).foregroundColor(.secondary)
                                    Spacer()
                                    Text(tx("Zdraví")).font(.caption).foregroundColor(.secondary)
                                    ProgressView(value: max(0, min(1, p.health))).frame(width: 90)
                                }
                                Text(p.needsText()).font(.system(size: 11)).foregroundColor(.secondary)
                                let st = Life.statsText(Life.stats(p.idx))
                                if !st.isEmpty { Text(st).font(.system(size: 11)) }
                            }
                        }
                        ForEach(0..<E.count, id: \.self) { i in
                            if !Life.alive(i) { Text("🍼 " + tx("Brzy se narodí nový medojed…")).font(.system(size: 12)) }
                        }
                        Divider()
                        HStack {
                            Text("🏠 " + tx("Nora") + ": " + Life.levelText)
                            Spacer()
                            if Life.streakAlive && Life.streak > 0 { Text("🔥 " + String(format: tx("%d dní v kuse"), Life.streak)) }
                        }.font(.system(size: 12, weight: .semibold))
                        Text(tx("Nora roste s tím, co medojedi postaví, prokopou, snědí a donesou.")).font(.system(size: 11)).foregroundColor(.secondary)
                        Text(tx("Péče: med (⌘B), hlazení a hraní je drží zdravé a přidávají jim dny života. Hladoví a znudění stůňou a stárnou rychleji. Když necháš Badgertop běžet každý den, série dní jim taky prodlužuje život."))
                            .font(.system(size: 11)).foregroundColor(.secondary).fixedSize(horizontal: false, vertical: true)
                        Divider()
                        Text(tx("Vzpomínky")).font(.system(size: 12, weight: .semibold))
                        let mem = Array(Life.memorials.suffix(6).reversed())
                        if mem.isEmpty { Text(tx("Zatím nikdo neumřel.")).font(.system(size: 11)).foregroundColor(.secondary) }
                        ForEach(mem.indices, id: \.self) { j in
                            let m = mem[j]
                            Text("🪦 " + (m["name"] as? String ?? "?") + " · " + String(format: tx("%d dní"), m["days"] as? Int ?? 0) + "   " + Life.statsText(m["stats"] as? [String: Double] ?? [:]))
                                .font(.system(size: 11))
                        }
                    }.padding(6)
                }
                // jazyk
                GroupBox(label: Text(tx("Jazyk")).bold()) {
                    Picker("", selection: Binding(get: { L.lang.rawValue }, set: { new in
                        if let l = Lang(rawValue: new), l.premium && !unlocked { Supporter.offer(l.title); tick += 1 } else { lang = new; tick += 1 }
                    })) {
                        ForEach(Lang.allCases, id: \.rawValue) { l in
                            Text(l.title + (l.premium && !unlocked ? "  🔒" : "")).tag(l.rawValue)
                        }
                    }.pickerStyle(.segmented).labelsHidden().padding(6)
                }
                // vzhled každého medojeda
                GroupBox(label: Text(tx("Vzhled")).bold()) {
                    VStack(alignment: .leading, spacing: 14) {
                        Toggle(tx("Zobrazit noru"), isOn: Binding(get: { E.homeOn }, set: { E.setHomeOn($0); tick += 1 }))
                        ForEach(E.pets.indices, id: \.self) { i in
                            let p = E.pets[i]
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(p.name).font(.headline)
                                    Spacer()
                                    TextField(tx("Jméno"), text: Binding(
                                        get: { UserDefaults.standard.string(forKey: "name\(p.idx)") ?? "" },
                                        set: { UserDefaults.standard.set($0, forKey: "name\(p.idx)"); tick += 1 }))
                                    .frame(width: 160).disabled(!unlocked)
                                }
                                LazyVGrid(columns: Array(repeating: GridItem(.fixed(60), spacing: 6), count: 7), alignment: .leading, spacing: 6) {
                                    ForEach(Skins.all.indices, id: \.self) { k in
                                        let sk = Skins.all[k]
                                        let locked = sk.premium && !unlocked
                                        SkinSwatch(skin: k, selected: p.skin == k, locked: locked)
                                            .help(tx(sk.name))
                                            .onTapGesture {
                                                if locked { Supporter.offer(tx("Barva") + " „" + tx(sk.name) + "“"); tick += 1 }
                                                else { p.skin = k; p.showEmote(.heart, 1.5); tick += 1 }
                                            }
                                    }
                                }
                            }
                        }
                    }.padding(6)
                }
                // bonusové chování
                GroupBox(label: HStack { Text(tx("Bonusy pro podporovatele")).bold(); if !unlocked { Text("🔒") } }) {
                    VStack(alignment: .leading, spacing: 8) {
                        knob(tx("Rychlost"), $speedMul, 0.4, 2.5)
                        knob(tx("Lezení na okna"), $climbMul, 0, 3)
                        knob(tx("Skákání"), $jumpMul, 0, 3)
                        knob(tx("Tunely"), $tunnelMul, 0, 4)
                        knob(tx("Povídání"), $talkMul, 0, 4)
                        knob(tx("Spaní"), $sleepMul, 0, 3)
                        knob(tx("Hraní si spolu"), $playMul, 0, 4)
                        HStack {
                            Button(tx("Výchozí hodnoty")) { for k in Knobs.keys { UserDefaults.standard.set(1.0, forKey: k) }; tick += 1 }
                                .disabled(!unlocked)
                            Spacer()
                            if !unlocked { Button(tx("Odemknout bonusy…")) { Supporter.buy(); tick += 1 } }
                        }
                    }.padding(6).disabled(!unlocked && false)
                }
            }.padding(18)
        }.frame(minWidth: 540, minHeight: 560)
        .onReceive(NotificationCenter.default.publisher(for: .supporterChanged)) { _ in tick += 1 }
        .onReceive(Timer.publish(every: 5, on: .main, in: .common).autoconnect()) { _ in tick += 1 }
    }

    func knob(_ title: String, _ v: Binding<Double>, _ lo: Double, _ hi: Double) -> some View {
        HStack {
            Text(title).frame(width: 150, alignment: .leading)
            Slider(value: v, in: lo...hi).disabled(!Supporter.unlocked)
            Text(String(format: "%.1f×", v.wrappedValue)).monospacedDigit().frame(width: 44)
        }
    }
}
