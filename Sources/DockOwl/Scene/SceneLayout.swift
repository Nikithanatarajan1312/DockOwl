import AppKit
import CoreGraphics

// MARK: - Palette

enum ScenePalette: Character {
    case clear       = "."
    case cloudLight  = "W"
    case cloudMid    = "w"
    case cloudShadow = "s"
    case leafDark    = "D"
    case leafMid     = "L"
    case leafLight   = "l"
    case trunk       = "T"
    case trunkDark   = "t"
    case branch      = "B"
    case clockSlot   = "K"

    var color: NSColor? {
        switch self {
        case .clear:       return nil
        case .cloudLight:  return NSColor(calibratedRed: 0.98, green: 0.99, blue: 1.00, alpha: 1.00)
        case .cloudMid:    return NSColor(calibratedRed: 0.88, green: 0.93, blue: 0.98, alpha: 1.00)
        case .cloudShadow: return NSColor(calibratedRed: 0.72, green: 0.80, blue: 0.90, alpha: 0.85)
        case .leafDark:    return NSColor(calibratedRed: 0.10, green: 0.36, blue: 0.16, alpha: 1.00)
        case .leafMid:     return NSColor(calibratedRed: 0.20, green: 0.54, blue: 0.26, alpha: 1.00)
        case .leafLight:   return NSColor(calibratedRed: 0.52, green: 0.82, blue: 0.34, alpha: 1.00)
        case .trunk:       return NSColor(calibratedRed: 0.52, green: 0.34, blue: 0.16, alpha: 1.00)
        case .trunkDark:   return NSColor(calibratedRed: 0.34, green: 0.20, blue: 0.09, alpha: 1.00)
        case .branch:      return NSColor(calibratedRed: 0.42, green: 0.26, blue: 0.12, alpha: 1.00)
        case .clockSlot:   return NSColor(calibratedRed: 0.06, green: 0.20, blue: 0.10, alpha: 1.00)
        }
    }
}

// MARK: - Tree

enum TreeArt {
    // Every row is exactly 18 chars wide.
    // Canopy is a round blob: narrow top, wide middle, narrow bottom.
    // D (dark) pixels cluster on the right-interior to fake shadow depth.
    // Clock slot (K) sits on its own row, fully below the canopy.
    static let pixels: [String] = [
        "......lll.........",  //  0  crown tip
        ".....lLLll........",  //  1
        "....lLLLLDl.......",  //  2
        "...llLLLLDDl......",  //  3
        "..lLLLLLLDDDl.....",  //  4  widest foliage row
        "..lLLLLLDDDDl.....",  //  5
        "..lLLLLLDDLLl.....",  //  6
        "..lLLLLLLLLll.....",  //  7
        "...lLLLlllll......",  //  8  bottom canopy fringe — perch row
        "....KKKKKK........",  //  9  clock slot, clear of foliage
        ".....TTTt.........",  // 10  upper trunk
        ".....TTTt.........",  // 11
        ".....TTTt.........",  // 12
        "....tTTTtt........",  // 13  trunk widens
        "...ttBBBttt.......",  // 14  root flare
    ]

    static let clockRowFromTop = 9
    static let clockColStart   = 4
    static let clockColEnd     = 9
    static let perchRowFromTop = 8
}

// MARK: - Cloud

enum CloudArt {
    // Every row is exactly 18 chars wide.
    // Two lobes with a visible saddle at row 3.
    // Flat bottom with shadow hem — no pixels below the hem row.
    static let pixels: [String] = [
        "....wwww..........",  //  0  left lobe top
        "...wWWWWww........",  //  1
        "..wWWWWWWWww......",  //  2  left lobe widens
        ".wwWWWWwWWWWww....",  //  3  saddle dip between lobes
        "wwWWWWWWWWWWWWww..",  //  4  widest — lobes merge
        "wwWWWWWWWWWWWWww..",  //  5
        ".wwWWWWWWWWWWww...",  //  6  taper
        "..wwwssssssswww...",  //  7  shadow hem, flat base
    ]
}

// MARK: - Layout

enum SceneLayout {
    static func layout(in bounds: CGRect, cloudCenterX: CGFloat) -> Layout {
        Layout(bounds: bounds, cloudCenterX: cloudCenterX)
    }

    struct Layout {
        let bounds: CGRect
        let cloud: CGRect
        let tree: CGRect
        let treeLeaves: CGRect
        let clock: CGRect
        let cloudPerch: CGPoint
        let treePerch: CGPoint

        init(bounds: CGRect, cloudCenterX: CGFloat) {
            self.bounds = bounds

            tree = CGRect(x: 10, y: 8, width: 104, height: bounds.height - 12)
            let metrics = SceneRenderer.treeMetrics(in: tree)

            let clockPixelRect = metrics.rectForSpriteRow(
                TreeArt.clockRowFromTop,
                colStart: TreeArt.clockColStart,
                colEnd: TreeArt.clockColEnd
            )
            clock = clockPixelRect.insetBy(dx: -6, dy: -4).offsetBy(dx: 0, dy: -6)

            let foliageTop = metrics.rectForSpriteRow(0, colStart: 0, colEnd: metrics.cols - 1)
            let foliageBottom = metrics.rectForSpriteRow(8, colStart: 0, colEnd: metrics.cols - 1)
            treeLeaves = CGRect(
                x: foliageTop.minX,
                y: foliageBottom.minY,
                width: foliageTop.width,
                height: foliageTop.maxY - foliageBottom.minY + metrics.pixelSize
            )

            let perchRect = metrics.rectForSpriteRow(
                TreeArt.perchRowFromTop,
                colStart: 2,
                colEnd: metrics.cols - 3
            )
            treePerch = CGPoint(
                x: perchRect.midX - Constants.owlSceneWidth / 2,
                y: perchRect.maxY
            )

            let cloudWidth = DockGeometry.cloudWidth
            cloud = CGRect(
                x: cloudCenterX - cloudWidth / 2,
                y: bounds.height - 62,
                width: cloudWidth,
                height: 50
            )
            cloudPerch = CGPoint(
                x: cloud.midX - Constants.owlSceneWidth / 2,
                y: cloud.minY + 6
            )
        }

        func owlRect(at position: CGPoint) -> CGRect {
            CGRect(
                x: position.x,
                y: position.y,
                width: Constants.owlSceneWidth,
                height: Constants.owlSceneHeight
            )
        }

        func hitTarget(at point: CGPoint, owlPosition: CGPoint, roost: OwlRoost) -> HitTarget {
            let owl = owlRect(at: owlPosition)
            if owl.contains(point) {
                return .owl
            }

            switch roost {
            case .cloud:
                if cloud.contains(point) {
                    return .cloud
                }
            case .tree:
                if treeLeaves.contains(point) || tree.contains(point) {
                    return .tree
                }
            }

            return .none
        }
    }
}

enum OwlRoost {
    case cloud
    case tree
}

enum HitTarget {
    case cloud
    case tree
    case owl
    case none
}