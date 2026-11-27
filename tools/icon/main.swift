// Vygeneruje Resources/AppIcon.icns z pixelových spritů (spouští release.sh / build.sh)
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

let out = CommandLine.arguments[1]
let iconset = out + "/AppIcon.iconset"
try? FileManager.default.removeItem(atPath: iconset)
try! FileManager.default.createDirectory(atPath: iconset, withIntermediateDirectories: true)

func render(_ size: Int) -> Data {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: size, pixelsHigh: size, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    let ctx = NSGraphicsContext.current!.cgContext
    ctx.interpolationQuality = .none
    let S = CGFloat(size), k = S / 1024
    // zaoblený čtverec jako macOS ikony
    let body = NSRect(x: 100 * k, y: 100 * k, width: 824 * k, height: 824 * k)
    let path = NSBezierPath(roundedRect: body, xRadius: 185 * k, yRadius: 185 * k)
    ctx.saveGState()
    path.addClip()
    // obloha v pixelových pruzích
    let sky: [(CGFloat, CGFloat, CGFloat)] = [(0.98, 0.78, 0.42), (0.98, 0.72, 0.38), (0.96, 0.64, 0.34), (0.93, 0.56, 0.3)]
    for (i, c) in sky.enumerated() {
        NSColor(red: c.0, green: c.1, blue: c.2, alpha: 1).setFill()
        NSRect(x: body.minX, y: body.maxY - CGFloat(i + 1) * 150 * k, width: body.width, height: 150 * k).fill()
    }
    // slunce
    NSColor(red: 1, green: 0.93, blue: 0.6, alpha: 1).setFill()
    NSRect(x: 640 * k, y: 700 * k, width: 120 * k, height: 120 * k).fill()
    // tráva
    NSColor(red: 0.42, green: 0.62, blue: 0.27, alpha: 1).setFill(); NSRect(x: body.minX, y: body.minY, width: body.width, height: 250 * k).fill()
    NSColor(red: 0.33, green: 0.5, blue: 0.22, alpha: 1).setFill(); NSRect(x: body.minX, y: body.minY, width: body.width, height: 120 * k).fill()
    // medojed + hrnec medu
    let px = 21 * k
    ctx.draw(Badger.image(.idle, 0, blink: false), in: CGRect(x: 120 * k, y: 215 * k, width: 32 * px, height: 24 * px))
    ctx.draw(Honey.pot, in: CGRect(x: 700 * k, y: 200 * k, width: 24 * 8 * k, height: 24 * 8 * k))
    ctx.restoreGState()
    NSColor(white: 0, alpha: 0.18).setStroke(); path.lineWidth = 6 * k; path.stroke()
    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])!
}
for (name, sz) in [("16x16", 16), ("16x16@2x", 32), ("32x32", 32), ("32x32@2x", 64), ("128x128", 128), ("128x128@2x", 256),
                   ("256x256", 256), ("256x256@2x", 512), ("512x512", 512), ("512x512@2x", 1024)] {
    try! render(sz).write(to: URL(fileURLWithPath: "\(iconset)/icon_\(name).png"))
}
try! render(1024).write(to: URL(fileURLWithPath: out + "/icon-1024.png"))
