import AppKit

enum OwlRenderer {
    static func draw(pose: OwlPose, in context: CGContext, bounds: CGRect) {
        context.interpolationQuality = .none
        context.setShouldAntialias(false)

        let rows = OwlSprites.pixels(for: pose)
        let grid = Constants.spriteSize

        var minRow = grid
        var maxRow = 0
        for (rowIndex, row) in rows.enumerated() {
            for character in row where character != "." && OwlPalette(rawValue: character)?.color != nil {
                minRow = min(minRow, rowIndex)
                maxRow = max(maxRow, rowIndex)
                break
            }
        }
        guard minRow <= maxRow else { return }

        let pixelWidth = bounds.width / CGFloat(grid)
        let pixelHeight = bounds.height / CGFloat(grid)
        let drawWidth = CGFloat(grid) * pixelWidth
        let originX = bounds.minX + (bounds.width - drawWidth) / 2
        // Feet sit on bounds.minY instead of floating inside empty padding.
        let originY = bounds.minY - CGFloat(grid - maxRow - 1) * pixelHeight

        for rowIndex in 0..<grid {
            let row = rows[rowIndex]
            for columnIndex in 0..<grid {
                let index = row.index(row.startIndex, offsetBy: columnIndex)
                let character = row[index]
                guard let palette = OwlPalette(rawValue: character),
                      let color = palette.color else { continue }

                let rect = CGRect(
                    x: originX + CGFloat(columnIndex) * pixelWidth,
                    y: originY + CGFloat(grid - rowIndex - 1) * pixelHeight,
                    width: pixelWidth,
                    height: pixelHeight
                )
                context.setFillColor(color.cgColor)
                context.fill(rect)
            }
        }
    }
}
