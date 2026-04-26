#!/usr/bin/swift

// Generates AppIcon.icns for Claude Notifier.
// Output: /tmp/ClaudeNotifierIcon/AppIcon.icns
// Run: swift scripts/generate-icon.swift

import AppKit
import CoreGraphics

// MARK: - Sizes required for a macOS .iconset

let iconSizes: [(Int, String)] = [
    (16,   "icon_16x16"),
    (32,   "icon_16x16@2x"),
    (32,   "icon_32x32"),
    (64,   "icon_32x32@2x"),
    (128,  "icon_128x128"),
    (256,  "icon_128x128@2x"),
    (256,  "icon_256x256"),
    (512,  "icon_256x256@2x"),
    (512,  "icon_512x512"),
    (1024, "icon_512x512@2x"),
]

// MARK: - Drawing

func makeIcon(px: Int) -> NSImage {
    let size = CGFloat(px)
    let bounds = CGRect(origin: .zero, size: CGSize(width: size, height: size))

    let image = NSImage(size: bounds.size, flipped: false) { _ in
        guard let ctx = NSGraphicsContext.current?.cgContext else { return false }

        // Rounded rect clip (22% corner radius = macOS standard)
        let radius = size * 0.22
        let path = CGPath(roundedRect: bounds, cornerWidth: radius, cornerHeight: radius, transform: nil)
        ctx.addPath(path)
        ctx.clip()

        // Gradient: bottom-left deep purple → top-right vibrant purple
        let space = CGColorSpaceCreateDeviceRGB()
        let stops: [CGFloat] = [0, 1]
        let colors: [CGColor] = [
            CGColor(red: 0.18, green: 0.06, blue: 0.42, alpha: 1),
            CGColor(red: 0.52, green: 0.22, blue: 0.92, alpha: 1),
        ]
        if let grad = CGGradient(colorsSpace: space, colors: colors as CFArray, locations: stops) {
            ctx.drawLinearGradient(grad,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: size, y: size),
                options: [])
        }

        // Bell symbol - palette: white bell, orange badge
        let symbolPt = size * 0.52
        let paletteCfg = NSImage.SymbolConfiguration(paletteColors: [.white, .orange, .white])
        let weightCfg = NSImage.SymbolConfiguration(pointSize: symbolPt, weight: .medium)
        let cfg = paletteCfg.applying(weightCfg)

        if let sym = NSImage(systemSymbolName: "bell.badge.fill", accessibilityDescription: nil)?
            .withSymbolConfiguration(cfg) {
            let x = (size - sym.size.width) / 2
            let y = (size - sym.size.height) / 2 - size * 0.01
            sym.draw(in: CGRect(x: x, y: y, width: sym.size.width, height: sym.size.height))
        }

        return true
    }
    return image
}

// MARK: - Export

let outputDir = URL(fileURLWithPath: "/tmp/ClaudeNotifierIcon")
let iconsetDir = outputDir.appendingPathComponent("AppIcon.iconset")

let fm = FileManager.default
try? fm.removeItem(at: outputDir)
try! fm.createDirectory(at: iconsetDir, withIntermediateDirectories: true)

for (px, name) in iconSizes {
    let img = makeIcon(px: px)
    guard let tiff = img.tiffRepresentation,
          let bmp = NSBitmapImageRep(data: tiff),
          let png = bmp.representation(using: .png, properties: [:]) else {
        print("Failed to encode \(name).png")
        continue
    }
    let dest = iconsetDir.appendingPathComponent("\(name).png")
    try! png.write(to: dest)
    print("  \(name).png  (\(px)x\(px))")
}

// Run iconutil
let task = Process()
task.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
task.arguments = ["-c", "icns", iconsetDir.path, "-o", outputDir.appendingPathComponent("AppIcon.icns").path]
try! task.run()
task.waitUntilExit()

if task.terminationStatus == 0 {
    print("\nAppIcon.icns → \(outputDir.path)/AppIcon.icns")
} else {
    print("iconutil failed with status \(task.terminationStatus)")
    exit(1)
}
