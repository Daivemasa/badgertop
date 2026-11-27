// Pixel-art renderer: zvířata se skládají z jednoduchých tvarů na mřížce 24×24,
// každá část má vlastní obrys → vypadá to jako ručně kreslený sprite.

import Cocoa

enum Pal: UInt8 {
    case clear = 0, K, B, b, F, L, E, W, P, Y, y, N, Z, R, O, D, d, S, s, H, h, C, c, M, m, G, g, X, V, v, Q, A, T
    var rgb: (UInt8, UInt8, UInt8) {
        switch self {
        case .clear: return (0, 0, 0)
        case .K: return (42, 26, 18)       // obrys
        case .B: return (146, 92, 48)      // srst
        case .b: return (108, 66, 34)      // tmavší srst (vzdálené končetiny)
        case .F: return (238, 198, 150)    // obličej / bříško
        case .L: return (250, 224, 188)    // čumák
        case .E: return (22, 16, 14)       // oči
        case .W: return (255, 255, 255)
        case .P: return (226, 128, 128)    // růžová
        case .Y: return (252, 214, 64)     // banán
        case .y: return (214, 164, 36)
        case .N: return (92, 62, 24)
        case .Z: return (128, 38, 40)      // otevřená pusa
        case .R: return (230, 60, 70)      // srdíčko
        case .O: return (14, 14, 16)       // obrys medojeda
        case .D: return (50, 50, 56)       // černá srst
        case .d: return (32, 32, 37)
        case .S: return (218, 218, 210)    // stříbrný hřbet
        case .s: return (168, 168, 160)
        case .H: return (246, 176, 40)     // med
        case .h: return (206, 126, 22)
        case .C: return (196, 116, 64)     // hrnec
        case .c: return (146, 80, 42)
        case .M: return (238, 222, 178)    // krémový hřbet (druhý medojed)
        case .m: return (190, 170, 128)
        case .G: return (132, 92, 56)      // hlína
        case .g: return (90, 60, 36)
        case .X: return (34, 22, 16)       // díra
        case .V: return (104, 172, 76)     // tráva
        case .v: return (64, 124, 52)
        case .Q: return (110, 182, 242)    // pot
        case .A: return (255, 214, 60)     // hvězda
        case .T: return (166, 112, 64)     // dřevo
        }
    }
}

struct Canvas {
    let w: Int, h: Int
    var px: [UInt8]
    init(_ w: Int = 24, _ h: Int = 24) { self.w = w; self.h = h; px = [UInt8](repeating: 0, count: w * h) }
    func get(_ x: Int, _ y: Int) -> Pal { (x >= 0 && x < w && y >= 0 && y < h) ? (Pal(rawValue: px[y * w + x]) ?? .clear) : .clear }
    mutating func put(_ x: Int, _ y: Int, _ c: Pal) {
        guard x >= 0, x < w, y >= 0, y < h else { return }
        px[y * w + x] = c.rawValue
    }
    mutating func fill(_ c: Pal, _ test: (CGFloat, CGFloat) -> Bool) {
        for y in 0..<h { for x in 0..<w where test(CGFloat(x) + 0.5, CGFloat(y) + 0.5) { px[y * w + x] = c.rawValue } }
    }
    mutating func recolor(_ from: Pal, _ to: Pal, _ test: (CGFloat, CGFloat) -> Bool) {
        for y in 0..<h { for x in 0..<w where px[y * w + x] == from.rawValue && test(CGFloat(x) + 0.5, CGFloat(y) + 0.5) { px[y * w + x] = to.rawValue } }
    }
    mutating func ellipse(_ c: CGPoint, _ rx: CGFloat, _ ry: CGFloat, _ col: Pal, rot: CGFloat = 0) {
        let ca = cos(-rot), sa = sin(-rot)
        fill(col) { x, y in
            let px = x - c.x, py = y - c.y
            let lx = px * ca - py * sa, ly = px * sa + py * ca
            let dx = lx / rx, dy = ly / ry
            return dx * dx + dy * dy <= 1
        }
    }
    mutating func disc(_ c: CGPoint, _ r: CGFloat, _ col: Pal) { ellipse(c, r, r, col) }
    mutating func line(_ pts: [CGPoint], _ r: CGFloat, _ col: Pal) {
        guard !pts.isEmpty else { return }
        fill(col) { x, y in polyDist(P(x, y), pts) <= r }
    }
    mutating func oEllipse(_ c: CGPoint, _ rx: CGFloat, _ ry: CGFloat, _ col: Pal, ol: Pal = .K, rot: CGFloat = 0) {
        ellipse(c, rx + 1, ry + 1, ol, rot: rot); ellipse(c, rx, ry, col, rot: rot)
    }
    mutating func oLimb(_ pts: [CGPoint], _ r: CGFloat, _ col: Pal, tip: Pal = .F, tipR: CGFloat = 1.15, ol: Pal = .K) {
        guard let end = pts.last else { return }
        line(pts, r + 0.95, ol); disc(end, tipR + 0.95, ol)
        line(pts, r, col); disc(end, tipR, tip)
    }

    func image(_ over: [Pal: (UInt8, UInt8, UInt8)] = [:]) -> CGImage {
        var data = [UInt8](repeating: 0, count: w * h * 4)
        for y in 0..<h { for x in 0..<w {
            let v = px[y * w + x]
            guard v != 0, let c = Pal(rawValue: v) else { continue }
            let i = ((h - 1 - y) * w + x) * 4
            let (r, g, b) = over[c] ?? c.rgb
            data[i] = r; data[i + 1] = g; data[i + 2] = b; data[i + 3] = 255
        } }
        let provider = CGDataProvider(data: Data(data) as CFData)!
        return CGImage(width: w, height: h, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: w * 4,
                       space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
                       provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)!
    }
}

func polyDist(_ p: CGPoint, _ pts: [CGPoint]) -> CGFloat {
    if pts.count == 1 { return (p - pts[0]).len }
    var best = CGFloat.greatestFiniteMagnitude
    for i in 0..<(pts.count - 1) {
        let a = pts[i], b = pts[i + 1], ab = b - a
        let l2 = ab.dot(ab)
        let t = l2 > 0 ? clamp((p - a).dot(ab) / l2, 0, 1) : 0
        best = min(best, (p - (a + ab * t)).len)
    }
    return best
}

// MARK: - Animace

