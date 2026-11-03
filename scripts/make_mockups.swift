// Renders README mockups for Wnotch (illustrations, not screenshots).
// usage: swift scripts/make_mockups.swift <outdir>
import AppKit

let outDir = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
try? FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)
let cs = CGColorSpace(name: CGColorSpace.sRGB)!
let S: CGFloat = 2 // retina

func canvas(_ w: CGFloat, _ h: CGFloat, _ draw: (CGContext, CGRect) -> Void) -> CGImage {
    let ctx = CGContext(data: nil, width: Int(w * S), height: Int(h * S), bitsPerComponent: 8, bytesPerRow: 0,
                        space: cs, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    ctx.scaleBy(x: S, y: S)
    // flip to top-left origin for easier layout
    ctx.translateBy(x: 0, y: h); ctx.scaleBy(x: 1, y: -1)
    let g = NSGraphicsContext(cgContext: ctx, flipped: true)
    NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current = g
    draw(ctx, CGRect(x: 0, y: 0, width: w, height: h))
    NSGraphicsContext.restoreGraphicsState()
    return ctx.makeImage()!
}

func save(_ img: CGImage, _ name: String) {
    let rep = NSBitmapImageRep(cgImage: img)
    try! rep.representation(using: .png, properties: [:])!.write(to: outDir.appendingPathComponent(name))
    print("wrote", name, img.width, "x", img.height)
}

func color(_ hex: UInt32, _ a: CGFloat = 1) -> NSColor {
    NSColor(srgbRed: CGFloat((hex >> 16) & 0xff) / 255, green: CGFloat((hex >> 8) & 0xff) / 255, blue: CGFloat(hex & 0xff) / 255, alpha: a)
}

func wallpaper(_ ctx: CGContext, _ r: CGRect) {
    let grad = CGGradient(colorsSpace: cs, colors: [color(0x1d2b64).cgColor, color(0x6a3093).cgColor, color(0xf8cdda).cgColor] as CFArray, locations: [0, 0.6, 1])!
    ctx.drawLinearGradient(grad, start: .zero, end: CGPoint(x: r.width, y: r.height), options: [])
}

func menuBar(_ r: CGRect, notch: Bool, clock: String = "Tue 9:41") {
    color(0x000000, 0.25).setFill(); NSBezierPath(rect: CGRect(x: 0, y: 0, width: r.width, height: 30)).fill()
    let attrs: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: 13, weight: .semibold), .foregroundColor: NSColor.white]
    if let apple = NSImage(systemSymbolName: "apple.logo", accessibilityDescription: nil)?.withSymbolConfiguration(.init(pointSize: 14, weight: .semibold)) {
        let tinted = NSImage(size: apple.size, flipped: false) { rect in
            apple.draw(in: rect); NSColor.white.set(); rect.fill(using: .sourceAtop); return true
        }
        tinted.draw(in: CGRect(x: 18, y: 7, width: apple.size.width, height: apple.size.height))
    }
    ("Spotify   File   Edit   View   Playback" as NSString).draw(at: CGPoint(x: 44, y: 7), withAttributes: attrs)
    let darkAttrs = attrs.merging([.shadow: { let s = NSShadow(); s.shadowColor = NSColor.black.withAlphaComponent(0.5); s.shadowBlurRadius = 3; return s }()]) { $1 }
    (clock as NSString).draw(at: CGPoint(x: r.width - 18 - (clock as NSString).size(withAttributes: attrs).width, y: 7), withAttributes: darkAttrs)
}

func text(_ s: String, _ size: CGFloat, _ weight: NSFont.Weight, _ c: NSColor, center: CGPoint, maxWidth: CGFloat = 1000, design: NSFontDescriptor.SystemDesign = .rounded) {
    var font = NSFont.systemFont(ofSize: size, weight: weight)
    if let d = font.fontDescriptor.withDesign(design) { font = NSFont(descriptor: d, size: size) ?? font }
    let p = NSMutableParagraphStyle(); p.alignment = .center
    let a = NSAttributedString(string: s, attributes: [.font: font, .foregroundColor: c, .paragraphStyle: p])
    let b = a.boundingRect(with: CGSize(width: maxWidth, height: 200), options: [.usesLineFragmentOrigin])
    a.draw(with: CGRect(x: center.x - maxWidth / 2, y: center.y - b.height / 2, width: maxWidth, height: b.height), options: [.usesLineFragmentOrigin])
}

func pill(_ rect: CGRect, radius: CGFloat) {
    NSColor.black.setFill(); NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius).fill()
}

