// Život medojedů: věk, stáří, zdraví, smrt, hrobeček, narození nástupce,
// návrat po nepřítomnosti, série dní a nora, která roste s jejich prací.

import Cocoa

@MainActor enum Life {
    static let ud = UserDefaults.standard
    /// délka jednoho „dne“ v sekundách (ZV_DAY=10 pro rychlé testování)
    static let dayLen: Double = Double(ProcessInfo.processInfo.environment["ZV_DAY"] ?? "") ?? 86400
    static var now: Double { Date().timeIntervalSince1970 }
    static let cubDays = 2.0          // dorůstání
    static let graveDays = 1.0        // jak dlouho stojí hrobeček
    static let rebirthDays = 0.05     // za jak dlouho se narodí nový (~1 h)

    // MARK: jeden medojed (slot 0/1)
    static func born(_ i: Int) -> Double {
        if let b = ud.object(forKey: "born\(i)") as? Double { return b }
        // stávající i nová instalace: začínají jako mladí dospělí
        let first = ud.object(forKey: "firstRun") as? Double ?? now
        let b = min(first, now) - (3 + Double(i) * 0.7) * dayLen
        ud.set(b, forKey: "born\(i)")
        return b
    }
    static func gen(_ i: Int) -> Int { max(1, ud.integer(forKey: "gen\(i)")) }
    static func span(_ i: Int) -> Double {
        if let s = ud.object(forKey: "span\(i)") as? Double { return s }
        let s = rnd(30, 42); ud.set(s, forKey: "span\(i)"); return s
    }
    static func mod(_ i: Int) -> Double { ud.double(forKey: "lifeMod\(i)") }
    static func addMod(_ i: Int, _ v: Double) { ud.set(max(-12, min(8, mod(i) + v)), forKey: "lifeMod\(i)") }
    /// délka života včetně péče a série dní
    static func effSpan(_ i: Int) -> Double { span(i) + mod(i) + min(6, Double(streak) * 0.2) }
    static func age(_ i: Int) -> Double { max(0, (now - born(i)) / dayLen) }
    static func rebirthAt(_ i: Int) -> Double? { ud.object(forKey: "rebirthAt\(i)") as? Double }
    static func alive(_ i: Int) -> Bool { rebirthAt(i) == nil }

    enum Stage { case cub, adult, senior }
    static func stage(_ i: Int) -> Stage {
        let a = age(i)
        if a < cubDays { return .cub }
        return a > effSpan(i) * 0.75 ? .senior : .adult
    }
    /// 0.6 → 1 během dorůstání
    static func growth(_ i: Int) -> CGFloat { CGFloat(0.6 + 0.4 * min(1, age(i) / cubDays)) }
    /// 0 → 1 během stáří (šediví)
    static func oldness(_ i: Int) -> CGFloat {
        let s = effSpan(i)
        return CGFloat(max(0, min(1, (age(i) - s * 0.75) / (s * 0.25))))
    }
    static func stageName(_ i: Int) -> String {
        switch stage(i) { case .cub: return tx("mládě"); case .adult: return tx("dospělý"); case .senior: return tx("senior") }
    }
    static func ageText(_ i: Int) -> String {
        let a = age(i)
        if a < 1 { return String(format: tx("%d h"), Int(a * 24)) }
        return String(format: tx("%d dní"), Int(a))
    }

    // MARK: statistiky
    static let statKeys = ["honey", "built", "tunnels", "notes", "petted"]
    static let statIcons = ["honey": "🍯", "built": "🪜", "tunnels": "🕳", "notes": "✉️", "petted": "❤️"]
    static func stats(_ i: Int) -> [String: Double] { ud.dictionary(forKey: "stats\(i)") as? [String: Double] ?? [:] }
    static func add(_ i: Int, _ k: String, _ v: Double = 1) {
        var s = stats(i); s[k, default: 0] += v; ud.set(s, forKey: "stats\(i)")
    }
    static func statsText(_ s: [String: Double]) -> String {
        statKeys.compactMap { k in s[k].map { "\(statIcons[k]!) \(Int($0))" } }.joined(separator: "  ")
    }