enum Anim: String { case idle, walk, run, sit, sleep, climb, hang, brach, jump, fall, drag, wave, eat, sniff, stand, dig, crouch, growl, roll, look,
    lie, sleep2, passout, bow, yawn, scratch, shake, groom, sniffair, sneeze, lookback, celebrate, dizzy, tumble, stretch, tailwag }

// MARK: - Srdíčko, Z


enum PixelItems {
    static let heart: [String] = [".X.X.", "XXXXX", "XXXXX", ".XXX.", "..X.."]
    static let zed: [String] = ["XXXX", "..X.", ".X..", "XXXX"]

    static func drawPattern(_ pat: [String], at c: CGPoint, px: CGFloat, color: NSColor, outline: NSColor?) {
        let h = CGFloat(pat.count), w = CGFloat(pat[0].count)
        let origin = P(c.x - w * px / 2, c.y - h * px / 2)
        func cells(_ body: (CGRect) -> Void) {
            for (ri, row) in pat.enumerated() {
                for (ci, ch) in row.enumerated() where ch == "X" {
                    body(CGRect(x: origin.x + CGFloat(ci) * px, y: origin.y + (h - 1 - CGFloat(ri)) * px, width: px, height: px))
                }
            }
        }
        if let o = outline { o.setFill(); cells { $0.insetBy(dx: -px * 0.6, dy: -px * 0.6).fill() } }
        color.setFill(); cells { $0.fill() }
    }
}

// MARK: - Medojed (32×24, bokem, čumák doprava)

struct QPose {
    var body = P(15, 8.6)
    var bodyR = P(8.6, 4.2)
    var rot: CGFloat = 0
    var head = P(25.2, 8.8)
    var headR = P(3.9, 3.4)
    var snout = P(28.8, 7.6)
    var snoutR = P(2.3, 1.7)
    var ear = P(23.0, 11.9)
    var legs: [[CGPoint]] = []   // 0 zadní vzdálená, 1 přední vzdálená, 2 zadní blízká, 3 přední blízká
    var tail: [CGPoint] = []
    var tailFront = false
    var eye = 0     // 0 otevřené, 1 zavřené, 2 vykulené, 3 šťastné, 4 naštvané
    var mouth = 0   // 0 zavřená, 1 otevřená (vrčí), 2 žere
    var upside = false
    var headRot: CGFloat? = nil
    var headBack = false

    mutating func map(_ f: (CGPoint) -> CGPoint) {
        body = f(body); head = f(head); snout = f(snout); ear = f(ear)
        legs = legs.map { $0.map(f) }; tail = tail.map(f)
    }
    mutating func shift(_ d: CGPoint) { map { $0 + d } }
    mutating func shiftUpper(_ dy: CGFloat) {
        body.y += dy; head.y += dy; snout.y += dy; ear.y += dy
        tail = tail.map { P($0.x, $0.y + dy) }
        for i in legs.indices where !legs[i].isEmpty { legs[i][0].y += dy }
    }
    mutating func rotate(_ a: CGFloat, around c: CGPoint) {
        let ca = cos(a), sa = sin(a)
        map { p in let d = p - c; return c + P(d.x * ca - d.y * sa, d.x * sa + d.y * ca) }
        rot += a
    }
    func loc(_ v: CGPoint) -> CGPoint {   // lokální vektor -> světový (podle rotace těla)
        let ca = cos(rot), sa = sin(rot); return P(v.x * ca - v.y * sa, v.x * sa + v.y * ca)
    }
    func hloc(_ v: CGPoint) -> CGPoint {  // vektor vůči hlavě
        let r = headRot ?? rot, ca = cos(r), sa = sin(r), x = headBack ? -v.x : v.x
        return P(x * ca - v.y * sa, x * sa + v.y * ca)
    }
    /// natočí hlavu (čumák + ucho se dopočítají)
    mutating func aimHead(_ r: CGFloat) {
        headRot = r
        snout = head + hloc(P(3.6, -1.2)); ear = head + hloc(P(-2.2, 3.1))
    }
}

enum Badger {
    static let W = 32, H = 24
    static var cache: [String: CGImage] = [:]

    static func frames(_ a: Anim) -> Int {
        switch a {
        case .walk: return 8
        case .run: return 6
        case .idle, .sniff, .dig, .drag: return 4
        case .look: return 4
        case .stand, .sleep, .eat, .growl, .roll, .fall: return 2
        case .sit, .lie, .sleep2, .passout, .bow, .scratch, .groom, .sniffair, .lookback, .celebrate, .dizzy, .tailwag, .stretch: return 2
        case .yawn, .sneeze: return 3
        case .shake, .tumble: return 4
        default: return 1
        }
    }
    static func fps(_ a: Anim) -> Double {
        switch a {
        case .lie, .lookback, .sit: return 1.2
        case .sleep2: return 0.7
        case .passout: return 1.5
        case .bow, .tailwag: return 6
        case .yawn: return 1.6
        case .scratch: return 10
        case .shake: return 14
        case .groom: return 4
        case .sniffair: return 6
        case .sneeze: return 3
        case .celebrate: return 5
        case .dizzy: return 3
        case .tumble: return 12
        case .stretch: return 1.0
        case .walk: return 9
        case .run: return 14
        case .idle: return 2
        case .look: return 1.5
        case .sniff: return 7
        case .dig: return 12
        case .stand: return 1.5
        case .sleep: return 0.7
        case .eat: return 6
        case .growl: return 9
        case .roll: return 5
        case .fall: return 8
        case .drag: return 10
        default: return 1
        }
    }

    static func image(_ a: Anim, _ f: Int, blink: Bool, skin: Int = 0) -> CGImage {
        let frame = f % frames(a)
        let key = "\(a.rawValue)-\(frame)-\(blink)-\(skin)"
        if let c = cache[key] { return c }
        var p = pose(a, frame)
        if blink && p.eye == 0 { p.eye = 1 }
        let img = render(p, skin: skin)
        cache[key] = img
        return img
    }

    static let hips: [CGPoint] = [P(9.4, 6.4), P(20.4, 6.4), P(10.8, 6.0), P(21.8, 6.0)]

    static func base() -> QPose {
        var p = QPose()
        p.legs = hips.map { [$0, P($0.x + 0.4, 1.4)] }
        p.tail = [P(6.8, 10.0), P(4.4, 10.8), P(2.6, 9.8)]
        return p
    }

    /// nohy znovu „postaví" na zem z aktuálních kyčlí
    static func plant(_ p: inout QPose, _ dx: [CGFloat] = [0.4, 0.4, 0.4, 0.4]) {
        for i in 0..<4 { let h = p.legs[i][0]; p.legs[i] = [h, P(h.x + dx[i], 1.4)] }
    }

