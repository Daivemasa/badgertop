// Vykreslí propagační obrázky pro GitHub / web z pixelových sprajtů aplikace.
// swiftc tools/promo/main.swift Pixel.swift -o promo && ./promo docs/images
import Cocoa
func P(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x, y: y) }
extension CGPoint {
    static func + (a: CGPoint, b: CGPoint) -> CGPoint { P(a.x + b.x, a.y + b.y) }
    static func - (a: CGPoint, b: CGPoint) -> CGPoint { P(a.x - b.x, a.y - b.y) }
    static func * (a: CGPoint, k: CGFloat) -> CGPoint { P(a.x * k, a.y * k) }
    var len: CGFloat { hypot(x, y) }
    func dot(_ b: CGPoint) -> CGFloat { x * b.x + y * b.y }
}
func clamp(_ v: CGFloat, _ a: CGFloat, _ b: CGFloat) -> CGFloat { max(a, min(b, v)) }
func C(_ r: Int, _ g: Int, _ b: Int, _ a: CGFloat = 1) -> NSColor { NSColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: a) }

func canvas(_ w: CGFloat, _ h: CGFloat, _ scale: CGFloat, _ path: String, _ draw: (CGContext) -> Void) {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(w * scale), pixelsHigh: Int(h * scale), bitsPerSample: 8, samplesPerPixel: 4,
                               hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    rep.size = NSSize(width: w, height: h)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    let ctx = NSGraphicsContext.current!.cgContext
    ctx.interpolationQuality = .none
    draw(ctx)
    NSGraphicsContext.restoreGraphicsState()
    try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: path))
}

/// medojed: střed spodní hrany (nohy) v bodě p, otočený tak, že „nahoru“ = n
func badger(_ ctx: CGContext, _ a: Anim, _ f: Int, at p: CGPoint, size s: CGFloat, skin: Int = 0, face: Bool = true, n: CGPoint = P(0, 1), gray: CGFloat = 0, alpha: CGFloat = 1) {
    let img = Badger.image(a, f, blink: false, skin: skin)
    ctx.saveGState()
    ctx.setAlpha(alpha)
    ctx.translateBy(x: p.x, y: p.y)
    ctx.rotate(by: atan2(n.y, n.x) - .pi / 2)
    ctx.scaleBy(x: face ? 1 : -1, y: 1)
    let r = CGRect(x: -s / 2, y: 0, width: s, height: s * 0.75)
    if gray > 0 {
        ctx.beginTransparencyLayer(auxiliaryInfo: nil)
        ctx.draw(img, in: r)
        ctx.setBlendMode(.sourceAtop)
        ctx.setFillColor(NSColor(white: 0.62, alpha: 0.42 * gray).cgColor); ctx.fill(r)
        ctx.endTransparencyLayer()
    } else { ctx.draw(img, in: r) }
    ctx.restoreGState()
}

func text(_ s: String, _ p: CGPoint, _ size: CGFloat, _ weight: NSFont.Weight = .regular, _ color: NSColor = .black, center: Bool = false, width: CGFloat = 0) {
    let ps = NSMutableParagraphStyle(); ps.alignment = center ? .center : .left
    let at: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: size, weight: weight), .foregroundColor: color, .paragraphStyle: ps]
    if center { (s as NSString).draw(in: NSRect(x: p.x - width / 2, y: p.y, width: width, height: size * 1.5), withAttributes: at) }
    else { (s as NSString).draw(at: p, withAttributes: at) }
}

func bubble(_ s: String, tail: CGPoint, _ size: CGFloat = 15) {
    let at: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: size, weight: .semibold), .foregroundColor: NSColor(white: 0.1, alpha: 1)]
    let br = (s as NSString).size(withAttributes: at)
    let r = NSRect(x: tail.x - br.width / 2 - 12, y: tail.y + 10, width: br.width + 24, height: br.height + 14)
    NSColor(white: 0, alpha: 0.18).setFill(); NSBezierPath(roundedRect: r.offsetBy(dx: 0, dy: -2), xRadius: 10, yRadius: 10).fill()
    NSColor.white.setFill(); NSBezierPath(roundedRect: r, xRadius: 10, yRadius: 10).fill()
    let t = NSBezierPath(); t.move(to: P(tail.x - 7, r.minY + 1)); t.line(to: tail); t.line(to: P(tail.x + 7, r.minY + 1)); t.close(); t.fill()
    (s as NSString).draw(at: P(r.minX + 12, r.minY + 7), withAttributes: at)
}

