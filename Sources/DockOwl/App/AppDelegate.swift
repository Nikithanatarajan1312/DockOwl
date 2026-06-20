import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate, FocusSessionDelegate, PetWindowControllerDelegate {
    private let focusSession = FocusSession()
    private var menuBarController: MenuBarController!
    private var petWindowController: PetWindowController!

    func applicationDidFinishLaunching(_ notification: Notification) {
        focusSession.delegate = self

        menuBarController = MenuBarController(focusSession: focusSession)
        menuBarController.onStartFocus = { [weak self] in
            self?.startFocusWithFlight()
        }
        menuBarController.onPause = { [weak self] in
            self?.pauseWithFlight()
        }
        menuBarController.onEndSession = { [weak self] in
            self?.endSessionWithFlight()
        }
        menuBarController.onQuit = {
            NSApp.terminate(nil)
        }
        menuBarController.onToggleSounds = { [weak self] in
            SoundEffects.isEnabled.toggle()
            self?.menuBarController.refresh()
        }

        petWindowController = PetWindowController()
        petWindowController.interactionDelegate = self
        petWindowController.showWindow(nil)

        refreshScene()
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        .terminateNow
    }

    // MARK: - FocusSessionDelegate

    func focusSessionDidUpdate(phase: FocusPhase, remainingSeconds: Int) {
        refreshScene()
    }

    func focusSessionDidCompleteWorkBlock() {
        petWindowController.celebrate()
        SoundEffects.play(.workComplete)
    }

    func focusSessionDidCompleteBreak() {
        SoundEffects.play(.breakComplete)
        petWindowController.returnOwlToCloudIfNeeded()
        menuBarController.refresh()
    }

    // MARK: - PetWindowControllerDelegate

    func petDidLandOnTree() {
        if focusSession.phase == .idle || focusSession.phase == .paused {
            focusSession.startFocus()
        }
    }

    func petDidLandOnCloud() {
        if focusSession.phase == .focusing || focusSession.phase == .onBreak {
            focusSession.pause()
        }
    }

    // MARK: - Menu actions

    private func startFocusWithFlight() {
        petWindowController.flyToTree { [weak self] in
            self?.focusSession.startFocus()
        }
    }

    private func pauseWithFlight() {
        petWindowController.flyToCloud { [weak self] in
            self?.focusSession.pause()
        }
    }

    private func endSessionWithFlight() {
        petWindowController.flyToCloud { [weak self] in
            self?.focusSession.endSession()
        }
    }

    private func refreshScene() {
        petWindowController.update(
            focusPhase: focusSession.phase,
            clockText: focusSession.clockText,
            toolTip: focusSession.toolTipText
        )
        menuBarController.refresh()
    }
}