    static func pose(_ a: Anim, _ f: Int) -> QPose {
        let n = CGFloat(frames(a))
        let ph = CGFloat(f) / n * 2 * .pi
        var p = base()
        switch a {
        case .idle:
            if f % 2 == 1 { p.bodyR.y += 0.35; p.body.y += 0.2 }
            if f == 2 { p.tail[2] = p.tail[2] + P(-0.2, 1.4) }
        case .look:
            // rozhlíží se: hlava nahoru / zpátky
            let up: CGFloat = [0, 1.2, 1.2, 0][f]
            p.head.y += up; p.snout = p.snout + P(-0.3 * up, up * 1.5); p.ear.y += up
        case .walk:
            let off: [CGFloat] = [.pi, 0, 0, .pi]
            for i in 0..<4 {
                let h = p.legs[i][0], q = ph + off[i]
                p.legs[i] = [h, P(h.x + 0.3 + 2.0 * sin(q), 1.4 + max(0, cos(q)) * 1.3)]
            }
            if abs(sin(ph)) < 0.5 { p.shiftUpper(0.6) }
            p.tail[2] = p.tail[2] + P(0, 0.6 * sin(ph))
        case .run:
            let back = ph + .pi * 0.9
            for i in 0..<4 {
                let h = p.legs[i][0], q = (i == 1 || i == 3) ? ph : back
                let e: CGFloat = (i == 0 || i == 1) ? 0.4 : 0
                p.legs[i] = [h, P(h.x + 0.3 + 2.8 * sin(q + e), 1.4 + max(0, cos(q + e)) * 2.0)]
            }
            p.bodyR.x += 0.7 * sin(ph)
            p.shiftUpper(0.7 + 0.7 * cos(ph))
            p.head = p.head + P(0.4, -0.3); p.snout = p.snout + P(0.4, -0.3); p.ear = p.ear + P(0.2, -0.6)
            p.tail = [P(6.8, 10.2), P(4.2, 11.4), P(2.2, 11.2)]
        case .sniff, .eat:
            p.head = P(25.0, 6.6); p.snout = P(28.6, 4.6); p.ear = P(22.8, 9.8)
            if a == .sniff { p.snout.x += f % 2 == 0 ? 0 : 0.6; p.snout.y += f % 2 == 0 ? 0 : -0.3 }
            else { p.mouth = f == 0 ? 2 : 0; p.eye = 3 }
        case .stand:
            p.rotate(1.12, around: P(10.6, 1.6))
            for i in [0, 2] { let h = p.legs[i][0]; p.legs[i] = [h, P(h.x + 1.6, 1.4)] }
            for i in [1, 3] { let h = p.legs[i][0]; p.legs[i] = [h, h + P(1.6, -2.4), h + P(2.4, -3.2)] }
            p.tail = [P(8.0, 4.4), P(5.4, 2.6), P(3.4, 1.8)]
            if f == 1 { p.head.y += 0.5; p.snout = p.snout + P(-0.2, 0.7) }
        case .sleep:
            p.body = P(16, 5.8); p.bodyR = P(7.4, 4.8 + (f == 1 ? 0.3 : 0))
            p.head = P(21.6, 4.6); p.headR = P(3.4, 3.0)
            p.snout = P(24.4, 3.4); p.snoutR = P(1.9, 1.4); p.ear = P(19.8, 7.4)
            p.legs = []
            p.tail = [P(9.0, 6.4), P(9.8, 2.6), P(14.6, 1.6), P(19.6, 1.8)]
            p.tailFront = true
            p.eye = 1
        case .dig:
            p.rotate(-0.22, around: P(22, 1.4))
            for i in [0, 2] { let h = p.legs[i][0]; p.legs[i] = [h, P(h.x + 0.6, 1.4)] }
            let k: [CGFloat] = [1, -1, 1, -1]
            let hn = p.legs[3][0], hf = p.legs[1][0]
            p.legs[3] = [hn, P(hn.x + 1.8 * k[f], 1.4 + (k[f] > 0 ? 0.3 : 1.6))]
            p.legs[1] = [hf, P(hf.x - 1.6 * k[f], 1.4 + (k[f] > 0 ? 1.6 : 0.3))]
            p.eye = 4
        case .crouch:
            p.shiftUpper(-1.4); p.bodyR = P(9.0, 3.9)
            plant(&p, [-0.6, 1.2, -0.6, 1.2])
            p.head = p.head + P(0.2, -0.4); p.snout = p.snout + P(0.2, -0.4)
            p.eye = 4
        case .jump:
            p.shiftUpper(1.2)
            p.rotate(0.18, around: p.body)
            for i in [0, 2] { let h = p.legs[i][0]; p.legs[i] = [h, h + P(-3.2, -2.6)] }
            for i in [1, 3] { let h = p.legs[i][0]; p.legs[i] = [h, h + P(3.0, -1.6)] }
            p.tail = [P(6.6, 11.4), P(3.8, 13.2), P(2.0, 13.6)]
            p.eye = 2
        case .fall:
            p.shiftUpper(1.6)
            let w: CGFloat = f == 0 ? 1 : -1
            p.legs[0] = [p.legs[0][0], p.legs[0][0] + P(-2.6, -3.2 + w)]
            p.legs[2] = [p.legs[2][0], p.legs[2][0] + P(-1.6, -3.6 - w)]
            p.legs[1] = [p.legs[1][0], p.legs[1][0] + P(2.6, -3.2 - w)]
            p.legs[3] = [p.legs[3][0], p.legs[3][0] + P(1.8, -3.6 + w)]
            p.tail = [P(6.8, 11.2), P(4.6, 13.4 + w), P(3.6, 15.0 + w)]
            p.eye = 2; p.mouth = 1
        case .drag:
            p.rotate(1.2, around: p.head)
            p.shift(P(18 - p.head.x, 18.5 - p.head.y))
            let w: [CGFloat] = [1, 0, -1, 0]
            for i in 0..<4 {
                let h = p.legs[i][0], s: CGFloat = i % 2 == 0 ? 1 : -1
                p.legs[i] = [h, h + P(1.6 + w[f] * s * 1.2, -2.6)]
            }
            p.tail = [p.tail[0], p.tail[0] + P(-0.6 + w[f] * 0.6, -2.2)]
            p.eye = 4; p.mouth = 1
        case .growl:
            p.shiftUpper(0.8); p.bodyR.y += 0.5
            p.head = P(26.0, 7.6); p.snout = P(29.6, 6.6); p.ear = P(23.6, 10.8)
            plant(&p, [-0.8, 1.0, -0.8, 1.0])
            p.tail = [P(6.8, 11.0), P(5.2, 13.6), P(4.8, 15.6)]
            p.shift(P(f == 0 ? -0.3 : 0.3, 0))
            p.eye = 4; p.mouth = 1
        case .roll:
            p.upside = true
            p.body = P(15, 6.4); p.head = P(25.0, 6.4); p.snout = P(28.4, 7.8); p.ear = P(23.4, 3.2)
            let w: CGFloat = f == 0 ? 1 : -1
            let hp: [CGPoint] = [P(9.6, 9.4), P(20.2, 9.4), P(11.0, 9.8), P(21.4, 9.8)]
            p.legs = hp.enumerated().map { i, h in [h, h + P((i % 2 == 0 ? 0.8 : -0.8) * w, 3.4)] }
            p.tail = [P(6.6, 5.0), P(4.0, 4.0), P(2.4, 5.0)]
            p.eye = 3; p.mouth = 1
        case .lie, .sleep2, .passout:
            p.body = P(15, 5.2); p.bodyR = P(9.0, 3.6 + (f == 1 ? 0.25 : 0))
            p.head = a == .lie ? P(25.4, 4.9) : P(25.2, 4.2); p.aimHead(a == .lie ? 0 : -0.12)
            p.legs = [[P(9.6, 3.2), P(5.6, 1.4)], [P(20.0, 3.2), P(25.2, 1.4)], [P(10.8, 3.0), P(6.8, 1.4)], [P(21.0, 3.0), P(26.6, 1.4)]]
            p.tail = [P(6.4, 6.0), P(3.8, 5.6), P(2.0, 4.2)]
            if a == .sleep2 { p.eye = 1 }
            if a == .passout { p.eye = 5; p.mouth = 4; p.head.y -= 0.6 }
        case .sit, .yawn, .scratch, .groom, .dizzy:
            p = sitPose()
            switch a {
            case .sit: if f == 1 { p.tail[2] = p.tail[2] + P(0, 0.8) }
            case .yawn:
                p.aimHead(0.5); p.eye = 1; p.mouth = f == 0 ? 1 : 3
            case .scratch:
                let h = p.legs[2][0]
                p.legs[2] = [h, h + P(2.6, 3.4), p.head + P(-1.6, -1.6 + (f == 0 ? 0.7 : -0.7))]
                p.eye = 3
            case .groom:
                p.head = p.head + P(-0.6, -2.0); p.aimHead(-0.35)
                let h = p.legs[3][0]
                p.legs[3] = [h, P(h.x + 2.0, 4.6), p.snout + P(-0.4, -1.9)]
                p.mouth = f == 0 ? 4 : 0; p.eye = 1
            default:
                p.head.x += f == 0 ? -0.5 : 0.5; p.aimHead(f == 0 ? 0.22 : -0.22); p.eye = 5
            }
        case .bow:
            p.rotate(-0.32, around: P(20, 1.4))
            for i in [0, 2] { let h = p.legs[i][0]; p.legs[i] = [h, P(h.x + 0.3, 1.4)] }
            for i in [1, 3] { let h = p.legs[i][0]; p.legs[i] = [h, P(h.x + 1.0, 1.6), P(h.x + 3.4, 1.4)] }
            p.aimHead(0.18)
            let w: CGFloat = f == 0 ? 0 : 1.2, t0 = p.tail[0]
            p.tail = [t0, t0 + P(-2.0, 2.4 + w), t0 + P(-2.4 - w, 4.6 + w)]
            p.eye = 3; p.mouth = 1
        case .shake:
            let o: CGFloat = f % 2 == 0 ? 0.9 : -0.9
            p.body.x += o; p.head.x -= o * 0.6; p.snout.x -= o * 0.6; p.ear.x -= o * 0.6
            p.tail = p.tail.enumerated().map { i, t in i == 0 ? t : t + P(0, o * CGFloat(i)) }
            p.eye = 1
        case .sniffair, .sneeze:
            if a == .sniffair || f == 0 {
                p.head = p.head + P(0.2, 0.8); p.aimHead(0.5)
                if a == .sniffair && f == 1 { p.snout = p.snout + P(0.4, 0.3) }
                if a == .sneeze { p.eye = 1 }
            } else if f == 1 {
                p.head = p.head + P(0.6, -0.8); p.aimHead(-0.3); p.eye = 1; p.mouth = 1
            }
        case .lookback:
            p.headBack = true
            p.head = P(23.4, 9.8 + (f == 1 ? 0.5 : 0))
            p.snout = p.head + P(-3.5, -1.0); p.ear = p.head + P(2.0, 3.0)
        case .celebrate:
            p = pose(.stand, 0)
            let h1 = p.legs[1][0], h3 = p.legs[3][0]
            p.legs[1] = [h1, h1 + P(1.0, 2.4), h1 + P(0.8 + CGFloat(f) * 0.6, 4.2)]
            p.legs[3] = [h3, h3 + P(1.8, 2.2), h3 + P(2.4 - CGFloat(f) * 0.6, 4.0)]
            p.eye = 3; p.mouth = 1
        case .tumble:
            p = pose(.sleep, 0)
            p.rotate(CGFloat(f) * .pi / 2, around: p.body)
            p.eye = 2
        case .stretch:
            p.body = P(14.6, 6.6); p.bodyR = P(9.4, 3.7); p.rot = -0.08
            p.head = P(26.0, 6.8); p.aimHead(f == 1 ? 0.4 : 0.2)
            p.legs[1] = [P(20.6, 4.6), P(27.0, 1.4)]; p.legs[3] = [P(21.6, 4.4), P(28.4, 1.4)]
            plant(&p, [0.4, 6.4, 0.4, 6.8])
            p.legs[1] = [p.legs[1][0], P(27.0, 1.4)]; p.legs[3] = [p.legs[3][0], P(28.4, 1.4)]
            p.tail = [P(6.2, 9.0), P(3.8, 10.6), P(2.4, 12.4)]
            p.eye = 1; p.mouth = f == 1 ? 3 : 0
        case .tailwag:
            let w: CGFloat = f == 0 ? 0 : 1.4, t0 = p.tail[0]
            p.tail = [t0, t0 + P(-2.2, 2.0 + w), t0 + P(-3.0 + w * 0.6, 3.8 + w * 1.4)]
            p.eye = 3
        default: break
        }
        return p
    }

