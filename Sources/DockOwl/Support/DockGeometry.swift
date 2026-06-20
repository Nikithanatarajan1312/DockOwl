import AppKit

enum DockGeometry {
    static let cloudWidth: CGFloat = 100
    private static let cloudRightMargin: CGFloat = 12

    static func petFrame(on screen: NSScreen) -> CGRect {
        let visible = screen.visibleFrame
        let height = Constants.sceneHeight
        let cloudCenterX = cloudCenterX(frameMinX: visible.minX, on: screen)
        let width = cloudCenterX + cloudWidth / 2 + cloudRightMargin
        return CGRect(x: visible.minX, y: visible.minY, width: width, height: height)
    }

    static func cloudCenterX(frameMinX: CGFloat, on screen: NSScreen) -> CGFloat {
        screen.visibleFrame.midX - frameMinX
    }

    static func cloudCenterX(for window: NSWindow?) -> CGFloat {
        guard let window, let screen = window.screen else {
            return cloudWidth
        }
        return cloudCenterX(frameMinX: window.frame.minX, on: screen)
    }

    static func primaryScreen() -> NSScreen {
        NSScreen.main ?? NSScreen.screens[0]
    }
}
