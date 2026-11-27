// Podpora autora: „zaplať, kolik chceš" + licenční klíč, který odemkne bonusy
// (14 barev srsti a mládě). Kód je open source, takže to není ochrana proti kopírování –
// je to poděkování podporovatelům.
//
// NASTAVENÍ PRO VYDÁNÍ: vyplň storeURL (a u Polaru/Gumroadu productId).
//   code (výchozí, nejlevnější): Stripe Payment Link s „Let customers choose what to pay“,
//                    na potvrzovací stránce je odemykací kód (SUPPORTER-CODE.txt, tady jen jeho otisk).
//                    Poplatek jen Stripe (~1,5 % + 6,50 Kč u evropských karet), ověření offline.
//   Polar: produkt „Pay what you want" s benefitem License Keys,
//                    storeURL = checkout link, productId = Organization ID (Settings → General).
//   Gumroad:         produkt s cenou „$X+" a zapnutými License keys, productId = product ID z nastavení produktu.
//   (Lemon Squeezy 16. 11. 2026 zavřel registrace a 31. 3. 2027 končí – nepoužívat.)

import Cocoa
import CryptoKit

extension Notification.Name { static let supporterChanged = Notification.Name("supporterChanged") }

enum Store {
    static let provider = "code"           // "code", "polar" nebo "gumroad"
    static let storeURL = "https://ko-fi.com/s/9223e4b2c2"   // Ko-fi Shop (PayPal): kód je ve zprávě po zaplacení + v souboru
    static let productId = ""              // Polar: Organization ID · Gumroad: product ID

    static var configured: Bool { provider == "code" ? !storeURL.isEmpty : !productId.isEmpty }
    /// otisky odemykacích kódů z potvrzovací stránky po zaplacení
    static let codeHashes: Set<String> = [
        "934d62c75e49e2ee599112ee1814e6a2540df0074c58bde91575e2513d2737c6",
    ]
}

@MainActor enum Supporter {
    static var unlocked: Bool {
        UserDefaults.standard.bool(forKey: "supporter") || ProcessInfo.processInfo.environment["ZV_SUPPORTER"] != nil
    }
    static var paid: Bool { UserDefaults.standard.bool(forKey: "supporter") }

    // MARK: zkušební verze (jednou, 3 dny)
    static let trialDays = 3.0
    static var trialUntil: Double { UserDefaults.standard.double(forKey: "trialUntil") }
    static var trialActive: Bool { trialUntil > Date().timeIntervalSince1970 }
    static var trialUsed: Bool { UserDefaults.standard.object(forKey: "trialUntil") != nil }
    static var trialDaysLeft: Int { max(0, Int(ceil((trialUntil - Date().timeIntervalSince1970) / 86400))) }
    static func startTrial() {
        guard !trialUsed && !paid else { return }
        UserDefaults.standard.set(Date().timeIntervalSince1970 + trialDays * 86400, forKey: "trialUntil")
        NotificationCenter.default.post(name: .supporterChanged, object: nil)
        info(tx("Zkušební verze zapnutá 🎁"), tx("Všechny bonusy máš na 3 dny zdarma. Najdeš je v menu 🦡 → Nastavení."))
        E.pets.forEach { $0.showEmote(.heart, 2) }
    }

    // MARK: promo kódy (ověřují se offline; v kódu je jen otisk SHA-256)
    static let promoHashes: Set<String> = [
    ]
    static func sha(_ s: String) -> String {
        SHA256.hash(data: Data(s.uppercased().trimmingCharacters(in: .whitespaces).utf8)).map { String(format: "%02x", $0) }.joined()
    }

    static func openStore() {
        if let u = URL(string: Store.storeURL), !Store.storeURL.isEmpty { NSWorkspace.shared.open(u) }
        else {
            info(tx("Obchod se připravuje"), tx("Podpora medojedů bude brzy možná. Díky, že o tom uvažuješ! 🦡"))
        }
    }