func notchShape(_ rect: CGRect) {
    // hardware-notch style: square top, rounded bottom
    let p = NSBezierPath()
    let r: CGFloat = 14
    p.move(to: CGPoint(x: rect.minX - 8, y: rect.minY))
    p.line(to: CGPoint(x: rect.maxX + 8, y: rect.minY))
    p.curve(to: CGPoint(x: rect.maxX, y: rect.minY + 8), controlPoint1: CGPoint(x: rect.maxX, y: rect.minY), controlPoint2: CGPoint(x: rect.maxX, y: rect.minY))
    p.line(to: CGPoint(x: rect.maxX, y: rect.maxY - r))
    p.curve(to: CGPoint(x: rect.maxX - r, y: rect.maxY), controlPoint1: CGPoint(x: rect.maxX, y: rect.maxY), controlPoint2: CGPoint(x: rect.maxX, y: rect.maxY))
    p.line(to: CGPoint(x: rect.minX + r, y: rect.maxY))
    p.curve(to: CGPoint(x: rect.minX, y: rect.maxY - r), controlPoint1: CGPoint(x: rect.minX, y: rect.maxY), controlPoint2: CGPoint(x: rect.minX, y: rect.maxY))
    p.line(to: CGPoint(x: rect.minX, y: rect.minY + 8))
    p.curve(to: CGPoint(x: rect.minX - 8, y: rect.minY), controlPoint1: CGPoint(x: rect.minX, y: rect.minY), controlPoint2: CGPoint(x: rect.minX, y: rect.minY))
    NSColor.black.setFill(); p.fill()
}

// 1) Hero: notched MacBook, lyrics strip under the notch
save(canvas(1200, 420) { ctx, r in
    wallpaper(ctx, r)
    menuBar(r, notch: true)
    let w: CGFloat = 520, h: CGFloat = 74
    notchShape(CGRect(x: r.midX - w / 2, y: 0, width: w, height: h))
    text("♪ your lyrics, line by line, in sync ♪", 19, .semibold, .white, center: CGPoint(x: r.midX, y: 52), maxWidth: w - 40)
    text("Wnotch", 64, .black, .white, center: CGPoint(x: r.midX, y: 230), design: .default)
    text("Synced Spotify lyrics, right in your notch.", 24, .medium, NSColor.white.withAlphaComponent(0.85), center: CGPoint(x: r.midX, y: 300), design: .default)
}, "hero.png")

// 2) Lyrics on a notchless Mac (floating island)
save(canvas(900, 260) { ctx, r in
    wallpaper(ctx, r)
    menuBar(r, notch: false)
    let w: CGFloat = 420, h: CGFloat = 56
    pill(CGRect(x: r.midX - w / 2, y: 42, width: w, height: h), radius: h / 2)
    text("♪ every line lands right on the beat ♪", 18, .semibold, .white, center: CGPoint(x: r.midX, y: 42 + h / 2), maxWidth: w - 40)
    text("No notch? Wnotch floats as an island at the top.", 20, .medium, NSColor.white.withAlphaComponent(0.85), center: CGPoint(x: r.midX, y: 180), design: .default)
}, "lyrics-island.png")

// 3) Idle: clock + battery
save(canvas(900, 260) { ctx, r in
    wallpaper(ctx, r)
    menuBar(r, notch: true, clock: "Tue  Nov 3")
    let w: CGFloat = 330, h: CGFloat = 34
    notchShape(CGRect(x: r.midX - w / 2, y: 0, width: w, height: h))
    let left = r.midX - w / 2 + 22, right = r.midX + w / 2 - 22
    ("9:41" as NSString).draw(at: CGPoint(x: left, y: 8), withAttributes: [.font: NSFont.monospacedDigitSystemFont(ofSize: 15, weight: .semibold), .foregroundColor: NSColor.white])
    let batt = NSAttributedString(string: "86%", attributes: [.font: NSFont.monospacedDigitSystemFont(ofSize: 15, weight: .semibold), .foregroundColor: NSColor.white])
    batt.draw(at: CGPoint(x: right - 64, y: 8))
    if let sym = NSImage(systemSymbolName: "battery.75percent", accessibilityDescription: nil)?.withSymbolConfiguration(.init(pointSize: 15, weight: .regular)) {
        let tinted = NSImage(size: sym.size, flipped: false) { rect in
            sym.draw(in: rect); NSColor.white.set(); rect.fill(using: .sourceAtop); return true
        }
        // vertically centre the glyph on the 15pt text line (text box y 8...26)
        tinted.draw(in: CGRect(x: right - 26, y: 17 - sym.size.height / 2 + 1, width: sym.size.width, height: sym.size.height))
    }
    text("Nothing playing? The notch shows time and battery.", 20, .medium, NSColor.white.withAlphaComponent(0.85), center: CGPoint(x: r.midX, y: 170), design: .default)
}, "idle.png")