    // MARK: vzpomínky (zemřelí)
    static var memorials: [[String: Any]] { ud.array(forKey: "memorials") as? [[String: Any]] ?? [] }
    static func addMemorial(_ m: [String: Any]) {
        var a = memorials; a.append(m); if a.count > 30 { a.removeFirst(a.count - 30) }
        ud.set(a, forKey: "memorials")
    }

    // MARK: série dní (aplikace běží a ty jsi u počítače aspoň 10 minut denně)
    static var streak: Int { ud.integer(forKey: "streak") }
    static func dayKey(_ t: Double) -> String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f.string(from: Date(timeIntervalSince1970: t))
    }
    static func activeMinute() {
        let today = dayKey(now)
        if ud.string(forKey: "activeDay") != today { ud.set(today, forKey: "activeDay"); ud.set(0, forKey: "activeToday") }
        let m = ud.integer(forKey: "activeToday") + 1
        ud.set(m, forKey: "activeToday")
        guard m >= 10, ud.string(forKey: "streakDay") != today else { return }
        let yesterday = dayKey(now - 86400)
        ud.set(ud.string(forKey: "streakDay") == yesterday ? streak + 1 : 1, forKey: "streak")
        ud.set(today, forKey: "streakDay")
    }
    static var streakAlive: Bool {
        let d = ud.string(forKey: "streakDay")
        return d == dayKey(now) || d == dayKey(now - 86400)
    }

    // MARK: nora roste s prací
    static let levels: [Double] = [0, 30, 90, 180, 320, 500, 750, 1100]
    static var xp: Double { ud.double(forKey: "burrowXP") }
    static var level: Int { (levels.lastIndex { xp >= $0 } ?? 0) + 1 }
    static func addXP(_ v: Double) {
        let before = level
        ud.set(xp + v, forKey: "burrowXP")
        if level > before { E.burrowLevelUp() }
    }
    static var levelText: String {
        let l = level
        if l >= levels.count { return String(format: tx("úroveň %d (max)"), l) }
        return String(format: tx("úroveň %d · %d/%d"), l, Int(xp), Int(levels[l]))
    }

    // MARK: hrobečky (přetrvají restart)
    static var graves: [[String: Any]] {
        get { ud.array(forKey: "graves") as? [[String: Any]] ?? [] }
        set { ud.set(newValue, forKey: "graves") }
    }

    static func roman(_ n: Int) -> String {
        let r = ["", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]
        return n < r.count ? r[n] : "\(n)"
    }
}

// MARK: - Hrobeček

enum Tomb {
    static var cache: CGImage?
    static func image() -> CGImage {
        if let c = cache { return c }
        var cv = Canvas(18, 22)
        // kámen
        func stone(_ x: CGFloat, _ y: CGFloat, _ m: CGFloat) -> Bool {
            let dx: CGFloat = x - 9, dy: CGFloat = y - 15
            let r: CGFloat = 6.5 - m
            if y < 15 { return x > 2 + m && x < 15 - m && y > 1.5 + m }
            return dx * dx + dy * dy < r * r
        }
        cv.fill(.K) { x, y in stone(x, y, 0) }
        cv.fill(.s) { x, y in stone(x, y, 1) }
        cv.fill(.S) { x, y in stone(x, y, 1) && x > 4 && x < 7 && y > 3 }
        // křížek
        cv.line([P(9, 8), P(9, 17)], 0.6, .d); cv.line([P(6.5, 14.5), P(11.5, 14.5)], 0.6, .d)
        // tráva a kytičky
        cv.fill(.v) { x, y in y < 2.5 }
        cv.fill(.V) { x, y in y < 1.6 }
        for (x, c) in [(1, Pal.R), (16, Pal.A), (3, Pal.P), (14, Pal.W)] {
            cv.put(x, 2, .v); cv.put(x, 3, c)
        }
        let img = cv.image()
        cache = img
        return img
    }
}

final class GraveView: NSView {
    weak var grave: Grave?
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
    override func mouseUp(with e: NSEvent) { grave?.clicked() }
    override func draw(_ r: NSRect) { grave?.draw() }
}

