import AppKit

final class MenuBarController: NSObject {
    private let statusItem: NSStatusItem
    private let focusSession: FocusSession

    var onStartFocus: (() -> Void)?
    var onPause: (() -> Void)?
    var onEndSession: (() -> Void)?
    var onQuit: (() -> Void)?
    var onToggleSounds: (() -> Void)?

    init(focusSession: FocusSession) {
        self.focusSession = focusSession
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        super.init()
        configure()
    }

    func refresh() {
        guard let button = statusItem.button else { return }
        button.image = StatusBarIcon.make(for: focusSession.phase)
        button.imagePosition = .imageOnly
        button.toolTip = focusSession.toolTipText
        statusItem.menu = buildMenu()
        statusItem.isVisible = true
    }

    private func configure() {
        guard let button = statusItem.button else { return }
        button.image = StatusBarIcon.make(for: .idle)
        button.imagePosition = .imageOnly
        button.toolTip = "DockOwl"
        statusItem.isVisible = true
        refresh()
    }

    private func buildMenu() -> NSMenu {
        let menu = NSMenu()

        let status = NSMenuItem(title: focusSession.statusLabel, action: nil, keyEquivalent: "")
        status.isEnabled = false
        menu.addItem(status)

        let completed = NSMenuItem(
            title: "Sessions today: \(focusSession.completedToday)",
            action: nil,
            keyEquivalent: ""
        )
        completed.isEnabled = false
        menu.addItem(completed)

        menu.addItem(.separator())

        let startTitle = focusSession.phase == .paused ? "Resume Focus" : "Start Focus"
        let start = NSMenuItem(title: startTitle, action: #selector(startFocus), keyEquivalent: "f")
        start.target = self
        start.isEnabled = focusSession.phase == .idle || focusSession.phase == .paused
        menu.addItem(start)

        let pause = NSMenuItem(title: "Pause", action: #selector(pause), keyEquivalent: "p")
        pause.target = self
        pause.isEnabled = focusSession.phase == .focusing || focusSession.phase == .onBreak
        menu.addItem(pause)

        let end = NSMenuItem(title: "End Session", action: #selector(endSession), keyEquivalent: "e")
        end.target = self
        end.isEnabled = focusSession.phase != .idle
        menu.addItem(end)

        menu.addItem(.separator())

        let sounds = NSMenuItem(
            title: "Sounds",
            action: #selector(toggleSounds),
            keyEquivalent: ""
        )
        sounds.target = self
        sounds.state = SoundEffects.isEnabled ? .on : .off
        menu.addItem(sounds)

        let quit = NSMenuItem(title: "Quit DockOwl", action: #selector(quit), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)

        return menu
    }

    @objc private func startFocus() {
        onStartFocus?()
    }

    @objc private func pause() {
        onPause?()
    }

    @objc private func endSession() {
        onEndSession?()
    }

    @objc private func toggleSounds() {
        onToggleSounds?()
    }

    @objc private func quit() {
        onQuit?()
    }
}
