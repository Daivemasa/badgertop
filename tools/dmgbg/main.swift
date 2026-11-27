// Vykreslí pozadí instalačního okna DMG (720×480 bodů, @1x a @2x).
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

let W: CGFloat = 720, H: CGFloat = 480
func render(scale: CGFloat, to path: String) {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(W * scale), pixelsHigh: Int(H * scale), bitsPerSample: 8, samplesPerPixel: 4,
                               hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    rep.size = NSSize(width: W, height: H)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    let ctx = NSGraphicsContext.current!.cgContext
    ctx.interpolationQuality = .none
    // pozadí: krémová + pixelová tráva dole
    NSColor(red: 0.99, green: 0.95, blue: 0.86, alpha: 1).setFill(); NSRect(x: 0, y: 0, width: W, height: H).fill()
    NSColor(red: 0.98, green: 0.85, blue: 0.6, alpha: 1).setFill(); NSRect(x: 0, y: H - 86, width: W, height: 86).fill()
    NSColor(red: 0.42, green: 0.62, blue: 0.27, alpha: 1).setFill(); NSRect(x: 0, y: 0, width: W, height: 8).fill()
    NSColor(red: 0.33, green: 0.5, blue: 0.22, alpha: 1).setFill(); NSRect(x: 0, y: 0, width: W, height: 4).fill()
    // titulek
    let ink = NSColor(white: 0.1, alpha: 1)
    ("Badgertop" as NSString).draw(at: P(118, H - 58), withAttributes: [.font: NSFont.systemFont(ofSize: 30, weight: .heavy), .foregroundColor: ink])
    ("Two honey badgers. Zero cares." as NSString).draw(at: P(120, H - 78), withAttributes: [.font: NSFont.systemFont(ofSize: 13, weight: .medium), .foregroundColor: NSColor(white: 0.25, alpha: 1)])
    ctx.draw(Badger.image(.idle, 0, blink: false), in: CGRect(x: 26, y: H - 78, width: 80, height: 60))
    ctx.draw(Badger.image(.sit, 0, blink: false, skin: 1), in: CGRect(x: W - 110, y: H - 80, width: 80, height: 60))
    // krok 1 + šipka mezi ikonami (ikony stojí na y = 190 shora)
    let step: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: 15, weight: .bold), .foregroundColor: ink]
    ("1  Drag Badgertop to Applications" as NSString).draw(at: P(232, H - 128), withAttributes: step)
    NSColor(red: 0.85, green: 0.45, blue: 0.2, alpha: 1).setFill()
    let ay = H - 196
    for i in 0..<34 { NSRect(x: 290 + CGFloat(i) * 4, y: ay, width: 4, height: 6).fill() }
    for k in 0..<5 { NSRect(x: 426 + CGFloat(k) * 3, y: ay - 12 + CGFloat(k) * 3, width: 3, height: 30 - CGFloat(k) * 6).fill() }
    // spodní box s pokyny
    let box = NSRect(x: 28, y: 18, width: W - 56, height: 182)
    NSColor(white: 1, alpha: 0.85).setFill(); NSBezierPath(roundedRect: box, xRadius: 10, yRadius: 10).fill()
    NSColor(white: 0, alpha: 0.12).setStroke(); let bp = NSBezierPath(roundedRect: box, xRadius: 10, yRadius: 10); bp.lineWidth = 1.5; bp.stroke()
    let body: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: 11.5), .foregroundColor: NSColor(white: 0.15, alpha: 1)]
    let bold: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: 12.5, weight: .bold), .foregroundColor: ink]
    func para(_ title: String, _ text: String, _ y: CGFloat) {
        (title as NSString).draw(at: P(46, y), withAttributes: bold)
        (text as NSString).draw(with: NSRect(x: 46, y: y - 48, width: W - 92, height: 48), options: [.usesLineFragmentOrigin], attributes: body)
    }
    para("2  First launch – macOS will block it. That's expected.",
         "Open the app once, then go to  System Settings → Privacy & Security, scroll down and click  “Open Anyway”.  " +
         "Badgertop isn't notarized by Apple (that costs $99/year – it's a small indie project), so this is the only way to start it the first time.", 172)
    para("3  That's it – no extra permissions needed",
         "Within seconds the badgers climb out of their burrow and start building stuff on your windows. " +
         "They never read window contents or what you type, and nothing is sent anywhere. Settings and options: 🦡 in the menu bar  (⌘,).", 100)
    ("CZ: přetáhni do Aplikací → Nastavení systému → Soukromí a zabezpečení → „Přesto otevřít“. Žádná další oprávnění nejsou potřeba."
        as NSString).draw(at: P(46, 26), withAttributes: [.font: NSFont.systemFont(ofSize: 10), .foregroundColor: NSColor(white: 0.35, alpha: 1)])
    NSGraphicsContext.restoreGraphicsState()
    try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: path))
}
let out = CommandLine.arguments[1]
render(scale: 1, to: out + "/dmg-bg.png")
render(scale: 2, to: out + "/dmg-bg@2x.png")
