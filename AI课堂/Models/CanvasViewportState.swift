import CoreGraphics

struct CanvasViewportState: Equatable {
    var horizontalOffset: CGFloat = 0

    mutating func updateHorizontalDrag(startOffset: CGFloat, translationWidth: CGFloat) {
        horizontalOffset = startOffset + translationWidth
    }
}