@MainActor final class Grave {
    let id: String
    let name: String
    let days: Int
    let stats: [String: Double]
    let until: Double
    var si: Int
    var x: CGFloat
    var ghostT: Double
    let panel: OverlayPanel
    let view: GraveView
    var lastSig = -1
    static let w: CGFloat = 110, h: CGFloat = 120

    init(_ m: [String: Any], ghost: Bool) {
        id = m["id"] as? String ?? UUID().uuidString
        name = m["name"] as? String ?? "?"
        days = m["days"] as? Int ?? 0
        stats = m["stats"] as? [String: Double] ?? [:]
        until = m["until"] as? Double ?? 0
        si = min(m["si"] as? Int ?? 0, W.scrs.count - 1)
        x = CGFloat(m["x"] as? Double ?? Double(W.scrs[0].frame.midX))
        ghostT = ghost ? 4.5 : 0
        panel = makePanel(NSSize(width: Grave.w, height: Grave.h), level: 0)
        view = GraveView(frame: NSRect(x: 0, y: 0, width: Grave.w, height: Grave.h))
        panel.contentView = view
        view.grave = self
        panel.ignoresMouseEvents = false
    }

    var groundY: CGFloat {
        if let dk = W.dock, dk.width > dk.height, x > dk.minX, x < dk.maxX, dk.minY < W.scrs[si].frame.minY + 60 { return dk.maxY }
        return W.floorY(si)
    }
    var dead: Bool { Life.now > until }

    func update(_ dt: Double) { ghostT = max(0, ghostT - dt) }

    func render() {
        si = min(si, W.scrs.count - 1)
        let f = W.scrs[si].frame
        x = clamp(x, f.minX + Grave.w / 2, f.maxX - Grave.w / 2)
        let fr = NSRect(x: (x - Grave.w / 2).rounded(), y: groundY.rounded(), width: Grave.w, height: Grave.h)
        if panel.frame != fr { panel.setFrame(fr, display: false) }
        let sig = Int(ghostT * 20)
        if sig != lastSig { lastSig = sig; view.needsDisplay = true }
        if !E.hidden && !panel.isVisible { panel.orderFrontRegardless() }
    }

    func draw() {
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }
        ctx.interpolationQuality = .none
        let sw: CGFloat = 36, sh: CGFloat = 44
        ctx.draw(Tomb.image(), in: CGRect(x: (Grave.w - sw) / 2, y: 0, width: sw, height: sh))
        // jméno a věk
        let ps = NSMutableParagraphStyle(); ps.alignment = .center
        let sh2 = NSShadow(); sh2.shadowColor = NSColor(white: 0, alpha: 0.85); sh2.shadowBlurRadius = 2; sh2.shadowOffset = .zero
        let at: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: 10, weight: .bold), .foregroundColor: NSColor.white, .paragraphStyle: ps, .shadow: sh2]
        (name as NSString).draw(in: NSRect(x: 0, y: sh + 12, width: Grave.w, height: 14), withAttributes: at)
        let at2: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: 9, weight: .semibold), .foregroundColor: NSColor(white: 0.92, alpha: 1), .paragraphStyle: ps, .shadow: sh2]
        (String(format: tx("%d dní"), days) as NSString).draw(in: NSRect(x: 0, y: sh + 1, width: Grave.w, height: 12), withAttributes: at2)
        // duch stoupá k nebi
        if ghostT > 0 {
            let k = CGFloat(1 - ghostT / 4.5)
            ctx.saveGState()
            ctx.setAlpha(0.55 * (1 - k))
            let img = Badger.image(.idle, 0, blink: true, skin: 0)
            let gs: CGFloat = 44
            let gx = (Grave.w - gs) / 2 + CGFloat(sin(Double(k) * 9)) * 6
            ctx.draw(img, in: CGRect(x: gx, y: 20 + k * 55, width: gs, height: gs * 0.75))
            NSColor(white: 1, alpha: 0.6 * (1 - k)).setFill()
            NSRect(x: gx + gs / 2 - 8, y: 20 + k * 55 + gs * 0.75 + 4, width: 16, height: 2).fill()
            ctx.restoreGState()
        }
    }

    func clicked() {
        NSApp.activate(ignoringOtherApps: true)
        let a = NSAlert()
        a.messageText = "🪦 " + name
        a.informativeText = String(format: tx("Dožil se %d dní."), days) + "\n\n" + Life.statsText(stats)
        a.runModal()
        E.pets.filter { $0.phys == .surface }.randomElement()?.say(L.r(L.mourn), dur: 2.6)
    }

    func destroy() { panel.orderOut(nil); view.grave = nil }
}

