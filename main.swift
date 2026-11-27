// Badgertop – two pixel honey badgers on your macOS desktop. Zero cares.
// Lezou po oknech, Docku a menu baru, hrají si spolu, mají noru, hlad a náladu,
// nosí lístečky s připomínkami a trochu otravují.

import Cocoa
import ApplicationServices
import ServiceManagement

// MARK: - Math

func P(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x, y: y) }
extension CGPoint {
    static func + (a: CGPoint, b: CGPoint) -> CGPoint { P(a.x + b.x, a.y + b.y) }
    static func - (a: CGPoint, b: CGPoint) -> CGPoint { P(a.x - b.x, a.y - b.y) }
    static func * (a: CGPoint, k: CGFloat) -> CGPoint { P(a.x * k, a.y * k) }
    var len: CGFloat { hypot(x, y) }
    var norm: CGPoint { let l = len; return l > 0.0001 ? P(x / l, y / l) : P(0, 0) }
    func dot(_ b: CGPoint) -> CGFloat { x * b.x + y * b.y }
}
extension CGRect { var center: CGPoint { P(midX, midY) } }
func rnd(_ a: Double, _ b: Double) -> Double { Double.random(in: a...b) }
func rndf(_ a: CGFloat, _ b: CGFloat) -> CGFloat { a < b ? CGFloat.random(in: a...b) : a }
func chance(_ p: Double) -> Bool { Double.random(in: 0..<1) < p }
func clamp(_ v: CGFloat, _ a: CGFloat, _ b: CGFloat) -> CGFloat { max(a, min(b, v)) }
func wrapAngle(_ a: CGFloat) -> CGFloat {
    var d = a.truncatingRemainder(dividingBy: 2 * .pi)
    if d > .pi { d -= 2 * .pi } else if d < -.pi { d += 2 * .pi }
    return d
}
let GRAV: CGFloat = 1800

// MARK: - Texty

let NAMES = ["Medák", "Drápek"]

// MARK: - World

struct Win { let id: Int; let rect: CGRect; let z: Int; let pid: Int32 }
struct Scr {
    let frame: CGRect
    let visible: CGRect
    let menuBottom: CGFloat
    var hasMenu: Bool { menuBottom < frame.maxY - 1 }
}
enum Host: Equatable { case window(Int), screen(Int), dock, menubar(Int), prop(Int) }
struct Edge { let start: CGPoint; let dir: CGPoint; let len: CGFloat; let n: CGPoint }

/// Obvod obdélníku. outer = vnější strana okna, inner = vnitřek obrazovky.
func edgeOf(_ r: CGRect, inner: Bool, _ e: Int) -> Edge {
    let w = r.width, h = r.height
    if !inner {
        switch e & 3 {
        case 0: return Edge(start: P(r.minX, r.maxY), dir: P(1, 0), len: w, n: P(0, 1))
        case 1: return Edge(start: P(r.maxX, r.maxY), dir: P(0, -1), len: h, n: P(1, 0))
        case 2: return Edge(start: P(r.maxX, r.minY), dir: P(-1, 0), len: w, n: P(0, -1))
        default: return Edge(start: P(r.minX, r.minY), dir: P(0, 1), len: h, n: P(-1, 0))
        }
    } else {
        switch e & 3 {
        case 0: return Edge(start: P(r.minX, r.minY), dir: P(1, 0), len: w, n: P(0, 1))
        case 1: return Edge(start: P(r.maxX, r.minY), dir: P(0, 1), len: h, n: P(-1, 0))
        case 2: return Edge(start: P(r.maxX, r.maxY), dir: P(-1, 0), len: w, n: P(0, -1))
        default: return Edge(start: P(r.minX, r.maxY), dir: P(0, -1), len: h, n: P(1, 0))
        }
    }
}

@MainActor final class World {
    var wins: [Win] = []
    var byId: [Int: Win] = [:]
    var scrs: [Scr] = []
    var dock: CGRect?
    var dockExact = false
    var primaryH: CGFloat = 0
    let myPid = ProcessInfo.processInfo.processIdentifier
    let ignoredOwners: Set<String> = ["Window Server", "Dock", "Control Center", "Notification Center", "SystemUIServer", "Spotlight", "Screenshot", "WindowManager"]

    func refreshScreens() {
        let screens = NSScreen.screens
        primaryH = screens.first?.frame.maxY ?? 1000
        scrs = screens.map { s in
            let f = s.frame, vf = s.visibleFrame
            let mb = vf.maxY < f.maxY - 1 ? vf.maxY : f.maxY
            return Scr(frame: f, visible: vf, menuBottom: mb)
        }
        if scrs.isEmpty { scrs = [Scr(frame: CGRect(x: 0, y: 0, width: 1440, height: 900), visible: CGRect(x: 0, y: 0, width: 1440, height: 875), menuBottom: 875)] }
    }

    func refreshWindows() {
        guard let list = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]] else { return }
        var out: [Win] = []
        var z = 0
        for w in list {
            guard let layer = w[kCGWindowLayer as String] as? Int, layer == 0,
                  let pid = w[kCGWindowOwnerPID as String] as? Int32, pid != myPid,
                  let num = w[kCGWindowNumber as String] as? Int,
                  let bd = w[kCGWindowBounds as String] as? NSDictionary,
                  let b = CGRect(dictionaryRepresentation: bd) else { continue }
            if let owner = w[kCGWindowOwnerName as String] as? String, ignoredOwners.contains(owner) { continue }
            if let a = w[kCGWindowAlpha as String] as? Double, a < 0.1 { continue }
            if b.width < 120 || b.height < 60 { continue }
            let r = CGRect(x: b.minX, y: primaryH - b.minY - b.height, width: b.width, height: b.height)
            out.append(Win(id: num, rect: r, z: z, pid: pid))
            z += 1
        }
        wins = out
        activeCache = nil
        byId = Dictionary(out.map { ($0.id, $0) }, uniquingKeysWith: { a, _ in a })
    }

    func refreshDock() {
        CFPreferencesAppSynchronize("com.apple.dock" as CFString)
        refreshScreens()
        let prefs = UserDefaults(suiteName: "com.apple.dock")
        if prefs?.bool(forKey: "autohide") == true || DockAPI.autoHide() == true { dock = nil; return }
        // přesný obdélník Docku od systému (bez Zpřístupnění)
        if let r = DockAPI.rect(), r.width > 10, r.height > 10 {
            let c = CGRect(x: r.minX, y: primaryH - r.minY - r.height, width: r.width, height: r.height)
            if scrs.contains(where: { $0.frame.intersects(c) }) {
                dockExact = true
                if c.width > c.height {
                    // konce radši kratší: ať spadnou o kus dřív, než aby šlapali vzduch
                    let cut = max(22, c.height * 0.7)
                    dock = CGRect(x: c.minX + cut, y: c.minY, width: max(40, c.width - 2 * cut), height: max(20, c.height - 2))
                } else {
                    let cut = max(22, c.width * 0.7)
                    dock = CGRect(x: c.minX, y: c.minY + cut, width: c.width, height: max(40, c.height - 2 * cut))
                }
                return
            }
        }
        if AXIsProcessTrusted(), let app = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.dock").first {
            let ax = AXUIElementCreateApplication(app.processIdentifier)
            var ch: CFTypeRef?
            if AXUIElementCopyAttributeValue(ax, kAXChildrenAttribute as CFString, &ch) == .success, let arr = ch as? [AXUIElement] {
                for el in arr {
                    var role: CFTypeRef?
                    AXUIElementCopyAttributeValue(el, kAXRoleAttribute as CFString, &role)
                    guard (role as? String) == "AXList" else { continue }
                    var pr: CFTypeRef?, sr: CFTypeRef?
                    AXUIElementCopyAttributeValue(el, kAXPositionAttribute as CFString, &pr)
                    AXUIElementCopyAttributeValue(el, kAXSizeAttribute as CFString, &sr)
                    var p = CGPoint.zero, s = CGSize.zero
                    if let pr = pr, let sr = sr {
                        AXValueGetValue(pr as! AXValue, .cgPoint, &p)
                        AXValueGetValue(sr as! AXValue, .cgSize, &s)
                        if s.width > 20 && s.height > 20 {
                            dockExact = true
                            dock = CGRect(x: p.x, y: primaryH - p.y - s.height, width: s.width, height: s.height)
                            return
                        }
                    }
                }
            }
        }
        dockExact = false
        let orient = prefs?.string(forKey: "orientation") ?? "bottom"
        guard let s = scrs.first(where: { orient == "bottom" ? $0.visible.minY > $0.frame.minY + 1
                                          : orient == "left" ? $0.visible.minX > $0.frame.minX + 1
                                          : $0.visible.maxX < $0.frame.maxX - 1 }) else { dock = nil; return }
        let thick: CGFloat = orient == "bottom" ? s.visible.minY - s.frame.minY
            : orient == "left" ? s.visible.minX - s.frame.minX : s.frame.maxX - s.visible.maxX
        let ts = CGFloat(prefs?.double(forKey: "tilesize") ?? 0)
        let tile = ts > 10 ? ts : thick * 0.72
        let persistent = (prefs?.array(forKey: "persistent-apps") as? [[String: Any]]) ?? []
        let pIds = Set(persistent.compactMap { (($0["tile-data"] as? [String: Any])?["bundle-identifier"] as? String) })
        var appTiles: CGFloat = 0
        for t in persistent {
            switch t["tile-type"] as? String {
            case "small-spacer-tile": appTiles += 0.5
            default: appTiles += 1
            }
        }
        let others = CGFloat((prefs?.array(forKey: "persistent-others"))?.count ?? 1)
        let running = NSWorkspace.shared.runningApplications.filter {
            $0.activationPolicy == .regular && !pIds.contains($0.bundleIdentifier ?? "") && $0.bundleIdentifier != "com.apple.finder"
        }.count
        let showRecents = (prefs?.object(forKey: "show-recents") as? Bool) ?? true
        let recents = CGFloat(showRecents ? min(3, (prefs?.array(forKey: "recent-apps"))?.count ?? 3) : 0)
        let recentSection = CGFloat(running) + recents
        let seps: CGFloat = recentSection > 0 ? 2 : 1
        // Finder + aplikace + nedávné + složky + koš, mezery, okraje
        let length = (1 + appTiles + recentSection + others + 1) * tile * 1.04 + seps * tile * 0.5 + tile * 0.8
        switch orient {
        case "left": dock = CGRect(x: s.frame.minX, y: s.frame.midY - length / 2, width: thick - 4, height: length)
        case "right": dock = CGRect(x: s.frame.maxX - thick + 4, y: s.frame.midY - length / 2, width: thick - 4, height: length)
        default:
            let w = max(60, length - tile * 1.2)
            dock = CGRect(x: s.frame.midX - w / 2, y: s.frame.minY, width: w, height: max(20, thick - 2))
        }
    }

    func geom(_ h: Host) -> (rect: CGRect, inner: Bool)? {
        switch h {
        case .window(let id): return byId[id].map { ($0.rect, false) }
        case .screen(let i):
            guard i < scrs.count else { return nil }
            let s = scrs[i]
            let fy = floorY(i)
            return (CGRect(x: s.frame.minX, y: fy, width: s.frame.width, height: s.menuBottom - fy), true)
        case .dock: return dock.map { ($0, false) }
        case .prop: return nil
        case .menubar(let i):
            guard i < scrs.count, scrs[i].hasMenu else { return nil }
            let s = scrs[i]
            return (CGRect(x: s.frame.minX, y: s.menuBottom - 1, width: s.frame.width, height: 1), false)
        }
    }

    var activeCache: Win??
    /// okno aktivní aplikace
    var active: Win? {
        if let c = activeCache { return c }
        let r = computeActive()
        activeCache = .some(r)
        return r
    }
    func computeActive() -> Win? {
        let fp = NSWorkspace.shared.frontmostApplication?.processIdentifier ?? -1
        let ok = { (w: Win) in w.rect.width >= 250 && w.rect.height >= 150 && self.onScreen(P(w.rect.midX, w.rect.maxY - 5)) }
        return wins.first { $0.pid == fp && ok($0) } ?? wins.first(where: ok)
    }

    func covered(_ p: CGPoint, frontOf z: Int) -> Bool {
        for w in wins where w.z < z { if w.rect.contains(p) { return true } }
        return false
    }
    func coveringWindow(_ p: CGPoint, frontOf z: Int) -> Win? { wins.first { $0.z < z && $0.rect.contains(p) } }

    /// podlaha obrazovky: spodní okraj, nebo horní hrana Docku, když je dole a neznáme jeho přesný tvar
    func floorY(_ i: Int) -> CGFloat {
        guard i < scrs.count else { return 0 }
        let s = scrs[i]
        if dock == nil && s.visible.minY > s.frame.minY + 1 { return s.visible.minY }
        return s.frame.minY
    }

    func screenIndex(_ p: CGPoint) -> Int {
        if let i = scrs.firstIndex(where: { $0.frame.contains(p) }) { return i }
        var best = 0, bd = CGFloat.greatestFiniteMagnitude
        for (i, s) in scrs.enumerated() {
            let cx = clamp(p.x, s.frame.minX, s.frame.maxX), cy = clamp(p.y, s.frame.minY, s.frame.maxY)
            let dd = hypot(p.x - cx, p.y - cy)
            if dd < bd { bd = dd; best = i }
        }
        return best
    }
    func onScreen(_ p: CGPoint) -> Bool { scrs.contains { $0.frame.insetBy(dx: 0, dy: -3).contains(p) } }

    /// horní hrana okna, která není schovaná v menu baru (maximalizovaná okna)
    func topUsable(_ w: Win) -> Bool {
        let s = scrs[screenIndex(P(w.rect.midX, w.rect.maxY - 2))]
        return w.rect.maxY < s.menuBottom - 40
    }

    func floors(at x: CGFloat) -> [(Host, CGFloat)] {
        var r: [(Host, CGFloat)] = []
        for w in wins where x >= w.rect.minX + 2 && x <= w.rect.maxX - 2 && topUsable(w) {
            if !covered(P(x, w.rect.maxY + 8), frontOf: w.z) && onScreen(P(x, w.rect.maxY)) { r.append((.window(w.id), w.rect.maxY)) }
        }
        if let d = dock, x >= d.minX + 4, x <= d.maxX - 4 { r.append((.dock, d.maxY)) }
        for (i, s) in scrs.enumerated() where x >= s.frame.minX && x < s.frame.maxX {
            r.append((.screen(i), floorY(i)))
        }
        return r
    }

    /// x na horní hraně okna, kde to není schované, co nejblíž k `near`
    func visibleTopX(_ w: Win, near: CGFloat) -> CGFloat? {
        guard topUsable(w) else { return nil }
        let x0 = clamp(near, w.rect.minX + 30, w.rect.maxX - 30)
        if !covered(P(x0, w.rect.maxY + 8), frontOf: w.z) && onScreen(P(x0, w.rect.maxY)) { return x0 }
        let xs = stride(from: w.rect.minX + 30, to: w.rect.maxX - 30, by: 24).filter {
            !covered(P($0, w.rect.maxY + 8), frontOf: w.z) && onScreen(P($0, w.rect.maxY))
        }
        return xs.min { abs($0 - near) < abs($1 - near) }
    }
}

// MARK: - Panels & views

final class OverlayPanel: NSPanel {
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
    override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect { frameRect }
}

/// soukromé API Docku (CoreDock): obdélník a schovávání, funguje bez Zpřístupnění
enum DockAPI {
    private static let h = dlopen(nil, RTLD_NOW)
    private typealias RectF = @convention(c) (UnsafeMutablePointer<CGRect>) -> Int32
    private typealias BoolF = @convention(c) () -> Bool
    private static let rectF: RectF? = dlsym(h, "CoreDockGetRect").map { unsafeBitCast($0, to: RectF.self) }
    private static let hideF: BoolF? = dlsym(h, "CoreDockGetAutoHideEnabled").map { unsafeBitCast($0, to: BoolF.self) }
    /// v souřadnicích s počátkem vlevo nahoře (jako CGWindow)
    static func rect() -> CGRect? {
        guard let f = rectF else { return nil }
        let buf = UnsafeMutablePointer<CGRect>.allocate(capacity: 4)
        defer { buf.deallocate() }
        buf.initialize(repeating: .zero, count: 4)
        guard f(buf) == 0 else { return nil }
        let r = buf[0]
        return r.width.isFinite && r.height.isFinite ? r : nil
    }
    static func autoHide() -> Bool? { hideF?() }
}

@MainActor func makePanel(_ size: NSSize, level: Int = 1) -> OverlayPanel {
    let p = OverlayPanel(contentRect: NSRect(origin: P(-3000, -3000), size: size), styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
    p.isOpaque = false
    p.backgroundColor = .clear
    p.hasShadow = false
    p.level = NSWindow.Level(rawValue: NSWindow.Level.statusBar.rawValue + level)
    p.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]
    p.isFloatingPanel = true
    p.hidesOnDeactivate = false
    p.becomesKeyOnlyIfNeeded = true
    p.isReleasedWhenClosed = false
    p.ignoresMouseEvents = true
    p.animationBehavior = .none
    p.sharingType = UserDefaults.standard.object(forKey: "hideShare") as? Bool ?? false ? .none : .readOnly
    return p
}

final class BubbleView: NSView {
    var text = ""
    var tailDown = true
    static let attrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.monospacedSystemFont(ofSize: 12, weight: .bold),
        .foregroundColor: NSColor(white: 0.08, alpha: 1),
    ]
    static func size(for t: String) -> NSSize {
        let br = (t as NSString).boundingRect(with: NSSize(width: 230, height: 1000), options: [.usesLineFragmentOrigin], attributes: attrs)
        return NSSize(width: ceil(br.width) + 26, height: ceil(br.height) + 16 + 10)
    }
    override func draw(_ r: NSRect) {
        let ink = NSColor(white: 0.08, alpha: 1), paper = NSColor.white
        let body = NSRect(x: 3, y: tailDown ? 13 : 3, width: bounds.width - 6, height: bounds.height - 16)
        ink.setFill()
        body.insetBy(dx: -3, dy: 0).fill(); body.insetBy(dx: 0, dy: -3).fill()
        paper.setFill(); body.fill()
        let tx = (bounds.midX / 3).rounded() * 3
        for (i, w) in [9, 6, 3].enumerated() {
            let y = tailDown ? body.minY - CGFloat(i + 1) * 3 : body.maxY + CGFloat(i) * 3
            ink.setFill(); NSRect(x: tx - CGFloat(w) / 2 - 3, y: y, width: CGFloat(w) + 6, height: 3).fill()
            paper.setFill(); NSRect(x: tx - CGFloat(w) / 2, y: y, width: CGFloat(w), height: 3).fill()
        }
        ink.setFill(); NSRect(x: tx - 1.5, y: tailDown ? body.minY - 12 : body.maxY + 9, width: 3, height: 3).fill()
        (text as NSString).draw(with: body.insetBy(dx: 10, dy: 6), options: [.usesLineFragmentOrigin], attributes: BubbleView.attrs)
    }
}

final class MenuItem: NSMenuItem {
    let block: () -> Void
    @MainActor init(_ title: String, key: String = "", on: Bool = false, enabled: Bool = true, _ block: @escaping () -> Void) {
        self.block = block
        super.init(title: tx(title), action: enabled ? #selector(fire) : nil, keyEquivalent: key)
        target = self
        state = on ? .on : .off
        isEnabled = enabled
    }
    required init(coder: NSCoder) { fatalError() }
    @objc func fire() { block() }
}

/// Bublina s textem nad zvířetem
@MainActor final class Speech {
    var panel: OverlayPanel?
    var view: BubbleView?
    var t: Double = 0
    func say(_ text: String, dur: Double) {
        guard !E.hidden else { return }
        if panel == nil {
            panel = makePanel(NSSize(width: 100, height: 40), level: 3)
            view = BubbleView(frame: NSRect(x: 0, y: 0, width: 100, height: 40))
            panel!.contentView = view
        }
        view!.text = text
        let sz = BubbleView.size(for: text)
        panel!.setContentSize(sz)
        view!.frame = NSRect(origin: .zero, size: sz)
        view!.needsDisplay = true
        t = dur
        panel!.alphaValue = 1
        panel!.orderFrontRegardless()
    }
    func update(_ dt: Double) { if t > 0 { t -= dt; if t <= 0 { panel?.orderOut(nil) } } }
    func hide() { t = 0; panel?.orderOut(nil) }
    func place(center bc: CGPoint, halfH: CGFloat, preferAbove: Bool) {
        guard let b = panel, let bv = view, t > 0 else { return }
        let sz = b.frame.size
        let s = W.scrs[W.screenIndex(bc)].frame
        var above = preferAbove
        var y = bc.y + halfH + 4
        if !above || y + sz.height > s.maxY - 2 { above = false; y = bc.y - halfH - 4 - sz.height }
        let x = clamp(bc.x - sz.width / 2, s.minX + 2, s.maxX - sz.width - 2)
        if bv.tailDown != above { bv.tailDown = above; bv.needsDisplay = true }
        let o = P(x.rounded(), y.rounded())
        if b.frame.origin != o { b.setFrameOrigin(o) }
        let a: CGFloat = t < 0.4 ? CGFloat(t / 0.4) : 1
        if abs(b.alphaValue - a) > 0.02 { b.alphaValue = a }
    }
}

// MARK: - Items (med, lísteček)

final class ItemView: NSView {
    weak var item: Item?
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
    override func mouseUp(with e: NSEvent) { item?.clicked() }
    override func rightMouseDown(with e: NSEvent) { item?.clicked() }
    override func draw(_ r: NSRect) { item?.draw(in: self) }
}

@MainActor final class Item {
    enum Kind { case honey, note(String), support(String), poop, vomit, tree, worm, mole }
    let kind: Kind
    var phys: Phys = .air
    var host: Host = .screen(0)
    var d: CGFloat = 0
    var pos = CGPoint.zero
    var vel = CGPoint.zero
    weak var carrier: Pet?
    var age: Double = 0
    var dead = false
    let panel: OverlayPanel
    let view: ItemView
    var shown = false
    var owner = -1
    var reacted = Set<Int>()
    var fruit = true
    var lastFrame = -1
    let noteSize: NSSize

    var isNote: Bool { switch kind { case .note, .support: return true; default: return false } }
    var isSupport: Bool { if case .support = kind { return true }; return false }
    /// lísteček s odkazem (nová verze)
    var link: URL?
    var text: String { switch kind { case .note(let t), .support(let t): return t; default: return "" } }
    static let noteAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.monospacedSystemFont(ofSize: 11, weight: .bold),
        .foregroundColor: NSColor(white: 0.12, alpha: 1),
    ]

    init(_ k: Kind) {
        kind = k
        if case .note(let t) = k {
            let br = (t as NSString).boundingRect(with: NSSize(width: 112, height: 400), options: [.usesLineFragmentOrigin], attributes: Item.noteAttrs)
            noteSize = NSSize(width: 136, height: ceil(br.height) + 34)
        } else if case .support(let t) = k {
            let br = (t as NSString).boundingRect(with: NSSize(width: 112, height: 400), options: [.usesLineFragmentOrigin], attributes: Item.noteAttrs)
            noteSize = NSSize(width: 136, height: ceil(br.height) + 34)
        } else { noteSize = .zero }
        panel = makePanel(NSSize(width: 40, height: 40), level: 0)
        view = ItemView(frame: NSRect(x: 0, y: 0, width: 40, height: 40))
        panel.contentView = view
        view.item = self
    }

    func clicked() {
        switch kind {
        case .poop, .vomit: dead = true; E.pets.first { $0.phys == .surface }?.say(L.r(L.cleaned), dur: 1.6); return
        default: break
        }
        guard isNote, carrier == nil else { return }
        dead = true
        if let l = link { NSWorkspace.shared.open(l); return }
        if isSupport { Supporter.ask(); return }
        E.pets.randomElement()?.say(L.r(L.noteDismissed), dur: 1.8)
    }

