import Foundation

enum OwlMood {
    case idle
    case watching
    case celebrating
    case sleeping
    case flying
}

final class OwlBehavior {
    private(set) var mood: OwlMood = .idle
    private(set) var pose: OwlPose = .idle
    private var frameCounter = 0
    private var celebrationFramesRemaining = 0
    private var isFlying = false

    func setFlying(_ flying: Bool) {
        isFlying = flying
        if flying {
            mood = .flying
            pose = .celebrate
        }
    }

    func update(focusPhase: FocusPhase) {
        guard !isFlying else { return }

        frameCounter += 1

        if celebrationFramesRemaining > 0 {
            celebrationFramesRemaining -= 1
            mood = .celebrating
            pose = .celebrate
            if celebrationFramesRemaining == 0 {
                applyMood(for: focusPhase)
            }
            return
        }

        applyMood(for: focusPhase)
        applyAmbientAnimation()
    }

    func triggerCelebration() {
        guard !isFlying else { return }
        celebrationFramesRemaining = 90
        mood = .celebrating
        pose = .celebrate
    }

    private func applyMood(for phase: FocusPhase) {
        switch phase {
        case .focusing:
            mood = .watching
            pose = .watching
        case .onBreak:
            mood = .sleeping
            pose = .sleep
        case .idle, .paused:
            mood = .idle
            if pose == .watching || pose == .sleep {
                pose = .idle
            }
        }
    }

    private func applyAmbientAnimation() {
        guard mood == .idle else { return }

        if frameCounter % 150 == 0 {
            pose = .blink
        } else if pose == .blink && frameCounter % 150 > 6 {
            pose = .idle
        }
    }
}