    static func sitPose() -> QPose {
        var p = base()
        p.rotate(0.42, around: P(9.0, 2.2))
        p.aimHead(0.08)
        for i in [0, 2] { let h = p.legs[i][0]; p.legs[i] = [h, P(h.x + 3.0, 2.2), P(h.x + 4.2, 1.4)] }
        for i in [1, 3] { let h = p.legs[i][0]; p.legs[i] = [h, P(h.x + 0.6, 1.4)] }
        p.tail = [P(7.4, 3.6), P(4.6, 2.0), P(2.4, 1.8)]
        return p
    }

    static func render(_ p: QPose, skin: Int = 0) -> CGImage {
        var cv = Canvas(W, H)
        func limb(_ i: Int, _ col: Pal) {
            guard i < p.legs.count else { return }
            cv.oLimb(p.legs[i], 1.3, col, tip: col, tipR: 1.45, ol: .O)
        }
        limb(0, .d); limb(1, .d)
        if !p.tailFront { cv.line(p.tail, 2.2, .O); cv.line(p.tail, 1.25, .S) }
        // tělo + hlava
        cv.ellipse(p.body, p.bodyR.x + 1, p.bodyR.y + 1, .O, rot: p.rot)
        cv.ellipse(p.head, p.headR.x + 1, p.headR.y + 1, .O, rot: p.rot)
        cv.ellipse(p.snout, p.snoutR.x + 1, p.snoutR.y + 1, .O, rot: p.rot)
        cv.ellipse(p.body, p.bodyR.x, p.bodyR.y, .D, rot: p.rot)
        cv.ellipse(p.head, p.headR.x, p.headR.y, .D, rot: p.rot)
        cv.ellipse(p.snout, p.snoutR.x, p.snoutR.y, .D, rot: p.rot)
        // stříbrný hřbet od temene po ocas
        let ca = cos(-p.rot), sa = sin(-p.rot)
        let sg: CGFloat = p.upside ? -1 : 1
        func local(_ x: CGFloat, _ y: CGFloat, _ c: CGPoint) -> CGPoint { let dx = x - c.x, dy = y - c.y; return P(dx * ca - dy * sa, (dx * sa + dy * ca) * sg) }
        let hr = p.headRot ?? p.rot, hca = cos(-hr), hsa = sin(-hr), hxs: CGFloat = p.headBack ? -1 : 1
        func hlocal(_ x: CGFloat, _ y: CGFloat) -> CGPoint { let dx = x - p.head.x, dy = y - p.head.y; return P((dx * hca - dy * hsa) * hxs, (dx * hsa + dy * hca) * sg) }
        let thr = p.bodyR.y * 0.12
        cv.recolor(.D, .s) { x, y in
            let q = local(x, y, p.body), dx = q.x / p.bodyR.x, dy = q.y / p.bodyR.y
            if dx * dx + dy * dy <= 1 && q.y > thr { return true }
            let hq = hlocal(x, y), hx = hq.x / p.headR.x, hy = hq.y / p.headR.y
            return hx * hx + hy * hy <= 1 && hq.y > 0.2 && hq.x < 1.8
        }
        cv.recolor(.s, .S) { x, y in
            let q = local(x, y, p.body)
            if q.y > thr + 1.0 && abs(q.x) < p.bodyR.x - 0.5 { return true }
            let hq = hlocal(x, y)
            return hq.y > 1.2 && hq.x < 1.0 && (q.y > thr + 1.0 || hq.x < 0.8)
        }
        if p.tailFront { cv.line(p.tail, 2.2, .O); cv.line(p.tail, 1.25, .S) }
        // ucho
        cv.disc(p.ear, 1.9, .O); cv.disc(p.ear, 0.9, .s)
        // oko
        let e = p.head + p.hloc(P(1.3, p.upside ? 0.6 : -0.1))
        let ex = Int(floor(e.x)), ey = Int(floor(e.y))
        switch p.eye {
        case 1: cv.put(ex - 1, ey, .s); cv.put(ex, ey, .s)
        case 2: cv.put(ex, ey, .W); cv.put(ex, ey + 1, .W); cv.put(ex + 1, ey, .E)
        case 3: cv.put(ex - 1, ey, .W); cv.put(ex, ey + 1, .W); cv.put(ex + 1, ey, .W)
        case 4: cv.put(ex, ey, .W); cv.put(ex - 1, ey + 1, .S); cv.put(ex, ey + 1, .S)
        case 5: cv.put(ex - 1, ey - 1, .W); cv.put(ex + 1, ey + 1, .W); cv.put(ex, ey, .W); cv.put(ex + 1, ey - 1, .W); cv.put(ex - 1, ey + 1, .W)
        default: cv.put(ex, ey, .W); cv.put(ex, ey + 1, .s)
        }
        // nos + pusa
        let tip = p.snout + p.hloc(P(p.snoutR.x - 0.2, 0.3 * (p.upside ? -1 : 1)))
        cv.put(Int(floor(tip.x)), Int(floor(tip.y)), .O)
        if p.mouth != 0 {
            let m = p.snout + p.hloc(P(0.2, -1.2 * (p.upside ? -1 : 1)))
            let mx = Int(floor(m.x)), my = Int(floor(m.y))
            if p.mouth == 4 { cv.put(mx, my, .P); cv.put(mx, my - 1, .P) } else {
                cv.put(mx, my, .Z); cv.put(mx + 1, my, .Z); cv.put(mx - 1, my, .Z)
            }
            if p.mouth == 3 { cv.put(mx, my - 1, .Z); cv.put(mx + 1, my - 1, .Z); cv.put(mx - 1, my + 1, .W); cv.put(mx + 1, my + 1, .W) }
            if p.mouth == 1 { cv.put(mx + 1, my + (p.upside ? -1 : 1), .W); cv.put(mx - 1, my - (p.upside ? -1 : 1), .W) }
        }
        limb(2, .D); limb(3, .D)
        // drápky
        if !p.upside {
            for i in [2, 3] where i < p.legs.count {
                if let paw = p.legs[i].last { cv.put(Int(floor(paw.x + 1.4)), Int(floor(paw.y - 0.6)), .S) }
            }
        }
        return cv.image(Skins.all[max(0, min(skin, Skins.all.count - 1))].map)
    }
}