    /// co podporovatelé dostanou (v jazyce aplikace)
    static func perks() -> String {
        switch L.lang {
        case .cs: return """
Medojedy můžeš podpořit libovolnou částkou – už od ceny jednoho espressa ☕ (cca 50 Kč). Jako dík dostaneš odemykací kód, který natrvalo odemkne:

• 14 barev srsti (zlatý, albín, panda, zombie, noční se svítícíma očima…)
• mládě, které cupitá za rodiči a napodobuje je
• jídlo z přírody: stromy s jablky, žížaly, krtci (a ty nechutnosti k tomu)
• otravnost „Hodně“ a častější lístečky
• další jazyky: čeština, němčina, španělština, francouzština
• nastavení skoro všeho a vlastní jména medojedů

Všechno ostatní je a zůstane zdarma.
"""
        case .de: return """
Unterstütze die Dachse mit einem beliebigen Betrag – schon ab dem Preis eines Espressos ☕ (ca. 2 €). Als Dank bekommst du einen Freischaltcode, der dauerhaft freischaltet:

• 14 Fellfarben (Gold, Albino, Panda, Zombie, Nacht mit leuchtenden Augen…)
• das Junge, das den Eltern hinterherläuft und sie nachahmt
• Essen aus der Natur: Apfelbäume, Würmer, Maulwürfe (und das Eklige dazu)
• Nerv-Faktor „Sehr“ und häufigere Zettel
• weitere Sprachen: Tschechisch, Deutsch, Spanisch, Französisch
• Einstellungen für fast alles und eigene Namen

Alles andere ist und bleibt kostenlos.
"""
        case .es: return """
Apoya a los tejones con lo que quieras, desde el precio de un espresso ☕ (unos 2 €). Como agradecimiento recibes un código que desbloquea para siempre:

• 14 colores de pelaje (dorado, albino, panda, zombi, nocturno con ojos brillantes…)
• la cría, que sigue a sus padres y los imita
• comida de la naturaleza: manzanos, gusanos, topos (y lo asqueroso también)
• fastidio «Mucho» y notas más frecuentes
• más idiomas: checo, alemán, español, francés
• ajustes de casi todo y nombres propios

Todo lo demás es y seguirá siendo gratis.
"""
        case .fr: return """
Soutiens les ratels du montant de ton choix, dès le prix d'un expresso ☕ (environ 2 €). En remerciement, tu reçois un code qui débloque pour toujours :

• 14 couleurs de pelage (doré, albinos, panda, zombie, nuit aux yeux brillants…)
• le petit, qui suit ses parents et les imite
• de la nourriture : pommiers, vers, taupes (et le côté dégoûtant aussi)
• embêtement « Beaucoup » et mots plus fréquents
• d'autres langues : tchèque, allemand, espagnol, français
• des réglages pour presque tout et des noms personnalisés

Tout le reste est et restera gratuit.
"""
        default: return """
Support the badgers with any amount – starting at the price of one espresso ☕ (about $2). As a thank-you you get an unlock code that permanently unlocks:

• 14 fur colors (golden, albino, panda, zombie, night with glowing eyes…)
• the cub that follows its parents and copies them
• food from nature: apple trees, worms, moles (and the gross stuff too)
• “A lot” annoyance and more frequent notes
• more languages: Czech, German, Spanish, French
• settings for almost everything and custom names

Everything else is and stays free.
"""
        }
    }

    /// nabídka z menu / nastavení: co všechno člověk dostane + koupit
    static func buy() {
        NSApp.activate(ignoringOtherApps: true)
        let a = NSAlert()
        a.messageText = tx("Odemkni všechny bonusy ❤️")
        a.informativeText = perks()
        a.addButton(withTitle: tx("Upgradovat nebo podpořit jakoukoli částkou ☕"))
        a.addButton(withTitle: tx("Mám klíč"))
        a.addButton(withTitle: tx("Teď ne"))
        switch a.runModal() {
        case .alertFirstButtonReturn: openStore()
        case .alertSecondButtonReturn: askKey()
        default: break
        }
    }

    /// obecná prosba o podporu (týdenní lísteček)
    static func ask() {
        NSApp.activate(ignoringOtherApps: true)
        let a = NSAlert()
        a.messageText = tx("Podpoř medojedy ❤️")
        a.informativeText = perks() + "\n" + tx("Tohle upozornění se ukáže jen jednou za týden.")
        a.addButton(withTitle: tx("Upgradovat nebo podpořit jakoukoli částkou ☕"))
        a.addButton(withTitle: tx("Mám klíč"))
        a.addButton(withTitle: tx("Teď ne"))
        switch a.runModal() {
        case .alertFirstButtonReturn: openStore()
        case .alertSecondButtonReturn: askKey()
        default: break
        }
    }

    /// nabídka, když někdo klikne na zamčenou věc
    static func offer(_ what: String) {
        NSApp.activate(ignoringOtherApps: true)
        let a = NSAlert()
        a.messageText = what + tx(" je bonus pro podporovatele 🔒")
        a.informativeText = perks()
        a.addButton(withTitle: tx("Upgradovat nebo podpořit jakoukoli částkou ☕"))
        a.addButton(withTitle: tx("Mám klíč"))
        a.addButton(withTitle: tx("Zrušit"))
        switch a.runModal() {
        case .alertFirstButtonReturn: openStore()
        case .alertSecondButtonReturn: askKey()
        default: break
        }
    }

