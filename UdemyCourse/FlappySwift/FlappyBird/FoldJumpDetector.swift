import CoreGraphics

/// One jump per close gesture. Reopen beyond 120 degrees to arm the next jump.
struct FoldJumpDetector {
    private(set) var isArmed = false

    mutating func consume(angleInRadians angle: CGFloat?) -> Bool {
        guard let angle = angle, angle.isFinite, (0...CGFloat.pi).contains(angle) else {
            reset()
            return false
        }

        if angle > 120 * .pi / 180 {
            isArmed = true
        } else if isArmed && angle < .pi / 2 {
            isArmed = false
            return true
        }
        return false
    }

    mutating func reset() {
        isArmed = false
    }
}
