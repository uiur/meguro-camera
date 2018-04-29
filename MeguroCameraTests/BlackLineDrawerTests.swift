import XCTest
import Vision
@testable import MeguroCamera

class BlackLineDrawerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testGravity() {
        let point = BlackLineDrawer.gravity(points: [
            CGPoint(x: 0.0, y: 0.0),
            CGPoint(x: 1.0, y: 1.0)
        ])
        XCTAssertEqual(point.x, 0.5)
        XCTAssertEqual(point.y, 0.5)
    }

    func testDraw() {
        let leftEye = [CGPoint(x: 0, y: 0)]
        let rightEye = [CGPoint(x: 1, y: 1)]

        BlackLineDrawer.draw(leftEyeRegion: leftEye, rightEyeRegion: rightEye)
    }
}