    func update(_ dt: Double) {
        age += dt
        switch kind {
        case .honey: if age > 150 { dead = true }
        case .note, .support: if age > 1800 { dead = true }
        case .poop: if age > 60 { dead = true }
        case .vomit: if age > 40 { dead = true }
        case .tree: if age > 150 || (!fruit && age > 30) { dead = true }
        case .worm: if age > 40 { dead = true }
        case .mole: if age > 26 { dead = true }
        }
        if let c = carrier { pos = c.mouth; phys = .hidden; return }
        switch phys {
        case .air:
            let prev = pos
            vel.y = max(vel.y - GRAV * CGFloat(dt), -2400)
            pos = pos + vel * CGFloat(dt)
            if vel.y <= 0 {
                var best: (Host, CGFloat)?
                for f in W.floors(at: pos.x) where f.1 <= prev.y + 0.01 && f.1 >= pos.y {
                    if best == nil || f.1 > best!.1 { best = f }
                }
                if let b = best, let g = W.geom(b.0) {
                    host = b.0; pos.y = b.1
                    d = pos.x - edgeOf(g.rect, inner: g.inner, 0).start.x
                    phys = .surface; vel = .zero
                    if case .honey = kind { E.treatLanded(self) }
                }
            }
            let f = W.scrs[W.screenIndex(pos)].frame
            let fy = W.floorY(W.screenIndex(pos))
            if phys == .air && pos.y < fy { pos.y = fy; vel = .zero; phys = .surface; host = .screen(W.screenIndex(pos)); d = pos.x - f.minX }
        case .surface, .hidden:
            guard let g = W.geom(host) else { phys = .air; return }
            let e = edgeOf(g.rect, inner: g.inner, 0)
            d = clamp(d, 0, e.len)
            pos = e.start + e.dir * d
            phys = .surface
            if case .window(let id) = host, let w = W.byId[id], W.covered(pos + P(0, 8), frontOf: w.z) { phys = .air }
        default: break
        }
    }

    func render() {
        let size: NSSize
        let origin: CGPoint
        if carrier != nil {
            size = NSSize(width: 26, height: 26); origin = P(pos.x - 13, pos.y - 13)
        } else if isNote {
            size = noteSize; origin = P(pos.x - size.width / 2, pos.y - 2)
        } else {
            let sz = spriteSize
            size = NSSize(width: sz + 2, height: sz + 2); origin = P(pos.x - sz / 2 - 1, pos.y - 2)
        }
        let fr = NSRect(origin: P(origin.x.rounded(), origin.y.rounded()), size: size)
        if panel.frame != fr {
            let resized = panel.frame.size != size
            panel.setFrame(fr, display: false)
            if resized { view.frame = NSRect(origin: .zero, size: size); view.needsDisplay = true }
        }
        if case .poop = kind { let a: CGFloat = age > 55 ? CGFloat(max(0, (60 - age) / 5)) : 1; if abs(panel.alphaValue - a) > 0.02 { panel.alphaValue = a } }
        if case .vomit = kind { let a: CGFloat = age > 35 ? CGFloat(max(0, (40 - age) / 5)) : 1; if abs(panel.alphaValue - a) > 0.02 { panel.alphaValue = a } }
        var clickable = isNote && carrier == nil
        if case .poop = kind { clickable = true }
        if case .vomit = kind { clickable = true }
        if panel.ignoresMouseEvents == clickable { panel.ignoresMouseEvents = !clickable }
        let fr0 = animFrame
        if fr0 != lastFrame { lastFrame = fr0; view.needsDisplay = true }
        if !shown && !E.hidden { panel.orderFrontRegardless(); shown = true }
    }

    func draw(in v: NSView) {
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }
        ctx.interpolationQuality = .none
        let b = v.bounds
        if !isNote {
            let sz = spriteSize
            let r = CGRect(x: (b.width - sz) / 2, y: 0, width: sz, height: sz)
            switch kind {
            case .tree: ctx.draw(Critter.tree(min(3, Int(age / 1.2)), fruit: fruit), in: r)
            case .worm: ctx.draw(Critter.worm(Int(age * 4)), in: r)
            case .mole: ctx.draw(Critter.mole(animFrame), in: r)
            case .poop:
                ctx.draw(Critter.poop(), in: r)
                // smradlavé čárky
                NSColor(red: 0.45, green: 0.55, blue: 0.3, alpha: 0.7).setFill()
                for i in 0..<3 {
                    let ph = CGFloat(age * 3) + CGFloat(i) * 2
                    let x0 = r.midX - 8 + CGFloat(i) * 8, y0 = r.minY + sz * 0.55
                    for j in 0..<4 { NSRect(x: x0 + sin(ph + CGFloat(j)) * 2, y: y0 + CGFloat(j) * 3 + CGFloat(Int(age * 6) % 3), width: 2, height: 2).fill() }
                }
            case .vomit: ctx.draw(Critter.vomit(), in: r)
            default: ctx.draw(Honey.pot, in: CGRect(x: (b.width - 34) / 2, y: 0, width: 34, height: 34))
            }
            return
        }
        let ink = NSColor(white: 0.1, alpha: 1), paper = isSupport ? NSColor(red: 1, green: 0.84, blue: 0.9, alpha: 1) : NSColor(red: 1, green: 0.95, blue: 0.62, alpha: 1)
        if carrier != nil {
            let r = NSRect(x: 4, y: 7, width: 18, height: 13)
            ink.setFill(); r.insetBy(dx: -2, dy: 0).fill(); r.insetBy(dx: 0, dy: -2).fill()
            paper.setFill(); r.fill()
            ink.setFill(); NSRect(x: 7, y: 15, width: 12, height: 2).fill(); NSRect(x: 7, y: 11, width: 9, height: 2).fill()
            return
        }
        let r = NSRect(x: 3, y: 3, width: b.width - 6, height: b.height - 12)
        ink.setFill(); r.insetBy(dx: -3, dy: 0).fill(); r.insetBy(dx: 0, dy: -3).fill()
        paper.setFill(); r.fill()
        NSColor(red: 0.94, green: 0.86, blue: 0.45, alpha: 1).setFill(); NSRect(x: r.minX, y: r.minY, width: r.width, height: 4).fill()
        NSColor(red: 0.9, green: 0.24, blue: 0.28, alpha: 1).setFill(); NSRect(x: b.midX - 4, y: b.height - 12, width: 8, height: 8).fill()
        ink.setFill(); NSRect(x: b.midX - 1, y: b.height - 16, width: 2, height: 4).fill()
        (text as NSString).draw(with: r.insetBy(dx: 9, dy: 8), options: [.usesLineFragmentOrigin], attributes: Item.noteAttrs)
        let small: [NSAttributedString.Key: Any] = [.font: NSFont.monospacedSystemFont(ofSize: 8, weight: .regular), .foregroundColor: NSColor(white: 0.35, alpha: 1)]
        (tx(isSupport ? "— klik = podpořit / zavřít" : "— medojedi · klik = pryč") as NSString).draw(at: P(r.minX + 8, r.minY + 5), withAttributes: small)
    }

    func destroy() { panel.orderOut(nil); view.item = nil }

    var spriteSize: CGFloat {
        switch kind { case .tree: return 56; case .worm: return 34; case .mole: return 40; case .poop: return 30; case .vomit: return 44; default: return 34 }
    }
    var animFrame: Int {
        switch kind {
        case .tree: return min(3, Int(age / 1.2)) * 2 + (fruit ? 1 : 0)
        case .worm: return Int(age * 4) % 2
        case .mole: return age < 0.7 ? 0 : (age > 24 ? 0 : (Int(age / 1.4) % 3 == 0 ? 1 : 2))
        case .poop: return Int(age * 6)
        default: return 0
        }
    }
    /// dá se sníst (a je zrovna k mání)
    var edible: Bool {
        switch kind {
        case .honey, .worm: return true
        case .mole: return age > 0.7 && age < 24
        case .tree: return fruit && age > 3.6
        default: return false
        }
    }
    var kindIsWorm: Bool { if case .worm = kind { return true }; return false }
    var isFood: Bool { switch kind { case .honey, .worm, .mole, .tree: return true; default: return false } }

    /// položit na podlahu (bez pádu)
    func place(_ h: Host, _ x: CGFloat) {
        guard let g = W.geom(h) else { return }
        let e = edgeOf(g.rect, inner: g.inner, 0)
        host = h; d = clamp(x - e.start.x, 6, e.len - 6); pos = e.start + e.dir * d; phys = .surface
    }
}

// MARK: - Pet

enum Phys { case surface, air, dragged, home, hidden }
enum Act { case idle, walk, run, sleep }
enum Social { case greet, fight, bonk }
enum Goal {
    case window(Int, Double)
    case cursor(Double)
    case treat(Item)
    case meet(Pet, Social, Double)
    case chase(Pet, Double)
    case flee(Pet, Double)
    case follow(Pet, Double)
    case home(Double)
    case deliver(Int, Double)
    case build(Int, Double)
}
struct Particle { var p: CGPoint; var v: CGPoint; var age: CGFloat; let life: CGFloat; let kind: String }

final class PetView: NSView {
    weak var pet: Pet?
    var downAt = CGPoint.zero
    var dragging = false
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
    override func mouseDown(with e: NSEvent) { downAt = NSEvent.mouseLocation; dragging = false; pet?.pressed = true }
    override func mouseDragged(with e: NSEvent) {
        let m = NSEvent.mouseLocation
        if !dragging && (m - downAt).len > 4 { dragging = true; pet?.beginDrag(m) }
    }
    override func mouseUp(with e: NSEvent) {
        pet?.pressed = false
        if dragging { if pet?.phys == .dragged { pet?.endDrag() } } else { pet?.petted() }
        dragging = false
    }
    override func rightMouseDown(with e: NSEvent) { pet?.showMenu(in: self, event: e) }
    override func draw(_ dirtyRect: NSRect) { pet?.draw(in: self) }
}

@MainActor final class Pet {
    let idx: Int
    var name: String {
        let n = petName(idx, baby: isBaby)
        return !isBaby && Life.gen(idx) > 1 ? n + " " + Life.roman(Life.gen(idx)) + "." : n
    }
    let isBaby: Bool
    weak var parent: Pet?
    var skin: Int {
        get {
            let v = UserDefaults.standard.object(forKey: "skin\(idx)") as? Int ?? (isBaby ? (parent?.skin ?? 0) : idx % 2)
            let k = max(0, min(v, Skins.all.count - 1))
            return Skins.all[k].premium && !Supporter.unlocked ? idx % 2 : k
        }
        set { UserDefaults.standard.set(newValue, forKey: "skin\(idx)"); lastSig = 0 }
    }
    var alt: Bool { skin == 1 }
    var S: CGFloat { (64 * E.petScale * (isBaby ? 0.55 : Life.growth(idx))).rounded() }
    let aspect: CGFloat = 0.75
    var speed: CGFloat { 55 * CGFloat(E.k["speedMul"] ?? 1) * lifeSpeed }
    static let box: CGFloat = 160
    var box: CGFloat { (160 * E.petScale * (isBaby ? 0.7 : 1)).rounded() }

    var phys: Phys = .home
    var host: Host = .screen(0)
    var edge = 0
    var d: CGFloat = 0
    var dir: CGFloat = 1
    var lastDirT: Double = -10
    var pos = CGPoint.zero
    var n = P(0, 1)
    var vel = CGPoint.zero
    var landMaxY: CGFloat?
    var act: Act = .idle
    var actT: Double = 1
    var sleepFlat = false
    var goal: Goal? { didSet { navPlan = nil } }
    var climbFor = -1
    var arrivedAt: Double = -100
    // tunel: 1 = zahrabává se, 2 = pod zemí, 3 = vyhrabává se
    var tunnelStage = 0
    /// přehoupnutí přes roh: tlapky drží roh, tělo se přetočí
    var cornerAnim: (from: CGPoint, to: CGPoint, t: Double, dur: Double)?
    var cornerN = P(0, 1)
    var cornerBulge: CGFloat = 0
    var drawC = P(80, 80)
    var cornerPose: Anim = .stretch
    var cornerConvex = true
    var attachLog: [Double] = []
    var noTransferUntil: Double = 0
    /// skok z boku okna na bok sousedního okna
    var leap: (from: CGPoint, to: CGPoint, win: Int, left: Bool, t: Double, dur: Double)?
    var tunnelT: Double = 0
    var sink: CGFloat = 0
    var tunnelTo: (host: Host, x: CGFloat)?
    /// kde naposledy narazil (aby nekmital tam a zpět)
    var blockMark: (host: Host, edge: Int, d: CGFloat, dir: CGFloat, t: Double)?
    var blockMarks: [(host: Host, edge: Int, d: CGFloat, dir: CGFloat, t: Double)] = []
    func towardBlock(_ nd: CGFloat) -> Bool {
        blockMarks.removeAll { E.now - $0.t > 8 }
        return blockMarks.contains { $0.host == host && $0.edge == edge && $0.dir == nd && abs(d - $0.d) < 50 }
    }
    /// zapamatovat zablokované místo; u rohu i z druhé strany rohu
    func markBlock(_ e: Int, _ dd: CGFloat, _ dr: CGFloat) {
        blockMark = (host, e, dd, dr, E.now)
        blockMarks.append((host, e, dd, dr, E.now))
        guard let g = W.geom(host) else { return }
        let len = edgeOf(g.rect, inner: g.inner, e).len
        if (dr > 0 && dd < 40) || (dr < 0 && dd > len - 40) {
            let prev = dr > 0 ? (e + 3) & 3 : (e + 1) & 3
            let pl = edgeOf(g.rect, inner: g.inner, prev).len
            blockMarks.append((host, prev, dr > 0 ? pl : 0, dr, E.now))
        }
    }
    var oneShot: Anim?
    var oneShotT: Double = 0
    var emote: Emote?
    var emoteT: Double = 0
    var prepT: Double = 0
    var pendingJump = CGPoint.zero
    var jumpCD: Double = 0
    var navCD: Double = 0
    var navDir: CGFloat = 0
    var stuckRef = CGPoint.zero
    var stuckT: Double = 0
    var strikes = 0
    var flipTimes: [Double] = []
    var face = true
    var angle: CGFloat = 0
    var targetAngle: CGFloat = 0
    var squash: CGFloat = 0
    var animT: Double = 0
    var curAnim: Anim = .idle
    var blinkT: Double = 0
    var nextBlink: Double = 3
    var t: Double = Double.random(in: 0...10)
    var particles: [Particle] = []
    var zT: Double = 0
    var dirtT: Double = 0
    var cornerT: Double = 0
    var dispC = P(-9999, -9999)
    var annoyT = rnd(40, 90)
    var hunger: Double = 0.3
    var energy: Double = 0.9
    var fun: Double = 0.7
    var health: Double = 1
    var sickNag: Double = 60
    var oldNag: Double = 120
    var dyingT: Double = -1
    var modAcc: Double = 0
    var hungerNag: Double = 90
    var carrying: Item?
    var muddyT: Double = 0
    var stepAcc: CGFloat = 0
    var pawFlip = false
    var homeT: Double = 0
    var exitT: Double = -1
    var hideSeek = false
    var dizzyOnLand = false
    var tags = 0
    var hoverT: Double = 0
    var hoverDone = false
    var laserCD: Double = 0
    var lookCD: Double = 0
    var dustT: Double = 0
    var lastHostId = -1
    var lastHostOrigin = CGPoint.zero
    var lastHostT: Double = 0
    var navPlan: (x: CGFloat, ladder: Int, left: Bool)?
    var badWin: [Int: Double] = [:]
    var stuckS: [(p: CGPoint, t: Double, moving: Bool)] = []
    var stuckSampleT: Double = 0
    /// běhá na pár centimetrech tam a zpátky → otočit se a jinudy
    func stuckCheck() -> Bool {
        guard E.now - stuckSampleT >= 0.4 else { return false }
        stuckSampleT = E.now
        var excluded = false
        if case .cursor? = goal { excluded = true }
        if case .build? = goal { excluded = true }
        let moving = !excluded && (act == .walk || act == .run) && oneShot == nil && cornerAnim == nil && prepT <= 0
        stuckS.append((pos, E.now, moving))
        stuckS.removeAll { E.now - $0.t > 7.5 }
        guard stuckS.count >= 16, E.now - stuckS[0].t > 6.5 else { return false }
        let mv = stuckS.filter { $0.moving }.count
        guard Double(mv) >= Double(stuckS.count) * 0.75 else { return false }
        let xs = stuckS.map { $0.p.x }, ys = stuckS.map { $0.p.y }
        guard xs.max()! - xs.min()! < 70, ys.max()! - ys.min()! < 70 else { return false }
        stuckS.removeAll()
        ev("stuck at \(host) e\(edge)")
        if case .window(let id) = host { badWin[id] = E.now + 25 }
        if goal != nil { endGoal() }
        navCD = 10
        if chance(0.5) { say(L.r(L.dontCare), dur: 1.8) }
        showEmote(.anger, 1.2)
        if case .window = host { fall(); return true }
        if host == .dock && abs(n.x) > 0.5 { letGo(nil); return true }
        // otočit a na 20 s zakázat směr, odkud se vracel
        markBlock(edge, d, dir)
        blockMarks = blockMarks.map { ($0.host, $0.edge, $0.d, $0.dir, $0.t + 12) }
        dir = -dir; lastDirT = E.now; updateFace()
        act = .walk; actT = rnd(4, 7)
        return true
    }
    func isBad(_ id: Int) -> Bool { (badWin[id] ?? -1e9) > E.now }
    /// cíl se nedaří: zapomenout ho na chvíli
    func giveUp(_ cd: Double = 6) {
        if let gw = goalWindow { badWin[gw] = E.now + 45 }
        endGoal(); navCD = cd
    }
    var grabOff = CGPoint.zero
    var pressed = false
    var dead = false
    let panel: OverlayPanel
    let view: PetView
    let speech = Speech()
    var ignoring = true
    var lastSig = 0
    var shown = false

    var body: CGPoint { pos + n * (S * aspect / 2) }
    var onFloor: Bool { phys == .surface && n.y > 0.5 }
    var free: Bool { !dead && tunnelStage == 0 && phys == .surface && goal == nil && oneShot == nil && act != .sleep && prepT <= 0 && carrying == nil }
    /// pozice tlamy (pro nošení věcí)
    var mouth: CGPoint {
        let loc = P(S * 0.42 * (face ? 1 : -1), -S * aspect * 0.12)
        let ca = cos(angle), sa = sin(angle)
        return body + P(loc.x * ca - loc.y * sa, loc.x * sa + loc.y * ca)
    }

    init(_ idx: Int, baby: Bool = false) {
        self.idx = idx
        isBaby = baby
        panel = makePanel(NSSize(width: Pet.box, height: Pet.box), level: 2)
        view = PetView(frame: NSRect(x: 0, y: 0, width: Pet.box, height: Pet.box))
        panel.contentView = view
        view.pet = self
        if let a = UserDefaults.standard.array(forKey: "needs\(idx)") as? [Double], a.count >= 3 { hunger = a[0]; energy = a[1]; fun = a[2]; if a.count >= 4 { health = a[3] } }
    }

    func saveNeeds() { if !dead { UserDefaults.standard.set([hunger, energy, fun, health], forKey: "needs\(idx)") } }

    func destroy() {
        dead = true
        panel.orderOut(nil); speech.hide(); view.pet = nil
        if let c = carrying { c.carrier = nil; c.dead = true }
    }

    // MARK: update

    func update(_ dt: Double, _ m: CGPoint) {
        t += dt; poopT -= dt; jumpCD -= dt; navCD -= dt; cornerT -= dt; muddyT -= dt; laserCD -= dt; lookCD -= dt
        let fdt = CGFloat(dt)
        hunger = min(1, hunger + dt / 2400)
        if phys == .home { energy = min(1, energy + dt / 200) }
        else if act == .sleep { energy = min(1, energy + dt / 400) }
        else { energy = max(0, energy - dt / 3200 * (E.isNight ? 3 : 1)) }
        fun = max(0, fun - dt / 1500)
        lifeUpdate(dt)
        if dyingT >= 0 { dyingStep(dt); if dead { return }; if oneShot == nil { act = .idle } }

        switch phys {
        case .surface: surfaceStep(dt, m)
        case .air: airStep(fdt)
        case .dragged: dragStep(fdt, m)
        case .home: homeStep(dt)
        case .hidden: if tunnelStage == 2 { undergroundStep(dt) }
        }

        for i in particles.indices {
            particles[i].age += fdt
            if particles[i].age > 0 {
                particles[i].p = particles[i].p + particles[i].v * fdt
                if particles[i].kind == "dirt" || particles[i].kind == "spray" || particles[i].kind == "vomit" { particles[i].v.y -= 260 * fdt }
                if particles[i].kind == "bee" {
                    let q = particles[i].p - P(0, 6)
                    particles[i].v = particles[i].v + (P(rndf(-260, 260), rndf(-260, 260)) - q * 4) * fdt
                }
            }
        }
        particles.removeAll { $0.age > $0.life }
        if act == .sleep && phys == .surface {
            zT -= dt
            if zT <= 0 { zT = 1.5; particles.append(Particle(p: P(S * 0.15, S * 0.2), v: P(10, 18), age: 0, life: 2.4, kind: "z")) }
        }
        if oneShot == .dig && phys == .surface {
            dirtT -= dt
            if dirtT <= 0 {
                dirtT = 0.07
                let back: CGFloat = face ? -1 : 1
                particles.append(Particle(p: P(back * S * 0.1, -S * 0.25), v: P(back * rndf(60, 120), rndf(60, 140)), age: 0, life: 0.6, kind: "dirt"))
            }
        }
        if phys == .surface && n.y > 0.5 && act == .run && oneShot == nil {
            dustT -= dt
            if dustT <= 0 {
                dustT = 0.14
                let back: CGFloat = face ? -1 : 1
                particles.append(Particle(p: P(back * S * 0.3, -S * aspect / 2 + 3), v: P(back * rndf(10, 30), rndf(8, 22)), age: 0, life: 0.45, kind: "dust"))
            }
        }
        // najetí myší: chvilka zpoždění, ať nechytá kliknutí při rychlém přejetí
        let hb = dispC.x > -9000 ? dispC : body
        if (phys == .surface || phys == .air) && (m - hb).len < 26 * E.petScale { hoverT += dt } else { hoverT = 0; hoverDone = false }
        if hoverT > 0.9 && !hoverDone && phys == .surface && goal == nil && act != .sleep && oneShot == nil {
            hoverDone = true
            faceToward(m.x)
            play(.sniffair, 1.4)
            if chance(0.5) { showEmote(chance(0.6) ? .heart : .question, 1.6) }
        }
        if emoteT > 0 { emoteT -= dt; if emoteT <= 0 { emote = nil } }
        squash = max(0, squash - fdt * 2.2)
        let an = currentAnim()
        if an != curAnim { curAnim = an; animT = 0 }
        animT += dt * Badger.fps(an)
        nextBlink -= dt
        if nextBlink <= 0 { blinkT = 0.14; nextBlink = rnd(2, 6) }
        if blinkT > 0 { blinkT -= dt }
        if phys != .surface { targetAngle = 0 }
        angle += wrapAngle(targetAngle - angle) * min(1, fdt * 12)
        if let ca = cornerAnim, phys == .surface {
            let k0 = CGFloat(min(1, ca.t / ca.dur))
            func sm(_ x: CGFloat) -> CGFloat { let c = clamp(x, 0, 1); return c * c * (3 - 2 * c) }
            var k: CGFloat
            if cornerConvex {
                // nakloní se přes hranu, přehoupne se obloukem, chytne se
                if k0 < 0.35 { k = 0.22 * sm(k0 / 0.35); cornerPose = .sniff; cornerBulge = 0 }
                else if k0 < 0.82 { let kb = (k0 - 0.35) / 0.47; k = 0.22 + 0.78 * sm(kb); cornerPose = .jump; cornerBulge = sin(kb * .pi) * 14 }
                else { k = 1; cornerPose = .crouch; cornerBulge = 0 }
            } else {
                // postaví se na zadní, opře se tlapkami a vyšplhá
                if k0 < 0.35 { k = 0; cornerPose = .stand; cornerBulge = 0 }
                else if k0 < 0.85 { k = sm((k0 - 0.35) / 0.5); cornerPose = .stretch; cornerBulge = 0 }
                else { k = 1; cornerPose = .crouch; cornerBulge = 0 }
            }
            let a0 = atan2(ca.from.y, ca.from.x), a1 = atan2(ca.to.y, ca.to.x)
            let a = a0 + wrapAngle(a1 - a0) * k
            cornerN = P(cos(a), sin(a))
            angle = a - .pi / 2; targetAngle = atan2(ca.to.y, ca.to.x) - .pi / 2
        }
        speech.update(dt)
    }

    func currentAnim() -> Anim {
        switch phys {
        case .air: return vel.len > 1400 ? .tumble : (vel.y > 120 ? .jump : .fall)
        case .dragged: return .drag
        case .home, .hidden: return .idle
        case .surface:
            if cornerAnim != nil { return cornerPose }
            if prepT > 0 { return .crouch }
            if let o = oneShot { return o }
            switch act {
            case .walk: return .walk
            case .run: return .run
            case .sleep: return sleepFlat ? .sleep2 : .sleep
            case .idle: return .idle
            }
        }
    }

    /// hrana, po které právě leze (včetně opřené větve)
    func edgeNow() -> Edge? {
        if case .prop(let id) = host {
            guard let pr = E.props[id], pr.ready else { return nil }
            return Edge(start: pr.base, dir: pr.dirV, len: pr.len, n: pr.normal)
        }
        guard let g = W.geom(host) else { return nil }
        return edgeOf(g.rect, inner: g.inner, edge)
    }