enum Honey {
    static let pot: CGImage = {
        var cv = Canvas(24, 24)
        cv.ellipse(P(12, 8.6), 8.0, 7.6, .O); cv.ellipse(P(12, 8.6), 7.0, 6.6, .C)
        cv.ellipse(P(9.4, 10.6), 2.2, 2.8, .F)
        cv.line([P(5.2, 15.6), P(18.8, 15.6)], 2.6, .O); cv.line([P(5.2, 15.6), P(18.8, 15.6)], 1.6, .c)
        cv.ellipse(P(12, 17.6), 5.4, 2.4, .O); cv.ellipse(P(12, 17.6), 4.4, 1.5, .H)
        cv.line([P(8.4, 16.4), P(8.4, 12.4)], 1.9, .O); cv.line([P(8.4, 16.4), P(8.4, 12.4)], 0.9, .H)
        cv.line([P(14.6, 16.2), P(14.6, 13.8)], 1.7, .O); cv.line([P(14.6, 16.2), P(14.6, 13.8)], 0.8, .H)
        cv.put(13, 18, .W); cv.put(7, 7, .h)
        return cv.image()
    }()
}

// MARK: - Emoce, nora, stopy

enum Emote: String { case heart, bang, question, note, anger, sweat, dots, star, honey, zzz }