    static func askKey() {
        NSApp.activate(ignoringOtherApps: true)
        let a = NSAlert()
        a.messageText = tx("Zadej licenční klíč")
        a.informativeText = Store.provider == "code"
            ? tx("Kód uvidíš hned po zaplacení na potvrzovací stránce. Ověří se v počítači, nic se nikam neposílá.")
            : tx("Klíč ti přišel e-mailem po podpoře. Ověří se jednou přes internet, pak už funguje offline.")
        let tf = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
        tf.placeholderString = Store.provider == "code" ? "BADGER-XXXX-XXXX" : "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
        a.accessoryView = tf
        a.addButton(withTitle: tx("Odemknout"))
        a.addButton(withTitle: tx("Zrušit"))
        a.window.initialFirstResponder = tf
        guard a.runModal() == .alertFirstButtonReturn else { return }
        let key = tf.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty else { return }
        if Store.codeHashes.contains(sha(key)) {
            UserDefaults.standard.set(true, forKey: "supporter")
            UserDefaults.standard.set("code", forKey: "licenseKey")
            NotificationCenter.default.post(name: .supporterChanged, object: nil)
            info(tx("Díky moc! ❤️"), tx("Bonusy jsou odemčené. Všechno najdeš v menu 🦡 → Nastavení."))
            E.pets.forEach { $0.showEmote(.heart, 3) }
            E.pets.first { $0.phys == .surface }?.say("Děkujeme! Teď jsme ještě hezčí.", dur: 3)
            return
        }
        if Store.provider == "code" && !promoHashes.contains(sha(key)) {
            info(tx("Klíč nesedí"), tx("Zkontroluj, že je klíč opsaný přesně.")); return
        }
        if promoHashes.contains(sha(key)) {
            UserDefaults.standard.set(true, forKey: "supporter")
            UserDefaults.standard.set("promo", forKey: "licenseKey")
            NotificationCenter.default.post(name: .supporterChanged, object: nil)
            info(tx("Díky moc! ❤️"), tx("Bonusy jsou odemčené. Všechno najdeš v menu 🦡 → Nastavení."))
            E.pets.forEach { $0.showEmote(.heart, 3) }
            return
        }
        guard Store.configured else { info(tx("Obchod se připravuje"), tx("Ověřování klíčů zatím není zapnuté.")); return }
        verify(key) { ok, msg in
            if ok {
                UserDefaults.standard.set(true, forKey: "supporter")
                UserDefaults.standard.set(key, forKey: "licenseKey")
                NotificationCenter.default.post(name: .supporterChanged, object: nil)
                info(tx("Díky moc! ❤️"), tx("Bonusy jsou odemčené. Všechno najdeš v menu 🦡 → Nastavení."))
                E.pets.forEach { $0.showEmote(.heart, 3) }
                E.pets.first { $0.phys == .surface }?.say("Děkujeme! Teď jsme ještě hezčí.", dur: 3)
            } else {
                info(tx("Klíč nesedí"), msg)
            }
        }
    }

    static func info(_ title: String, _ text: String) {
        NSApp.activate(ignoringOtherApps: true)
        let a = NSAlert(); a.messageText = title; a.informativeText = text; a.runModal()
    }

