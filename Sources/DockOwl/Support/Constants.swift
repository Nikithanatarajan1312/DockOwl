import CoreGraphics
import Foundation

enum Constants {
    static let spriteSize = 32
    static let owlSceneScale: CGFloat = 2.9
    static let owlVerticalScale: CGFloat = 1.28
    static let owlSceneWidth = CGFloat(spriteSize) * owlSceneScale
    static let owlSceneHeight = owlSceneWidth * owlVerticalScale

    static let sceneWidth: CGFloat = 210
    static let sceneHeight: CGFloat = 168
    static let frameInterval: TimeInterval = 1.0 / 60.0
    static let flightArcHeight: CGFloat = 38

    static let defaultWorkMinutes = 25
    static let defaultBreakMinutes = 5
}