    @discardableResult func resolve() -> Bool {
        guard let e = edgeNow() else { return false }
        d = clamp(d, 0, e.len)
        pos = e.start + e.dir * d
        n = e.n
        return true
    }

    func currentEdge() -> Edge? { edgeNow() }

    func setDir(_ nd: CGFloat, force: Bool = false) {
        if towardBlock(nd) {
            // tam už narazil: cíl tudy nevede, radši zastavit než kmitat
            if goal != nil { endGoal(); navCD = 2 } else if act == .walk || act == .run { act = .idle; actT = rnd(0.8, 1.6) }
            return
        }
        if nd == dir { return }
        if !force && E.now - lastDirT < 0.4 { return }
        dir = nd; lastDirT = E.now
        updateFace()
    }
    func updateFace() {
        guard let e = currentEdge() else { return }
        face = (e.dir * dir).dot(P(n.y, -n.x)) > 0
    }
    func faceToward(_ x: CGFloat) { if onFloor { face = x > pos.x } }

    func play(_ a: Anim, _ dur: Double) {
        oneShot = a; oneShotT = dur; act = .idle; animT = 0
        // mládě napodobuje rodiče
        if !isBaby, ![Anim.dig, .eat, .growl, .crouch].contains(a),
           let b = E.pets.first(where: { $0.isBaby && $0.parent === self }), b.free, b.onFloor, (b.body - body).len < 220 {
            E.later(rnd(0.4, 0.8)) { if b.free { b.play(a, dur) } }
        }
        if a == .sneeze {
            E.later(0.65) { [weak self] in
                guard let s = self, s.oneShot == .sneeze else { return }
                let f: CGFloat = s.face ? 1 : -1
                for _ in 0..<7 { s.particles.append(Particle(p: P(f * s.S * 0.45, -s.S * 0.05), v: P(f * rndf(60, 150), rndf(-20, 60)), age: 0, life: 0.5, kind: "spray")) }
            }
        }
    }
    func showEmote(_ e: Emote, _ dur: Double = 2.2) { emote = e; emoteT = dur }

    // MARK: surface

    func blockedHere() -> Bool {
        if case .prop = host { return false }
        let b = pos + n * 12
        if !W.scrs.contains(where: { $0.frame.insetBy(dx: -1, dy: -1).contains(b) }) { return true }
        if case .window(let id) = host, let w = W.byId[id] {
            if W.covered(pos + n * 8, frontOf: w.z) { return true }
            if edge == 0 && !W.topUsable(w) { return true }   // horní hrana v menu baru: tam ne
        }
        if case .screen = host, edge == 2 { return true }       // strop pod menu barem: tam ne
        if case .screen(let si) = host, si < W.scrs.count {     // stěna za bočním Dockem: tam ne
            let sc = W.scrs[si]
            if edge == 3 && sc.visible.minX > sc.frame.minX + 1 { return true }
            if edge == 1 && sc.visible.maxX < sc.frame.maxX - 1 { return true }
        }
        return false
    }

    func surfaceStep(_ dt: Double, _ m: CGPoint) {
        guard resolve() else {
            if case .window = host, chance(0.5) { say(L.r(L.windowGone), dur: 1.4) }
            lastHostId = -1
            fall(); return
        }
        if case .screen = host, edge == 2 { fall(); return }
        if stuckCheck() { return }
        // pod Dockem se zůstat nedá: vyskočit na něj
        if case .screen = host, edge == 0, prepT <= 0, let dk = W.dock, dk.minY <= pos.y + 2, pos.x > dk.minX + 4, pos.x < dk.maxX - 4,
           !E.homeOn || abs(pos.x - E.home.x) > 45 {
            launch(P(pos.x, dk.maxY)); return
        }
        if carryStick { if case .build? = goal {} else { carryStick = false } }
        if let c = carrying {
            if c.dead { carrying = nil }
            else if case .deliver? = goal {} else { dropCarried() }
        }
        // okno se hýbe: pomalu se veze, při prudkém trhnutí spadne
        if case .window(let id) = host, let w = W.byId[id] {
            if id != lastHostId { lastHostId = id; lastHostOrigin = w.rect.origin; lastHostT = E.now }
            else if w.rect.origin != lastHostOrigin {
                let dtw = max(1.0 / 60, E.now - lastHostT)
                let v = (w.rect.origin - lastHostOrigin) * CGFloat(1 / dtw)
                lastHostOrigin = w.rect.origin; lastHostT = E.now
                if v.len > 1700 && prepT <= 0 && phys == .surface { shakeOff(v); return }
                if v.len > 500 && emote == nil && chance(0.1) { showEmote(.sweat, 1.2) }
            }
        } else { lastHostId = -1 }
        if var ca = cornerAnim {
            ca.t += dt
            cornerAnim = ca.t >= ca.dur ? nil : ca
            return
        }
        if tunnelStage == 1 {
            tunnelT -= dt
            sink = clamp(CGFloat((1.0 - tunnelT) / 0.7), 0, 1)
            if tunnelT <= 0 { goUnderground() }
            return
        }
        if tunnelStage == 3 {
            tunnelT -= dt
            sink = clamp(CGFloat(tunnelT / 0.7), 0, 1)
            if tunnelT <= 0 { tunnelStage = 0; sink = 0; play(.shake, 1.0); say(L.r(L.tunnelOut), dur: 2); Life.add(idx, "tunnels"); Life.addXP(3) }
            return
        }
        if prepT > 0 {
            prepT -= dt
            if prepT <= 0 { launch(pendingJump) }
            return
        }
        if case .window(let id) = host, let w = W.byId[id], let cov = W.coveringWindow(pos + n * 8, frontOf: w.z) {
            // okno přetažené přes nás: vyškrábe se nahoru, nebo spadne
            if edge == 0 && cov.rect.maxY - pos.y < 90 && pos.x > cov.rect.minX + 8 && pos.x < cov.rect.maxX - 8 {
                launch(P(pos.x, cov.rect.maxY))
            } else { fall() }
            return
        }
        targetAngle = atan2(n.y, n.x) - .pi / 2

        if let o = oneShot {
            oneShotT -= dt
            if oneShotT <= 0 { oneShot = nil; if o == .dig { muddyT = 25 } }
            if oneShot != nil { return }
        }
        if E.userIdle {
            if case .home? = goal {} else { goal = .home(E.now + 120); act = .idle }
        }
        annoyT -= dt
        if annoyT <= 0 {
            annoyT = (E.annoy >= 2 ? rnd(25, 60) : rnd(70, 160)) * (fun < 0.3 ? 0.6 : 1)
            if E.annoy > 0 && free && navCD <= 0 && !E.userIdle { goal = .cursor(E.now + 20); if chance(0.3) { showEmote(.bang, 1.5) } }
        }
        hungerNag -= dt
        if hunger > 0.7 && hungerNag <= 0 && !E.userIdle {
            hungerNag = rnd(70, 140)
            showEmote(.honey, 3)
            say(L.r(L.hunger), dur: 2.6)
        }

        if goal == nil && oneShot == nil && act == .idle && onFloor && lookCD <= 0 {
            lookCD = 0.5
            if abs(m.x - pos.x) > 24 && (m - body).len < 380 { face = m.x > pos.x }
        }
        if case .prop(let id) = host, let pr = E.props[id], goal != nil {
            let up: CGFloat = goalWindow == pr.winId || climbFor == pr.winId ? 1 : -1
            if dir != up { setDir(up, force: true) }
            act = .run
        } else if let g = goal {
            pursue(g, m)
            if goal != nil, phys == .surface, act == .idle, let b = blockMark, E.now - b.t < 3, E.now - b.t > 1.2, b.host == host {
                endGoal(); navCD = 2
            }
            if goal != nil && phys == .surface {
                stuckT += dt
                if stuckT > 5 {
                    if (pos - stuckRef).len < 20 && prepT <= 0 { strikes += 1; if strikes >= 2 { giveUp(10) } } else { strikes = 0 }
                    stuckT = 0; stuckRef = pos
                }
            }
        } else {
            actT -= dt
            if actT <= 0 { decide() }
        }
        if phys != .surface || prepT > 0 || oneShot != nil { return }
        let sp = (act == .run ? speed * (goal != nil ? 2.9 : 2.3) : speed) * (n.y > 0.5 ? 1 : 0.75)
        if act == .walk || act == .run { moveAlong(sp * CGFloat(dt)) }
    }

    func moveAlong(_ delta: CGFloat) {
        if case .prop(let id) = host {
            guard let pr = E.props[id], let e = edgeNow() else { fall(); return }
            d += delta * dir
            if d >= e.len {
                // nahoře na větvi: přelézt na bok okna a dál nahoru
                guard let w = W.byId[pr.winId] else { fall(); return }
                host = .window(w.id)
                if pr.left { edge = 3; d = clamp(pr.top.y - w.rect.minY, 0, w.rect.height); setDir(1, force: true) }
                else { edge = 1; d = clamp(w.rect.maxY - pr.top.y, 0, w.rect.height); setDir(-1, force: true) }
                resolve(); updateFace(); cornerT = 0.3; climbFor = -1
            } else if d <= 0 {
                host = pr.baseHost; edge = 0
                if let g = W.geom(pr.baseHost) { d = pr.base.x - edgeOf(g.rect, inner: g.inner, 0).start.x }
                resolve(); updateFace(); cornerT = 0.2; climbFor = -1
            } else { resolve() }
            return
        }
        guard let g = W.geom(host) else { return }
        let oldPos = pos
        let oldMotion = edgeOf(g.rect, inner: g.inner, edge).dir * dir
        let wasBlocked = blockedHere()
        let se = edge, sd = d
        d += delta * dir
        for _ in 0..<5 {
            let e = edgeOf(g.rect, inner: g.inner, edge)
            if d > e.len { d -= e.len; edge = (edge + 1) & 3 }
            else if d < 0 { edge = (edge + 3) & 3; d += edgeOf(g.rect, inner: g.inner, edge).len }
            else { break }
        }
        resolve()
        if host == .dock, abs(n.x) > 0.5, let dk = W.dock {
            let si = W.screenIndex(P(pos.x, dk.minY))
            if pos.y <= W.floorY(si) + 10, (oldPos.y - pos.y) > 0 {
                let f = W.scrs[si].frame
                host = .screen(si); edge = 0; d = clamp(pos.x + n.x * 16 - f.minX, 0, f.width)
                dir = n.x > 0 ? 1 : -1; lastDirT = E.now
                resolve(); updateFace(); cornerT = 0.25
                return
            }
        }
        if case .screen = host, let dk = W.dock, dk.insetBy(dx: -8, dy: -8).contains(pos + n * 12) {
            // narazil na Dock -> leze po něm
            let mv = (currentEdge()?.dir ?? P(0, 1)) * dir
            attach(to: .dock, motion: mv)
            return
        }
        if !wasBlocked && blockedHere() {
            // nahoře na vysokém okně (horní hrana v menu baru): otočit se jednou, cíl tudy nevede
            if case .window(let id) = host, edge == 0, let w = W.byId[id], !W.topUsable(w) {
                edge = se; d = sd; resolve()
                if goal != nil { badWin[id] = E.now + 90; giveUp(8) }
                setDir(-dir, force: true)
                act = .walk; actT = rnd(2, 5)
                return
            }
            // vrazil do okna, které stojí před tím jeho: vyleze na něj
            if E.now > noTransferUntil, case .window(let id) = host, let w = W.byId[id], let cov = W.coveringWindow(pos + n * 8, frontOf: w.z) {
                attach(to: .window(cov.id), motion: oldMotion)
                if case .window(let nid) = host, nid == cov.id { return }
            }
            edge = se; d = sd; resolve()
            flipTimes.append(E.now)
            flipTimes = flipTimes.filter { E.now - $0 < 2 }
            if flipTimes.count >= 3 {
                flipTimes = []
                act = .idle; actT = rnd(1, 2)
                if goal != nil { giveUp() }
            } else {
                // zablokovaný z obou stran (roh u kraje obrazovky / zakryté okno): utéct
                if let b = blockMark, E.now - b.t < 3, b.host == host, b.edge == se, b.dir == -dir, abs(b.d - sd) < 60 {
                    blockMark = nil
                    if let lp = nearbyWallLeap() { startLeap(lp.0, lp.1, left: lp.2); return }
                    if jumpCD <= 0, let hop = nearbyHop() { jump(to: hop); return }
                    if case .screen = host { act = .idle; actT = 2; return }
                    ev("escape corner"); letGo(nil); return
                }
                markBlock(se, sd, dir)
                setDir(-dir, force: true)
                navDir = -navDir
                if goal != nil { act = .idle; actT = 0.6 }
            }
            return
        }
        if edge != se {
            // zastavit na rohu a přehoupnout se – ale jen když je za rohem volno
            let oldN = n
            if let e = currentEdge() { d = dir > 0 ? 0 : e.len }
            resolve()
            if let e = currentEdge() {
                let ahead = pos + e.dir * (dir * 18) + e.n * 12
                var bad = !W.scrs.contains { $0.frame.insetBy(dx: -1, dy: -1).contains(ahead) }
                if case .window(let id) = host, let w = W.byId[id] {
                    if W.covered(ahead, frontOf: w.z) { bad = true }
                    if edge == 0 && !W.topUsable(w) { bad = true }
                }
                if case .screen = host, edge == 2 { bad = true }
                if bad {
                    edge = se; d = sd; resolve()
                    markBlock(se, sd, dir)
                    setDir(-dir, force: true)
                    if goal != nil { act = .idle; actT = 0.6 }
                    return
                }
            }
            if (oldN - n).len > 0.1 {
                // vnější roh (přes hranu dolů) = přehoupnutí, vnitřní (ze země na stěnu) = vyšplhání
                cornerConvex = n.dot(oldMotion) > 0.5
                cornerAnim = (oldN, n, 0, cornerConvex ? 0.85 : 0.75)
                cornerN = oldN
            }
            updateFace()
            return
        }
        // křížení s hranou jiného okna: při cestě na cíl přeleze, při toulání občas
        if E.now > noTransferUntil, let j = junction(oldPos, pos) {
            if j.id == goalWindow || (goal == nil && chance(0.25)) {
                attach(to: .window(j.id), motion: oldMotion)
                return
            }
        }
        // po boku okna dolů a tady je opřený žebřík: slézt po něm
        if case .window(let wid) = host, abs(n.x) > 0.5, (oldPos.y - pos.y) > 0 {
            for pr in E.props.values where pr.winId == wid && pr.ready && pr.left == (edge == 3) {
                if (oldPos.y - pr.top.y) * (pos.y - pr.top.y) <= 0 && (goal != nil || chance(0.6)) {
                    ev("mount top \(pr.id)")
                    host = .prop(pr.id); edge = 0; d = max(0, pr.len - 3); dir = -1; lastDirT = E.now; climbFor = -1
                    resolve(); updateFace(); cornerT = 0.3
                    return
                }
            }
        }
        if muddyT > 0 && n.y > 0.5 {
            stepAcc += abs(delta)
            if stepAcc > 14 { stepAcc = 0; pawFlip.toggle(); E.decals.add(kind: 0, host: host, x: pos.x + (face ? -6 : 6), flip: pawFlip) }
        }
    }

    func crossToward(_ tsi: Int) {
        if case .screen(let si) = host, edge == 0 {
            let f = W.scrs[si].frame, tf = W.scrs[tsi].frame
            let goRight = tf.midX > f.midX
            setDir(goRight ? 1 : -1); act = .run
            if (goRight && pos.x > f.maxX - 30) || (!goRight && pos.x < f.minX + 30) {
                host = .screen(tsi); edge = 0
                d = goRight ? 20 : tf.width - 20
                resolve(); dispC = body; updateFace()
            }
        } else { descend() }
    }

    /// Okno s horní hranou v menu baru: dostat se na jeho bok
    /// (ze země, když okno sahá dolů, jinak po stropě pod menu barem a slézt po boku).
    func navigateToSide(_ w: Win) {
        if prepT > 0 { return }
        let sides = [true, false].filter { left -> Bool in
            let probe = P(left ? w.rect.minX - 6 : w.rect.maxX + 6, w.rect.maxY - 60)
            return !W.covered(probe, frontOf: w.z) && W.onScreen(probe)
        }
        guard !sides.isEmpty else { endGoal(); navCD = 8; return }
        let left = sides.count == 1 ? sides[0] : abs(pos.x - w.rect.minX) < abs(pos.x - w.rect.maxX)
        let sx = left ? w.rect.minX - 2 : w.rect.maxX + 2
        let tsi = W.screenIndex(P(sx, w.rect.maxY - 20))
        if tsi != W.screenIndex(body) { crossToward(tsi); return }
        if n.y > 0.5, let gl = grabSide(w) {
            let gx = gl ? w.rect.minX - 2 : w.rect.maxX + 2
            if abs(pos.x - gx) < 9 { grab(w, left: gl) } else { walkToward(gx); act = abs(pos.x - gx) > 90 ? .run : .walk }
            return
        }
        ladderTo(w)
    }

    /// okno, ke kterému aktuální cíl vede
    var goalWindow: Int? {
        switch goal {
        case .window(let id, _)?, .deliver(let id, _)?, .build(let id, _)?: return id
        case .meet(let o, _, _)?, .chase(let o, _)?, .follow(let o, _)?:
            if case .window(let id) = o.host { return id }
            return nil
        case .treat(let it)?:
            if case .window(let id) = it.host { return id }
            return nil
        default: return nil
        }
    }

    /// protnul pohyb a→b hranu jiného (viditelného) okna?
    func junction(_ a: CGPoint, _ b: CGPoint) -> Win? {
        if case .screen = host { return nil }
        let vertical = abs(a.x - b.x) < 0.5
        if vertical && abs(a.y - b.y) < 0.01 { return nil }
        for w in W.wins.prefix(12) where host != .window(w.id) && !isBad(w.id) {
            if vertical {
                let x = a.x
                guard x > w.rect.minX + 4 && x < w.rect.maxX - 4 else { continue }
                for (y, nn) in [(w.rect.maxY, CGFloat(1)), (w.rect.minY, CGFloat(-1))] where (a.y - y) * (b.y - y) <= 0 {
                    if nn > 0 && !W.topUsable(w) { continue }
                    if W.covered(P(x, y + nn * 8), frontOf: w.z) || !W.onScreen(P(x, y + nn * 12)) { continue }
                    return w
                }
            } else {
                let y = a.y
                guard y > w.rect.minY + 4 && y < w.rect.maxY - 4 else { continue }
                for (x, nn) in [(w.rect.minX, CGFloat(-1)), (w.rect.maxX, CGFloat(1))] where (a.x - x) * (b.x - x) <= 0 && abs(a.x - b.x) > 0.01 {
                    if W.covered(P(x + nn * 8, y), frontOf: w.z) || !W.onScreen(P(x + nn * 12, y)) { continue }
                    return w
                }
            }
        }
        return nil
    }

    /// Cíl je výš a nejde se ho chytit ze země: najít „žebřík" – okno sahající k zemi, jehož bok
    /// vede přes spodní hranu cíle. Po něm vylézt a na křížení přelézt (nebo vrazit do cíle a vylézt na něj).
    func ladderTo(_ t: Win) {
        if case .window(let id) = host, id != t.id {
            if abs(n.x) > 0.5 { goUp(); act = .run; return }
            if n.y < -0.5, let e = currentEdge() {
                // spodní hrana okna v cestě: přelézt k rohu blíž k cíli a po boku nahoru
                let a = e.start.x, b = e.start.x + e.dir.x * e.len
                walkToward(abs(t.rect.midX - a) < abs(t.rect.midX - b) ? a - 50 : b + 50); act = .run
                return
            }
        }
        guard n.y > 0.5, edge == 0 else { descend(); return }
        // opřená větev k cíli už stojí: dojít k ní a vylézt
        if let pr = E.props.values.first(where: { $0.winId == t.id && !$0.falling && !$0.dead }) {
            if navigate(pr.baseHost, pr.base.x) && pr.ready { mount(pr) }
            return
        }
        var windowGoal = false
        if case .window? = goal { windowGoal = true }
        if navPlan == nil {
            // občas si radši postaví vlastní (i když by šlo jinak)
            if windowGoal && chance([0.0, 0.15, 0.3, 0.6][max(0, min(3, E.buildLevel))]) && startBuild(t) { return }
            var best: (x: CGFloat, ladder: Int, left: Bool, cost: CGFloat)?
            for w in W.wins.prefix(14) where w.id != t.id && !isBad(w.id) {
                guard let left = grabSide(w) else { continue }
                let sx = left ? w.rect.minX - 2 : w.rect.maxX + 2
                guard sx > t.rect.minX + 6 && sx < t.rect.maxX - 6 && w.rect.maxY > t.rect.minY + 10 else { continue }
                let c = abs(pos.x - sx)
                if best == nil || c < best!.cost { best = (sx, w.id, left, c) }
            }
            guard let b = best else {
                if windowGoal && W.topUsable(t) && !isBaby && chance(0.5), let x = W.visibleTopX(t, near: t.rect.midX), startTunnel(to: (.window(t.id), x)) { return }
                if !(windowGoal && E.buildLevel > 0 && startBuild(t)) { giveUp(8) }
                return
            }
            navPlan = (b.x, b.ladder, b.left)
        }
        guard let plan = navPlan else { return }
        guard let w = W.byId[plan.ladder] else { navPlan = nil; return }
        if abs(pos.x - plan.x) < 9 { grab(w, left: plan.left) } else { walkToward(plan.x); act = .run }
    }

    // MARK: tunely

    /// prohrabat se na jiné okno (nebo na zem). Vrací false, když není kam.
    @discardableResult func startTunnel(to target: (host: Host, x: CGFloat)? = nil) -> Bool {
        guard onFloor, tunnelStage == 0, carrying == nil, !carryStick else { return false }
        var tgt = target
        if tgt == nil {
            var c: [(host: Host, x: CGFloat)] = []
            for w in W.wins.prefix(10) where W.topUsable(w) && host != .window(w.id) && w.rect.width > 200 {
                if let x = W.visibleTopX(w, near: rndf(w.rect.minX + 40, w.rect.maxX - 40)) { c.append((.window(w.id), x)) }
            }
            if let aw = W.active, W.topUsable(aw), host != .window(aw.id), let x = W.visibleTopX(aw, near: aw.rect.midX) { c += [(.window(aw.id), x), (.window(aw.id), x)] }
            for (i, sc) in W.scrs.enumerated() where host != .screen(i) || chance(0.5) {
                c.append((.screen(i), rndf(sc.visible.minX + 80, sc.visible.maxX - 80)))
            }
            tgt = c.filter { abs($0.x - pos.x) > 200 || $0.host != host }.randomElement()
        }
        guard let t = tgt else { return false }
        tunnelTo = t
        tunnelStage = 1; tunnelT = 1.7
        goal = nil
        play(.dig, 1.0)
        muddyT = 0
        E.decals.add(kind: 2, host: host, x: pos.x, flip: false)
        if chance(0.6) { say(L.r(L.tunnelIn), dur: 1.8) }
        // mládě jde za rodičem
        if !isBaby, let b = E.pets.first(where: { $0.isBaby && $0.parent === self }), b.free, b.onFloor, (b.body - body).len < 250 {
            E.later(0.9) { b.say("Počkej na mě!", dur: 1.4); _ = b.startTunnel(to: (t.host, t.x + 40)) }
        }
        return true
    }

    func goUnderground() {
        tunnelStage = 2; tunnelT = rnd(1.4, 3.2); sink = 1
        phys = .hidden
        panel.orderOut(nil); speech.hide(); shown = false
    }

    func undergroundStep(_ dt: Double) {
        tunnelT -= dt
        guard tunnelT <= 0 else { return }
        var t = tunnelTo ?? (.screen(0), W.scrs[0].frame.midX)
        // cílové okno mezitím zmizelo nebo ho něco zakrylo: vylézt na zemi
        if case .window(let id) = t.host, W.byId[id] == nil || !landable(t.host, t.x) {
            let si = W.screenIndex(pos)
            t = (.screen(si), clamp(pos.x, W.scrs[si].visible.minX + 60, W.scrs[si].visible.maxX - 60))
        }
        guard let g = W.geom(t.host) else { phys = .air; tunnelStage = 0; sink = 0; return }
        let e = edgeOf(g.rect, inner: g.inner, 0)
        host = t.host; edge = 0; d = clamp(t.x - e.start.x, 10, e.len - 10)
        phys = .surface; resolve(); updateFace(); dispC = body
        tunnelStage = 3; tunnelT = 0.8; sink = 1
        E.decals.add(kind: 2, host: host, x: pos.x, flip: false)
        for i in 0..<10 {
            let sx: CGFloat = i % 2 == 0 ? 1 : -1
            particles.append(Particle(p: P(sx * rndf(4, 20), -S * aspect / 2 + 4), v: P(sx * rndf(40, 110), rndf(70, 150)), age: -CGFloat(i) * 0.03, life: 0.7, kind: "dirt"))
        }
        play(.sniffair, 1.0)
        if !E.hidden { panel.orderFrontRegardless(); shown = true }
    }

