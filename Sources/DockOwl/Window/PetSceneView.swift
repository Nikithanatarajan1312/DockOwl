import AppKit

final class PetSceneView: NSView {
    var pose: OwlPose = .idle {
        didSet { needsDisplay = true }
    }

    var owlPosition = CGPoint.zero {
        didSet { needsDisplay = true }
    }

    var clockText = "--:--" {
        didSet { needsDisplay = true }
    }

    var clockActive = false {
        didSet { needsDisplay = true }
    }

    var onClick: ((CGPoint) -> Void)?

    override var isOpaque: Bool { false }

    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        context.clear(bounds)

        let layout = SceneLayout.layout(
            in: bounds,
            cloudCenterX: DockGeometry.cloudCenterX(for: window)
        )

        SceneRenderer.drawCloud(in: layout.cloud, context: context)
        SceneRenderer.drawTree(in: layout.tree, context: context)
        SceneRenderer.drawClock(text: clockText, in: layout.clock, isActive: clockActive)

        let owlRect = CGRect(
            x: owlPosition.x,
            y: owlPosition.y,
            width: Constants.owlSceneWidth,
            height: Constants.owlSceneHeight
        )
        OwlRenderer.draw(pose: pose, in: context, bounds: owlRect)
    }

    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        onClick?(point)
    }
}
