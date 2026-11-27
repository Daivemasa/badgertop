// Výběr jazyka: angličtina zdarma, ostatní pro podporovatele.

import Foundation

enum Lang: String, CaseIterable {
    case en, cs, de, es, fr
    var title: String {
        switch self { case .en: return "English"; case .cs: return "Čeština"; case .de: return "Deutsch"; case .es: return "Español"; case .fr: return "Français" }
    }
    var premium: Bool { self != .en }
    var idx: Int { switch self { case .en: return 0; case .de: return 1; case .es: return 2; case .fr: return 3; case .cs: return -1 } }
}

@MainActor enum L {
    static var recent: [String: [String]] = [:]

    static var lang: Lang {
        let l = Lang(rawValue: UserDefaults.standard.string(forKey: "lang") ?? "en") ?? .en
        return l.premium && !Supporter.unlocked ? .en : l
    }

    /// náhodná hláška, která nezazněla mezi posledními
    static func r(_ arr: [String]) -> String {
        guard let key = arr.first else { return "…" }
        var rec = recent[key] ?? []
        let fresh = arr.filter { !rec.contains($0) }
        let s = (fresh.isEmpty ? arr : fresh).randomElement() ?? "…"
        rec.append(s)
        if rec.count > max(1, min(40, arr.count * 2 / 3)) { rec.removeFirst() }
        recent[key] = rec
        return s
    }

    static func pick<T>(_ cs: T, _ en: T, _ de: T, _ es: T, _ fr: T) -> T {
        switch lang { case .cs: return cs; case .en: return en; case .de: return de; case .es: return es; case .fr: return fr }
    }

