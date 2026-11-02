// Renders the Wnotch "W" icon to PNG at a given pixel size.
// usage: swift make_icon.swift <size> <out.png> [squircle=1|0]
import AppKit

let args = CommandLine.arguments
let size = CGFloat(Double(args[1])!)
let out = URL(fileURLWithPath: args[2])
let rounded = args.count < 4 || args[3] == "1"

let cs = CGColorSpace(name: CGColorSpace.sRGB)!
let ctx = CGContext(data: nil, width: Int(size), height: Int(size), bitsPerComponent: 8,
                    bytesPerRow: 0, space: cs, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!

// macOS icon grid: artwork inset ~10% with ~22.5% corner radius.
let inset = rounded ? size * 0.1 : 0
let rect = CGRect(x: inset, y: inset, width: size - inset * 2, height: size - inset * 2)
let path = CGPath(roundedRect: rect, cornerWidth: rect.width * 0.225, cornerHeight: rect.width * 0.225, transform: nil)

ctx.addPath(path)
ctx.clip()
let gradient = CGGradient(colorsSpace: cs, colors: [
    CGColor(red: 0.16, green: 0.16, blue: 0.18, alpha: 1),
    CGColor(red: 0.02, green: 0.02, blue: 0.03, alpha: 1)
] as CFArray, locations: [0, 1])!
ctx.drawLinearGradient(gradient, start: CGPoint(x: 0, y: rect.maxY), end: CGPoint(x: 0, y: rect.minY), options: [])

// Notch pill at the top, a nod to what the app lives in.
let pillW = rect.width * 0.38, pillH = rect.height * 0.075
let pill = CGRect(x: rect.midX - pillW / 2, y: rect.maxY - pillH * 1.6, width: pillW, height: pillH)
ctx.addPath(CGPath(roundedRect: pill, cornerWidth: pillH / 2, cornerHeight: pillH / 2, transform: nil))
ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.18))
ctx.fillPath()

// The W.
let font = NSFont.systemFont(ofSize: rect.height * 0.56, weight: .black)
let text = NSAttributedString(string: "W", attributes: [.font: font, .foregroundColor: NSColor.white])
let line = CTLineCreateWithAttributedString(text)
let bounds = CTLineGetBoundsWithOptions(line, .useGlyphPathBounds)
ctx.textPosition = CGPoint(x: rect.midX - bounds.width / 2 - bounds.minX,
                           y: rect.midY - bounds.height / 2 - bounds.minY - rect.height * 0.03)
CTLineDraw(line, ctx)

let rep = NSBitmapImageRep(cgImage: ctx.makeImage()!)
try! rep.representation(using: .png, properties: [:])!.write(to: out)
