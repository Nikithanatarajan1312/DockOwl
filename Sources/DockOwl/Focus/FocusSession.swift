import Foundation

enum FocusPhase: Equatable {
    case idle
    case focusing
    case onBreak
    case paused
}

protocol FocusSessionDelegate: AnyObject {
    func focusSessionDidUpdate(phase: FocusPhase, remainingSeconds: Int)
    func focusSessionDidCompleteWorkBlock()
    func focusSessionDidCompleteBreak()
}

final class FocusSession {
    weak var delegate: FocusSessionDelegate?

    private(set) var phase: FocusPhase = .idle
    private(set) var remainingSeconds = 0
    private var timer: Timer?
    private var completedWorkBlocksToday = 0

    var workMinutes: Int
    var breakMinutes: Int

    init(workMinutes: Int = Constants.defaultWorkMinutes, breakMinutes: Int = Constants.defaultBreakMinutes) {
        self.workMinutes = workMinutes
        self.breakMinutes = breakMinutes
    }

    var completedToday: Int {
        completedWorkBlocksToday
    }

    var statusLabel: String {
        switch phase {
        case .idle:
            return "Ready to focus"
        case .focusing:
            return "Watching · \(formattedRemaining)"
        case .onBreak:
            return "Break · \(formattedRemaining)"
        case .paused:
            return "Paused · \(formattedRemaining)"
        }
    }

    var clockText: String {
        switch phase {
        case .idle:
            return "--:--"
        case .focusing, .onBreak, .paused:
            return formattedRemaining
        }
    }

    var toolTipText: String {
        switch phase {
        case .idle:
            return """
            DockOwl
            Click the cloud on the right to fly to the tree and start focus
            \(workMinutes) min work · \(breakMinutes) min break
            Sessions today: \(completedToday)
            """
        case .focusing:
            return """
            Focus session
            \(formattedRemaining) remaining
            Click the tree on the left to fly home and pause
            Sessions today: \(completedToday)
            """
        case .onBreak:
            return """
            Break time
            \(formattedRemaining) remaining
            Click the tree on the left to fly home and pause
            Sessions today: \(completedToday)
            """
        case .paused:
            return """
            Paused
            \(formattedRemaining) left on the clock
            Click the cloud to fly back to the tree
            Sessions today: \(completedToday)
            """
        }
    }

    var formattedRemaining: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    func startFocus() {
        guard phase == .idle || phase == .paused else { return }
        if phase == .idle {
            remainingSeconds = workMinutes * 60
        }
        phase = .focusing
        startTimer()
        notify()
    }

    func startBreak() {
        remainingSeconds = breakMinutes * 60
        phase = .onBreak
        startTimer()
        notify()
    }

    func pause() {
        guard phase == .focusing || phase == .onBreak else { return }
        timer?.invalidate()
        timer = nil
        phase = .paused
        notify()
    }

    func endSession() {
        timer?.invalidate()
        timer = nil
        phase = .idle
        remainingSeconds = 0
        notify()
    }

    func toggle() {
        switch phase {
        case .idle:
            startFocus()
        case .focusing, .onBreak:
            pause()
        case .paused:
            startFocus()
        }
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
        if let timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    private func tick() {
        guard remainingSeconds > 0 else {
            finishCurrentBlock()
            return
        }
        remainingSeconds -= 1
        notify()
    }

    private func finishCurrentBlock() {
        timer?.invalidate()
        timer = nil

        switch phase {
        case .focusing:
            completedWorkBlocksToday += 1
            delegate?.focusSessionDidCompleteWorkBlock()
            startBreak()
        case .onBreak:
            delegate?.focusSessionDidCompleteBreak()
            phase = .idle
            remainingSeconds = 0
            notify()
        default:
            phase = .idle
            remainingSeconds = 0
            notify()
        }
    }

    private func notify() {
        delegate?.focusSessionDidUpdate(phase: phase, remainingSeconds: remainingSeconds)
    }
}