    static var idle: [String] { pick(CS.idle, EN.idle, DE.idle, ES.idle, FR.idle) }
    static var appTemplates: [String] { pick(CS.appTemplates, EN.appTemplates, DE.appTemplates, ES.appTemplates, FR.appTemplates) }
    static var apps: [(String, [String])] { pick(CS.apps, EN.apps, DE.apps, ES.apps, FR.apps) }
    static var morning: [String] { pick(CS.morning, EN.morning, DE.morning, ES.morning, FR.morning) }
    static var lunch: [String] { pick(CS.lunch, EN.lunch, DE.lunch, ES.lunch, FR.lunch) }
    static var afternoon: [String] { pick(CS.afternoon, EN.afternoon, DE.afternoon, ES.afternoon, FR.afternoon) }
    static var evening: [String] { pick(CS.evening, EN.evening, DE.evening, ES.evening, FR.evening) }
    static var night: [String] { pick(CS.night, EN.night, DE.night, ES.night, FR.night) }
    static var monday: [String] { pick(CS.monday, EN.monday, DE.monday, ES.monday, FR.monday) }
    static var friday: [String] { pick(CS.friday, EN.friday, DE.friday, ES.friday, FR.friday) }
    static var weekend: [String] { pick(CS.weekend, EN.weekend, DE.weekend, ES.weekend, FR.weekend) }
    static var health: [String] { pick(CS.health, EN.health, DE.health, ES.health, FR.health) }
    static var notes: [String] { pick(CS.notes, EN.notes, DE.notes, ES.notes, FR.notes) }
    static var facts: [String] { pick(CS.facts, EN.facts, DE.facts, ES.facts, FR.facts) }
    static var pet: [String] { pick(CS.pet, EN.pet, DE.pet, ES.pet, FR.pet) }
    static var woken: [String] { pick(CS.woken, EN.woken, DE.woken, ES.woken, FR.woken) }
    static var dragged: [String] { pick(CS.dragged, EN.dragged, DE.dragged, ES.dragged, FR.dragged) }
    static var hurt: [String] { pick(CS.hurt, EN.hurt, DE.hurt, ES.hurt, FR.hurt) }
    static var windowGone: [String] { pick(CS.windowGone, EN.windowGone, DE.windowGone, ES.windowGone, FR.windowGone) }
    static var shakeOff: [String] { pick(CS.shakeOff, EN.shakeOff, DE.shakeOff, ES.shakeOff, FR.shakeOff) }
    static var hunger: [String] { pick(CS.hunger, EN.hunger, DE.hunger, ES.hunger, FR.hunger) }
    static var eat: [String] { pick(CS.eat, EN.eat, DE.eat, ES.eat, FR.eat) }
    static var stolen: [String] { pick(CS.stolen, EN.stolen, DE.stolen, ES.stolen, FR.stolen) }
    static var honeySpotted: [String] { pick(CS.honeySpotted, EN.honeySpotted, DE.honeySpotted, ES.honeySpotted, FR.honeySpotted) }
    static var sleepy: [String] { pick(CS.sleepy, EN.sleepy, DE.sleepy, ES.sleepy, FR.sleepy) }
    static var exitHome: [String] { pick(CS.exitHome, EN.exitHome, DE.exitHome, ES.exitHome, FR.exitHome) }
    static var homeClicked: [String] { pick(CS.homeClicked, EN.homeClicked, DE.homeClicked, ES.homeClicked, FR.homeClicked) }
    static var dig: [String] { pick(CS.dig, EN.dig, DE.dig, ES.dig, FR.dig) }
    static var arrived: [String] { pick(CS.arrived, EN.arrived, DE.arrived, ES.arrived, FR.arrived) }
    static var newWindow: [String] { pick(CS.newWindow, EN.newWindow, DE.newWindow, ES.newWindow, FR.newWindow) }
    static var carryNote: [String] { pick(CS.carryNote, EN.carryNote, DE.carryNote, ES.carryNote, FR.carryNote) }
    static var delivered: [String] { pick(CS.delivered, EN.delivered, DE.delivered, ES.delivered, FR.delivered) }
    static var noteDismissed: [String] { pick(CS.noteDismissed, EN.noteDismissed, DE.noteDismissed, ES.noteDismissed, FR.noteDismissed) }
    static var cursor: [String] { pick(CS.cursor, EN.cursor, DE.cursor, ES.cursor, FR.cursor) }
    static var laser: [String] { pick(CS.laser, EN.laser, DE.laser, ES.laser, FR.laser) }
    static var typing: [String] { pick(CS.typing, EN.typing, DE.typing, ES.typing, FR.typing) }
    static var back: [String] { pick(CS.back, EN.back, DE.back, ES.back, FR.back) }
    static var scared: [String] { pick(CS.scared, EN.scared, DE.scared, ES.scared, FR.scared) }
    static var fightStart: [String] { pick(CS.fightStart, EN.fightStart, DE.fightStart, ES.fightStart, FR.fightStart) }
    static var win: [String] { pick(CS.win, EN.win, DE.win, ES.win, FR.win) }
    static var lose: [String] { pick(CS.lose, EN.lose, DE.lose, ES.lose, FR.lose) }
    static var chase: [String] { pick(CS.chase, EN.chase, DE.chase, ES.chase, FR.chase) }
    static var follow: [String] { pick(CS.follow, EN.follow, DE.follow, ES.follow, FR.follow) }
    static var greetA: [String] { pick(CS.greetA, EN.greetA, DE.greetA, ES.greetA, FR.greetA) }
    static var greetB: [String] { pick(CS.greetB, EN.greetB, DE.greetB, ES.greetB, FR.greetB) }
    static var dialogues: [[String]] { pick(CS.dialogues, EN.dialogues, DE.dialogues, ES.dialogues, FR.dialogues) }
    static var dontCare: [String] { pick(CS.dontCare, EN.dontCare, DE.dontCare, ES.dontCare, FR.dontCare) }
    static var searchStick: [String] { pick(CS.searchStick, EN.searchStick, DE.searchStick, ES.searchStick, FR.searchStick) }
    static var foundStick: [String] { pick(CS.foundStick, EN.foundStick, DE.foundStick, ES.foundStick, FR.foundStick) }
    static var built: [String] { pick(CS.built, EN.built, DE.built, ES.built, FR.built) }
    static var propDestroyed: [String] { pick(CS.propDestroyed, EN.propDestroyed, DE.propDestroyed, ES.propDestroyed, FR.propDestroyed) }
    static var propDestroyed2: [String] { pick(CS.propDestroyed2, EN.propDestroyed2, DE.propDestroyed2, ES.propDestroyed2, FR.propDestroyed2) }
    static var rebuild: [String] { pick(CS.rebuild, EN.rebuild, DE.rebuild, ES.rebuild, FR.rebuild) }
    static var laugh: [String] { pick(CS.laugh, EN.laugh, DE.laugh, ES.laugh, FR.laugh) }
    static var bees: [String] { pick(CS.bees, EN.bees, DE.bees, ES.bees, FR.bees) }
    static var wakeUp: [String] { pick(CS.wakeUp, EN.wakeUp, DE.wakeUp, ES.wakeUp, FR.wakeUp) }
    static var baby: [String] { pick(CS.baby, EN.baby, DE.baby, ES.baby, FR.baby) }
    static var protectBaby: [String] { pick(CS.protectBaby, EN.protectBaby, DE.protectBaby, ES.protectBaby, FR.protectBaby) }
    static var tunnelIn: [String] { pick(CS.tunnelIn, EN.tunnelIn, DE.tunnelIn, ES.tunnelIn, FR.tunnelIn) }
    static var tunnelOut: [String] { pick(CS.tunnelOut, EN.tunnelOut, DE.tunnelOut, ES.tunnelOut, FR.tunnelOut) }
    static var leap: [String] { pick(CS.leap, EN.leap, DE.leap, ES.leap, FR.leap) }
    static var poopSay: [String] { pick(CS.poopSay, EN.poopSay, DE.poopSay, ES.poopSay, FR.poopSay) }
    static var poopReact: [String] { pick(CS.poopReact, EN.poopReact, DE.poopReact, ES.poopReact, FR.poopReact) }
    static var vomit: [String] { pick(CS.vomit, EN.vomit, DE.vomit, ES.vomit, FR.vomit) }
    static var vomitReact: [String] { pick(CS.vomitReact, EN.vomitReact, DE.vomitReact, ES.vomitReact, FR.vomitReact) }
    static var foodSpot: [String] { pick(CS.foodSpot, EN.foodSpot, DE.foodSpot, ES.foodSpot, FR.foodSpot) }
    static var envy: [String] { pick(CS.envy, EN.envy, DE.envy, ES.envy, FR.envy) }
    static var moleEscaped: [String] { pick(CS.moleEscaped, EN.moleEscaped, DE.moleEscaped, ES.moleEscaped, FR.moleEscaped) }
    static var wormEat: [String] { pick(CS.wormEat, EN.wormEat, DE.wormEat, ES.wormEat, FR.wormEat) }
    static var cleaned: [String] { pick(CS.cleaned, EN.cleaned, DE.cleaned, ES.cleaned, FR.cleaned) }
    static var eatApple: [String] { pick(CS.eatApple, EN.eatApple, DE.eatApple, ES.eatApple, FR.eatApple) }
    static var eatMole: [String] { pick(CS.eatMole, EN.eatMole, DE.eatMole, ES.eatMole, FR.eatMole) }
    static var oldAge: [String] { pick(CS.oldAge, EN.oldAge, DE.oldAge, ES.oldAge, FR.oldAge) }
    static var sick: [String] { pick(CS.sick, EN.sick, DE.sick, ES.sick, FR.sick) }
    static var farewell: [String] { pick(CS.farewell, EN.farewell, DE.farewell, ES.farewell, FR.farewell) }
    static var mourn: [String] { pick(CS.mourn, EN.mourn, DE.mourn, ES.mourn, FR.mourn) }
    static var birth: [String] { pick(CS.birth, EN.birth, DE.birth, ES.birth, FR.birth) }
    static var newborn: [String] { pick(CS.newborn, EN.newborn, DE.newborn, ES.newborn, FR.newborn) }
    static var welcomeShort: [String] { pick(CS.welcomeShort, EN.welcomeShort, DE.welcomeShort, ES.welcomeShort, FR.welcomeShort) }
    static var welcomeLong: [String] { pick(CS.welcomeLong, EN.welcomeLong, DE.welcomeLong, ES.welcomeLong, FR.welcomeLong) }
    static var burrowUp: [String] { pick(CS.burrowUp, EN.burrowUp, DE.burrowUp, ES.burrowUp, FR.burrowUp) }
}