    // MARK: stavění

    var buildP: BuildPlan?
    var buildStage = 0
    var buildSpot: CGFloat = 0
    var carryStick = false

    func mount(_ pr: Prop) {
        ev("mount prop \(pr.id)")
        climbFor = pr.winId
        host = .prop(pr.id); edge = 0; d = 2; dir = 1; lastDirT = E.now
        resolve(); updateFace(); cornerT = 0.25; act = .run; navPlan = nil
    }

    /// naplánovat stavbu opřené větve/žebříku k oknu t
    func startBuild(_ t: Win) -> Bool {
        if isBaby { return false }
        guard E.props.count < 6, !E.props.values.contains(where: { $0.winId == t.id }) else { return false }
        for left in [true, false].shuffled() {
            let sideX = left ? t.rect.minX : t.rect.maxX
            let probe = P(left ? sideX - 6 : sideX + 6, t.rect.minY + 30)
            if W.covered(probe, frontOf: t.z) || !W.onScreen(probe) { continue }
            let bx = sideX + (left ? -1 : 1) * rndf(70, 110)
            guard W.onScreen(P(bx, t.rect.minY)) else { continue }
            let sf = W.scrs[W.screenIndex(P(bx, t.rect.minY))]
            if bx < sf.visible.minX + 40 || bx > sf.visible.maxX - 40 { continue }
            if let dk = W.dock, dk.insetBy(dx: -30, dy: -30).contains(P(bx, dk.midY)) && dk.minY < t.rect.minY { continue }
            if abs(bx - E.home.x) < 70 { continue }
            let fls = W.floors(at: bx)
            // lávka nahoře: z horní hrany sousedního okna na vršek cíle
            let high = W.topUsable(t) ? fls.filter { $0.1 > t.rect.maxY - 220 && $0.1 < t.rect.maxY - 8 }.max(by: { $0.1 < $1.1 }) : nil
            let plank = high != nil && chance(0.6)
            guard let fl = plank ? high : fls.filter({ $0.1 < t.rect.minY + 120 }).max(by: { $0.1 < $1.1 }),
                  let g = W.geom(fl.0) else { continue }
            let leanY = plank ? t.rect.maxY - 3 : clamp(fl.1 + rndf(150, 220), t.rect.minY + 40, t.rect.maxY - 30)
            let h = leanY - fl.1
            guard (plank && h >= 4 && h <= 230) || (h >= 50 && h <= 260) else { continue }
            let e = edgeOf(g.rect, inner: g.inner, 0)
            let spot = clamp(bx + (chance(0.5) ? 1 : -1) * rndf(140, 340), e.start.x + 30, e.start.x + e.len - 30)
            buildP = BuildPlan(win: t.id, left: left, baseHost: fl.0, base: P(bx, fl.1), leanOffY: leanY - t.rect.minY,
                               kind: PropKind(rawValue: Int.random(in: 0...2)) ?? .branch)
            buildSpot = spot; buildStage = 0
            goal = .build(t.id, E.now + 100)
            if chance(0.6) { say(L.r(L.searchStick), dur: 2.4) }
            ev("build plan \(t.id)")
            return true
        }
        return false
    }

    /// sousední okno blízko boku, na které jde přeskočit
    func nearbyWallLeap() -> (Win, CGPoint, Bool)? {
        guard case .window(let hid) = host, abs(n.x) > 0.5 else { return nil }
        let out: CGFloat = n.x > 0 ? 1 : -1
        var best: (Win, CGPoint, Bool, CGFloat)?
        for w in W.wins.prefix(12) where w.id != hid && !isBad(w.id) {
            let left = out > 0          // skáčeme doprava → chytá se levého boku
            let sx = left ? w.rect.minX : w.rect.maxX
            let gap = (sx - pos.x) * out
            guard gap > 30 && gap < 190 else { continue }
            let y = clamp(pos.y + rndf(-40, 60), w.rect.minY + 20, w.rect.maxY - 30)
            guard abs(y - pos.y) < 130 else { continue }
            let probe = P(sx + (left ? -8 : 8), y)
            if W.covered(probe, frontOf: w.z) || !W.onScreen(probe) { continue }
            if best == nil || gap < best!.3 { best = (w, P(left ? sx - 1 : sx + 1, y), left, gap) }
        }
        return best.map { ($0.0, $0.1, $0.2) }
    }

    func startLeap(_ w: Win, _ to: CGPoint, left: Bool) {
        leap = (pos, to, w.id, left, 0, 0.5)
        phys = .air; vel = .zero; landMaxY = nil
        face = to.x > pos.x
        if chance(0.4) { say(L.r(L.leap), dur: 1.2) }
    }

    /// malý skok na blízké okno (ne na místě, ne vysoko)
    func nearbyHop() -> CGPoint? {
        var c: [CGPoint] = []
        for w in W.wins.prefix(12) where W.topUsable(w) && host != .window(w.id) {
            let lo = max(w.rect.minX + 16, pos.x - 320), hi = min(w.rect.maxX - 16, pos.x + 320)
            guard lo < hi else { continue }
            let dy = w.rect.maxY - pos.y
            guard dy <= 90 && dy >= -400 else { continue }
            let x = rndf(lo, hi)
            if abs(x - pos.x) < 50 { continue }
            if landable(.window(w.id), x) { c.append(P(x, w.rect.maxY)) }
        }
        return c.randomElement()
    }

    func heightAboveFloor() -> CGFloat {
        let x = pos.x + n.x * 30
        let below = W.floors(at: x).map { $0.1 }.filter { $0 < pos.y - 4 }.max() ?? W.scrs[W.screenIndex(pos)].frame.minY
        return pos.y - below
    }

    /// slézt níž: po podlaze ke kraji, po stěně dolů, nízko se pustit
    func descend() {
        if n.y > 0.5, let g = W.geom(host) {
            let e = edgeOf(g.rect, inner: g.inner, 0)
            walkToward(pos.x < e.start.x + e.len / 2 ? e.start.x - 50 : e.start.x + e.len + 50); act = .run
        } else if heightAboveFloor() < 180 {
            letGo(nil)
        } else if abs(n.x) > 0.5 {
            goDown(); act = .run
        } else if case .screen = host, let e = currentEdge() {
            let a = e.start.x, b = e.start.x + e.dir.x * e.len
            walkToward(abs(pos.x - a) < abs(pos.x - b) ? a - 50 : b + 50); act = .run
        } else { letGo(nil) }
    }

    func shakeOff(_ v: CGPoint) {
        fall()
        let l = v.len
        let vv = l > 2600 ? v * (2600 / l) : v
        vel = P(vv.x * 0.5, max(260, vv.y * 0.5 + 300))
        say(L.r(L.shakeOff), dur: 1.6)
        showEmote(.sweat, 1.4)
        lastHostId = -1
    }

    /// přichytí se na nejbližší bod obvodu (vnější strana) a pokračuje podobným směrem
    func attach(to h: Host, motion: CGPoint) {
        guard let g = W.geom(h) else { return }
        ev("attach->\(h)")
        var best = (0, CGFloat(0), CGFloat.greatestFiniteMagnitude)
        var topOK = true
        if case .window(let id) = h, let w = W.byId[id] { topOK = W.topUsable(w) }
        for e in 0..<4 {
            if e == 0 && !g.inner && !topOK { continue }
            let ed = edgeOf(g.rect, inner: g.inner, e)
            let t = clamp((pos - ed.start).dot(ed.dir), 0, ed.len)
            let q = ed.start + ed.dir * t
            if !W.onScreen(q + ed.n * 12) { continue }
            let dd = (q - pos).len
            if dd < best.2 { best = (e, t, dd) }
        }
        guard best.2 < .greatestFiniteMagnitude else { return }
        host = h; edge = best.0; d = best.1
        let ed = edgeOf(g.rect, inner: g.inner, edge)
        let dd = ed.dir.dot(motion)
        var want: CGFloat = abs(dd) < 0.1 ? (ed.dir.y < 0 ? -1 : 1) : (dd >= 0 ? 1 : -1)
        // směr, kde je opravdu volno (ne zakryté jiným oknem, ne mimo obrazovku)
        func freeDir(_ sgn: CGFloat) -> Bool {
            let q = ed.start + ed.dir * clamp(best.1 + sgn * 26, 0, ed.len) + ed.n * 10
            if !W.onScreen(q) { return false }
            if case .window(let id) = h, let w = W.byId[id], W.covered(q, frontOf: w.z) { return false }
            return true
        }
        if !freeDir(want) && freeDir(-want) { want = -want }
        dir = want; lastDirT = E.now
        resolve(); updateFace(); cornerT = 0.3
        attachLog.append(E.now)
        attachLog = attachLog.filter { E.now - $0 < 4 }
        if attachLog.count >= 3 { noTransferUntil = E.now + 6; attachLog = [] }
    }

    func decide() {
        if isBaby, let par = parent, !par.dead {
            if par.phys == .home { goal = .home(E.now + 90); return }
            if par.act == .sleep && onFloor { act = .sleep; actT = rnd(5, 10); sleepFlat = chance(0.5); return }
            if par.phys == .surface && (par.host != host || (par.body - body).len > 90) && chance(0.85) {
                goal = .follow(par, E.now + 20); return
            }
        }
        if host == .dock, let dk = W.dock, chance(0.35) {
            if edge == 0 {
                // nahoře na Docku: dojít na kraj a seskočit vedle
                let nearLeft = pos.x - dk.minX < dk.maxX - pos.x
                let edgeX = nearLeft ? dk.minX : dk.maxX
                if abs(pos.x - edgeX) < 70, jumpCD <= 0 {
                    let si = W.screenIndex(P(edgeX, dk.minY))
                    jump(to: P(edgeX + (nearLeft ? -45 : 45), W.floorY(si)))
                } else { walkToward(edgeX); act = .walk; actT = rnd(3, 6) }
            } else if abs(n.x) > 0.5 { goDown(); act = .walk; actT = rnd(2, 5) }
            else { act = .walk; actT = rnd(2, 4) }
            return
        }
        if jumpCD <= 0 && chance(min(0.9, 0.22 * (E.k["jumpMul"] ?? 1))), let hop = nearbyHop() { jump(to: hop); return }
        if onFloor, let o = E.pets.first(where: { $0 !== self && $0.phys == .surface && $0.host == host && $0.edge == 0 && edge == 0 && abs($0.pos.x - pos.x) < 36 }) {
            act = .walk; actT = rnd(1, 2.5); setDir(pos.x < o.pos.x ? -1 : 1, force: true)
            return
        }
        if case .prop = host { act = .walk; actT = rnd(2, 4); setDir(chance(0.85) ? 1 : -1, force: true); return }
        if !isBaby && chance(min(0.9, 0.35 * (E.k["jumpMul"] ?? 1))), let lp = nearbyWallLeap() { startLeap(lp.0, lp.1, left: lp.2); return }
        if n.y <= 0.5 {
            // na stěně nebo stropě hlavně leze dál; stěny obrazovky radši dolů, nízko občas seskočí
            if E.now - arrivedAt > 20 && chance(0.04) && heightAboveFloor() < 120 { letGo(nil); return }
            if case .screen = host, abs(n.x) > 0.5, chance(0.65) { goDown(); act = .walk; actT = rnd(2, 6); return }
            if chance(0.8) { act = .walk; actT = rnd(2, 6); if chance(0.12) { setDir(-dir) } }
            else { play(chance(0.5) ? .look : .idle, rnd(0.8, 1.8)) }
            return
        }
        if Supporter.unlocked && poopT <= 0 && chance(0.5) { poop(); return }
        if !isBaby {
            // stavění (podle nastavení) a tunely
            let pb = [0.0, 0.07, 0.18, 0.4][max(0, min(3, E.buildLevel))]
            if chance(pb) {
                func gx(_ w: Win) -> CGFloat { min(abs(w.rect.minX - pos.x), abs(w.rect.maxX - pos.x)) }
                // i k oknu, na kterém zrovna je (žebřík dolů)
                if case .window(let hid) = host, chance(0.4), let cw = W.byId[hid], startBuild(cw) { return }
                let near = W.wins.prefix(10).filter { !isBad($0.id) && $0.rect.height > 150 && host != .window($0.id) }.sorted { gx($0) < gx($1) }.prefix(3)
                for w in near.shuffled() where startBuild(w) { return }
            }
            if chance(min(0.8, 0.08 * (E.k["tunnelMul"] ?? 1))) && startTunnel() { ev("tunnel"); return }
        }
        if energy < 0.25 && chance(0.6) { goal = .home(E.now + 90); say(L.r(L.sleepy), dur: 2); return }
        if navCD <= 0, let aw = W.active, !isBad(aw.id), host != .window(aw.id), chance(min(0.95, 0.4 * (E.k["climbMul"] ?? 1))) { goal = .window(aw.id, E.now + 75); return }
        if navCD <= 0 && chance(min(0.95, { if case .screen = host { return 0.6 }; return 0.15 }() * (E.k["climbMul"] ?? 1))) {
            func dx(_ w: Win) -> CGFloat { max(0, w.rect.minX - pos.x, pos.x - w.rect.maxX) }
            let si = W.screenIndex(body)
            let near = W.wins.prefix(10).filter { !isBad($0.id) && $0.rect.width >= 250 && $0.rect.height >= 150 && host != .window($0.id) && W.screenIndex(P($0.rect.midX, $0.rect.midY)) == si }
                .sorted { dx($0) < dx($1) }.prefix(3)
            if let w = near.randomElement() { goal = .window(w.id, E.now + 75); return }
        }
        if chance(0.02) { goal = .home(E.now + 90); return }

        if chance(0.06) {
            play(.dig, rnd(2, 3.5))
            E.decals.add(kind: 1, host: host, x: pos.x + (face ? 1 : -1) * S * 0.35, flip: false)
            if chance(0.3) { say(L.r(L.dig), dur: 1.8) }
            return
        }
        if chance((energy < 0.5 ? 0.06 : 0.015) * (E.k["sleepMul"] ?? 1) * sleepFactor) { act = .sleep; actT = rnd(5, 12); sleepFlat = chance(0.5); return }
        if chance(0.5) {
            act = chance(0.15) ? .run : .walk
            actT = rnd(3, 10)
            if chance(0.3) { setDir(-dir) }
            return
        }
        var opts: [(Anim, Double)] = [(.sit, rnd(3, 6)), (.lie, rnd(4, 8)), (.sniff, 1.8), (.look, 2.6), (.lookback, 2.0),
                                      (.scratch, 2.0), (.groom, 2.6), (.shake, 1.0), (.stretch, 2.2), (.tailwag, 2.0),
                                      (.sniffair, 2.0), (.sneeze, 1.4), (.idle, 2.5), (.stand, 3.0)]
        if energy < 0.5 { opts += [(.yawn, 2.0), (.yawn, 2.0)] }
        if fun > 0.7 { opts += [(.celebrate, 1.6), (.bow, 1.4)] }
        let o = opts.randomElement()!
        play(o.0, o.1)
        if o.0 == .stand && chance(0.3) { showEmote(.question, 1.6) }
    }

    func endGoal() {
        goal = nil; act = .idle; actT = rnd(0.8, 2); strikes = 0; stuckT = 0; navDir = 0
        hideSeek = false
        navPlan = nil
        climbFor = -1
    }

    // MARK: goals

    func pursue(_ g: Goal, _ m: CGPoint) {
        switch g {
        case .window(let id, let until):
            guard let w = W.byId[id], E.now < until else { endGoal(); return }
            if case .window(let hid) = host, hid == id, edge == 0 || !W.topUsable(w) {
                endGoal(); arrivedAt = E.now
                if chance(0.35) { say(L.r(L.arrived), dur: 1.6) }
                if edge == 0 && chance(0.5) { play(.sit, rnd(2, 4)) }
                return
            }
            // má k oknu postavenou větev/žebřík: jde přes ni
            if host != .window(id), let pr = E.props.values.first(where: { $0.winId == id && !$0.falling && !$0.dead }) {
                if host != .prop(pr.id) && navigate(pr.baseHost, pr.base.x) && pr.ready { mount(pr) }
                return
            }
            if !W.topUsable(w) { navigateToSide(w); return }
            guard let x = W.visibleTopX(w, near: pos.x) else { navigateToSide(w); return }
            navigate(.window(id), x)
        case .cursor(let until):
            if E.now > until { endGoal(); return }
            if (m - body).len < 60 { endGoal(); reachedCursor(m); return }
            guard let f = W.floors(at: m.x).filter({ $0.1 <= m.y + 10 && m.y - $0.1 < 240 }).max(by: { $0.1 < $1.1 }) else { endGoal(); return }
            navigate(f.0, m.x)
        case .treat(let it):
            if it.dead || it.carrier != nil { endGoal(); return }
            if case .tree = it.kind, !it.fruit { endGoal(); return }
            if (it.pos - pos).len < 32 && onFloor {
                if !it.edible { act = .idle; faceToward(it.pos.x); return }
                if case .mole = it.kind, chance(0.4) {
                    it.dead = true; endGoal(); play(.growl, 1.4); showEmote(.anger, 2)
                    say(L.r(L.moleEscaped), dur: 2)
                    return
                }
                eat(it); return
            }
            if it.phys == .surface { navigate(it.host, it.pos.x) } else { act = .idle }
        case .meet(let o, let kind, let until):
            if E.now > until || o.dead || o.phys == .home { endGoal(); return }
            if close(to: o) { endGoal(); E.met(self, o, kind); return }
            approachPet(o, run: kind != .greet)
        case .chase(let o, let until):
            if E.now > until || o.dead || o.phys == .home || o.phys == .hidden { endGoal(); return }
            if close(to: o) { endGoal(); E.caught(self, o); return }
            approachPet(o, run: true)
        case .flee(let o, let until):
            if E.now > until || o.dead { endGoal(); return }
            if o.phys == .surface && o.host == host && edge == 0 && o.edge == 0 && abs(o.pos.x - pos.x) < 250 {
                walkToward(pos.x + (pos.x - o.pos.x))
            }
            act = .run
        case .follow(let o, let until):
            if E.now > until || o.dead || o.phys == .home { endGoal(); return }
            if o.onFloor && o.host == host && edge == 0 {
                let tx = o.pos.x - (o.face ? 1 : -1) * (isBaby ? 38 : 60)
                if abs(tx - pos.x) < 14 { act = .idle; faceToward(o.pos.x) } else { walkToward(tx); act = abs(tx - pos.x) > 140 ? .run : .walk }
            } else if o.onFloor { navigate(o.host, o.pos.x) } else { act = .idle }
        case .home(let until):
            if E.now > until { endGoal(); return }
            if !E.homeOn {
                let hs = hideSeek; endGoal(); hideSeek = false
                if !hs && onFloor { act = .sleep; actT = rnd(15, 35); sleepFlat = chance(0.5) }
                return
            }
            let h = E.home!
            if navigate(h.hostH, h.x) { let hs = hideSeek; endGoal(); hideSeek = hs; enterHome() }
        case .build(let id, let until):
            guard W.byId[id] != nil, E.now < until, let bp = buildP else { carryStick = false; buildP = nil; giveUp(); return }
            switch buildStage {
            case 0:
                if navigate(bp.baseHost, buildSpot) { buildStage = 1; play(.dig, 1.8); if chance(0.5) { say(L.r(L.searchStick), dur: 1.8) } }
            case 1:
                buildStage = 2; carryStick = true; showEmote(.bang, 1)
                if chance(0.4) { say(L.r(L.foundStick), dur: 1.6) }
            case 2:
                if navigate(bp.baseHost, bp.base.x) {
                    buildStage = 3
                    if let w = W.byId[id] { face = (bp.left ? w.rect.minX : w.rect.maxX) > pos.x }
                    play(.stand, 1.0)
                }
            default:
                carryStick = false; buildStage = 0
                // okno se mezitím mohlo pohnout: přepočítat a zkontrolovat
                guard let w = W.byId[id], let g = W.geom(bp.baseHost) else { buildP = nil; giveUp(); return }
                let nb = P(bp.base.x, edgeOf(g.rect, inner: g.inner, 0).start.y)
                let tx = bp.left ? w.rect.minX : w.rect.maxX
                let hh = w.rect.minY + bp.leanOffY - nb.y
                guard abs(tx - nb.x) > 40 && abs(tx - nb.x) < 170 && hh > 2 && hh < 270 && bp.leanOffY <= w.rect.height else {
                    buildP = nil; giveUp(); return
                }
                let plan = BuildPlan(win: bp.win, left: bp.left, baseHost: bp.baseHost, base: nb, leanOffY: bp.leanOffY, kind: bp.kind)
                if let pr = E.addProp(plan, builder: self) {
                    say(L.r(L.built), dur: 2); showEmote(.note, 1.5)
                    Life.add(idx, "built"); Life.addXP(6)
                    goal = .window(id, E.now + 60)
                    _ = pr
                } else { giveUp() }
                buildP = nil
            }
        case .deliver(let id, let until):
            guard let w = W.byId[id], E.now < until else { endGoal(); dropCarried(); return }
            if case .window(let hid) = host, hid == id, edge == 0 {
                endGoal(); dropCarried()
                say(L.r(L.delivered), dur: 2); Life.add(idx, "notes"); Life.addXP(2)
                return
            }
            if let x = W.visibleTopX(w, near: pos.x) { navigate(.window(id), x); return }
            // okno bez volné horní hrany: nechá lísteček na zemi pod ním
            let si = W.screenIndex(P(w.rect.midX, max(w.rect.minY, W.scrs[0].frame.minY) + 5))
            let fx = clamp(w.rect.midX, W.scrs[si].frame.minX + 80, W.scrs[si].frame.maxX - 80)
            if navigate(.screen(si), fx) {
                endGoal(); dropCarried()
                say(L.r(L.delivered), dur: 2); Life.add(idx, "notes"); Life.addXP(2)
            }
        }
    }

    func close(to o: Pet) -> Bool { o.phys == .surface && phys == .surface && (body - o.body).len < 46 }

    func approachPet(_ o: Pet, run: Bool) {
        guard o.phys == .surface else { act = .idle; return }
        if o.host == host && edge == 0 && o.edge == 0 {
            walkToward(o.pos.x); act = run || abs(o.pos.x - pos.x) > 150 ? .run : .walk
            return
        }
        if o.onFloor { navigate(o.host, o.pos.x); if run && act == .walk { act = .run }; return }
        if o.host == host, let g = W.geom(host) {
            // po obvodu stejného okna kratší cestou
            func per(_ e: Int, _ dd: CGFloat) -> CGFloat {
                var s: CGFloat = 0
                for i in 0..<e { s += edgeOf(g.rect, inner: g.inner, i).len }
                return s + dd
            }
            let L = 2 * (g.rect.width + g.rect.height)
            let diff = (per(o.edge, o.d) - per(edge, d) + L).truncatingRemainder(dividingBy: L)
            setDir(diff < L / 2 ? 1 : -1); act = .run
            return
        }
        // kamarád visí na boku jiného okna: dolézt za ním
        if case .window(let id) = o.host, let w = W.byId[id] {
            if W.topUsable(w), let x = W.visibleTopX(w, near: o.pos.x) { navigate(.window(id), x) } else { navigateToSide(w) }
            if run && act == .walk { act = .run }
            return
        }
        if case .screen = o.host { descend(); return }
        act = .idle
    }

    func walkToward(_ x: CGFloat) {
        guard let e = currentEdge() else { return }
        if abs(e.dir.x) < 0.5 { return }
        let want: CGFloat = ((x - pos.x) * e.dir.x) > 0 ? 1 : -1
        if towardBlock(want) { if goal != nil { endGoal(); navCD = 2 } else { act = .idle }; return }
        if want != dir { setDir(want) }
        if act != .run { act = .walk }
    }
    func goDown() {
        guard let e = currentEdge(), abs(e.dir.y) > 0.5 else { return }
        setDir((e.dir.y < 0) ? 1 : -1, force: true)
    }
    func goUp() {
        guard let e = currentEdge(), abs(e.dir.y) > 0.5 else { return }
        setDir((e.dir.y > 0) ? 1 : -1, force: true)
    }
    func ev(_ what: String) {
        guard E.debug else { return }
        print("EV", name, what, host, "e\(edge)", Int(pos.x), Int(pos.y), "gw:\(goalWindow ?? -1)"); fflush(stdout)
    }
    func letGo(_ y: CGFloat?) {
        ev("letGo")
        fall()
        landMaxY = y.map { $0 + 2 }
    }

