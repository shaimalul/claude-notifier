import AppKit

enum CNMenuBarIcon {
    static func make() -> NSImage {
        let pt: CGFloat = 18
        let scale: CGFloat = 2
        let px = pt * scale

        let img = NSImage(size: NSSize(width: pt, height: pt), flipped: false) { _ in
            guard let ctx = NSGraphicsContext.current?.cgContext else { return false }
            ctx.scaleBy(x: 1 / scale, y: 1 / scale)

            drawIcon(ctx: ctx, size: px)
            return true
        }
        img.isTemplate = true
        return img
    }

    private static func drawIcon(ctx: CGContext, size: CGFloat) {
        let rect = iconRect(size: size)
        drawBorder(ctx: ctx, rect: rect, size: size)
        drawLetter(ctx: ctx, size: size)
        drawOrbitalDots(ctx: ctx, rect: rect)
    }

    private static func iconRect(size: CGFloat) -> CGRect {
        CGRect(origin: .zero, size: CGSize(width: size, height: size))
            .insetBy(dx: 1.5, dy: 1.5)
    }

    private static func drawBorder(ctx: CGContext, rect: CGRect, size: CGFloat) {
        let radius = size * 0.22
        ctx.setStrokeColor(NSColor.black.cgColor)
        ctx.setLineWidth(2.2)
        ctx.addPath(CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil))
        ctx.strokePath()
    }

    private static func drawLetter(ctx _: CGContext, size: CGFloat) {
        let font = NSFont.systemFont(ofSize: size * 0.46, weight: .bold)
        let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: NSColor.black]
        let str = NSAttributedString(string: "C", attributes: attrs)
        let sz = str.size()
        str.draw(at: NSPoint(x: (size - sz.width) / 2, y: (size - sz.height) / 2 + size * 0.01))
    }

    private static func drawOrbitalDots(ctx: CGContext, rect: CGRect) {
        ctx.setFillColor(NSColor.black.cgColor)
        let dotR: CGFloat = 1.8
        let cx = rect.maxX - 1
        let cy = rect.maxY - 1
        for i in 0 ..< 3 {
            let angle = CGFloat(i) * (.pi / 5) + .pi * 1.25
            let r = 4.5 * CGFloat(i + 1) / 2.8
            ctx.fillEllipse(in: CGRect(
                x: cx + cos(angle) * r - dotR / 2,
                y: cy + sin(angle) * r - dotR / 2,
                width: dotR,
                height: dotR
            ))
        }
    }
}
