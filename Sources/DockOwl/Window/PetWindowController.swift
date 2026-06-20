import AppKit

protocol PetWindowControllerDelegate: AnyObject {
    func petDidLandOnTree()
    func petDidLandOnCloud()
}

final class PetWindowController: NSWindowController {
    weak var interactionDelegate: PetWindowControllerDelegate?

    private let sceneView = PetSceneView(frame: .zero)
    private let behavior = OwlBehavior()
    private let flight = FlightAnimator()
    private var animationTimer: Timer?
    private var focusPhase: FocusPhase = .idle
    private var roost: OwlRoost = .cloud
    private var owlPosition = CGPoint.zero
    private var clockText = "--:--"
    private var pendingMenuAction: (() -> Void)?

    init() {
        let screen = DockGeometry.primaryScreen()
        let frame = DockGeometry.petFrame(on: screen)
        let window = NSWindow(
            contentRect: frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.ignoresMouseEvents = false
        window.isMovable = false
        super.init(window: window)

        let layout = SceneLayout.layout(
            in: frame,
            cloudCenterX: DockGeometry.cloudCenterX(frameMinX: frame.minX, on: screen)
        )
        owlPosition = layout.cloudPerch

        sceneView.frame = NSRect(origin: .zero, size: frame.size)
        sceneView.owlPosition = owlPosition
        sceneView.onClick = { [weak self] point in
            self?.handleClick(at: point)
        }
        window.contentView = sceneView

        startAnimationLoop()
        observeScreenChanges()
        syncSceneView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        animationTimer?.invalidate()
    }

    func update(focusPhase: FocusPhase, clockText: String, toolTip: String) {
        self.focusPhase = focusPhase
        self.clockText = clockText
        sceneView.toolTip = toolTip
        sceneView.clockText = clockText
        sceneView.clockActive = focusPhase == .focusing || focusPhase == .onBreak
        syncSceneView()
    }

    func celebrate() {
        behavior.triggerCelebration()
    }

    func flyToTree(then action: (() -> Void)? = nil) {
        guard roost == .cloud, !flight.isFlying else {
            action?()
            return
        }
        pendingMenuAction = action
        beginFlight(to: .tree)
    }

    func flyToCloud(then action: (() -> Void)? = nil) {
        guard roost == .tree, !flight.isFlying else {
            action?()
            return
        }
        pendingMenuAction = action
        beginFlight(to: .cloud)
    }

    func returnOwlToCloudIfNeeded() {
        guard roost == .tree, !flight.isFlying else { return }
        beginFlight(to: .cloud)
    }

    private func startAnimationLoop() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: Constants.frameInterval, repeats: true) { [weak self] _ in
            self?.step()
        }
        if let animationTimer {
            RunLoop.main.add(animationTimer, forMode: .common)
        }
    }

    private func step() {
        if let flyingPosition = flight.step() {
            owlPosition = flyingPosition
            behavior.setFlying(true)
        } else {
            behavior.setFlying(false)
            behavior.update(focusPhase: focusPhase)
        }

        sceneView.pose = behavior.pose
        sceneView.owlPosition = owlPosition
        repositionIfNeeded()
    }

    private func handleClick(at point: CGPoint) {
        guard !flight.isFlying else { return }

        let layout = currentLayout()
        let target = layout.hitTarget(at: point, owlPosition: owlPosition, roost: roost)

        switch roost {
        case .cloud:
            if target == .cloud || target == .owl {
                beginFlight(to: .tree)
            }
        case .tree:
            if target == .tree || target == .owl {
                beginFlight(to: .cloud)
            }
        }
    }

    private func beginFlight(to destination: OwlRoost) {
        SoundEffects.play(.takeoff)
        let layout = currentLayout()
        let target = destination == .cloud ? layout.cloudPerch : layout.treePerch

        flight.fly(from: owlPosition, to: target) { [weak self] in
            self?.completeFlight(at: destination)
        }
    }

    private func completeFlight(at destination: OwlRoost) {
        roost = destination
        owlPosition = destination == .cloud
            ? currentLayout().cloudPerch
            : currentLayout().treePerch

        if let action = pendingMenuAction {
            pendingMenuAction = nil
            action()
        } else if destination == .tree {
            interactionDelegate?.petDidLandOnTree()
        } else {
            interactionDelegate?.petDidLandOnCloud()
        }

        switch destination {
        case .tree:
            SoundEffects.play(.landTree)
        case .cloud:
            SoundEffects.play(.landCloud)
        }

        syncSceneView()
    }

    private func currentLayout() -> SceneLayout.Layout {
        SceneLayout.layout(
            in: sceneView.bounds,
            cloudCenterX: DockGeometry.cloudCenterX(for: window)
        )
    }

    private func syncSceneView() {
        sceneView.owlPosition = owlPosition
        sceneView.clockText = clockText
        sceneView.clockActive = focusPhase == .focusing || focusPhase == .onBreak
        sceneView.pose = behavior.pose
    }

    private func repositionIfNeeded() {
        guard let window else { return }
        let screen = screenContaining(window: window)
        let frame = DockGeometry.petFrame(on: screen)
        if window.frame != frame {
            window.setFrame(frame, display: true)
            sceneView.frame = NSRect(origin: .zero, size: frame.size)
        }
    }

    private func screenContaining(window: NSWindow) -> NSScreen {
        let center = CGPoint(x: window.frame.midX, y: window.frame.midY)
        return NSScreen.screens.first { $0.frame.contains(center) } ?? DockGeometry.primaryScreen()
    }

    private func observeScreenChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleScreenChange),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }

    @objc private func handleScreenChange() {
        repositionIfNeeded()
    }

    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        window?.makeKeyAndOrderFront(nil)
    }
}