// MARK: - Engine: péče, smrt, narození

extension Engine {
    func lifeStart() {
        // hrobečky z minula
        for m in Life.graves where (m["until"] as? Double ?? 0) > Life.now { graves.append(Grave(m, ghost: false)) }
        Life.graves = Life.graves.filter { ($0["until"] as? Double ?? 0) > Life.now }
        // jak dlouho jsme byli pryč
        let ud = UserDefaults.standard
        if let last = ud.object(forKey: "lastSeen") as? Double {
            let hours = (Life.now - last) / 3600
            if hours > 2 {
                for p in adults {
                    p.hunger = min(0.95, p.hunger + min(0.6, hours * 0.05))
                    p.fun = max(0.1, p.fun - min(0.4, hours * 0.03))
                }
                later(5) {
                    guard let p = self.adults.first(where: { $0.phys == .surface }) ?? self.adults.first else { return }
                    p.say(L.r(hours > 20 ? L.welcomeLong : L.welcomeShort), dur: 3.5)
                    p.showEmote(hours > 20 ? .anger : .bang, 2)
                }
            }
        }
        ud.set(Life.now, forKey: "lastSeen")
    }

    /// jednou za sekundu
    func lifeTick() {
        let ud = UserDefaults.standard
        lifeSec += 1
        if lifeSec % 30 == 0 { ud.set(Life.now, forKey: "lastSeen") }
        if lifeSec % 60 == 0 {
            if !userIdle { Life.activeMinute() }
            if !userIdle && lifeSec % 1800 == 0 { Life.addXP(1) }
            pets.forEach { $0.saveNeeds() }
        }
        for g in graves where g.dead { g.destroy() }
        graves.removeAll { $0.dead }
        // narození
        for i in 0..<count where !pets.contains(where: { $0.idx == i && !$0.isBaby }) {
            guard let at = Life.rebirthAt(i), Life.now >= at else { continue }
            ud.removeObject(forKey: "rebirthAt\(i)")
            let p = spawnPet(i, initial: false)
            p.exitT = 2.5
            later(4) {
                p.say(L.r(L.newborn), dur: 2.4)
                if let o = self.adults.first(where: { $0 !== p && $0.phys == .surface }) {
                    o.showEmote(.heart, 3); o.say(L.r(L.birth), dur: 3)
                }
            }
        }
        // stáří a smrt
        for p in adults where p.dyingT < 0 && Life.alive(p.idx) && Life.age(p.idx) >= Life.effSpan(p.idx) {
            if p.phys == .home || (p.phys == .surface && p.onFloor && p.tunnelStage == 0 && p.carrying == nil) { p.startDying() }
        }
        // smutek u hrobečku
        if !graves.isEmpty, lifeSec % 40 == 0, chance(0.35),
           let p = adults.filter({ $0.free && Life.stage($0.idx) != .cub }).randomElement() {
            p.say(L.r(L.mourn), dur: 2.6); p.showEmote(.dots, 2.5)
        }
    }

    @discardableResult func spawnPet(_ i: Int, initial: Bool) -> Pet {
        let p = Pet(i)
        p.phys = .home
        p.homeT = 0
        p.energy = max(p.energy, 0.65)
        let pos = min(i, adults.count)
        pets.insert(p, at: pos)
        p.exitT = initial ? 0.8 + Double(i) * 2.4 : 0.4
        home?.peek(p, p.exitT)
        if let b = pets.first(where: { $0.isBaby }), b.parent == nil || b.parent?.dead == true { b.parent = adults.first }
        return p
    }