func window(_ r: NSRect, _ title: String, dark: Bool = false) {
    let body = dark ? C(40, 42, 48) : C(250, 250, 252)
    NSColor(white: 0, alpha: 0.28).setFill(); NSBezierPath(roundedRect: r.offsetBy(dx: 0, dy: -8).insetBy(dx: -6, dy: -4), xRadius: 16, yRadius: 16).fill()
    body.setFill(); NSBezierPath(roundedRect: r, xRadius: 12, yRadius: 12).fill()
    (dark ? C(52, 54, 60) : C(236, 236, 240)).setFill()
    let tb = NSBezierPath(roundedRect: NSRect(x: r.minX, y: r.maxY - 38, width: r.width, height: 38), xRadius: 12, yRadius: 12); tb.fill()
    NSRect(x: r.minX, y: r.maxY - 38, width: r.width, height: 14).fill()
    for (i, c) in [C(255, 95, 87), C(255, 189, 46), C(40, 200, 64)].enumerated() {
        c.setFill(); NSBezierPath(ovalIn: NSRect(x: r.minX + 16 + CGFloat(i) * 20, y: r.maxY - 25, width: 12, height: 12)).fill()
    }
    text(title, P(r.midX, r.maxY - 28), 13, .semibold, dark ? C(220, 220, 225) : C(70, 70, 80), center: true, width: 300)
    // obsah: řádky textu
    var y = r.maxY - 70
    var k = 0
    while y > r.minY + 24 {
        let w = (r.width - 60) * [0.92, 0.75, 0.85, 0.6, 0.9, 0.4][k % 6]
        (dark ? C(80, 82, 90) : C(222, 224, 230)).setFill()
        NSBezierPath(roundedRect: NSRect(x: r.minX + 30, y: y, width: w, height: 10), xRadius: 5, yRadius: 5).fill()
        y -= k % 6 == 5 ? 34 : 22; k += 1
    }
}

func ladder(_ base: CGPoint, top: CGPoint, px: CGFloat) {
    let dir = top - base, len = dir.len
    let u = dir * (1 / len), nrm = P(-u.y, u.x)
    let wood = C(166, 112, 64), dark = C(90, 60, 36)
    func seg(_ a: CGPoint, _ b: CGPoint, _ w: CGFloat, _ c: NSColor) {
        let p = NSBezierPath(); p.lineWidth = w; p.lineCapStyle = .square; p.move(to: a); p.line(to: b); c.setStroke(); p.stroke()
    }
    for side in [-1.0, 1.0] as [CGFloat] {
        let off = nrm * (side * px * 4)
        seg(base + off, top + off, px * 2.4, dark); seg(base + off, top + off, px * 1.3, wood)
    }
    var t: CGFloat = px * 6
    while t < len - px * 3 {
        let c = base + u * t
        seg(c - nrm * (px * 4), c + nrm * (px * 4), px * 1.8, dark); seg(c - nrm * (px * 4), c + nrm * (px * 4), px * 0.9, wood)
        t += px * 7
    }
}

func wallpaper(_ w: CGFloat, _ h: CGFloat) {
    let g = NSGradient(colors: [C(255, 196, 120), C(250, 150, 110), C(150, 110, 170), C(70, 80, 140)], atLocations: [0, 0.3, 0.7, 1], colorSpace: .deviceRGB)!
    g.draw(in: NSRect(x: 0, y: 0, width: w, height: h), angle: 90)
    // pixelové hory
    C(60, 70, 110, 0.55).setFill()
    let m = NSBezierPath(); m.move(to: P(0, 0))
    var x: CGFloat = 0
    for (i, hh) in [180, 260, 210, 320, 240, 290, 200, 250, 170].enumerated() { x = CGFloat(i) * w / 8; m.line(to: P(x, CGFloat(hh))) }
    m.line(to: P(w, 0)); m.close(); m.fill()
}

func menubar(_ w: CGFloat, _ h: CGFloat) {
    NSColor(white: 1, alpha: 0.35).setFill(); NSRect(x: 0, y: h - 30, width: w, height: 30).fill()
    text("", P(18, h - 24), 16, .regular, .black)
    text("Finder   File   Edit   View   Go   Window   Help", P(48, h - 23), 13, .medium, C(30, 30, 35))
    text("🦡", P(w - 250, h - 25), 16)
    text("🔋  Fri 9:41", P(w - 120, h - 23), 13, .medium, C(30, 30, 35))
}