    /// jediné spojení s internetem v celé aplikaci
    static func verify(_ key: String, done: @escaping @MainActor (Bool, String) -> Void) {
        var req: URLRequest
        var body: [String: String]
        if Store.provider == "polar" {
            // veřejný endpoint pro aplikace u zákazníka (bez tokenu)
            req = URLRequest(url: URL(string: "https://api.polar.sh/v1/customer-portal/license-keys/validate")!)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.setValue("application/json", forHTTPHeaderField: "Accept")
            req.httpBody = try? JSONSerialization.data(withJSONObject: ["key": key, "organization_id": Store.productId])
            req.timeoutInterval = 15
            let msgCheck = tx("Zkontroluj, že je klíč opsaný přesně."), msgConn = tx("Nepodařilo se spojit: ")
            URLSession.shared.dataTask(with: req) { data, resp, err in
                var ok = false
                var msg = msgCheck
                if let err = err { msg = msgConn + err.localizedDescription }
                let code = (resp as? HTTPURLResponse)?.statusCode ?? 0
                if code == 200, let data = data, let j = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    ok = (j["status"] as? String) == "granted"
                }
                DispatchQueue.main.async { MainActor.assumeIsolated { done(ok, msg) } }
            }.resume()
            return
        }
        if Store.provider == "gumroad" {
            req = URLRequest(url: URL(string: "https://api.gumroad.com/v2/licenses/verify")!)
            body = ["product_id": Store.productId, "license_key": key]
        } else {
            req = URLRequest(url: URL(string: "https://api.lemonsqueezy.com/v1/licenses/activate")!)
            body = ["license_key": key, "instance_name": "Badgertop-" + UUID().uuidString.prefix(8)]
        }
        req.httpMethod = "POST"
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        var allowed = CharacterSet.alphanumerics; allowed.insert(charactersIn: "-._~")
        req.httpBody = body.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: allowed) ?? "")" }
            .joined(separator: "&").data(using: .utf8)
        req.timeoutInterval = 15
        let msgCheck = tx("Zkontroluj, že je klíč opsaný přesně."), msgConn = tx("Nepodařilo se spojit: ")
        URLSession.shared.dataTask(with: req) { data, _, err in
            var ok = false
            var msg = msgCheck
            if let err = err { msg = msgConn + err.localizedDescription }
            if let data = data, let j = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                if Store.provider == "gumroad" {
                    let pur = j["purchase"] as? [String: Any]
                    ok = (j["success"] as? Bool) == true && (pur?["refunded"] as? Bool) != true
                        && (pur?["chargebacked"] as? Bool) != true && (pur?["disputed"] as? Bool) != true
                    if let m = j["message"] as? String, !ok { msg = m }
                } else {
                    let activated = (j["activated"] as? Bool) == true || ((j["license_key"] as? [String: Any])?["status"] as? String) == "active"
                    let pid = (j["meta"] as? [String: Any])?["product_id"].map { "\($0)" } ?? ""
                    ok = activated && (pid == Store.productId)
                    if let e = j["error"] as? String, !ok { msg = e }
                }
            }
            DispatchQueue.main.async { MainActor.assumeIsolated { done(ok, msg) } }
        }.resume()
    }
}


// MARK: - Aktualizace
// Jednou denně se podívá na poslední vydání na GitHubu. Je-li novější, medojed přinese
// růžový lísteček – kliknutím se otevře stránka ke stažení. Nic dalšího se neposílá.

@MainActor enum Updates {
    /// "uzivatel/repozitar" na GitHubu (prázdné = vypnuto)
    static let repo = "Daivemasa/badgertop"
    static var current: String { Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0" }
    static var busy = false

    static func newer(_ a: String, than b: String) -> Bool {
        let pa = a.trimmingCharacters(in: CharacterSet(charactersIn: "vV ")).split(separator: ".").map { Int($0) ?? 0 }
        let pb = b.split(separator: ".").map { Int($0) ?? 0 }
        for i in 0..<max(pa.count, pb.count) {
            let x = i < pa.count ? pa[i] : 0, y = i < pb.count ? pb[i] : 0
            if x != y { return x > y }
        }
        return false
    }

    static func check() {
        guard !repo.isEmpty, !busy else { return }
        let ud = UserDefaults.standard
        let now = Date().timeIntervalSince1970
        guard now - ud.double(forKey: "updChecked") > 86400 else { return }
        guard let url = URL(string: "https://api.github.com/repos/\(repo)/releases/latest") else { return }
        busy = true
        ud.set(now, forKey: "updChecked")
        var req = URLRequest(url: url)
        req.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        req.timeoutInterval = 15
        URLSession.shared.dataTask(with: req) { data, _, _ in
            var tag = "", page = ""
            if let data = data, let j = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                tag = j["tag_name"] as? String ?? ""
                page = j["html_url"] as? String ?? ""
            }
            DispatchQueue.main.async { MainActor.assumeIsolated {
                busy = false
                guard !tag.isEmpty, newer(tag, than: current), ud.string(forKey: "updAnnounced") != tag,
                      let link = URL(string: page) else { return }
                if announce(tag, link) { ud.set(tag, forKey: "updAnnounced") } else { ud.set(0, forKey: "updChecked") }
            } }
        }.resume()
    }

    static func announce(_ tag: String, _ link: URL) -> Bool {
        guard let aw = W.active, let p = E.adults.filter({ $0.free }).randomElement() else { return false }
        let v = tag.trimmingCharacters(in: CharacterSet(charactersIn: "vV"))
        let it = Item(.support(String(format: tx("Nová verze %@ je venku! 🎉\nKlikni na mě a stáhni si ji."), v)))
        it.link = link
        it.carrier = p; it.pos = p.mouth
        E.items.append(it)
        p.carrying = it
        p.goal = .deliver(aw.id, E.now + 60)
        p.say("Něco ti nesu! Je to důležitý.", dur: 2.2)
        return true
    }
}