    func petDied(_ p: Pet) {
        let i = p.idx
        let si = W.screenIndex(p.pos)
        var x = Double(p.pos.x)
        if p.phys == .home || p.phys == .hidden, let h = home { x = Double(h.x + (chance(0.5) ? -95 : 95)) }
        let m: [String: Any] = ["id": UUID().uuidString, "name": p.name, "days": Int(Life.age(i)), "stats": Life.stats(i),
                                "until": Life.now + Life.graveDays * Life.dayLen, "si": si, "x": x, "died": Life.now, "gen": Life.gen(i)]
        Life.addMemorial(m)
        var gs = Life.graves; gs.append(m); Life.graves = gs
        graves.append(Grave(m, ghost: true))
        // nový slot: další generace
        let ud = UserDefaults.standard
        ud.set(Life.gen(i) + 1, forKey: "gen\(i)")
        let birth = Life.now + Life.rebirthDays * Life.dayLen
        ud.set(birth, forKey: "rebirthAt\(i)")
        ud.set(birth, forKey: "born\(i)")
        ud.set(rnd(30, 42), forKey: "span\(i)")
        ud.removeObject(forKey: "lifeMod\(i)")
        ud.removeObject(forKey: "stats\(i)")
        ud.removeObject(forKey: "needs\(i)")
        if let idx = pets.firstIndex(where: { $0 === p }) { pets.remove(at: idx) }
        p.destroy()
        // pozůstalý
        for o in adults where o.phys == .surface {
            o.goal = nil; o.oneShot = nil
            o.fun = max(0, o.fun - 0.35)
            later(2.5) { o.say(L.r(L.mourn), dur: 3); o.showEmote(.sweat, 3) }
        }
    }

    func burrowLevelUp() {
        home?.puff()
        for p in adults where p.phys == .surface { p.showEmote(.star, 2.5) }
        adults.first { $0.phys == .surface }?.say(L.r(L.burrowUp), dur: 2.6)
    }
}

// MARK: - Pet: zdraví a umírání

extension Pet {
    var lifeSpeed: CGFloat {
        if isBaby { return 1 }
        var k: CGFloat = 1
        switch Life.stage(idx) { case .cub: k = 1.1; case .senior: k = 0.8; case .adult: break }
        if health < 0.3 { k *= 0.8 }
        return k
    }
    var sleepFactor: Double {
        if isBaby { return 1 }
        return (Life.stage(idx) == .senior ? 2 : 1) * (health < 0.3 ? 1.6 : 1)
    }

    /// péče: hlad a nuda bez povšimnutí ubírají zdraví, dobrá péče přidává dny života
    func lifeUpdate(_ dt: Double) {
        guard !isBaby, !E.userIdle, dyingT < 0 else { return }
        if hunger > 0.85 || fun < 0.1 { health = max(0, health - dt / 5400) }
        else if hunger < 0.5 && fun > 0.4 { health = min(1, health + dt / 7200) }
        if health < 0.25 { modAcc -= dt / 3600 * 0.4 }
        else if health > 0.85 { modAcc += dt / 86400 * 0.5 }
        if abs(modAcc) > 0.001 && E.lifeSec % 30 == 0 { Life.addMod(idx, modAcc); modAcc = 0 }
        sickNag -= dt
        if health < 0.3, sickNag <= 0, phys == .surface {
            sickNag = rnd(90, 180)
            showEmote(.sweat, 2.5); say(L.r(L.sick), dur: 2.6)
            if onFloor && oneShot == nil { play(.sneeze, 1.2) }
        }
        oldNag -= dt
        if Life.stage(idx) == .senior, oldNag <= 0, free, chance(0.5) {
            oldNag = rnd(240, 480)
            say(L.r(L.oldAge), dur: 2.6)
        } else if oldNag <= 0 { oldNag = rnd(120, 240) }
    }

    func startDying() {
        guard dyingT < 0 else { return }
        dyingT = 6
        goal = nil
        if phys == .home { dyingT = 0.1; return }
        say(L.r(L.farewell), dur: 4)
        showEmote(.heart, 3)
        E.later(2.2) { [weak self] in self?.play(.passout, 4) }
    }
    func dyingStep(_ dt: Double) {
        guard dyingT >= 0 else { return }
        dyingT -= dt
        goal = nil; navCD = 5
        if dyingT <= 0 { dyingT = -1; E.petDied(self) }
    }
}
