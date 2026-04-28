#!/usr/bin/swift

// Generates AppIcon.icns for Claude Notifier.
// Output: /tmp/ClaudeNotifierIcon/AppIcon.icns
// Run: swift scripts/generate-icon.swift

import AppKit
import CoreGraphics

let iconSizes: [(Int, String)] = [
    (16, "icon_16x16"),
    (32, "icon_16x16@2x"),
    (32, "icon_32x32"),
    (64, "icon_32x32@2x"),
    (128, "icon_128x128"),
    (256, "icon_128x128@2x"),
    (256, "icon_256x256"),
    (512, "icon_256x256@2x"),
    (512, "icon_512x512"),
    (1024, "icon_512x512@2x"),
]

func makeIcon(px: Int) -> NSImage {
    let size = CGFloat(px)
    let bounds = CGRect(origin: .zero, size: CGSize(width: size, height: size))

    return NSImage(size: bounds.size, flipped: false) { _ in
        guard let ctx = NSGraphicsContext.current?.cgContext else { return false }

        // macOS standard rounded rect clip
        let radius = size * 0.22
        let path = CGPath(roundedRect: bounds, cornerWidth: radius, cornerHeight: radius, transform: nil)
        ctx.addPath(path)
        ctx.clip()

        // Background: deep ink
        ctx.setFillColor(CGColor(red: 0.07, green: 0.07, blue: 0.10, alpha: 1))
        ctx.fill(bounds)

        // Subtle radial glow for depth
        let space = CGColorSpaceCreateDeviceRGB()
        let glowColors: [CGColor] = [
            CGColor(red: 0.20, green: 0.20, blue: 0.30, alpha: 0.5),
            CGColor(red: 0.07, green: 0.07, blue: 0.10, alpha: 0),
        ]
        let glowStops: [CGFloat] = [0, 1]
        if let grad = CGGradient(colorsSpace: space, colors: glowColors as CFArray, locations: glowStops) {
            ctx.drawRadialGradient(
                grad,
                startCenter: CGPoint(x: size * 0.5, y: size * 0.5), startRadius: 0,
                endCenter: CGPoint(x: size * 0.5, y: size * 0.5), endRadius: size * 0.70,
                options: []
            )
        }

        // Text mark: "CN" at large sizes, "C" at small sizes for legibility
        let word: String = px >= 128 ? "CN" : "C"
        let fontSize: CGFloat = px >= 128 ? size * 0.44 : size * 0.60

        let font = NSFont.systemFont(ofSize: fontSize, weight: .semibold)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor(red: 0.97, green: 0.97, blue: 1.00, alpha: 1),
            .kern: px >= 128 ? fontSize * 0.04 : 0,
        ]
        let str = NSAttributedString(string: word, attributes: attrs)
        let strSize = str.size()

        // Optically center — nudge up very slightly
        let x = (size - strSize.width) / 2
        let y = (size - strSize.height) / 2 + size * 0.01

        str.draw(at: NSPoint(x: x, y: y))

        return true
    }
}

let outputDir = URL(fileURLWithPath: "/tmp/ClaudeNotifierIcon")
let iconsetDir = outputDir.appendingPathComponent("AppIcon.iconset")

let fm = FileManager.default
try? fm.removeItem(at: outputDir)
try! fm.createDirectory(at: iconsetDir, withIntermediateDirectories: true)

for (px, name) in iconSizes {
    let img = makeIcon(px: px)
    guard let tiff = img.tiffRepresentation,
          let bmp = NSBitmapImageRep(data: tiff),
          let png = bmp.representation(using: .png, properties: [:])
    else {
        print("Failed to encode \(name).png")
        continue
    }
    let dest = iconsetDir.appendingPathComponent("\(name).png")
    try! png.write(to: dest)
    print("  \(name).png  (\(px)x\(px))")
}

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