    func landable(_ h: Host, _ x: CGFloat) -> Bool {
        guard case .window(let id) = h, let w = W.byId[id] else { return true }
        return !W.covered(P(x, w.rect.maxY + 8), frontOf: w.z) && W.onScreen(P(x, w.rect.maxY))
    }

    /// Může se z podlahy chytit boku okna a vylézt nahoru? true = levý bok
    func grabSide(_ w: Win) -> Bool? {
        guard edge == 0, let g = W.geom(host) else { return nil }
        if case .window(let hid) = host, hid == w.id { return nil }
        guard w.rect.minY <= pos.y + 45, w.rect.maxY > pos.y + 25 else { return nil }
        let e = edgeOf(g.rect, inner: g.inner, 0)
        var best: Bool?
        var bd = CGFloat.greatestFiniteMagnitude
        for left in [true, false] {
            let sx = left ? w.rect.minX - 2 : w.rect.maxX + 2
            guard sx > e.start.x + 6 && sx < e.start.x + e.len - 6 else { continue }
            let probe = P(left ? w.rect.minX - 5 : w.rect.maxX + 5, max(pos.y, w.rect.minY) + 24)
            if W.covered(probe, frontOf: w.z) || !W.onScreen(probe) { continue }
            let dd = abs(sx - pos.x)
            if dd < bd { bd = dd; best = left }
        }
        return best
    }

    func grab(_ w: Win, left: Bool) {
        ev("grab \(w.id) left:\(left)")
        host = .window(w.id)
        if left { edge = 3; d = clamp(pos.y - w.rect.minY + 4, 0, w.rect.height); setDir(1, force: true) }
        else { edge = 1; d = clamp(w.rect.maxY - pos.y - 4, 0, w.rect.height); setDir(-1, force: true) }
        resolve(); updateFace(); cornerT = 0.3; act = .run
        navPlan = nil
    }

    /// Navigace: leze, slézá a jen málo skáče. Vrací true, když je na místě.
    @discardableResult func navigate(_ th: Host, _ tx: CGFloat) -> Bool {
        guard let tg = W.geom(th) else { endGoal(); return false }
        let te = edgeOf(tg.rect, inner: tg.inner, 0)
        let x = clamp(tx, te.start.x + 14, te.start.x + te.len - 14)
        let y = te.start.y
        if host == th && edge == 0 {
            if abs(pos.x - x) < 10 { act = .idle; return true }
            walkToward(x); act = abs(pos.x - x) > 90 ? .run : .walk
            return false
        }
        if prepT > 0 { return false }
        // cíl je na jiném monitoru: dojít po zemi k hraně a přejít
        let tsi = W.screenIndex(P(x, y + 1))
        if tsi != W.screenIndex(body) { crossToward(tsi); return false }
        let dx = x - pos.x, dy = y - pos.y
        let onWall = abs(n.x) > 0.5, onCeil = n.y < -0.5
        // malý skok: nahoru max ~75 px, dolů klidně víc
        if jumpCD <= 0 && dy <= 75 && dy > -1100 && abs(dx) <= (dy < -30 ? 440 : 220) && landable(th, x) && !(onCeil && dy > -10) {
            jump(to: P(x, y)); return false
        }
        // už je na cílovém okně (bok / spodek): lézt dál nahoru k horní hraně
        if host == th && dy > -30 {
            if onWall { goUp(); act = .run; return false }
            if onCeil, let e = currentEdge() {
                let a = e.start.x, b = e.start.x + e.dir.x * e.len
                walkToward(abs(pos.x - a) < abs(pos.x - b) ? a - 50 : b + 50); act = .run
                return false
            }
        }
        // Dock v cestě: přelézt ho
        if host == .dock && onWall && (th == .dock || (x - pos.x) * n.x < 0) { goUp(); act = .run; return false }
        let minX = te.start.x + 10, maxX = te.start.x + te.len - 10
        if dy < -30 {
            let dropX = pos.x + n.x * 30
            let aligned = dropX > minX && dropX < maxX && landable(th, dropX)
            if onCeil {
                if aligned { letGo(y); return false }
                if let e = currentEdge(), case .screen = host {
                    let lo = min(e.start.x, e.start.x + e.dir.x * e.len), hi = max(e.start.x, e.start.x + e.dir.x * e.len)
                    if x > lo + 10 && x < hi - 10 { walkToward(x); act = .run; return false }
                }
                descend()
                return false
            }
            if onWall {
                if aligned { letGo(y) } else if heightAboveFloor() < 170 { letGo(nil) } else { goDown(); act = .run }
                return false
            }
            walkToward(x); act = .run   // k okraji, za rohem slézá a pak se pustí
            return false
        }
        // cíl je výš: chytit se boku okna
        if case .window(let wid) = th, let w = W.byId[wid], n.y > 0.5, let left = grabSide(w) {
            let sx = left ? w.rect.minX - 2 : w.rect.maxX + 2
            if abs(pos.x - sx) < 9 { grab(w, left: left) } else { walkToward(sx); act = abs(pos.x - sx) > 90 ? .run : .walk }
            return false
        }
        // jinak po „žebříku" (boku jiného okna), na křížení přelézt na cíl
        if case .window(let tid) = th, let tw = W.byId[tid] { ladderTo(tw) } else { descend() }
        return false
    }

    // MARK: jumps & air

    func jump(to tgt: CGPoint) {
        pendingJump = tgt; prepT = 0.3; jumpCD = 1.6; act = .idle
        if onFloor { face = tgt.x > pos.x }
    }

    func launch(_ tgt: CGPoint) {
        ev("launch->\(Int(tgt.x)),\(Int(tgt.y))")
        let start = pos + n * 3
        let dx = tgt.x - start.x, dy = tgt.y - start.y
        let vy0: CGFloat = dy > 0 ? sqrt(2 * GRAV * (dy + 22)) : 230
        let disc = max(0, vy0 * vy0 - 2 * GRAV * dy)
        let T = max(0.25, (vy0 + sqrt(disc)) / GRAV)
        vel = P(dx / T, vy0)
        pos = start; n = P(0, 1)
        phys = .air; landMaxY = tgt.y + 2; jumpCD = 1.4; squash = 0.2
        if abs(dx) > 5 { face = dx > 0 }
    }

    func fall() {
        cornerAnim = nil; leap = nil
        if E.debug && phys == .surface { print("EV", name, "fall", host, "e\(edge)", Int(pos.x), Int(pos.y)); fflush(stdout) }
        phys = .air
        vel = n * 60
        landMaxY = nil
    }

    func land(_ h: Host, _ y: CGFloat) {
        guard let g = W.geom(h) else { return }
        if E.debug { print("EV", name, "land", h, Int(pos.x), Int(y)); fflush(stdout) }
        host = h; edge = 0
        let e = edgeOf(g.rect, inner: g.inner, 0)
        d = clamp(pos.x - e.start.x, 0, e.len)
        pos.y = y
        let impact = -vel.y
        squash = min(0.4, 0.06 + impact / 4500)
        if impact > 450 {
            for i in 0..<6 {
                let sx: CGFloat = i % 2 == 0 ? 1 : -1
                particles.append(Particle(p: P(sx * rndf(6, 18), -S * aspect / 2 + 2), v: P(sx * rndf(30, 70), rndf(10, 30)), age: 0, life: 0.5, kind: "dust"))
            }
        }
        if abs(vel.x) > 20 { dir = vel.x > 0 ? 1 : -1; lastDirT = E.now }
        vel = .zero; phys = .surface; landMaxY = nil; navDir = 0; navPlan = nil
        resolve(); updateFace()
        cornerT = 0
        dispC = body
        if impact > 1500 || dizzyOnLand {
            dizzyOnLand = false
            play(.dizzy, 1.8); showEmote(.star, 1.8)
            if impact > 1500 { say(chance(0.4) ? L.r(L.dontCare) : L.r(L.hurt), dur: 1.8) }
        } else if act != .sleep { act = .idle; actT = rnd(0.4, 1.2) }
    }

    func airStep(_ dt: CGFloat) {
        if var lp = leap {
            lp.t += Double(dt); leap = lp
            let k = CGFloat(min(1, lp.t / lp.dur))
            let mid = lp.from + (lp.to - lp.from) * k
            pos = P(mid.x, mid.y + sin(k * .pi) * 45)
            n = P(0, 1)
            if k >= 1 {
                leap = nil
                if let w = W.byId[lp.win] {
                    host = .window(w.id)
                    if lp.left { edge = 3; d = clamp(lp.to.y - w.rect.minY, 0, w.rect.height); dir = 1 }
                    else { edge = 1; d = clamp(w.rect.maxY - lp.to.y, 0, w.rect.height); dir = -1 }
                    phys = .surface; lastDirT = E.now; resolve(); updateFace(); cornerT = 0.25
                    act = .walk; actT = rnd(1.5, 4); squash = 0.25
                } else { vel = P(0, -100) }
            }
            return
        }
        let prev = pos
        vel.y = max(vel.y - GRAV * dt, -2600)
        pos = pos + vel * dt
        n = P(0, 1)
        if vel.y <= 0 {
            var best: (Host, CGFloat)?
            for fl in W.floors(at: pos.x) where fl.1 <= prev.y + 0.01 && fl.1 >= pos.y {
                if let lm = landMaxY, fl.1 > lm { continue }
                if best == nil || fl.1 > best!.1 { best = fl }
            }
            if let b = best { land(b.0, b.1); return }
        }
        let si = W.screenIndex(pos)
        let f = W.scrs[si].frame
        if !W.scrs.contains(where: { $0.frame.contains(pos) }) {
            if pos.x < f.minX { pos.x = f.minX + 2; vel.x = abs(vel.x) * 0.4 }
            if pos.x > f.maxX { pos.x = f.maxX - 2; vel.x = -abs(vel.x) * 0.4 }
            if pos.y < W.floorY(si) { pos.y = W.floorY(si); land(.screen(si), W.floorY(si)); return }
        }
        if pos.y > f.maxY - 6 { pos.y = f.maxY - 6; vel.y = min(0, vel.y) }
        if abs(vel.x) > 30 { face = vel.x > 0 }
    }

    // MARK: drag

    func beginDrag(_ m: CGPoint) {
        if isBaby, let par = parent, par.phys == .surface {
            par.goal = nil; par.play(.growl, 1.6); par.showEmote(.anger, 2.5)
            par.say(L.r(L.protectBaby), dur: 2.4)
        }
        if phys == .home || phys == .hidden || tunnelStage != 0 { return }
        dropCarried()
        leap = nil; cornerAnim = nil
        phys = .dragged; grabOff = m - pos; goal = nil; prepT = 0; oneShot = nil; hideSeek = false; tunnelStage = 0; sink = 0; cornerAnim = nil
        act = .idle
        say(chance(0.35) ? L.r(L.dontCare) : L.r(L.dragged), dur: 1.8)
        showEmote(.anger, 1.5)
    }
    func dragStep(_ dt: CGFloat, _ m: CGPoint) {
        let np = m - grabOff
        let v = (np - pos) * (1 / max(dt, 0.001))
        vel = vel * 0.55 + v * 0.45
        pos = np; n = P(0, 1)
        if abs(v.x) > 30 { face = v.x > 0 }
    }
    func endDrag() {
        phys = .air
        let l = vel.len
        if l > 3200 { vel = vel * (3200 / l) }
        landMaxY = nil
        act = .idle; actT = 1
        if chance(0.4) { E.later(1.4) { [weak self] in if let s = self, s.phys == .surface { s.say(L.r(L.dontCare), dur: 2) } } }
    }

    // MARK: home

    func enterHome() {
        dropCarried()
        phys = .home
        panel.orderOut(nil); speech.hide(); shown = false
        homeT = rnd(25, 70) * (energy < 0.5 ? 2.5 : 1)
        if hideSeek { homeT = rnd(8, 14) }
        act = .sleep; oneShot = nil
        E.home.puff()
    }
    func homeStep(_ dt: Double) {
        if !E.homeOn { if exitT < 0 { exitHome() }; return }
        homeT -= dt
        if E.userIdle { homeT = max(homeT, 3) }
        if exitT >= 0 {
            exitT -= dt
            if exitT <= 0 { exitHome() }
        } else if homeT <= 0 && (energy > 0.6 || hideSeek) && !E.userIdle {
            exitT = 1.3; E.home.peek(self, 1.3)
        }
    }
    func callOut() {
        guard phys == .home, exitT < 0 else { return }
        homeT = 0; energy = max(energy, 0.61)
    }
    func exitHome() {
        exitT = -1
        let h = E.home!
        let si = min(h.si, W.scrs.count - 1)
        host = .screen(si); edge = 0
        d = h.x - W.scrs[si].frame.minX
        if E.homeOn, h.onDock, let dk = W.dock { host = .dock; d = clamp(h.x - dk.minX, 10, dk.width - 10) }
        if !E.homeOn { let fw = Double(W.scrs[si].frame.width); d = CGFloat(rnd(120, max(130, fw - 120))) }
        phys = .surface; act = .walk; actT = rnd(2, 4)
        resolve()
        dir = chance(0.5) ? 1 : -1; lastDirT = E.now; updateFace()
        dispC = body; squash = 0.3
        if !E.hidden { panel.orderFrontRegardless(); shown = true }
        if hideSeek {
            hideSeek = false
            say("BÚ!", dur: 1.5); showEmote(.bang, 1.5)
            if let o = E.pets.first(where: { $0 !== self && $0.phys == .surface }) {
                o.play(.growl, 1.2); o.showEmote(.bang, 1.5); o.say(L.r(L.scared), dur: 1.8)
            }
        } else if chance(0.5) {
            say(L.r(L.exitHome), dur: 1.8)
        }
    }

    // MARK: interaction

    func reachedCursor(_ m: CGPoint) {
        faceToward(m.x)
        play(.growl, 1.3)
        fun = min(1, fun + 0.1)
        say(L.r(L.cursor), dur: 1.8)
        if E.annoy >= 2 && chance(0.3) {
            E.grabCursor(self, 1.4)
            E.later(1.3) { [weak self] in self?.act = .run; self?.actT = 1.4 }
        } else if E.annoy >= 2 || (E.annoy >= 1 && chance(0.4)) {
            E.nudge(P(rndf(-45, 45), rndf(-30, 30)))
        }
    }

    func eat(_ it: Item) {
        it.dead = true
        endGoal()
        faceToward(it.pos.x)
        play(.eat, 2.4)
        hunger = max(0, hunger - 0.6); fun = min(1, fun + 0.1)
        health = min(1, health + 0.08); Life.add(idx, "honey"); Life.addXP(1)
        showEmote(.heart, 2.2)
        let isHoney: Bool = { if case .honey = it.kind { return true }; return false }()
        switch it.kind {
        case .worm: say(L.r(L.wormEat), dur: 2)
        case .tree: say(L.r(L.eatApple), dur: 2)
        case .mole: say(L.r(L.eatMole), dur: 2)
        default: say(L.r(L.eat), dur: 2)
        }
        // druhý závidí
        for o in E.pets where o !== self && o.phys == .surface && (o.body - body).len < 600 && chance(0.6) {
            E.later(1.2) { o.say(L.r(L.envy), dur: 1.8); o.showEmote(.anger, 1.4) }
        }
        if Supporter.unlocked && chance(0.15) {
            E.later(3.0) { [weak self] in self?.vomit() }
        } else if isHoney && chance(0.45) {
            // včely! medojedovi je to jedno
            for _ in 0..<8 { particles.append(Particle(p: P(rndf(-30, 30), rndf(0, 30)), v: P(rndf(-40, 40), rndf(-30, 30)), age: 0, life: 3.4, kind: "bee")) }
            E.later(1.0) { [weak self] in self?.say(L.r(L.bees), dur: 2.2) }
        } else if chance(0.25) {
            E.later(2.6) { [weak self] in
                guard let s = self, s.phys == .surface, s.onFloor else { return }
                s.play(.passout, 4.2); s.showEmote(.star, 3.5)
                E.later(4.4) { if s.phys == .surface { s.say(L.r(L.wakeUp), dur: 2.2); s.play(.shake, 1.0) } }
            }
        }
        for o in E.pets where o !== self {
            if case .treat(let ot)? = o.goal, ot === it {
                o.endGoal(); o.showEmote(.anger, 2)
                o.say(L.r(L.stolen), dur: 2)
            }
        }
    }

    var poopT: Double = ProcessInfo.processInfo.environment["ZV_FAST"] != nil ? 20 : rnd(300, 700)

    func poop() {
        guard onFloor else { return }
        poopT = rnd(360, 800)
        play(.crouch, 1.7); showEmote(.sweat, 1.6)
        E.later(1.4) { [weak self] in
            guard let s = self, s.phys == .surface, s.onFloor else { return }
            let it = Item(.poop); it.owner = s.idx
            it.place(s.host, s.pos.x + (s.face ? -1 : 1) * s.S * 0.45)
            E.items.append(it)
            s.say(L.r(L.poopSay), dur: 1.8)
        }
    }

    func vomit() {
        guard phys == .surface, onFloor else { return }
        play(.sniff, 1.4); showEmote(.sweat, 1.5)
        let f: CGFloat = face ? 1 : -1
        for _ in 0..<10 { particles.append(Particle(p: P(f * S * 0.42, -S * 0.1), v: P(f * rndf(40, 110), rndf(-20, 40)), age: 0, life: 0.6, kind: "vomit")) }
        let it = Item(.vomit); it.owner = idx
        it.place(host, pos.x + f * S * 0.55)
        E.items.append(it)
        say(L.r(L.vomit), dur: 2)
    }

    func wantTreat(_ it: Item) {
        guard phys == .surface, carrying == nil else { return }
        if case .deliver? = goal { return }
        goal = .treat(it); oneShot = nil
        if act == .sleep { act = .idle }
        showEmote(.bang, 1.2)
        jumpCD = min(jumpCD, 0)
    }

    func dropCarried() {
        guard let it = carrying else { return }
        carrying = nil
        it.carrier = nil
        it.pos = mouth
        it.phys = .air
        it.vel = P((face ? 1 : -1) * 60, 140)
    }

    func petted() {
        if phys == .home { callOut(); return }
        let wasAsleep = act == .sleep
        showEmote(wasAsleep ? .bang : .heart, 2)
        squash = 0.25
        fun = min(1, fun + 0.15)
        health = min(1, health + 0.03); Life.add(idx, "petted")
        say(wasAsleep ? L.r(L.woken) : L.r(L.pet), dur: 2.4)
        if phys == .surface {
            goal = nil; act = .idle; actT = rnd(2, 4)
            if !wasAsleep && onFloor && oneShot == nil { play(chance(0.6) ? .roll : .tailwag, 1.8) }
        }
    }

    func showMenu(in v: NSView, event: NSEvent) {
        let menu = NSMenu()
        let head = NSMenuItem(title: tx("\(name)  ·  \(needsText())"), action: nil, keyEquivalent: "")
        head.isEnabled = false
        menu.addItem(head)
        menu.addItem(MenuItem("Pohladit ❤️") { [weak self] in self?.petted() })
        menu.addItem(MenuItem(act == .sleep ? "Probudit" : "Uspat 💤") { [weak self] in
            guard let s = self, s.phys == .surface else { return }
            if s.act == .sleep { s.act = .idle; s.actT = 1; s.say("Ááá… dobré ráno.", dur: 2) } else { s.goal = nil; s.oneShot = nil; s.act = .sleep; s.actT = rnd(20, 40) }
        })
        menu.addItem(MenuItem("Med sem 🍯") { [weak self] in if let s = self { E.dropTreat(at: s.body + P(0, 90)) } })
        menu.addItem(MenuItem("Jdi do nory 🏠") { [weak self] in self?.goal = .home(E.now + 120) })
        NSMenu.popUpContextMenu(menu, with: event, for: v)
    }

    func needsText() -> String {
        func bar(_ v: Double) -> String { let k = Int((v * 5).rounded()); return String(repeating: "▮", count: k) + String(repeating: "▯", count: 5 - k) }
        let base = "❤️ \(bar(health))  🍯 \(bar(1 - hunger))  ⚡ \(bar(energy))  🎾 \(bar(fun))"
        return isBaby ? base : Life.ageText(idx) + " · " + Life.stageName(idx) + "   " + base
    }

    func say(_ text0: String, dur: Double = 3) {
        guard !dead, phys != .home && phys != .hidden else { return }
        var text = tx(text0)
        if isBaby && !L.baby.contains(text) && chance(0.65) { text = L.r(L.baby) }
        if E.debug { print("💬", name, text); fflush(stdout) }
        speech.say(text, dur: dur)
    }

    // MARK: render

    func render(_ m: CGPoint) {
        if phys == .home || phys == .hidden { return }
        if !shown && !E.hidden { panel.orderFrontRegardless(); shown = true }
        let target = cornerAnim != nil ? pos + cornerN * (S * aspect / 2 + cornerBulge) : body
        if cornerAnim != nil { dispC = target }
        else if cornerT > 0 && phys == .surface && (target - dispC).len < 150 { dispC = dispC + (target - dispC) * 0.3 } else { dispC = target }
        let bc = dispC
        if abs(panel.frame.width - box) > 0.5 {
            panel.setContentSize(NSSize(width: box, height: box)); view.frame = NSRect(x: 0, y: 0, width: box, height: box); view.needsDisplay = true
        }
        // okno celé na jednom displeji (přes hranu displejů ho macOS přehazuje = blikání)
        var o = P((bc.x - box / 2).rounded(), (bc.y - box / 2).rounded())
        let sf = W.scrs[W.screenIndex(bc)].frame
        o.x = clamp(o.x, sf.minX, sf.maxX - box); o.y = clamp(o.y, sf.minY, sf.maxY - box)
        let nc = bc - o
        if (nc - drawC).len > 0.01 { drawC = nc; lastSig = 0 }
        if panel.frame.origin != o { panel.setFrameOrigin(o) }
        let grabbable = phys == .surface || phys == .air
        let wantMouse = pressed || phys == .dragged || (grabbable && hoverT > 0.12 && !E.clickThrough)
        if ignoring == wantMouse { ignoring = !wantMouse; panel.ignoresMouseEvents = ignoring }
        var hs = Hasher()
        hs.combine(Int(angle * 200)); hs.combine(Int(squash * 200)); hs.combine(face); hs.combine(Int(sink * 40))
        hs.combine(curAnim.rawValue); hs.combine(Int(animT)); hs.combine(blinkT > 0)
        hs.combine(emote?.rawValue); hs.combine(Int(emoteT * 4))
        for p in particles { hs.combine(Int(p.age * 30)) }
        let sig = hs.finalize()
        if sig != lastSig { lastSig = sig; view.needsDisplay = true }
        speech.place(center: bc, halfH: S * aspect / 2 + (emote != nil ? 22 : 0), preferAbove: n.y > -0.5)
        if let it = carrying { it.pos = mouth }
    }