enum Emotes {
    static let pat: [Emote: [String]] = [
        .heart: [".KK.KK.", "KRRKRRK", "KRRRRRK", "KRRRRRK", ".KRRRK.", "..KRK..", "...K..."],
        .bang: ["..KKK..", "..KAK..", "..KAK..", "..KAK..", "..KKK..", "..KAK..", "..KKK.."],
        .question: [".KKKKK.", "KWWWWWK", "KKKKWWK", "..KWWK.", "..KKKK.", "..KWWK.", "..KKKK."],
        .note: ["...KKKK", "...KWWK", "...KWKK", "...KWK.", ".KKKWK.", "KWWWWK.", ".KKKK.."],
        .anger: [".KK.KK.", "KRRKRRK", "KRK.KRK", ".K...K.", "KRK.KRK", "KRRKRRK", ".KK.KK."],
        .sweat: ["...K...", "..KQK..", "..KQK..", ".KQQQK.", "KQQWQQK", "KQQQQQK", ".KKKKK."],
        .dots: [".......", ".......", "KKKKKKK", "KWKWKWK", "KKKKKKK", ".......", "......."],
        .star: ["...K...", "..KAK..", "KKKAKKK", "KAAAAAK", ".KAAAK.", "KAAKAAK", "KK...KK"],
        .honey: [".KKKKK.", "KHHHHHK", ".KKKKK.", "KCCCCCK", "KCFCCCK", "KCCCCCK", ".KKKKK."],
        .zzz: ["KKKKKK.", "KWWWWK.", "KKKWKK.", "..KWK..", ".KWKKKK", "KWWWWWK", "KKKKKKK"],
    ]
    static let colors: [Character: NSColor] = [
        "K": NSColor(white: 0.08, alpha: 1), "R": NSColor(red: 0.9, green: 0.24, blue: 0.28, alpha: 1),
        "A": NSColor(red: 1, green: 0.84, blue: 0.24, alpha: 1), "W": .white,
        "Q": NSColor(red: 0.43, green: 0.71, blue: 0.95, alpha: 1), "H": NSColor(red: 0.96, green: 0.69, blue: 0.16, alpha: 1),
        "C": NSColor(red: 0.77, green: 0.45, blue: 0.25, alpha: 1), "F": NSColor(red: 0.93, green: 0.78, blue: 0.59, alpha: 1),
    ]
    static func draw(_ e: Emote, at c: CGPoint, px: CGFloat, alpha: CGFloat) {
        guard let rows = pat[e] else { return }
        let h = CGFloat(rows.count), w = CGFloat(rows[0].count)
        let o = P(c.x - w * px / 2, c.y - h * px / 2)
        for (ri, row) in rows.enumerated() {
            for (ci, ch) in row.enumerated() {
                guard let col = colors[ch] else { continue }
                col.withAlphaComponent(alpha).setFill()
                NSRect(x: o.x + CGFloat(ci) * px, y: o.y + (h - 1 - CGFloat(ri)) * px, width: px, height: px).fill()
            }
        }
    }
}

enum Burrow {
    static let W = 40, H = 26
    static var cache: [Int: CGImage] = [:]
    /// 0 = nora, 1 = medojed vykukuje, 2 = vykukuje druhý (krémový)
    static func image(_ v: Int) -> CGImage {
        if let c = cache[v] { return c }
        var cv = Canvas(W, H)
        cv.ellipse(P(20, 1.5), 19.5, 15.5, .g); cv.ellipse(P(20, 1.5), 18.4, 14.4, .G)
        for (x, y) in [(8, 6), (14, 11), (27, 12), (31, 5), (11, 2), (34, 9), (18, 13), (24, 8)] { cv.put(x, y, .g) }
        for (x, y) in [(9, 7), (28, 13), (32, 6)] { cv.put(x, y, .M) }
        // díra
        cv.ellipse(P(20.5, 4.6), 7.6, 6.2, .g); cv.ellipse(P(20.5, 4.6), 6.6, 5.2, .X)
        cv.line([P(13.2, 0.4), P(27.8, 0.4)], 0.9, .X)
        // tráva
        for (x0, h, lean) in [(5.0, 4.0, -0.8), (6.5, 5.0, 0.6), (11.5, 3.4, -0.5), (29.0, 4.4, 0.7), (30.6, 3.2, -0.6), (36.0, 3.6, 0.5)] as [(CGFloat, CGFloat, CGFloat)] {
            let base = P(x0, max(1.5, 1.5 + 15.5 * sqrt(max(0, 1 - pow((x0 - 20) / 19.5, 2))) - 1.4))
            cv.line([base, base + P(lean, h)], 0.55, .v); cv.line([base + P(0.2, 0), base + P(lean * 0.6, h * 0.7)], 0.4, .V)
        }
        // cedulka s medem
        cv.line([P(35.0, 1.0), P(35.0, 13.0)], 0.9, .g); cv.line([P(35.0, 1.0), P(35.0, 13.0)], 0.4, .T)
        cv.ellipse(P(35.0, 15.0), 4.3, 3.0, .g); cv.ellipse(P(35.0, 15.0), 3.4, 2.1, .T)
        cv.disc(P(35.0, 14.6), 1.4, .H); cv.put(35, 16, .H)
        if v > 0 {
            let silver: Pal = v == 2 ? .M : .S
            cv.ellipse(P(20.5, 5.4), 4.4, 3.4, .O); cv.ellipse(P(20.5, 5.4), 3.6, 2.7, .D)
            cv.ellipse(P(20.5, 7.4), 3.0, 1.2, silver)
            cv.ellipse(P(20.5, 3.4), 1.8, 1.2, .D); cv.put(20, 2, .O); cv.put(21, 2, .O)
            cv.put(18, 5, .W); cv.put(22, 5, .W)
            cv.disc(P(16.6, 7.2), 1.2, .O); cv.disc(P(24.4, 7.2), 1.2, .O)
            cv.disc(P(17.8, 1.4), 1.3, .O); cv.disc(P(23.2, 1.4), 1.3, .O)
            cv.put(17, 1, .D); cv.put(23, 1, .D)
        }
        let img = cv.image()
        cache[v] = img
        return img
    }
}

