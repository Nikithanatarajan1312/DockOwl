import CoreGraphics
import Foundation
import QuartzCore

final class FlightAnimator {
    private(set) var isFlying = false
    private var from = CGPoint.zero
    private var to = CGPoint.zero
    private var startTime: CFTimeInterval = 0
    private var duration: TimeInterval = 1
    private var completion: (() -> Void)?

    func fly(from: CGPoint, to: CGPoint, completion: @escaping () -> Void) {
        self.from = from
        self.to = to
        startTime = CACurrentMediaTime()
        duration = Self.duration(forDistance: hypot(to.x - from.x, to.y - from.y))
        isFlying = true
        self.completion = completion
    }

    @discardableResult
    func step() -> CGPoint? {
        guard isFlying else { return nil }

        let elapsed = CACurrentMediaTime() - startTime
        let raw = CGFloat(min(1, elapsed / duration))
        if raw >= 1 {
            isFlying = false
            let done = completion
            completion = nil
            done?()
            return to
        }

        let eased = Self.easeInOut(raw)
        let x = from.x + (to.x - from.x) * eased
        let arc = sin(raw * .pi)
        let arcBump = arc * arc * Constants.flightArcHeight
        let y = from.y + (to.y - from.y) * eased + arcBump
        return CGPoint(x: x, y: y)
    }

    func cancel() {
        isFlying = false
        completion = nil
    }

    private static func easeInOut(_ t: CGFloat) -> CGFloat {
        t < 0.5 ? 4 * t * t * t : 1 - pow(-2 * t + 2, 3) / 2
    }

    private static func duration(forDistance distance: CGFloat) -> TimeInterval {
        let secondsPerPoint: TimeInterval = 1.0 / 320
        let minDuration: TimeInterval = 0.85
        let maxDuration: TimeInterval = 2.4
        return min(maxDuration, max(minDuration, TimeInterval(distance) * secondsPerPoint))
    }
}