    func draw(in v: NSView) {
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }
        let c = drawC
        let s = S
        let img = Badger.image(curAnim, Int(animT), blink: blinkT > 0, skin: skin)
        ctx.saveGState()
        ctx.interpolationQuality = .none
        ctx.translateBy(x: c.x, y: c.y)
        ctx.rotate(by: angle)
        ctx.translateBy(x: 0, y: -s * aspect / 2)
        if sink > 0 {
            ctx.clip(to: CGRect(x: -s, y: 0, width: s * 2, height: s * 2))
            ctx.translateBy(x: 0, y: -sink * s * aspect * 0.95)
        }
        if phys == .surface && sink == 0 && !(oneShot == .tumble) {
            NSColor(white: 0, alpha: 0.16).setFill()
            NSRect(x: -s * 0.30, y: -2, width: s * 0.60, height: 2).fill()
            NSRect(x: -s * 0.22, y: -4, width: s * 0.44, height: 2).fill()
        }
        ctx.scaleBy(x: (1 + squash * 0.5) * (face ? 1 : -1), y: 1 - squash * 0.6)
        let old = isBaby ? 0 : Life.oldness(idx)
        if old > 0.02 || health < 0.3 {
            ctx.beginTransparencyLayer(auxiliaryInfo: nil)
            ctx.draw(img, in: CGRect(x: -s / 2, y: 0, width: s, height: s * aspect))
            ctx.setBlendMode(.sourceAtop)
            if old > 0.02 { ctx.setFillColor(NSColor(white: 0.62, alpha: 0.42 * old).cgColor); ctx.fill(CGRect(x: -s / 2, y: 0, width: s, height: s * aspect)) }
            if health < 0.3 { ctx.setFillColor(NSColor(red: 0.5, green: 0.75, blue: 0.4, alpha: 0.22).cgColor); ctx.fill(CGRect(x: -s / 2, y: 0, width: s, height: s * aspect)) }
            ctx.endTransparencyLayer()
        } else {
            ctx.draw(img, in: CGRect(x: -s / 2, y: 0, width: s, height: s * aspect))
        }
        if carryStick && phys != .home {
            NSColor(white: 0.08, alpha: 1).setFill()
            for i in 0..<12 { NSRect(x: s * 0.12 + CGFloat(i) * 3 - 1, y: s * aspect * 0.18 + CGFloat(i) * 0.9 - 1, width: 5, height: 5).fill() }
            NSColor(red: 0.5, green: 0.33, blue: 0.18, alpha: 1).setFill()
            for i in 0..<12 { NSRect(x: s * 0.12 + CGFloat(i) * 3, y: s * aspect * 0.18 + CGFloat(i) * 0.9, width: 3, height: 3).fill() }
            NSColor(red: 0.42, green: 0.7, blue: 0.3, alpha: 1).setFill()
            NSRect(x: s * 0.12 + 30, y: s * aspect * 0.18 + 14, width: 4, height: 3).fill()
        }
        ctx.restoreGState()
        for p in particles where p.age >= 0 {
            let alpha = max(0, 1 - p.age / p.life)
            let at = P(c.x + p.p.x, c.y + p.p.y)
            switch p.kind {
            case "dirt": PixelItems.drawPattern(["XX", "XX"], at: at, px: 2, color: NSColor(red: 0.47, green: 0.33, blue: 0.2, alpha: alpha), outline: nil)
            case "spray": PixelItems.drawPattern(["X"], at: at, px: 2, color: NSColor(red: 0.75, green: 0.9, blue: 1, alpha: alpha), outline: nil)
            case "bee":
                let bx = (at.x / 2).rounded() * 2, by = (at.y / 2).rounded() * 2
                NSColor(white: 0.05, alpha: alpha).setFill(); NSRect(x: bx - 3, y: by - 2, width: 7, height: 5).fill()
                NSColor(red: 1, green: 0.82, blue: 0.2, alpha: alpha).setFill(); NSRect(x: bx - 2, y: by - 1, width: 2, height: 3).fill(); NSRect(x: bx + 2, y: by - 1, width: 1, height: 3).fill()
                NSColor(white: 1, alpha: alpha * 0.8).setFill(); NSRect(x: bx - 1, y: by + 2, width: 3, height: 2).fill()
            case "vomit": PixelItems.drawPattern(["XX"], at: at, px: 2, color: NSColor(red: 0.6, green: 0.8, blue: 0.3, alpha: alpha), outline: nil)
            case "dust": PixelItems.drawPattern(["X"], at: at, px: 3, color: NSColor(white: 0.82, alpha: alpha * 0.7), outline: nil)
            case "z": PixelItems.drawPattern(PixelItems.zed, at: at, px: 2.5, color: NSColor(white: 1, alpha: alpha), outline: NSColor(white: 0.1, alpha: alpha))
            default: break
            }
        }
        if let e = emote {
            let a: CGFloat = emoteT < 0.3 ? CGFloat(emoteT / 0.3) : 1
            let bob = CGFloat(sin(t * 5)) * 1.5
            Emotes.draw(e, at: P(c.x, c.y + s * aspect / 2 + 14 + bob), px: 3, alpha: a)
        }
    }
}

// MARK: - Nora

final class HomeView: NSView {
    weak var home: Home?
    var downAt = CGPoint.zero
    var dragging = false
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
    override func mouseDown(with e: NSEvent) { downAt = NSEvent.mouseLocation; dragging = false }
    override func mouseDragged(with e: NSEvent) {
        let m = NSEvent.mouseLocation
        if !dragging && (m - downAt).len > 4 { dragging = true }
        if dragging { home?.dragTo(m) }
    }
    override func mouseUp(with e: NSEvent) {
        if dragging { home?.drop(NSEvent.mouseLocation) } else { home?.clicked() }
        dragging = false
    }
    override func rightMouseDown(with e: NSEvent) { home?.showMenu(in: self, event: e) }
    override func draw(_ r: NSRect) { home?.draw(in: self) }
}

@MainActor final class Home {
    var si: Int
    var x: CGFloat
    let w: CGFloat = 80
    let panel: OverlayPanel
    let view: HomeView
    var peekT: Double = 0
    var peekAlt = false
    var puffT: Double = 0
    var zs: [Particle] = []
    var zT: Double = 0
    var dragPos: CGPoint?
    var lastSig = 0

    init() {
        let ud = UserDefaults.standard
        si = ud.object(forKey: "homeSi") as? Int ?? 0
        if si >= W.scrs.count { si = 0 }
        if let hx = ud.object(forKey: "homeX") as? Double { x = CGFloat(hx) } else { x = W.scrs[si].frame.minX + 70 }
        panel = makePanel(NSSize(width: 150, height: 90), level: 0)
        view = HomeView(frame: NSRect(x: 0, y: 0, width: 150, height: 90))
        panel.contentView = view
        view.home = self
        panel.ignoresMouseEvents = false
        clampX()
    }

    func clampX() {
        si = min(si, W.scrs.count - 1)
        let f = W.scrs[si].frame
        x = clamp(x, f.minX + w / 2 + 4, f.maxX - w / 2 - 4)
        let vf = W.scrs[si].visible
        if vf.minX > f.minX + 1 && x - w / 2 < vf.minX { x = vf.minX + w / 2 + 6 }
        if vf.maxX < f.maxX - 1 && x + w / 2 > vf.maxX { x = vf.maxX - w / 2 - 6 }
        x = clamp(x, f.minX + w / 2 + 2, f.maxX - w / 2 - 2)
        // částečně přes konec Docku: buď celá na Dock, nebo celá vedle
        if let dk = W.dock, dk.width > dk.height, dk.minY < f.minY + 60, x + w / 2 > dk.minX, x - w / 2 < dk.maxX {
            if x < dk.minX + w / 2 + 4 {
                x = dk.minX - f.minX > w + 12 ? dk.minX - w / 2 - 6 : dk.minX + w / 2 + 4
            } else if x > dk.maxX - w / 2 - 4 {
                x = f.maxX - dk.maxX > w + 12 ? dk.maxX + w / 2 + 6 : dk.maxX - w / 2 - 4
            }
        }
    }

    func resetCorner() { si = 0; x = W.scrs[0].frame.minX + 70; save() }
    func save() { UserDefaults.standard.set(si, forKey: "homeSi"); UserDefaults.standard.set(Double(x), forKey: "homeX") }

    /// nora stojí na Docku (dole by byla pod ním)
    var onDock: Bool {
        guard let dk = W.dock, dk.width > dk.height else { return false }
        let f = W.scrs[min(si, W.scrs.count - 1)].frame
        return dk.minY < f.minY + 60 && x + w / 2 > dk.minX && x - w / 2 < dk.maxX && f.contains(P(dk.midX, dk.midY))
    }
    var hostH: Host { onDock ? .dock : .screen(min(si, W.scrs.count - 1)) }
    var groundY: CGFloat { onDock ? W.dock!.maxY : W.floorY(min(si, W.scrs.count - 1)) }
    var inside: [Pet] { E.pets.filter { $0.phys == .home } }

    func peek(_ p: Pet, _ dur: Double) { peekT = dur; peekAlt = p.alt }
    func puff() { puffT = 0.4 }

    func update(_ dt: Double) {
        peekT -= dt; puffT -= dt
        if !inside.isEmpty && peekT <= 0 {
            zT -= dt
            if zT <= 0 { zT = 1.6; zs.append(Particle(p: P(79, 20), v: P(8, 16), age: 0, life: 2.6, kind: "z")) }
        }
        for i in zs.indices { zs[i].age += CGFloat(dt); zs[i].p = zs[i].p + zs[i].v * CGFloat(dt) }
        zs.removeAll { $0.age > $0.life }
    }

    func render() {
        clampX()
        let base = dragPos ?? P(x, groundY)
        let fr = NSRect(x: (base.x - 75).rounded(), y: base.y.rounded(), width: 150, height: 90)
        if panel.frame != fr { panel.setFrame(fr, display: false) }
        var hs = Hasher()
        hs.combine(peekT > 0); hs.combine(peekAlt); hs.combine(puffT > 0); hs.combine(Life.level); hs.combine(E.isNight)
        for z in zs { hs.combine(Int(z.age * 10)) }
        let sig = hs.finalize()
        if sig != lastSig { lastSig = sig; view.needsDisplay = true }
    }

    func draw(in v: NSView) {
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }
        ctx.interpolationQuality = .none
        let variant = peekT > 0 ? (peekAlt ? 2 : 1) : 0
        let dy: CGFloat = puffT > 0 ? 2 : 0
        let lv = Life.level
        if lv >= 7 && E.isNight {
            // lucerna svítí
            NSColor(red: 1, green: 0.85, blue: 0.4, alpha: 0.18).setFill()
            NSBezierPath(ovalIn: NSRect(x: -10, y: 14, width: 30, height: 30)).fill()
        }
        ctx.draw(BurrowDecor.image(lv, night: E.isNight), in: CGRect(x: 0, y: 0, width: 150, height: 60))
        ctx.draw(Burrow.image(variant), in: CGRect(x: 35, y: dy, width: 80, height: 52))
        for z in zs {
            let a = max(0, 1 - z.age / z.life)
            PixelItems.drawPattern(PixelItems.zed, at: z.p, px: 2, color: NSColor(white: 1, alpha: a), outline: NSColor(white: 0.1, alpha: a))
        }
    }

    func dragTo(_ m: CGPoint) { dragPos = P(m.x, m.y - 20) }
    func drop(_ m: CGPoint) {
        dragPos = nil
        si = W.screenIndex(m); x = m.x
        clampX(); save()
    }
    func clicked() {
        if let p = inside.first { p.callOut() }
        else { E.pets.filter { $0.phys == .surface }.randomElement()?.say(L.r(L.homeClicked), dur: 2) }
    }
    func showMenu(in v: NSView, event: NSEvent) {
        let menu = NSMenu()
        let t = NSMenuItem(title: inside.isEmpty ? tx("Nora je prázdná") : tx("Doma: ") + inside.map { $0.name }.joined(separator: ", "), action: nil, keyEquivalent: "")
        t.isEnabled = false
        menu.addItem(t)
        menu.addItem(MenuItem("Zavolat ven") { for p in E.pets { p.callOut() } })
        menu.addItem(MenuItem("Všichni domů") { for p in E.pets where p.phys == .surface { p.goal = .home(E.now + 120) } })
        menu.addItem(MenuItem("Přesunout do rohu") { [weak self] in self?.resetCorner() })
        let hint = NSMenuItem(title: tx("Noru můžeš přetáhnout myší"), action: nil, keyEquivalent: "")
        hint.isEnabled = false
        menu.addItem(hint)
        NSMenu.popUpContextMenu(menu, with: event, for: v)
    }
}

// MARK: - Stopy a díry (nalepené na okna)

struct Decal { let kind: Int; let host: Host; let off: CGFloat; let born: Double; let life: Double; let flip: Bool }

final class StripView: NSView {
    var marks: [(kind: Int, x: CGFloat, a: CGFloat, flip: Bool)] = []
    override func draw(_ r: NSRect) {
        for m in marks {
            let x = m.x
            if m.kind == 0 {
                NSColor(red: 0.35, green: 0.24, blue: 0.14, alpha: 0.75 * m.a).setFill()
                let fx: CGFloat = m.flip ? 1 : 0
                NSRect(x: x - 2 + fx, y: 1, width: 4, height: 3).fill()
                NSRect(x: x - 3 + fx, y: 5, width: 2, height: 2).fill()
                NSRect(x: x + 1 + fx, y: 5, width: 2, height: 2).fill()
            } else if m.kind == 1 {
                NSColor(red: 0.52, green: 0.36, blue: 0.22, alpha: m.a).setFill()
                NSRect(x: x - 12, y: 0, width: 24, height: 3).fill()
                NSRect(x: x - 9, y: 3, width: 18, height: 3).fill()
                NSRect(x: x - 5, y: 6, width: 10, height: 2).fill()
                NSColor(red: 0.36, green: 0.24, blue: 0.14, alpha: m.a).setFill()
                NSRect(x: x - 6, y: 2, width: 3, height: 2).fill()
                NSRect(x: x + 4, y: 4, width: 2, height: 2).fill()
            }
            if m.kind == 2 {
                NSColor(red: 0.5, green: 0.35, blue: 0.21, alpha: m.a).setFill()
                NSRect(x: x - 18, y: 0, width: 36, height: 3).fill()
                NSRect(x: x - 14, y: 3, width: 6, height: 3).fill(); NSRect(x: x + 8, y: 3, width: 6, height: 3).fill()
                NSColor(red: 0.12, green: 0.08, blue: 0.05, alpha: m.a).setFill()
                NSRect(x: x - 10, y: 0, width: 20, height: 4).fill()
                NSRect(x: x - 7, y: 4, width: 14, height: 2).fill()
            }
        }
    }
}

/// Tenký průhledný proužek podél horní hrany jednoho okna/obrazovky se stopami
@MainActor final class Strip {
    let panel: OverlayPanel
    let view: StripView
    var sig = 0
    var shown = false
    init(_ size: NSSize) {
        panel = makePanel(size, level: 0)
        view = StripView(frame: NSRect(origin: .zero, size: size))
        panel.contentView = view
    }
}

@MainActor final class Decals {
    var list: [Decal] = []
    var strips: [String: Strip] = [:]

    func add(kind: Int, host: Host, x: CGFloat, flip: Bool) {
        guard let g = W.geom(host) else { return }
        let e = edgeOf(g.rect, inner: g.inner, 0)
        list.append(Decal(kind: kind, host: host, off: x - e.start.x, born: E.now, life: kind == 0 ? 25 : (kind == 2 ? 30 : 45), flip: flip))
        if list.count > 120 { list.removeFirst(list.count - 120) }
    }

    func hideAll() { for s in strips.values { s.panel.orderOut(nil); s.shown = false } }

    func refresh() {
        list.removeAll { E.now - $0.born > $0.life }
        var groups: [String: (Host, [Decal])] = [:]
        for d in list { let k = "\(d.host)"; groups[k, default: (d.host, [])].1.append(d) }
        for (k, st) in strips where groups[k] == nil { st.panel.orderOut(nil); strips[k] = nil }
        for (k, grp) in groups {
            guard let g = W.geom(grp.0) else { strips[k]?.panel.orderOut(nil); strips[k] = nil; continue }
            let e = edgeOf(g.rect, inner: g.inner, 0)
            var z = Int.max
            if case .window(let id) = grp.0, let w = W.byId[id] { z = w.z }
            var marks: [(kind: Int, x: CGFloat, a: CGFloat, flip: Bool)] = []
            for d in grp.1 where d.off >= 0 && d.off <= e.len {
                if z != Int.max && W.covered(P(e.start.x + d.off, e.start.y + 3), frontOf: z) { continue }
                let a = CGFloat(Int(max(0, 1 - (E.now - d.born) / d.life) * 10)) / 10
                if a > 0 { marks.append((d.kind, (d.off + 16).rounded(), a, d.flip)) }
            }
            let fr = NSRect(x: (e.start.x - 16).rounded(), y: e.start.y.rounded(), width: (e.len + 32).rounded(), height: 12)
            let st = strips[k] ?? Strip(fr.size)
            strips[k] = st
            if st.panel.frame != fr {
                let resized = st.panel.frame.size != fr.size
                st.panel.setFrame(fr, display: false)
                if resized { st.view.frame = NSRect(origin: .zero, size: fr.size); st.view.needsDisplay = true }
            }
            var hs = Hasher()
            for m in marks { hs.combine(Int(m.x)); hs.combine(Int(m.a * 10)); hs.combine(m.kind) }
            let sig = hs.finalize()
            if sig != st.sig { st.sig = sig; st.view.marks = marks; st.view.needsDisplay = true }
            if !st.shown && !E.hidden { st.panel.orderFrontRegardless(); st.shown = true }
        }
    }
}

// MARK: - Rvačka (mrak prachu)

final class FightView: NSView {
    var t: Double = 0
    override func draw(_ r: NSRect) {
        let px: CGFloat = 4
        let frame = Int(t * 12)
        func h(_ i: Int) -> CGFloat { let v = sin(Double(i * 9283 + frame * 7919)) * 43758.5453; return CGFloat(v - floor(v)) }
        let cx = bounds.midX, cy = bounds.midY - 10
        var puffs: [(CGPoint, CGFloat)] = []
        for i in 0..<7 {
            let a = CGFloat(i) / 7 * 2 * .pi + h(i) * 0.6
            puffs.append((P(cx + cos(a) * 38 * (0.7 + h(i + 20) * 0.5), cy + sin(a) * 22 * (0.7 + h(i + 40) * 0.5)), 26 + h(i + 60) * 12))
        }
        puffs.append((P(cx, cy), 40))
        func inside(_ p: CGPoint) -> Bool { puffs.contains { ($0.0 - p).len <= $0.1 } }
        for i in 0..<5 {
            let a = h(i + 100) * 2 * .pi
            let base = P(cx + cos(a) * 44, cy + sin(a) * 30)
            let tip = base + P(cos(a), sin(a)) * (14 + h(i + 120) * 10)
            let col: NSColor = i == 2 ? NSColor(red: 0.93, green: 0.87, blue: 0.7, alpha: 1) : (i == 4 ? NSColor(white: 0.85, alpha: 1) : NSColor(white: 0.17, alpha: 1))
            let path = NSBezierPath(); path.move(to: base); path.line(to: tip)
            path.lineWidth = 9; NSColor(white: 0.05, alpha: 1).setStroke(); path.stroke()
            path.lineWidth = 6; col.setStroke(); path.stroke()
        }
        let ink = NSColor(white: 0.1, alpha: 1)
        let cols = Int(bounds.width / px), rows = Int(bounds.height / px)
        for yy in 0..<rows { for xx in 0..<cols {
            let p = P(CGFloat(xx) * px + px / 2, CGFloat(yy) * px + px / 2)
            guard inside(p) else { continue }
            let edge = !inside(p + P(px, 0)) || !inside(p - P(px, 0)) || !inside(p + P(0, px)) || !inside(p - P(0, px))
            if edge { ink.setFill() } else { NSColor(white: 0.86 + (p.y - cy) / 60 * 0.12, alpha: 1).setFill() }
            NSRect(x: CGFloat(xx) * px, y: CGFloat(yy) * px, width: px, height: px).fill()
        } }
        Emotes.draw(.star, at: P(cx - 30 + h(200) * 60, cy + 30 + h(201) * 20), px: 3, alpha: 1)
        Emotes.draw(frame % 2 == 0 ? .bang : .anger, at: P(cx + 40 - h(202) * 20, cy + 34), px: 3, alpha: 1)
        Emotes.draw(.star, at: P(cx + h(203) * 50 - 25, cy - 30), px: 2, alpha: 1)
    }
}

@MainActor final class FightCloud {
    let a: Pet, b: Pet
    let panel: OverlayPanel
    let view: FightView
    var t: Double = 0
    let dur: Double = 2.8
    let center: CGPoint

    init(_ a: Pet, _ b: Pet) {
        self.a = a; self.b = b
        center = P((a.body.x + b.body.x) / 2, max(a.body.y, b.body.y) + 10)
        panel = makePanel(NSSize(width: 240, height: 170), level: 2)
        view = FightView(frame: NSRect(x: 0, y: 0, width: 240, height: 170))
        panel.contentView = view
        panel.setFrameOrigin(P(center.x - 120, center.y - 85))
        panel.orderFrontRegardless()
        for p in [a, b] { p.dropCarried(); p.phys = .hidden; p.goal = nil; p.oneShot = nil; p.prepT = 0; p.panel.orderOut(nil); p.speech.hide(); p.shown = false }
    }

    func update(_ dt: Double) -> Bool {
        t += dt
        view.t = t
        let jig = P(CGFloat(sin(t * 31)) * 3, CGFloat(cos(t * 27)) * 2)
        panel.setFrameOrigin(P(center.x - 120 + jig.x, center.y - 85 + jig.y))
        view.needsDisplay = true
        if t >= dur {
            panel.orderOut(nil)
            if a.dead || b.dead {
                for p in [a, b] where !p.dead { p.phys = .surface; if !p.resolve() { p.fall() }; p.dispC = p.body }
                return false
            }
            let (w, l) = chance(0.5) ? (a, b) : (b, a)
            for p in [a, b] {
                p.phys = .surface
                if !p.resolve() { p.fall() }
                p.dispC = p.body
            }
            w.play(.celebrate, 1.8); w.showEmote(.note, 2)
            w.say(L.r(L.win), dur: 2)
            l.play(.dizzy, 2.2); l.showEmote(.star, 2.2)
            E.later(0.8) { l.say(L.r(L.lose), dur: 1.8) }
            for p in [a, b] { p.fun = min(1, p.fun + 0.3) }
            return false
        }
        return true
    }
}

// MARK: - Stavby (opřená větev, žebřík z klacků, kmen)

enum PropKind: Int { case branch = 0, ladder, log }
struct BuildPlan { let win: Int; let left: Bool; let baseHost: Host; let base: CGPoint; let leanOffY: CGFloat; let kind: PropKind }

final class PropView: NSView {
    weak var prop: Prop?
    override func draw(_ r: NSRect) { MainActor.assumeIsolated { prop?.draw(in: self) } }
}

@MainActor final class Prop {
    let id: Int
    let kind: PropKind
    let winId: Int
    let left: Bool
    let baseHost: Host
    let baseOff: CGFloat
    let leanOffY: CGFloat
    var base: CGPoint
    var top: CGPoint
    weak var builder: Pet?
    var grow: CGFloat = 0
    var falling = false
    var fallT: Double = 0
    var dead = false
    let panel: OverlayPanel
    let view: PropView
    var lastSig = 0
    var age: Double = 0

    var ready: Bool { !falling && !dead && grow >= 1 }
    var len: CGFloat { (top - base).len }
    var dirV: CGPoint { (top - base).norm }
    var normal: CGPoint { let d = dirV; let a = P(-d.y, d.x); return a.y >= 0 ? a : a * -1 }

    init(id: Int, plan: BuildPlan, win: Win, builder: Pet) {
        self.id = id; kind = plan.kind; winId = plan.win; left = plan.left
        baseHost = plan.baseHost; leanOffY = plan.leanOffY
        base = plan.base
        if let g = W.geom(plan.baseHost) { baseOff = plan.base.x - edgeOf(g.rect, inner: g.inner, 0).start.x } else { baseOff = 0 }
        top = P(plan.left ? win.rect.minX - 1 : win.rect.maxX + 1, win.rect.minY + plan.leanOffY)
        self.builder = builder
        panel = makePanel(NSSize(width: 10, height: 10), level: 1)
        view = PropView(frame: NSRect(x: 0, y: 0, width: 10, height: 10))
        view.prop = self
        panel.contentView = view
        if !E.hidden { panel.orderFrontRegardless() }
        layout()
    }

    func update(_ dt: Double) {
        if falling {
            fallT += dt
            if fallT > 1.8 { dead = true }
            layout(); view.needsDisplay = true
            return
        }
        if grow < 1 { grow = min(1, grow + CGFloat(dt) * 1.6); view.needsDisplay = true }
        // stojí okno i podlaha tam, kde byly?
        age += dt
        guard let w = W.byId[winId], let g = W.geom(baseHost) else { collapse(quiet: true); return }
        let mid = base + (top - base) * 0.5
        if age > 1200 || W.covered(mid, frontOf: w.z) || W.covered(top + P(left ? -6 : 6, 0), frontOf: w.z) { collapse(quiet: true); return }
        let e = edgeOf(g.rect, inner: g.inner, 0)
        let nb = P(e.start.x + baseOff, e.start.y)
        let nt = P(left ? w.rect.minX - 1 : w.rect.maxX + 1, w.rect.minY + leanOffY)
        if (nb - base).len > 5 || (nt - top).len > 5 || leanOffY > w.rect.height + 2 { collapse(); return }
        layout()
    }

    /// někdo pohnul oknem: stavba spadne a medojed zuří
    func collapse(quiet: Bool = false) {
        guard !falling else { return }
        falling = true; fallT = 0
        for p in E.pets where p.host == .prop(id) && p.phys == .surface { p.fall() }
        guard !quiet, let b = builder, !b.dead else { return }
        let laugh = E.pets.first { $0 !== b && $0.phys == .surface }
        E.later(0.35) {
            guard b.phys == .surface || b.phys == .air else { return }
            var delivering = false
            if case .deliver? = b.goal { delivering = true }
            if b.phys == .surface && !delivering { b.goal = nil; b.oneShot = nil; b.play(.growl, 1.8) }
            b.showEmote(.anger, 3.2); b.squash = 0.35
            b.say(L.r(L.propDestroyed), dur: 2.8)
        }
        E.later(2.4) {
            guard b.phys == .surface else { return }
            b.play(.shake, 1.0); b.showEmote(.anger, 2)
            b.say(L.r(L.propDestroyed2), dur: 2.6)
        }
        if let o = laugh, chance(0.6) {
            E.later(1.4) { o.play(.celebrate, 1.4); o.showEmote(.note, 1.8); o.say(L.r(L.laugh), dur: 2) }
        }
        let wid = winId
        if chance(0.55) {
            E.later(5.5) {
                guard b.free, let w = W.byId[wid] else { return }
                if b.startBuild(w) { b.say(L.r(L.rebuild), dur: 2.6); b.showEmote(.anger, 1.6) }
            }
        }
    }