// MARK: - Barvy srsti

struct Skin { let name: String; let premium: Bool; let map: [Pal: (UInt8, UInt8, UInt8)] }

enum Skins {
    static let all: [Skin] = [
        Skin(name: "Stříbrný (klasik)", premium: false, map: [:]),
        Skin(name: "Krémový", premium: false, map: [.S: (238, 222, 178), .s: (190, 170, 128)]),
        Skin(name: "Zlatý", premium: true, map: [.D: (122, 86, 32), .d: (92, 62, 22), .S: (255, 214, 80), .s: (222, 172, 52)]),
        Skin(name: "Albín", premium: true, map: [.D: (236, 232, 226), .d: (206, 200, 194), .S: (255, 255, 255), .s: (226, 222, 218), .O: (88, 76, 76), .W: (232, 92, 112)]),
        Skin(name: "Růžový", premium: true, map: [.D: (226, 118, 168), .d: (196, 88, 138), .S: (255, 222, 236), .s: (240, 182, 206)]),
        Skin(name: "Neonový", premium: true, map: [.S: (90, 255, 130), .s: (44, 200, 92), .W: (120, 255, 160)]),
        Skin(name: "Modrý", premium: true, map: [.D: (42, 62, 124), .d: (28, 42, 92), .S: (124, 222, 255), .s: (82, 172, 222)]),
        Skin(name: "Zrzavý", premium: true, map: [.D: (198, 100, 42), .d: (158, 76, 30), .S: (255, 232, 192), .s: (230, 190, 140)]),
        Skin(name: "Panda", premium: true, map: [.D: (240, 240, 238), .d: (208, 208, 206), .S: (26, 26, 30), .s: (62, 62, 68), .W: (26, 26, 30)]),
        Skin(name: "Čokoládový", premium: true, map: [.D: (94, 60, 38), .d: (68, 42, 26), .S: (212, 162, 112), .s: (172, 122, 82)]),
        Skin(name: "Mentolový", premium: true, map: [.D: (62, 112, 102), .d: (46, 86, 78), .S: (182, 250, 222), .s: (142, 212, 186)]),
        Skin(name: "Fialový", premium: true, map: [.D: (92, 52, 132), .d: (68, 38, 102), .S: (222, 182, 255), .s: (182, 142, 222)]),
        Skin(name: "Lávový", premium: true, map: [.D: (62, 22, 22), .d: (42, 14, 14), .S: (255, 122, 32), .s: (222, 72, 22), .W: (255, 210, 80)]),
        Skin(name: "Ledový", premium: true, map: [.D: (172, 212, 236), .d: (142, 182, 212), .S: (250, 255, 255), .s: (212, 236, 246), .O: (42, 72, 102)]),
        Skin(name: "Zombie", premium: true, map: [.D: (92, 132, 82), .d: (72, 102, 62), .S: (192, 202, 162), .s: (152, 162, 122), .W: (232, 62, 62)]),
        Skin(name: "Duch", premium: true, map: [.D: (226, 230, 240), .d: (202, 206, 222), .S: (255, 255, 255), .s: (236, 238, 246), .O: (152, 156, 178), .W: (42, 42, 62)]),
        Skin(name: "Noční (svítí oči)", premium: true, map: [.D: (22, 22, 32), .d: (14, 14, 22), .S: (72, 82, 142), .s: (52, 60, 112), .W: (255, 232, 92)]),
    ]
}

// MARK: - Jídlo a „věci“ (strom, žížala, krtek, hovínko, zvratky)

