import AppKit
import CoreGraphics

// MARK: - Anchor

enum PixelAnchor {
    case center
    case bottom
    case bottomLeading
}

// MARK: - Renderer

enum PixelArtRenderer {

    static func draw(
        rows: [String],
        in rect: CGRect,
        context: CGContext,
        anchor: PixelAnchor = .center
    ) {
        context.interpolationQuality = .none
        context.setShouldAntialias(false)

        let height = rows.count
        let width  = rows.first?.count ?? 0
        guard width > 0, height > 0 else { return }

        let pixelSize  = min(rect.width / CGFloat(width), rect.height / CGFloat(height))
        let drawWidth  = CGFloat(width)  * pixelSize
        let drawHeight = CGFloat(height) * pixelSize
        let originX: CGFloat = switch anchor {
        case .center, .bottom: rect.minX + (rect.width - drawWidth) / 2
        case .bottomLeading: rect.minX
        }
        let originY: CGFloat = switch anchor {
        case .center: rect.minY + (rect.height - drawHeight) / 2
        case .bottom, .bottomLeading: rect.minY
        }

        for (rowIndex, row) in rows.enumerated() {
            for (colIndex, char) in row.enumerated() {
                guard let palette = ScenePalette(rawValue: char),
                      let color   = palette.color else { continue }

                let block = CGRect(
                    x:      originX + CGFloat(colIndex)              * pixelSize,
                    y:      originY + CGFloat(height - rowIndex - 1) * pixelSize,
                    width:  pixelSize,
                    height: pixelSize
                )
                context.setFillColor(color.cgColor)
                context.fill(block)
            }
        }
    }

    static func metrics(
        rows: [String],
        in rect: CGRect,
        anchor: PixelAnchor = .bottom
    ) -> Metrics {
        let height     = rows.count
        let width      = rows.first?.count ?? 0
        let pixelSize  = min(rect.width / CGFloat(width), rect.height / CGFloat(height))
        let drawWidth  = CGFloat(width)  * pixelSize
        let drawHeight = CGFloat(height) * pixelSize
        let originX: CGFloat = switch anchor {
        case .center, .bottom: rect.minX + (rect.width - drawWidth) / 2
        case .bottomLeading: rect.minX
        }
        let originY: CGFloat = switch anchor {
        case .center: rect.minY + (rect.height - drawHeight) / 2
        case .bottom, .bottomLeading: rect.minY
        }
        return Metrics(
            pixelSize: pixelSize,
            originX:   originX,
            originY:   originY,
            rows:      height,
            cols:      width
        )
    }

    // MARK: Metrics

    struct Metrics {
        let pixelSize: CGFloat
        let originX:   CGFloat
        let originY:   CGFloat
        let rows:      Int
        let cols:      Int

        func rectForSpriteRow(
            _ rowIndexFromTop: Int,
            colStart: Int,
            colEnd: Int
        ) -> CGRect {
            CGRect(
                x:      originX + CGFloat(colStart)                    * pixelSize,
                y:      originY + CGFloat(rows - rowIndexFromTop - 1)  * pixelSize,
                width:  CGFloat(colEnd - colStart + 1)                 * pixelSize,
                height: pixelSize
            )
        }

        func contentBounds(
            pixelRows: [String],
            isSolid: (Character) -> Bool
        ) -> CGRect {
            var minRow = pixelRows.count
            var maxRow = 0
            var minCol = cols
            var maxCol = 0

            for (rowIndex, row) in pixelRows.enumerated() {
                for (colIndex, character) in row.enumerated() {
                    guard isSolid(character) else { continue }
                    minRow = min(minRow, rowIndex)
                    maxRow = max(maxRow, rowIndex)
                    minCol = min(minCol, colIndex)
                    maxCol = max(maxCol, colIndex)
                }
            }

            guard minRow <= maxRow, minCol <= maxCol else { return .zero }

            return CGRect(
                x: originX + CGFloat(minCol) * pixelSize,
                y: originY + CGFloat(rows - maxRow - 1) * pixelSize,
                width: CGFloat(maxCol - minCol + 1) * pixelSize,
                height: CGFloat(maxRow - minRow + 1) * pixelSize
            )
        }
    }
}

// MARK: - Scene

enum SceneRenderer {

    static func drawCloud(in rect: CGRect, context: CGContext) {
        PixelArtRenderer.draw(
            rows:    CloudArt.pixels,
            in:      rect,
            context: context,
            anchor:  .center
        )
    }

    static func treeMetrics(in rect: CGRect) -> PixelArtRenderer.Metrics {
        PixelArtRenderer.metrics(rows: TreeArt.pixels, in: rect, anchor: .bottomLeading)
    }

    static func cloudMetrics(in rect: CGRect) -> PixelArtRenderer.Metrics {
        PixelArtRenderer.metrics(rows: CloudArt.pixels, in: rect, anchor: .center)
    }

    static func solidScenePixel(_ character: Character) -> Bool {
        ScenePalette(rawValue: character)?.color != nil
    }

    static func drawTree(in rect: CGRect, context: CGContext) {
        PixelArtRenderer.draw(
            rows:    TreeArt.pixels,
            in:      rect,
            context: context,
            anchor:  .bottomLeading
        )
    }

    static func drawClock(text: String, in rect: CGRect, isActive: Bool) {
        let borderColor = isActive
            ? NSColor(calibratedRed: 0.38, green: 0.82, blue: 0.44, alpha: 1)
            : NSColor(calibratedRed: 0.55, green: 0.58, blue: 0.55, alpha: 1)
        let faceColor = NSColor(calibratedRed: 0.04, green: 0.10, blue: 0.06, alpha: 1)
        let textColor: NSColor = isActive
            ? NSColor(calibratedRed: 0.55, green: 1.0, blue: 0.62, alpha: 1)
            : NSColor(calibratedWhite: 0.88, alpha: 1)

        // Pixel-style block: outer border + dark face
        borderColor.setFill()
        NSBezierPath(rect: rect).fill()

        let inset: CGFloat = 2
        let face = NSRect(
            x: rect.minX + inset,
            y: rect.minY + inset,
            width: rect.width - inset * 2,
            height: rect.height - inset * 2
        )
        faceColor.setFill()
        NSBezierPath(rect: face).fill()

        let fontSize = max(11, min(14, rect.height * 0.62))
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedDigitSystemFont(ofSize: fontSize, weight: .bold),
            .foregroundColor: textColor,
        ]
        let size = (text as NSString).size(withAttributes: attributes)
        let point = NSPoint(
            x: rect.midX - size.width / 2,
            y: rect.midY - size.height / 2
        )
        (text as NSString).draw(at: point, withAttributes: attributes)
    }
}