func dock(_ w: CGFloat) -> NSRect {
    let r = NSRect(x: w / 2 - 300, y: 8, width: 600, height: 72)
    NSColor(white: 1, alpha: 0.32).setFill(); NSBezierPath(roundedRect: r, xRadius: 22, yRadius: 22).fill()
    NSColor(white: 1, alpha: 0.5).setStroke(); let b = NSBezierPath(roundedRect: r, xRadius: 22, yRadius: 22); b.lineWidth = 1; b.stroke()
    let cols = [C(70, 150, 245), C(250, 200, 60), C(240, 90, 80), C(110, 200, 120), C(160, 110, 230), C(60, 190, 200), C(250, 140, 60), C(120, 120, 130), C(230, 80, 150)]
    for (i, c) in cols.enumerated() {
        c.setFill(); NSBezierPath(roundedRect: NSRect(x: r.minX + 18 + CGFloat(i) * 64, y: r.minY + 10, width: 52, height: 52), xRadius: 12, yRadius: 12).fill()
    }
    return r
}

func tomb(_ ctx: CGContext, at p: CGPoint, px: CGFloat) {
    var cv = Canvas(18, 22)
    func stone(_ x: CGFloat, _ y: CGFloat, _ m: CGFloat) -> Bool {
        let dx: CGFloat = x - 9, dy: CGFloat = y - 15
        let r: CGFloat = 6.5 - m
        if y < 15 { return x > 2 + m && x < 15 - m && y > 1.5 + m }
        return dx * dx + dy * dy < r * r
    }
    cv.fill(.K) { x, y in stone(x, y, 0) }
    cv.fill(.s) { x, y in stone(x, y, 1) }
    cv.fill(.S) { x, y in stone(x, y, 1) && x > 4 && x < 7 && y > 3 }
    cv.line([P(9, 8), P(9, 17)], 0.6, .d); cv.line([P(6.5, 14.5), P(11.5, 14.5)], 0.6, .d)
    cv.fill(.v) { _, y in y < 2.5 }
    cv.fill(.V) { _, y in y < 1.6 }
    for (x, c) in [(1, Pal.R), (16, Pal.A), (3, Pal.P), (14, Pal.W)] { cv.put(x, 2, .v); cv.put(x, 3, c) }
    ctx.draw(cv.image(), in: CGRect(x: p.x - 9 * px, y: p.y, width: 18 * px, height: 22 * px))
}

let out = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "."

// 1) hlavní obrázek: plocha Macu s medojedy
let HW: CGFloat = 1280, HH: CGFloat = 800
canvas(HW, HH, 2, out + "/hero.png") { ctx in
    wallpaper(HW, HH)
    menubar(HW, HH)
    let dk = dock(HW)
    let w1 = NSRect(x: 120, y: 190, width: 470, height: 420)
    let w2 = NSRect(x: 700, y: 260, width: 470, height: 360)
    window(w1, "Notes")
    window(w2, "Inbox", dark: true)
    let s: CGFloat = 96
    // nora vlevo dole s výzdobou
    ctx.draw(BurrowDecor.image(6, night: false), in: CGRect(x: 0, y: 0, width: 300, height: 120))
    ctx.draw(Burrow.image(1), in: CGRect(x: 70, y: 0, width: 160, height: 104))
    // žebřík opřený o pravé okno
    ladder(P(1225, 0), top: P(w2.maxX - 2, w2.minY + 170), px: 3.2)
    badger(ctx, .climb, 1, at: P(1214, 150), size: s, skin: 1, face: false, n: P(1, 0.12) * (1 / hypot(1, 0.12)))
    // medojed leze po levém boku levého okna
    badger(ctx, .climb, 0, at: P(w1.minX, w1.minY + 210), size: s, skin: 0, face: true, n: P(-1, 0))
    // medojed nahoře na pravém okně + bublina
    badger(ctx, .stand, 0, at: P(w2.minX + 300, w2.maxY), size: s, skin: 0, face: false)
    bubble("Honey badger don't care. 🍯", tail: P(w2.minX + 300, w2.maxY + 70))
    // mládě na Docku
    badger(ctx, .walk, 1, at: P(dk.minX + 140, dk.maxY), size: s * 0.55, skin: 0, face: true)
    // med padá z nebe
    ctx.draw(Honey.pot, in: CGRect(x: 380, y: 660, width: 48, height: 48))
    for i in 0..<3 { C(255, 255, 255, 0.5).setFill(); NSRect(x: 402, y: 715 + CGFloat(i) * 14, width: 3, height: 8).fill() }
    // lísteček na okně
    let note = NSRect(x: w1.maxX - 170, y: w1.minY + 40, width: 140, height: 90)
    C(255, 236, 150).setFill(); NSBezierPath(rect: note).fill()
    C(220, 90, 90).setFill(); NSBezierPath(ovalIn: NSRect(x: note.midX - 5, y: note.maxY - 10, width: 10, height: 10)).fill()
    text("Drink some water.\nYou're doing great.", P(note.minX + 10, note.minY + 22), 12, .bold, C(50, 40, 20))
}