    func layout() {
        let m: CGFloat = 16
        var fr: NSRect
        if falling {
            let L = len + m
            fr = NSRect(x: base.x - L, y: base.y - 20, width: L * 2, height: L + 20)
        } else {
            fr = NSRect(x: min(base.x, top.x) - m, y: min(base.y, top.y) - m, width: abs(top.x - base.x) + 2 * m, height: abs(top.y - base.y) + 2 * m)
        }
        fr = NSRect(x: fr.minX.rounded(), y: fr.minY.rounded(), width: fr.width.rounded(), height: fr.height.rounded())
        if panel.frame != fr {
            panel.setFrame(fr, display: false)
            view.frame = NSRect(origin: .zero, size: fr.size)
            view.needsDisplay = true
        }
    }

    func draw(in v: NSView) {
        let o = panel.frame.origin
        var a = base - o
        var b = base + (top - base) * grow - o
        var alpha: CGFloat = 1
        if falling {
            // padá od okna pryč a zmizí
            let t = CGFloat(fallT)
            let ang = min(1.45, t * t * 3.2) * (left ? 1 : -1)
            let d = top - base
            let ca = cos(ang), sa = sin(ang)
            b = a + P(d.x * ca - d.y * sa, d.x * sa + d.y * ca)
            if b.y < a.y - 4 { b.y = a.y - 4 }
            alpha = fallT > 1.0 ? max(0, CGFloat(1.8 - fallT) / 0.8) : 1
            a.y += 0
        }
        func thick(_ p: CGPoint, _ q: CGPoint, _ w: CGFloat, _ c: NSColor) {
            c.withAlphaComponent(alpha).setFill()
            let l = max(1, (q - p).len)
            var t: CGFloat = 0
            while t <= l {
                let pt = p + (q - p) * (t / l)
                NSRect(x: (pt.x / 2).rounded() * 2 - w / 2, y: (pt.y / 2).rounded() * 2 - w / 2, width: w, height: w).fill()
                t += 2
            }
        }
        let ink = NSColor(white: 0.07, alpha: 1)
        let dv = (b - a).norm, nv = P(-dv.y, dv.x)
        switch kind {
        case .branch:
            thick(a, b, 8, ink); thick(a, b, 4, NSColor(red: 0.47, green: 0.31, blue: 0.17, alpha: 1))
            for f in [0.35, 0.62, 0.82] as [CGFloat] {
                let p = a + (b - a) * f, q = p + nv * (f == 0.62 ? -12 : 12) + dv * 8
                thick(p, q, 5, ink); thick(p, q, 2, NSColor(red: 0.47, green: 0.31, blue: 0.17, alpha: 1))
                NSColor(red: 0.38, green: 0.7, blue: 0.28, alpha: alpha).setFill()
                NSRect(x: q.x - 3, y: q.y - 2, width: 6, height: 4).fill()
            }
        case .ladder:
            for s in [-5, 5] as [CGFloat] { thick(a + nv * s, b + nv * s, 6, ink) }
            let l = (b - a).len
            var t: CGFloat = 10
            while t < l - 4 { let p = a + dv * t; thick(p - nv * 5, p + nv * 5, 5, ink); thick(p - nv * 5, p + nv * 5, 2, NSColor(red: 0.62, green: 0.45, blue: 0.26, alpha: 1)); t += 14 }
            for s in [-5, 5] as [CGFloat] { thick(a + nv * s, b + nv * s, 2, NSColor(red: 0.62, green: 0.45, blue: 0.26, alpha: 1)) }
        case .log:
            thick(a, b, 12, ink); thick(a, b, 8, NSColor(red: 0.55, green: 0.37, blue: 0.2, alpha: 1))
            thick(a + nv * 2, b + nv * 2, 2, NSColor(red: 0.66, green: 0.48, blue: 0.28, alpha: 1))
            NSColor(red: 0.86, green: 0.72, blue: 0.5, alpha: alpha).setFill()
            NSRect(x: b.x - 4, y: b.y - 4, width: 8, height: 8).fill()
            NSColor(red: 0.6, green: 0.42, blue: 0.24, alpha: alpha).setFill()
            NSRect(x: b.x - 2, y: b.y - 2, width: 4, height: 4).fill()
        }
    }
}

// MARK: - Engine

@MainActor final class Engine: NSObject {
    var pets: [Pet] = []
    var items: [Item] = []
    var home: Home!
    var decals: Decals!
    var fight: FightCloud?
    var props: [Int: Prop] = [:]
    var nextPropId = 1

    func addProp(_ bp: BuildPlan, builder: Pet) -> Prop? {
        guard let w = W.byId[bp.win] else { return nil }
        let pr = Prop(id: nextPropId, plan: bp, win: w, builder: builder)
        nextPropId += 1
        props[pr.id] = pr
        return pr
    }
    var annoyRaw: Int = UserDefaults.standard.object(forKey: "annoy") as? Int ?? 1
    var annoy: Int { get { Supporter.unlocked ? annoyRaw : min(annoyRaw, 1) } set { annoyRaw = newValue } }
    var talk: Bool = UserDefaults.standard.object(forKey: "talk") as? Bool ?? true
    var notesOn: Bool = UserDefaults.standard.object(forKey: "notes") as? Bool ?? true
    var count: Int = UserDefaults.standard.object(forKey: "count") as? Int ?? 2
    var graves: [Grave] = []
    var lifeSec = 0
    var hidden = false
    var userHidden = false
    var autoHidden = false
    var fsT: Double = 0
    var petScale: CGFloat = Engine.autoScale()
    /// bez ručního nastavení: jen vestavěný displej Macu → menší medojedi
    static func autoScale() -> CGFloat {
        if let v = UserDefaults.standard.object(forKey: "scale") as? Double { return CGFloat(v) }
        let ids = NSScreen.screens.compactMap { ($0.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber)?.uint32Value }
        let onlyBuiltin = !ids.isEmpty && ids.allSatisfy { CGDisplayIsBuiltin($0) != 0 }
        return onlyBuiltin ? 0.75 : 1.0
    }
    var clickThrough: Bool = UserDefaults.standard.object(forKey: "clickThrough") as? Bool ?? false
    var hideShare: Bool = UserDefaults.standard.object(forKey: "hideShare") as? Bool ?? false
    var buildLevel: Int = UserDefaults.standard.object(forKey: "build") as? Int ?? 2
    var hideFullscreen: Bool = UserDefaults.standard.object(forKey: "hideFullscreen") as? Bool ?? true

    /// je aktivní okno přes celou obrazovku (video, prezentace, fullscreen appka)?
    func fullscreenActive() -> Bool {
        let fp = NSWorkspace.shared.frontmostApplication?.processIdentifier ?? -1
        guard let w = W.wins.first(where: { $0.pid == fp }) else { return false }
        return W.scrs.contains { s in
            abs(s.frame.minX - w.rect.minX) < 2 && abs(s.frame.minY - w.rect.minY) < 2 &&
            abs(s.frame.width - w.rect.width) < 2 && abs(s.frame.height - w.rect.height) < 2
        }
    }
    func applySharing() { for w in NSApp.windows { w.sharingType = hideShare ? .none : .readOnly } }
    var now: Double = 0
    var userIdle = false
    var nextTalk: Double = 40
    var nextSocial: Double = 30
    var nextNote: Double = ProcessInfo.processInfo.environment["ZV_FAST"] != nil ? 15 : rnd(120, 240)
    var notesLevel: Int = UserDefaults.standard.object(forKey: "notesLevel") as? Int ?? 2
    var notesLevelEff: Int { Supporter.unlocked ? notesLevel : min(notesLevel, 1) }
    func noteInterval() -> Double { [0, rnd(900, 1500), rnd(360, 660), rnd(120, 240)][max(0, min(3, notesLevelEff))] }
    var nudgeRemain = CGPoint.zero
    weak var cursorHolder: Pet?
    var holdUntil: Double = 0
    var frontId = -1
    var timer: Timer?
    var tick = 0
    var last = CACurrentMediaTime()
    var laterQ: [(Double, () -> Void)] = []
    var saveT: Double = 60
    var rateHz: Double = 0
    var winT: Double = 0, idleT: Double = 0, dbgT: Double = 0, decT: Double = 0, dockT: Double = 60
    var lastM = CGPoint.zero, mouseV = CGPoint.zero, fastMouseT: Double = 0
    var typingS = 0, lastTypingComment: Double = -1000
    var idleSince: Double = 0
    var isNight = false
    var nextFood: Double = ProcessInfo.processInfo.environment["ZV_FAST"] != nil ? 5 : rnd(90, 200)

    func foodStep(_ dt: Double) {
        guard !userIdle, Supporter.unlocked else { return }
        nextFood -= dt
        guard nextFood <= 0 else { return }
        nextFood = ProcessInfo.processInfo.environment["ZV_FAST"] != nil ? 25 : rnd(120, 300)
        guard items.filter({ $0.isFood }).count < 3 else { return }
        let r = Double.random(in: 0..<1)
        let it = Item(r < 0.4 ? .tree : (r < 0.75 ? .worm : .mole))
        var spots: [(Host, CGFloat)] = []
        if case .mole = it.kind {} else if let aw = W.active, W.topUsable(aw), let x = W.visibleTopX(aw, near: rndf(aw.rect.minX + 60, aw.rect.maxX - 60)) { spots.append((.window(aw.id), x)) }
        for (i, sc) in W.scrs.enumerated() {
            let x = rndf(sc.visible.minX + 100, sc.visible.maxX - 100)
            if abs(x - home.x) > 90 { spots.append((.screen(i), x)) }
        }
        guard let sp = spots.randomElement() else { return }
        it.place(sp.0, sp.1)
        items.append(it)
        let delay: Double = { if case .tree = it.kind { return 3.8 }; return 0.8 }()
        later(delay) {
            guard !it.dead else { return }
            let cands = self.pets.filter { $0.phys == .surface && $0.carrying == nil && $0.tunnelStage == 0 }
                .sorted { ($0.pos - it.pos).len < ($1.pos - it.pos).len }
            for (i, p) in cands.enumerated() where i == 0 || chance(0.5) { p.wantTreat(it) }
            cands.first?.say(L.r(L.foodSpot), dur: 1.8)
        }
    }

    /// kdo jde kolem hovínka nebo zvratků, ten se ozve
    func messReactions() {
        for it in items {
            let poop: Bool
            switch it.kind { case .poop: poop = true; case .vomit: poop = false; default: continue }
            for p in pets where p.phys == .surface && p.idx != it.owner && !it.reacted.contains(p.idx) && (p.body - it.pos).len < 80 {
                it.reacted.insert(p.idx)
                p.say(L.r(poop ? L.poopReact : L.vomitReact), dur: 2)
                p.showEmote(poop ? .sweat : .anger, 1.6)
                if p.free && p.onFloor { p.play(.shake, 0.9) }
            }
        }
    }
    var k: [String: Double] = [:]
    func trialCheck() {
        let ud = UserDefaults.standard
        guard Supporter.trialUsed, !Supporter.unlocked, !Supporter.trialActive else { return }
        if pets.contains(where: { $0.isBaby }) { setBaby(false); ud.set(true, forKey: "baby") }
        if !ud.bool(forKey: "trialEndNotified"), let p = pets.first(where: { $0.phys == .surface }) {
            ud.set(true, forKey: "trialEndNotified")
            p.say(tx("Zkušební verze skončila. Bonusy se zamkly – podpoř medojedy, ať se vrátí! 🦡"), dur: 6)
        }
    }
    func refreshKnobs() { for key in Knobs.keys { k[key] = Knobs.v(key) } }
    let debug = ProcessInfo.processInfo.environment["ZV_DEBUG"] != nil

    func later(_ s: Double, _ f: @escaping () -> Void) { laterQ.append((now + s, f)) }

    var showcasePending = ProcessInfo.processInfo.environment["ZV_SHOWCASE"] != nil

    /// první spuštění: hned ukázat, co umí (stavění, tunel, med, rvačka, lísteček)
    func showcase() {
        let ad = adults
        guard ad.count >= 2 else { return }
        let a = ad[0], b = ad[1]
        for p in ad { p.energy = 1; p.fun = max(p.fun, 0.7) }
        nextSocial = 75; nextNote = 95
        for p in ad { p.homeT = 0; p.exitT = min(p.exitT, 0.6) }
        later(3) {
            a.say("Ahoj! Jsme medojedi. Nastavení najdeš pod 🦡 nahoře v liště.", dur: 5)
        }
        // A: hned něco stavět k nejbližšímu použitelnému oknu
        var tries = 0
        func tryBuild() {
            tries += 1
            guard tries < 12 else { _ = a.startTunnel(); return }
            guard a.free else { self.later(1.5) { tryBuild() }; return }
            let cands = ([W.active].compactMap { $0 } + W.wins.prefix(10))
                .filter { $0.rect.width >= 250 && $0.rect.height >= 150 && W.onScreen(P($0.rect.midX, $0.rect.minY + 30)) }
            for w in cands where a.startBuild(w) { a.showEmote(.bang, 1.2); return }
            self.later(2) { tryBuild() }
        }
        later(6) { tryBuild() }
        // B: otravuje, pak tunel
        later(8) {
            if b.free { b.goal = .follow(a, self.now + 10); b.say(L.r(L.follow), dur: 1.8) }
        }
        later(20) {
            if b.free || b.goal != nil {
                b.goal = nil
                if !b.startTunnel() { b.play(.dig, 1.6) }
            }
        }
        // med z nebe
        later(36) { if let w = W.active ?? W.wins.first { self.dropTreat(at: P(w.rect.midX, min(w.rect.maxY + 180, W.scrs[W.screenIndex(w.rect.center)].menuBottom - 30))) } else { self.dropTreat() } }
        // a nakonec rvačka
        later(58) {
            if a.free && b.free { a.goal = .meet(b, .fight, self.now + 30); self.wait(b, for: a); a.say(L.r(L.fightStart), dur: 1.6) }
            else { self.nextSocial = 0 }
        }
    }

    func start() {
        home = Home()
        decals = Decals()
        setCount(count, initial: true)
        lifeStart()
        if showcasePending { showcasePending = false; later(0.1) { self.showcase() } }
        if UserDefaults.standard.bool(forKey: "baby") && Supporter.unlocked { setBaby(true, initial: true) }
        setRate(30)
        if homeOn { home.panel.orderFrontRegardless() }
    }

    /// nora zapnutá/vypnutá (vypnutá: spí kde se zrovna nachází)
    var homeOn: Bool { UserDefaults.standard.object(forKey: "homeOn") as? Bool ?? true }
    func setHomeOn(_ on: Bool) {
        UserDefaults.standard.set(on, forKey: "homeOn")
        if on { if !hidden { home.panel.orderFrontRegardless() } }
        else { home.panel.orderOut(nil); for p in pets where p.phys == .home { p.exitHome() } }
    }

    var adults: [Pet] { pets.filter { !$0.isBaby } }

    func setCount(_ c0: Int, initial: Bool = false) {
        let c = c0
        count = c0
        UserDefaults.standard.set(c, forKey: "count")
        while adults.count > c, let i = pets.lastIndex(where: { !$0.isBaby }) { let p = pets.remove(at: i); p.saveNeeds(); p.destroy() }
        for i in 0..<c where !pets.contains(where: { $0.idx == i && !$0.isBaby }) && Life.alive(i) {
            spawnPet(i, initial: initial)
        }
        if let b = pets.first(where: { $0.isBaby }) { b.parent = adults.first }
    }

    func setBaby(_ on: Bool, initial: Bool = false) {
        UserDefaults.standard.set(on, forKey: "baby")
        if on, !pets.contains(where: { $0.isBaby }) {
            let b = Pet(9, baby: true)
            b.parent = adults.first
            b.phys = .home; b.homeT = 0; b.energy = max(b.energy, 0.65)
            b.exitT = initial ? 6.0 : 0.8
            pets.append(b)
        } else if !on, let i = pets.firstIndex(where: { $0.isBaby }) {
            let b = pets.remove(at: i); b.saveNeeds(); b.destroy()
        }
    }

    /// jednou týdně (pro nepodporovatele) lísteček s prosbou o podporu
    func weeklyAsk() {
        guard !Supporter.unlocked, !userIdle else { return }
        let ud = UserDefaults.standard
        let nowD = Date().timeIntervalSince1970
        let first = ud.object(forKey: "firstRun") as? Double ?? nowD
        if ud.object(forKey: "firstRun") == nil { ud.set(nowD, forKey: "firstRun") }
        let last = ud.object(forKey: "lastAsk") as? Double ?? 0
        guard nowD - first > 3 * 86400, nowD - last > 7 * 86400 else { return }
        guard let aw = W.active, let p = adults.filter({ $0.free }).randomElement() else { return }
        ud.set(nowD, forKey: "lastAsk")
        let it = Item(.support(tx("Líbíme se ti? 🦡\nPodpoř autora libovolnou částkou, ať má na zbytečně drahý kafe ☕\n\n(Tohle upozornění se ukáže jen jednou za týden.)") + "\n\n" + tx("Už od 1 espressa: 14 barev, mládě, jídlo z přírody, jazyky a další.")))
        it.carrier = p; it.pos = p.mouth
        items.append(it)
        p.carrying = it
        p.goal = .deliver(aw.id, now + 60)
        p.say("Něco ti nesu! Je to důležitý.", dur: 2.2)
    }

