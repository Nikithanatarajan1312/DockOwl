import AppKit

enum OwlPalette: Character {
    case clear = "."
    case outline = "O"
    case body = "B"
    case belly = "W"
    case eyeWhite = "E"
    case eyePupil = "P"
    case beak = "Y"
    case tuft = "T"
    case wing = "G"
    case closedEye = "C"
    case foot = "F"

    var color: NSColor? {
        switch self {
        case .clear: return nil
        case .outline: return NSColor(calibratedRed: 0.14, green: 0.09, blue: 0.05, alpha: 1)
        case .body: return NSColor(calibratedRed: 0.62, green: 0.43, blue: 0.26, alpha: 1)
        case .belly: return NSColor(calibratedRed: 0.93, green: 0.86, blue: 0.72, alpha: 1)
        case .eyeWhite: return NSColor(calibratedWhite: 1.0, alpha: 1)
        case .eyePupil: return NSColor(calibratedRed: 0.08, green: 0.06, blue: 0.05, alpha: 1)
        case .beak: return NSColor(calibratedRed: 0.96, green: 0.58, blue: 0.14, alpha: 1)
        case .tuft: return NSColor(calibratedRed: 0.42, green: 0.28, blue: 0.14, alpha: 1)
        case .wing: return NSColor(calibratedRed: 0.46, green: 0.30, blue: 0.16, alpha: 1)
        case .closedEye: return NSColor(calibratedRed: 0.32, green: 0.20, blue: 0.12, alpha: 1)
        case .foot: return NSColor(calibratedRed: 0.92, green: 0.62, blue: 0.18, alpha: 1)
        }
    }
}

enum OwlPose: CaseIterable {
    case idle
    case blink
    case watching
    case celebrate
    case sleep
}

enum OwlSprites {
    static func pixels(for pose: OwlPose) -> [String] {
        switch pose {
        case .idle: return idle
        case .blink: return blink
        case .watching: return watching
        case .celebrate: return celebrate
        case .sleep: return sleep
        }
    }

    private static let blank = String(repeating: ".", count: Constants.spriteSize)

    private static func frame(_ rows: [String]) -> [String] {
        precondition(rows.allSatisfy { $0.count == Constants.spriteSize })
        var padded = Array(repeating: blank, count: Constants.spriteSize)
        let start = (Constants.spriteSize - rows.count) / 2
        for (index, row) in rows.enumerated() {
            padded[start + index] = row
        }
        return padded
    }

    private static let idle = frame([
        "..........  TT....TT  ..........",
        ".......... TOOT..TOOT ..........",
        "..........TOBBBBBBBBBO..........",
        "........TOBWWWWWWWBBBBO.........",
        "......TOBWEPPEWWEPPEWBBBBO......",
        ".....TOBBBBBBWYYWBBBBBBBBO......",
        ".......TOBBBBBBBBBBBBBBO........",
        "........TOOBBBBBBBBBBOO.........",
        ".........TOOOBBBBBOOOO..........",
        "..........TOOOOOOOOOO...........",
        "............TFF..FFT............",
    ])

    private static let blink = frame([
        "..........  TT....TT  ..........",
        ".......... TOOT..TOOT ..........",
        "..........TOBBBBBBBBBO..........",
        "........TOBWWWWWWWBBBBO.........",
        "......TOBWWCCWWWWCCWWBBBBO......",
        ".....TOBBBBBBWYYWBBBBBBBBO......",
        ".......TOBBBBBBBBBBBBBBO........",
        "........TOOBBBBBBBBBBOO.........",
        ".........TOOOBBBBBOOOO..........",
        "..........TOOOOOOOOOO...........",
        "............TFF..FFT............",
    ])

    private static let watching = frame([
        "..........  TT....TT  ..........",
        ".......... TOOT..TOOT ..........",
        "..........TOBBBBBBBBBO..........",
        "........TOBWWWWWWWBBBBO.........",
        ".....TOBWEPPPEWWEPPPEWBBBBO.....",
        ".....TOBBBBBBWYYWBBBBBBBBO......",
        ".......TOBBBBBBBBBBBBBBO........",
        "........TOOBBBBBBBBBBOO.........",
        ".........TOOOBBBBBOOOO..........",
        "..........TOOOOOOOOOO...........",
        "............TFF..FFT............",
    ])

    private static let celebrate = frame([
        "..........  TT....TT  ..........",
        ".......... TOOT..TOOT ..........",
        ".......TGGBBBBBBBBBGGT..........",
        ".....TGGBWWWWWWWBBGGT...........",
        "....TGGBWWEPEWWEPPEWBBGGT.......",
        ".....TOBBBBBBWYYWBBBBBBBBO......",
        ".......TOBBBBBBBBBBBBBBO........",
        "........TOOBBBBBBBBBBOO.........",
        ".........TOOOBBBBBOOOO..........",
        "..........TOOOOOOOOOO...........",
        "............TFF..FFT............",
    ])

    private static let sleep = frame([
        ".......... TOBBBBBBBBO..........",
        "........TOBWWWWWWWBBBBO.........",
        "......TOBWWCCWWWWCCWWBBBBO......",
        ".....TOBBBBBBWYYWBBBBBBBBO......",
        ".......TOBBBBBBBBBBBBBBO........",
        ".........TOOBBBBBBBBBOO.........",
        "..........TOOOBBBBBOOO..........",
        "...........TOOOOOOOOO...........",
        "............TFF..FFT............",
    ])
}