// 2) funkce: barvy, život, nora
let FW: CGFloat = 1280, FH: CGFloat = 720
canvas(FW, FH, 2, out + "/features.png") { ctx in
    C(253, 243, 222).setFill(); NSRect(x: 0, y: 0, width: FW, height: FH).fill()
    C(250, 217, 153).setFill(); NSRect(x: 0, y: FH - 6, width: FW, height: 6).fill()
    let ink = C(30, 25, 20), sub = C(110, 95, 80)
    // barvy
    let free = Skins.all.filter { !$0.premium }.count
    text("\(Skins.all.count) fur colors", P(60, FH - 70), 28, .heavy, ink)
    text("\(free) free, \(Skins.all.count - free) for supporters", P(60, FH - 96), 15, .medium, sub)
    let perRow = (Skins.all.count + 1) / 2
    for (i, _) in Skins.all.enumerated() {
        let col = i % perRow, row = i / perRow
        badger(ctx, .idle, 0, at: P(105 + CGFloat(col) * 132, FH - 200 - CGFloat(row) * 95), size: 96, skin: i)
    }
    // život
    let ly: CGFloat = 200
    text("They grow up, get old – and live on", P(60, ly + 160), 28, .heavy, ink)
    text("Feed them, pet them, play with them. A new badger is born when one passes.", P(60, ly + 134), 15, .medium, sub)
    badger(ctx, .walk, 1, at: P(110, ly), size: 60, skin: 0)
    text("cub", P(110, ly - 34), 14, .semibold, sub, center: true, width: 120)
    badger(ctx, .idle, 0, at: P(260, ly), size: 104, skin: 0)
    text("adult", P(260, ly - 34), 14, .semibold, sub, center: true, width: 120)
    badger(ctx, .sit, 0, at: P(420, ly), size: 104, skin: 0, face: true, gray: 1)
    text("senior", P(420, ly - 34), 14, .semibold, sub, center: true, width: 120)
    tomb(ctx, at: P(560, ly), px: 3)
    text("Bodger · 37 days", P(560, ly - 34), 14, .semibold, sub, center: true, width: 160)
    badger(ctx, .wave, 0, at: P(700, ly), size: 62, skin: 0)
    text("Bodger II.", P(700, ly - 34), 14, .semibold, sub, center: true, width: 140)
    for x in [180, 335, 492, 630] as [CGFloat] { text("→", P(x - 8, ly + 20), 24, .bold, C(200, 120, 60)) }
    // nora
    text("Their burrow grows", P(820, ly + 160), 28, .heavy, ink)
    text("with everything they build and dig", P(820, ly + 134), 15, .medium, sub)
    for (i, lv) in [1, 4, 8].enumerated() {
        let bx = 820 + CGFloat(i) * 150, by: CGFloat = ly - 10
        ctx.draw(BurrowDecor.image(lv, night: false), in: CGRect(x: bx - 12, y: by, width: 150, height: 60))
        ctx.draw(Burrow.image(0), in: CGRect(x: bx + 23, y: by, width: 80, height: 52))
        text("level \(lv)", P(bx + 63, by - 30), 14, .semibold, sub, center: true, width: 120)
    }
    // pruh dole
    C(110, 170, 80).setFill(); NSRect(x: 0, y: 0, width: FW, height: 40).fill()
    C(84, 130, 60).setFill(); NSRect(x: 0, y: 0, width: FW, height: 18).fill()
    text("Climbing · ladders · tunnels · honey ⌘B · notes · cursor chasing · laser · night mode · 5 languages", P(FW / 2, 50), 15, .semibold, sub, center: true, width: FW)
}
print("ok")