    func setRate(_ hz: Double) {
        if timer != nil && hz == rateHz { return }
        rateHz = hz
        timer?.invalidate()
        let t = Timer(timeInterval: 1.0 / hz, target: self, selector: #selector(stepTimer), userInfo: nil, repeats: true)
        t.tolerance = hz >= 60 ? 0.002 : (hz >= 30 ? 0.006 : 0.02)
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    @objc func stepTimer() { step() }

    func step() {
        tick += 1
        let tn = CACurrentMediaTime()
        let dt = min(0.12, tn - last)
        last = tn; now += dt
        let pressed = NSEvent.pressedMouseButtons != 0
        let fast = pressed || fight != nil || nudgeRemain != .zero || cursorHolder != nil
            || pets.contains { $0.phys == .air || $0.phys == .dragged || $0.cornerAnim != nil } || items.contains { $0.phys == .air } || props.values.contains { $0.falling || $0.grow < 1 }
        let moving = pets.contains { $0.phys == .surface && ($0.act == .walk || $0.act == .run || $0.oneShot != nil || $0.prepT > 0) }
            || pets.contains { $0.exitT >= 0 }
        let running = pets.contains { $0.phys == .surface && ($0.act == .run || $0.prepT > 0) }
        // 60 fps při skocích/tažení, 30 při běhu, 20 při chůzi, 12 když se nic neděje
        setRate(hidden ? 4 : fast ? 60 : running ? 30 : moving ? 20 : 12)
        // přes celou obrazovku (video, prezentace) se schovají
        fsT -= dt
        if fsT <= 0 {
            fsT = 1
            if hidden { W.refreshWindows() }
            let fs = hideFullscreen && fullscreenActive()
            if fs != autoHidden { autoHidden = fs; setHidden(userHidden || autoHidden) }
        }
        if hidden { return }

        let onWin = pets.contains { p in if case .window = p.host, p.phys == .surface { return true }; return false }
        if pressed { winT = min(winT, onWin ? 1.0 / 30 : 1.0 / 12) }
        winT -= dt
        if winT <= 0 {
            winT = pressed ? (onWin ? 1.0 / 30 : 1.0 / 12) : (moving ? 0.4 : 0.9)
            W.refreshWindows()
            if let f = W.active?.id, f != frontId { if frontId != -1 { reactToActive() }; frontId = f }
        }
        dockT -= dt
        if dockT <= 0 { dockT = 20; W.refreshDock() }
        idleT -= dt
        if idleT <= 0 { idleT = 1; refreshKnobs(); trialCheck(); checkIdle(); typingCheck(); lifeTick(); if tick % 60 < 2 { weeklyAsk(); Updates.check() } }
        if ProcessInfo.processInfo.environment["ZV_DEBUG"] != nil {
            dbgT -= dt
            if dbgT <= 0 { dbgT = 2; debugDump() }
        }
        let m = NSEvent.mouseLocation
        let mv = (m - lastM) * CGFloat(1 / max(dt, 0.001))
        mouseV = mouseV * 0.5 + mv * 0.5
        lastM = m
        if !pressed { laserCheck(m, dt) } else { fastMouseT = 0 }

        let due = laterQ.filter { $0.0 <= now }
        laterQ.removeAll { $0.0 <= now }
        due.forEach { $0.1() }
        for p in pets { p.update(dt, m) }
        for it in items { it.update(dt) }
        for g in graves { g.update(dt) }
        let gone = items.filter { $0.dead }
        if !gone.isEmpty { gone.forEach { $0.destroy() }; items.removeAll { $0.dead } }
        if let f = fight, !f.update(dt) { fight = nil }
        home.update(dt)
        socialStep(dt)
        notesStep(dt)
        foodStep(dt)
        if tick % 10 == 0 { messReactions() }
        talkStep(dt)
        nudgeStep(m)
        if let h = cursorHolder {
            if now < holdUntil && h.phys == .surface {
                let t = h.mouth
                CGWarpMouseCursorPosition(CGPoint(x: t.x, y: W.primaryH - t.y))
                CGAssociateMouseAndMouseCursorPosition(1)
            } else { cursorHolder = nil }
        }
        for pr in props.values { pr.update(dt) }
        for (k, pr) in props where pr.dead { pr.panel.orderOut(nil); props[k] = nil }
        for p in pets { p.render(m) }
        for it in items { it.render() }
        for g in graves { g.render() }
        home.render()
        decT -= dt
        if !decals.list.isEmpty || !decals.strips.isEmpty {
            if decT <= 0 || pressed { decT = 0.15; decals.refresh() }
        }
        saveT -= dt
        if saveT <= 0 { saveT = 60; pets.forEach { $0.saveNeeds() } }
    }

    func debugDump() {
        for p in pets {
            let gs: String
            switch p.goal { case .window?: gs = "window"; case .cursor?: gs = "cursor"; case .treat?: gs = "treat"; case .meet?: gs = "meet"
            case .chase?: gs = "chase"; case .flee?: gs = "flee"; case .follow?: gs = "follow"; case .home?: gs = "home"; case .deliver?: gs = "deliver"; case .build?: gs = "build"; case nil: gs = "-" }
            print(p.name, p.phys, p.host, "e\(p.edge)", p.act, p.oneShot.map { "\($0)" } ?? "", "goal:\(gs)", Int(p.pos.x), Int(p.pos.y))
        }
        print("rate", Int(rateHz), "items", items.count, "decals", decals.list.count, "strips", decals.strips.count)
        fflush(stdout)
    }

    /// rychle mávaný kurzor u medojeda = laserové ukazovátko, honí ho
    func laserCheck(_ m: CGPoint, _ dt: Double) {
        if mouseV.len > 1500 { fastMouseT += dt } else { fastMouseT = max(0, fastMouseT - dt * 2) }
        guard fastMouseT > 0.25, !userIdle else { return }
        for p in pets where p.free && p.onFloor && p.laserCD <= 0 {
            if (m - p.body).len < 300 && abs(m.y - p.pos.y) < 160 {
                p.laserCD = 10
                p.goal = .cursor(now + 5); p.act = .run
                p.showEmote(.bang, 1.2)
                if chance(0.4) { p.say(L.r(L.laser), dur: 1.4) }
            }
        }
    }

    /// dlouhé psaní -> komentář a přijde se dívat
    func typingCheck() {
        let k = CGEventSource.secondsSinceLastEventType(.combinedSessionState, eventType: .keyDown)
        if k < 1.5 { typingS += 1 } else if k > 5 { typingS = 0 }
        guard typingS >= 45, now - lastTypingComment > 900, annoy > 0 else { return }
        lastTypingComment = now; typingS = 0
        if let p = pets.filter({ $0.free }).randomElement() {
            p.say(L.r(L.typing), dur: 2.6)
            if let aw = W.active, p.host != .window(aw.id) { p.goal = .window(aw.id, now + 75) }
        }
    }

    func reactToActive() {
        guard let aw = W.active, !userIdle else { return }
        for (i, p) in pets.enumerated() where p.free && chance(i == 0 ? 0.8 : 0.45) {
            later(rnd(0.6, 2.0)) {
                guard p.free, !p.isBad(aw.id), p.host != .window(aw.id) else { return }
                p.goal = .window(aw.id, self.now + 75)
                if chance(0.3) { p.say(L.r(L.newWindow), dur: 1.8) }
            }
        }
    }

    func checkIdle() {
        let types: [CGEventType] = [.mouseMoved, .keyDown, .leftMouseDown, .scrollWheel, .rightMouseDown]
        let idle = types.map { CGEventSource.secondsSinceLastEventType(.combinedSessionState, eventType: $0) }.min() ?? 0
        let h = Calendar.current.component(.hour, from: Date())
        isNight = h >= 23 || h < 6
        if !userIdle && idle > 300 && ProcessInfo.processInfo.environment["ZV_NOIDLE"] == nil {
            userIdle = true
            idleSince = now - idle
        } else if userIdle && idle < 2 {
            userIdle = false
            let away = now - idleSince
            for (i, p) in pets.enumerated() where p.phys == .home { p.homeT = 1.5 + Double(i) * 2; p.energy = max(p.energy, 0.65) }
            if away > 1800 {
                later(5) {
                    let line = away > 4 * 3600 && h < 12 ? tx("Dobré ráno!") : L.r(L.back)
                    self.pets.first { $0.phys == .surface }?.say(line, dur: 2.6)
                }
            }
        }
    }

    // MARK: social

    func socialStep(_ dt: Double) {
        let ad = adults
        guard ad.count >= 2, !userIdle, fight == nil else { return }
        nextSocial -= dt * (pets.contains { $0.fun < 0.3 } ? 1.6 : 1)
        guard nextSocial <= 0 else { return }
        let a = ad[0], b = ad[1]
        guard a.free && b.free else { nextSocial = 6; return }
        nextSocial = rnd(30, 70) / max(0.15, E.k["playMul"] ?? 1)
        if (E.k["playMul"] ?? 1) < 0.05 { return }
        let (x, y) = chance(0.5) ? (a, b) : (b, a)
        let r = Double.random(in: 0..<1)
        if r < 0.2 {
            x.goal = .meet(y, .greet, now + 30); wait(y, for: x)
        } else if r < 0.42 {
            startChase(x, y, tags: 0)
        } else if r < 0.58 {
            x.goal = .meet(y, .fight, now + 30); wait(y, for: x)
            x.say(L.r(L.fightStart), dur: 1.6)
        } else if r < 0.7 {
            x.play(.bow, 1.4); x.showEmote(.note, 2)
            later(0.9) { if y.free { y.play(.bow, 1.2) } }
            later(2.2) { if x.free && y.free { self.startChase(y, x, tags: 0) } }
        } else if r < 0.82 {
            x.goal = .meet(y, .bonk, now + 30); wait(y, for: x)
        } else if r < 0.92 {
            y.goal = .follow(x, now + 20); x.act = .walk; x.actT = 20
            y.say(L.r(L.follow), dur: 1.8)
        } else {
            x.hideSeek = true; x.goal = .home(now + 60)
            x.say("Schovávaná! Hledej!", dur: 2)
            y.showEmote(.question, 5); y.play(.look, 3)
        }
    }

    func wait(_ y: Pet, for x: Pet) {
        y.act = .idle; y.actT = 12
        y.faceToward(x.pos.x)
    }

    func startChase(_ x: Pet, _ y: Pet, tags: Int) {
        x.goal = .chase(y, now + 14); y.goal = .flee(x, now + 14)
        y.oneShot = nil; x.oneShot = nil
        y.showEmote(.bang, 1.4)
        x.say(tags == 0 ? L.r(L.chase) : "Mám tě! Teď ty!", dur: 1.6)
        x.tags = tags
    }

    func met(_ a: Pet, _ b: Pet, _ kind: Social) {
        if b.phys != .surface { return }
        b.goal = nil; b.oneShot = nil
        a.faceToward(b.pos.x); b.faceToward(a.pos.x)
        switch kind {
        case .greet:
            a.play(.sniff, 1.8); b.play(.sniffair, 1.8)
            a.showEmote(.heart, 2.4); b.showEmote(.heart, 2.4)
            a.say(L.r(L.greetA), dur: 1.8)
            later(1.2) { b.say(L.r(L.greetB), dur: 1.6) }
            a.fun = min(1, a.fun + 0.15); b.fun = min(1, b.fun + 0.15)
        case .fight:
            fight = FightCloud(a, b)
        case .bonk:
            a.say("BONK!", dur: 1.4)
            for (p, o) in [(a, b), (b, a)] {
                let back: CGFloat = p.pos.x < o.pos.x ? -1 : 1
                if p.onFloor { p.dizzyOnLand = true; p.launch(P(p.pos.x + back * 45, p.pos.y)) } else { p.play(.dizzy, 1.8) }
            }
            a.showEmote(.star, 2); b.showEmote(.star, 2)
            a.fun = min(1, a.fun + 0.2); b.fun = min(1, b.fun + 0.2)
        }
    }

    func caught(_ a: Pet, _ b: Pet) {
        if b.phys != .surface { return }
        b.goal = nil
        if a.tags < 3 && chance(0.55) {
            b.showEmote(.bang, 1.2)
            later(0.6) { self.startChase(b, a, tags: a.tags + 1) }
        } else if chance(0.6) {
            fight = FightCloud(a, b)
        } else {
            met(a, b, .greet)
        }
    }

    // MARK: notes, talk, treats

    func notesStep(_ dt: Double) {
        guard notesLevelEff > 0, !userIdle else { return }
        nextNote -= dt
        guard nextNote <= 0 else { return }
        nextNote = noteInterval()
        guard items.filter({ $0.isNote }).count < 3, let aw = W.active,
              let p = adults.filter({ $0.free }).randomElement() else { nextNote = 120; return }
        let it = Item(.note(L.r(L.notes)))
        it.carrier = p
        it.pos = p.mouth
        items.append(it)
        p.carrying = it
        p.goal = .deliver(aw.id, now + 60)
        p.say(L.r(L.carryNote), dur: 2)
    }

    func talkStep(_ dt: Double) {
        guard talk, annoy > 0, !userIdle else { return }
        nextTalk -= dt
        guard nextTalk <= 0 else { return }
        nextTalk = (annoy >= 2 ? rnd(25, 60) : rnd(60, 150)) / max(0.15, E.k["talkMul"] ?? 1)
        if (E.k["talkMul"] ?? 1) < 0.05 { return }
        if adults.count >= 2 && chance(0.3) && startDialogue() { return }
        if let p = pets.filter({ $0.phys == .surface && $0.act != .sleep && $0.speech.t <= 0 }).randomElement() {
            p.say(contextLine(), dur: 3)
        }
    }

    func contextLine() -> String {
        let app = NSWorkspace.shared.frontmostApplication?.localizedName ?? ""
        let la = app.lowercased()
        let cal = Calendar.current, d = Date()
        let h = cal.component(.hour, from: d), mi = cal.component(.minute, from: d), wd = cal.component(.weekday, from: d)
        if chance(0.08) { return L.r(L.facts) }
        var pools: [[String]] = [L.idle, L.idle, L.dontCare, L.dontCare]
        if !app.isEmpty && !["Badgertop", "Zviratka", "loginwindow", "ScreenSaverEngine", "Dock", "SystemUIServer", "UserNotificationCenter", "CoreServicesUIAgent"].contains(app) {
            if let spec = L.apps.first(where: { la.contains($0.0) })?.1 { pools += [spec, spec] }
            if chance(0.15) { return L.r(L.appTemplates).replacingOccurrences(of: "%@", with: app) }
        }
        if h >= 23 || h < 5 {
            if chance(0.3) { return String(format: tx("Je %d:%02d. Jdi spát!"), h, mi) }
            pools += [L.night, L.night]
        } else if h < 9 { pools.append(L.morning) }
        else if h >= 11 && h < 13 { pools.append(L.lunch) }
        else if h >= 14 && h < 17 { pools.append(L.afternoon) }
        else if h >= 18 { pools.append(L.evening) }
        if wd == 2 && h < 12 { pools.append(L.monday) }
        if wd == 6 && h >= 12 { pools.append(L.friday) }
        if wd == 1 || wd == 7 { pools.append(L.weekend) }
        if h >= 9 && h <= 18 { pools.append(L.health) }
        return L.r(pools.randomElement()!)
    }

    /// krátký rozhovor obou medojedů
    func startDialogue() -> Bool {
        let ps = adults.filter { $0.phys == .surface && $0.act != .sleep && $0.speech.t <= 0 }.shuffled()
        guard ps.count >= 2 else { return false }
        let first = L.r(L.dialogues.map { $0[0] })
        guard let dlg = L.dialogues.first(where: { $0[0] == first }) else { return false }
        let a = ps[0], b = ps[1]
        if a.onFloor && b.onFloor && a.host == b.host { a.faceToward(b.pos.x); b.faceToward(a.pos.x) }
        for (i, line) in dlg.enumerated() {
            let sp = i % 2 == 0 ? a : b
            later(Double(i) * 2.4) { sp.say(line, dur: 2.5) }
        }
        nextTalk += Double(dlg.count) * 2.4
        return true
    }

    func dropTreat(at p: CGPoint? = nil) {
        var pt = p
        if pt == nil {
            if let w = W.active ?? W.wins.first {
                pt = P(rndf(w.rect.minX + 40, w.rect.maxX - 40), min(w.rect.maxY + 200, W.scrs[W.screenIndex(w.rect.center)].menuBottom - 30))
            } else { pt = P(W.scrs[0].frame.midX, W.scrs[0].menuBottom - 30) }
        }
        let it = Item(.honey)
        it.pos = pt!
        it.phys = .air
        items.append(it)
    }

    func treatLanded(_ it: Item) {
        let cands = pets.filter { $0.phys == .surface && $0.carrying == nil }
        for p in cands { p.wantTreat(it) }
        cands.randomElement()?.say(L.r(L.honeySpotted), dur: 1.5)
    }

    func nudge(_ v: CGPoint) { nudgeRemain = nudgeRemain + v }
    func nudgeStep(_ m: CGPoint) {
        guard nudgeRemain.len > 1 else { nudgeRemain = .zero; return }
        let s = nudgeRemain * 0.3
        nudgeRemain = nudgeRemain - s
        let t = m + s
        CGWarpMouseCursorPosition(CGPoint(x: t.x, y: W.primaryH - t.y))
        CGAssociateMouseAndMouseCursorPosition(1)
    }
    func grabCursor(_ p: Pet, _ dur: Double) { cursorHolder = p; holdUntil = now + dur }

    func setHidden(_ h: Bool) {
        if hidden && !h { laterQ.removeAll { now - $0.0 > 2 } }
        hidden = h
        for p in pets where h { p.panel.orderOut(nil); p.speech.hide(); p.shown = false }
        for it in items { if h { it.panel.orderOut(nil) } else { it.panel.orderFrontRegardless() } }
        for pr in props.values { if h { pr.panel.orderOut(nil) } else { pr.panel.orderFrontRegardless() } }
        if h { for g in graves { g.panel.orderOut(nil) } }
        if h { home.panel.orderOut(nil); decals.hideAll(); fight?.panel.orderOut(nil) }
        else { if homeOn { home.panel.orderFrontRegardless() }; fight?.panel.orderFrontRegardless() }
        last = CACurrentMediaTime()
    }
}

// MARK: - App

@MainActor final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    var status: NSStatusItem!

    func applicationDidFinishLaunching(_ note: Notification) {
        // přenos nastavení ze staré verze (Zvířátka, local.zviratka)
        let udm = UserDefaults.standard
        if udm.object(forKey: "migratedOld") == nil {
            udm.set(true, forKey: "migratedOld")
            if let old = UserDefaults(suiteName: "local.zviratka")?.persistentDomain(forName: "local.zviratka") {
                for (k, v) in old where udm.object(forKey: k) == nil { udm.set(v, forKey: k) }
            }
        }
        W.refreshScreens(); W.refreshWindows(); W.refreshDock()
        status = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        status.button?.title = "🦡"
        let menu = NSMenu()
        menu.delegate = self
        status.menu = menu
        let ud = UserDefaults.standard
        if ud.object(forKey: "axAsked") == nil {
            let newInstall = ud.object(forKey: "count") == nil && ud.object(forKey: "annoy") == nil
            ud.set(true, forKey: "axAsked")
            if newInstall { E.showcasePending = true }
            // tvar Docku se teď čte bez Zpřístupnění → při prvním spuštění se na nic neptáme
            if false && newInstall && !AXIsProcessTrusted() {
                // nejdřív vlastními slovy vysvětlit proč, teprve pak systémový dotaz
                Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { _ in
                    MainActor.assumeIsolated {
                        NSApp.activate(ignoringOtherApps: true)
                        let a = NSAlert()
                        a.messageText = tx("Jedna drobnost: Zpřístupnění")
                        a.informativeText = tx("Medojedi potřebují Zpřístupnění jen proto, aby znali přesný tvar Docku – pak lezou po něm, a ne za ním.\n\nNečtou obsah oken ani to, co píšeš, a nic nikam neposílají. Klidně to odmítni, aplikace funguje i bez toho (povolit jde později v menu 🦡).")
                        a.addButton(withTitle: tx("Povolit…"))
                        a.addButton(withTitle: tx("Teď ne"))
                        if a.runModal() == .alertFirstButtonReturn {
                            let opts = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
                            _ = AXIsProcessTrustedWithOptions(opts)
                        }
                    }
                }
            }
        }
        E.start()
        NotificationCenter.default.addObserver(self, selector: #selector(screensChanged), name: NSApplication.didChangeScreenParametersNotification, object: nil)
        let wc = NSWorkspace.shared.notificationCenter
        wc.addObserver(self, selector: #selector(appActivated), name: NSWorkspace.didActivateApplicationNotification, object: nil)
        wc.addObserver(self, selector: #selector(appsChanged), name: NSWorkspace.didLaunchApplicationNotification, object: nil)
        wc.addObserver(self, selector: #selector(appsChanged), name: NSWorkspace.didTerminateApplicationNotification, object: nil)
    }

    func applicationWillTerminate(_ n: Notification) { E.pets.forEach { $0.saveNeeds() }; UserDefaults.standard.set(Life.now, forKey: "lastSeen") }

    @objc func screensChanged() { W.refreshScreens(); W.refreshDock(); E.home.clampX(); E.winT = 0; E.petScale = Engine.autoScale() }
    @objc func appActivated() { E.winT = min(E.winT, 0.08) }
    @objc func appsChanged() { E.dockT = min(E.dockT, 1); E.winT = min(E.winT, 0.3) }

    var menuOpen = false
    func menuWillOpen(_ menu: NSMenu) { menuOpen = true }
    func menuDidClose(_ menu: NSMenu) { menuOpen = false }

    func menuNeedsUpdate(_ menu: NSMenu) {
        // během otevřeného menu nepřestavovat (jinak se zavírají podmenu)
        if menuOpen { return }
        menu.removeAllItems()
        let head = NSMenuItem(title: tx("Medojedi"), action: nil, keyEquivalent: "")
        head.isEnabled = false
        menu.addItem(head)
        for p in E.pets {
            let wh = p.phys == .home ? tx(" (v noře)") : ""
            menu.addItem(MenuItem("\(p.name)\(wh)   \(p.needsText())", enabled: false) {})
        }
        for i in 0..<E.count where !Life.alive(i) {
            menu.addItem(MenuItem("🍼 " + tx("Brzy se narodí nový medojed…"), enabled: false) {})
        }
        let fam = "🏠 " + tx("Nora") + ": " + Life.levelText + (Life.streakAlive && Life.streak > 0 ? "   🔥 " + String(format: tx("%d dní v kuse"), Life.streak) : "")
        menu.addItem(MenuItem(fam, enabled: false) {})
        menu.addItem(.separator())
        menu.addItem(MenuItem("Hodit med 🍯", key: "b") { E.dropTreat() })
        menu.addItem(MenuItem("Pojďte sem 📣") {
            for p in E.pets {
                if p.phys == .home { p.callOut() }
                else if p.phys == .surface { p.oneShot = nil; if p.act == .sleep { p.act = .idle }; p.goal = .cursor(E.now + 25); p.jumpCD = 0; p.navCD = 0 }
            }
        })
        menu.addItem(MenuItem("Hrajte si! 🎾") {
            E.nextSocial = 0
            for p in E.pets where p.phys == .surface { p.goal = nil; p.oneShot = nil; if p.act == .sleep { p.act = .idle } }
            for p in E.pets { p.callOut() }
        })
        let homeItem = NSMenuItem(title: tx("Nora"), action: nil, keyEquivalent: "")
        let hm = NSMenu()
        hm.addItem(MenuItem("Všichni domů 🏠") { for p in E.pets where p.phys == .surface { p.goal = .home(E.now + 120) } })
        hm.addItem(MenuItem("Zavolat ven") { for p in E.pets { p.callOut() } })
        hm.addItem(MenuItem("Přesunout noru do rohu") { E.home.resetCorner() })
        hm.addItem(.separator())
        hm.addItem(MenuItem("Zobrazit noru", on: E.homeOn) { E.setHomeOn(!E.homeOn) })
        homeItem.submenu = hm
        menu.addItem(homeItem)
        menu.addItem(.separator())

        menu.addItem(MenuItem("Nastavení…", key: ",") { SettingsWindow.show() })
        let li = NSMenuItem(title: L.lang == .en ? "Language" : tx("Jazyk") + " / Language", action: nil, keyEquivalent: "")
        let lm = NSMenu()
        for l in Lang.allCases {
            let locked = l.premium && !Supporter.unlocked
            lm.addItem(MenuItem(l.title + (locked ? "  🔒" : ""), on: L.lang == l) {
                if locked { Supporter.offer(l.title) } else { UserDefaults.standard.set(l.rawValue, forKey: "lang") }
            })
        }
        li.submenu = lm
        menu.addItem(li)
        let hasBaby = E.pets.contains { $0.isBaby }
        menu.addItem(MenuItem(tx("Mládě") + (Supporter.unlocked ? "" : "  🔒"), on: hasBaby) {
            if !Supporter.unlocked { Supporter.offer(tx("Mládě")) } else { E.setBaby(!hasBaby) }
        })
        let cnt = NSMenuItem(title: tx("Počet medojedů"), action: nil, keyEquivalent: "")
        let cm = NSMenu()
        for c in [1, 2] {
            let locked = false
            cm.addItem(MenuItem(tx(c == 1 ? "Jeden" : "Dva (hrají si spolu)") + (locked ? "  🔒" : ""), on: E.adults.count == c) {
                if locked { Supporter.offer(tx("Dva (hrají si spolu)")) } else { E.setCount(c) }
            })
        }
        cnt.submenu = cm
        menu.addItem(cnt)
        let ann = NSMenuItem(title: tx("Otravnost"), action: nil, keyEquivalent: "")
        let annM = NSMenu()
        for (lvl, title) in [(0, "😴  Klid – jen si žijou"), (1, "🙂  Trochu"), (2, "😈  Hodně")] {
            let locked = lvl == 2 && !Supporter.unlocked
            annM.addItem(MenuItem(tx(title) + (locked ? "  🔒" : ""), on: E.annoy == lvl) {
                if locked { Supporter.offer(tx(title)); return }
                E.annoy = lvl; UserDefaults.standard.set(lvl, forKey: "annoy")
                for p in E.pets { p.annoyT = lvl >= 2 ? rnd(5, 20) : rnd(40, 90) }
                E.nextTalk = lvl >= 2 ? 3 : 30
            })
        }
        ann.submenu = annM
        menu.addItem(ann)
        menu.addItem(MenuItem("Povídají si", on: E.talk) { E.talk.toggle(); UserDefaults.standard.set(E.talk, forKey: "talk") })
        let ni = NSMenuItem(title: tx("Lístečky"), action: nil, keyEquivalent: "")
        let nm = NSMenu()
        for (lvl, t) in [(0, "Vypnuto"), (1, "Občas (~20 min)"), (2, "Často (~8 min)"), (3, "Pořád (~3 min)")] {
            let locked = lvl > 1 && !Supporter.unlocked
            nm.addItem(MenuItem(tx(t) + (locked ? "  🔒" : ""), on: E.notesLevelEff == lvl) {
                if locked { Supporter.offer(tx("Lístečky")); return }; E.notesLevel = lvl; UserDefaults.standard.set(lvl, forKey: "notesLevel"); if lvl > 0 { E.nextNote = E.noteInterval() } })
        }
        nm.addItem(.separator())
        nm.addItem(MenuItem("Donést lísteček teď ✉️") { if E.notesLevel == 0 { E.notesLevel = 1 }; E.nextNote = 0 })
        ni.submenu = nm
        menu.addItem(ni)
        menu.addItem(MenuItem("Schovat všechno", key: "h", on: E.userHidden) { E.userHidden.toggle(); E.setHidden(E.userHidden || E.autoHidden) })
        let sz = NSMenuItem(title: tx("Velikost"), action: nil, keyEquivalent: "")
        let szm = NSMenu()
        let manual = UserDefaults.standard.object(forKey: "scale") != nil
        szm.addItem(MenuItem("Automaticky", on: !manual) { UserDefaults.standard.removeObject(forKey: "scale"); E.petScale = Engine.autoScale() })
        szm.addItem(.separator())
        for (v, t) in [(0.75, "Malí"), (1.0, "Normální"), (1.25, "Velcí"), (1.5, "Obří")] as [(Double, String)] {
            szm.addItem(MenuItem(t, on: manual && abs(Double(E.petScale) - v) < 0.01) { E.petScale = CGFloat(v); UserDefaults.standard.set(v, forKey: "scale") })
        }
        sz.submenu = szm
        menu.addItem(sz)
        let bi = NSMenuItem(title: tx("Stavění"), action: nil, keyEquivalent: "")
        let bim = NSMenu()
        for (lvl, t) in [(0, "Vůbec"), (1, "Málo"), (2, "Normálně"), (3, "Hodně 🪵")] {
            let locked = false
            bim.addItem(MenuItem(tx(t) + (locked ? "  🔒" : ""), on: E.buildLevel == lvl) {
                if locked { Supporter.offer(tx("Stavění")) } else { E.buildLevel = lvl; UserDefaults.standard.set(lvl, forKey: "build") }
            })
        }
        bi.submenu = bim
        menu.addItem(bi)
        let opt = NSMenuItem(title: tx("Chování"), action: nil, keyEquivalent: "")
        let om = NSMenu()
        om.addItem(MenuItem("Schovat při videu / celé obrazovce", on: E.hideFullscreen) { E.hideFullscreen.toggle(); UserDefaults.standard.set(E.hideFullscreen, forKey: "hideFullscreen") })
        om.addItem(MenuItem("Nebýt vidět při sdílení obrazovky", on: E.hideShare) { E.hideShare.toggle(); UserDefaults.standard.set(E.hideShare, forKey: "hideShare"); E.applySharing() })
        om.addItem(MenuItem("Neblokovat kliknutí (nejdou chytit)", on: E.clickThrough) { E.clickThrough.toggle(); UserDefaults.standard.set(E.clickThrough, forKey: "clickThrough") })
        opt.submenu = om
        menu.addItem(opt)
        menu.addItem(.separator())
        let login = SMAppService.mainApp.status == .enabled
        menu.addItem(MenuItem("Spouštět po přihlášení", on: login) {
            if login { try? SMAppService.mainApp.unregister() } else { try? SMAppService.mainApp.register() }
        })
        if !AXIsProcessTrusted() {
            menu.addItem(MenuItem("Přesná poloha Docku (Zpřístupnění)…") {
                let opts = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
                _ = AXIsProcessTrustedWithOptions(opts)
            })
        }
        if Supporter.unlocked {
            menu.addItem(MenuItem("❤️ Podporovatel – díky!", enabled: false) {})
        } else {
            menu.addItem(MenuItem("☕ Upgradovat nebo podpořit…") { Supporter.buy() })
            menu.addItem(MenuItem("🔑 Zadat licenční klíč…") { Supporter.askKey() })
        }
        menu.addItem(MenuItem("O aplikaci…") {
            NSApp.activate(ignoringOtherApps: true)
            let credits = NSAttributedString(string: tx("Dva pixeloví medojedi, kteří lezou po tvých oknech, staví si žebříky a je jim všechno u prdele.\n\nNic neodesílá na internet (kromě jednorázového ověření licenčního klíče). Čte jen polohu oken, ne jejich obsah."),
                                             attributes: [.font: NSFont.systemFont(ofSize: 11), .foregroundColor: NSColor.labelColor])
            NSApp.orderFrontStandardAboutPanel(options: [.credits: credits])
        })
        menu.addItem(MenuItem("Konec", key: "q") { NSApp.terminate(nil) })
    }
}

@MainActor var W: World!
@MainActor var E: Engine!
@MainActor var appDelegate: AppDelegate?
MainActor.assumeIsolated {
    W = World()
    E = Engine()
    let app = NSApplication.shared
    appDelegate = AppDelegate()
    app.delegate = appDelegate
    app.setActivationPolicy(.accessory)
    app.run()
}