enum Critter {
    static var cache: [String: CGImage] = [:]
    static func get(_ key: String, _ make: () -> CGImage) -> CGImage {
        if let c = cache[key] { return c }
        let i = make(); cache[key] = i; return i
    }
    /// stromeček: stage 0…3, fruit = visí jablka
    static func tree(_ stage: Int, fruit: Bool) -> CGImage {
        get("tree\(stage)\(fruit)") {
            var cv = Canvas(24, 24)
            let h: [CGFloat] = [3, 6, 9, 11], r: [CGFloat] = [2, 3.6, 5.4, 7]
            let st = max(0, min(3, stage))
            let top = P(12, 1 + h[st])
            cv.line([P(12, 1), top], 1.9, .O); cv.line([P(12, 1), top], 1.0, .T)
            cv.disc(top + P(0, r[st] * 0.6), r[st] + 1, .O)
            cv.disc(top + P(0, r[st] * 0.6), r[st], .v)
            cv.disc(top + P(-r[st] * 0.3, r[st] * 0.9), r[st] * 0.6, .V)
            if fruit && st == 3 {
                for a in [P(-4, 4), P(3, 7), P(5, 3), P(-2, 9)] { cv.disc(top + a, 1.5, .O); cv.disc(top + a, 0.9, .R) }
            }
            cv.ellipse(P(12, 0.5), 5, 1.4, .g)
            return cv.image()
        }
    }
    static func apple() -> CGImage {
        get("apple") { var cv = Canvas(24, 24); cv.disc(P(12, 8), 6, .O); cv.disc(P(12, 8), 5, .R); cv.disc(P(10, 10), 1.5, .W)
            cv.line([P(12, 13), P(13, 16)], 1.2, .O); cv.ellipse(P(15, 15.5), 2.2, 1.2, .V); return cv.image() }
    }
    static func worm(_ f: Int) -> CGImage {
        get("worm\(f % 2)") {
            var cv = Canvas(24, 24)
            let ph: CGFloat = f % 2 == 0 ? 0 : .pi
            let pts = (0...6).map { i -> CGPoint in P(5 + CGFloat(i) * 2.3, 3 + sin(CGFloat(i) * 1.1 + ph) * 1.3) }
            cv.line(pts, 2.2, .O); cv.line(pts, 1.3, .P)
            cv.disc(pts.last!, 1.9, .O); cv.disc(pts.last!, 1.2, .R); cv.put(Int(pts.last!.x), Int(pts.last!.y) + 1, .W)
            cv.ellipse(P(5, 1), 3.5, 1.4, .g)
            return cv.image()
        }
    }
    /// krtek: 0 = jen hromádka, 1 = vykukuje, 2 = celý venku
    static func mole(_ f: Int) -> CGImage {
        get("mole\(f)") {
            var cv = Canvas(24, 24)
            if f >= 1 {
                let up: CGFloat = f == 2 ? 3 : 0
                cv.ellipse(P(12, 6 + up), 5.6, 4.6, .O); cv.ellipse(P(12, 6 + up), 4.6, 3.6, .d)
                cv.ellipse(P(16.6, 5 + up), 2, 1.3, .O); cv.ellipse(P(16.6, 5 + up), 1.3, 0.7, .P)
                cv.put(14, Int(7 + up), .W)
                if f == 2 { cv.disc(P(9, 4 + up), 1.4, .O); cv.disc(P(9, 4 + up), 0.8, .F); cv.disc(P(15, 3.6 + up), 1.4, .O); cv.disc(P(15, 3.6 + up), 0.8, .F) }
            }
            cv.ellipse(P(12, 1), 9, 3.6, .g); cv.ellipse(P(12, 1), 8, 2.8, .G)
            for (x, y) in [(6, 2), (15, 3), (18, 1)] { cv.put(x, y, .g) }
            return cv.image()
        }
    }
    static func poop() -> CGImage {
        get("poop") {
            var cv = Canvas(24, 24)
            cv.ellipse(P(12, 3), 7, 3, .O); cv.ellipse(P(12, 3), 6, 2.2, .N)
            cv.ellipse(P(12, 6.4), 5, 2.6, .O); cv.ellipse(P(12, 6.4), 4, 1.8, .N)
            cv.ellipse(P(12, 9.4), 3.2, 2, .O); cv.ellipse(P(12, 9.4), 2.2, 1.2, .N)
            cv.disc(P(13, 11.6), 1.4, .O); cv.disc(P(13, 11.6), 0.7, .N)
            cv.put(9, 4, .C); cv.put(11, 7, .C); cv.put(12, 10, .C)
            return cv.image()
        }
    }
    static func vomit() -> CGImage {
        get("vomit") {
            var cv = Canvas(24, 24)
            cv.ellipse(P(12, 1.5), 10, 2.6, .v); cv.ellipse(P(11, 1.8), 8, 1.8, .V)
            for (x, y) in [(6, 2), (10, 1), (15, 2), (18, 1), (13, 3)] { cv.put(x, y, .Y) }
            return cv.image()
        }
    }
}

// MARK: - Výzdoba nory (roste s prací medojedů)

enum BurrowDecor {
    static var cache: [Int: CGImage] = [:]
    /// plátno 75×30, nora je uprostřed (x 17,5–57,5)
    static func image(_ level: Int, night: Bool) -> CGImage {
        let key = level * 2 + (night ? 1 : 0)
        if let c = cache[key] { return c }
        var cv = Canvas(75, 30)
        if level >= 7 {          // lucerna vlevo
            cv.line([P(1.5, 0), P(1.5, 13)], 0.6, .d)
            cv.line([P(1.5, 13), P(3.5, 13)], 0.5, .d)
            cv.fill(.d) { x, y in x > 2.4 && x < 5.6 && y > 9.4 && y < 13.4 }
            cv.fill(night ? .A : .y) { x, y in x > 3 && x < 5 && y > 10 && y < 12.8 }
        }
        if level >= 4 {          // plůtek
            for x in [4, 7, 10] as [CGFloat] { cv.line([P(x, 0), P(x, 5.5)], 0.6, .T); cv.put(Int(x), 6, .g) }
            cv.line([P(3.5, 2), P(10.5, 2)], 0.45, .T); cv.line([P(3.5, 4.2), P(10.5, 4.2)], 0.45, .T)
        }
        if level >= 2 {          // cedulka
            cv.line([P(14, 0), P(14, 7)], 0.6, .g)
            cv.fill(.g) { x, y in x > 10 && x < 18 && y > 6 && y < 11 }
            cv.fill(.T) { x, y in x > 10.8 && x < 17.2 && y > 6.8 && y < 10.2 }
            cv.put(12, 8, .g); cv.put(13, 9, .g); cv.put(14, 8, .g); cv.put(15, 9, .g); cv.put(16, 8, .g)
        }
        if level >= 8 {          // pyramida hrnců s medem
            for (cx, cy) in [(59.5, 1.5), (63.5, 1.5), (61.5, 4.7)] as [(CGFloat, CGFloat)] {
                cv.ellipse(P(cx, cy), 2.0, 1.7, .c); cv.ellipse(P(cx, cy), 1.4, 1.1, .C)
                cv.line([P(cx - 1.4, cy + 1.6), P(cx + 1.4, cy + 1.6)], 0.5, .H)
            }
        }
        if level >= 6 {          // schránka
            cv.line([P(67, 0), P(67, 6)], 0.6, .T)
            cv.fill(.K) { x, y in x > 64 && x < 70 && y > 5.6 && y < 10 }
            cv.fill(.R) { x, y in x > 64.6 && x < 69.4 && y > 6.2 && y < 9.4 }
            cv.put(70, 9, .A); cv.put(70, 10, .A)
        }
        if level >= 5 {          // vlajka
            cv.line([P(73, 0), P(73, 22)], 0.55, .s)
            cv.fill(.R) { x, y in x > 66 && x < 72.6 && y > 16 && y < 21.6 && (73 - x) > (abs(y - 18.8) - 2.8) * 0.0 }
            cv.fill(.H) { x, y in x > 66 && x < 72.6 && y > 18 && y < 19.6 }
        }
        if level >= 3 {          // kytky
            for (x, c) in [(2, Pal.P), (12, Pal.A), (19, Pal.R), (56, Pal.W), (64, Pal.A), (71, Pal.P)] {
                cv.put(x, 0, .v); cv.put(x, 1, .v); cv.put(x, 2, c); cv.put(x - 1, 2, c); cv.put(x + 1, 2, c); cv.put(x, 3, c)
                cv.put(x, 2, .Y)
            }
        }
        let img = cv.image()
        cache[key] = img
        return img
    }
}
