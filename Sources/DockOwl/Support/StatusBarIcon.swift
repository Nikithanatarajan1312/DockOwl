import AppKit

enum StatusBarIcon {
    static func make(for phase: FocusPhase) -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size, flipped: false) { _ in
            NSColor.black.setFill()

            // Ear tufts
            NSBezierPath(ovalIn: NSRect(x: 3, y: 11, width: 4, height: 5)).fill()
            NSBezierPath(ovalIn: NSRect(x: 11, y: 11, width: 4, height: 5)).fill()

            // Body
            NSBezierPath(ovalIn: NSRect(x: 2, y: 2, width: 14, height: 13)).fill()

            switch phase {
            case .focusing:
                NSBezierPath(ovalIn: NSRect(x: 6, y: 5, width: 3, height: 3.5)).fill()
                NSBezierPath(ovalIn: NSRect(x: 9.5, y: 5, width: 3, height: 3.5)).fill()
            case .onBreak, .paused:
                NSBezierPath(rect: NSRect(x: 6, y: 6, width: 6, height: 1.5)).fill()
            case .idle:
                NSBezierPath(ovalIn: NSRect(x: 7, y: 5.5, width: 1.5, height: 2)).fill()
                NSBezierPath(ovalIn: NSRect(x: 9.5, y: 5.5, width: 1.5, height: 2)).fill()
            }

            let beak = NSBezierPath()
            beak.move(to: NSPoint(x: 9, y: 4))
            beak.line(to: NSPoint(x: 11, y: 3))
            beak.line(to: NSPoint(x: 9, y: 2))
            beak.close()
            beak.fill()

            return true
        }
        image.isTemplate = true
        return image
    }
}
