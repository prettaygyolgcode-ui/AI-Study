import CoreGraphics
import Testing
@testable import AI课堂

struct CanvasViewportStateTests {
    @Test
    func blankCanvasDragPansHorizontallyOnly() {
        var viewport = CanvasViewportState()

        viewport.updateHorizontalDrag(startOffset: 20, translationWidth: -75)

        #expect(viewport.horizontalOffset == -55)
    }
}
