import XCTest
@testable import FoundationPlus

final class FoundationPlusTests: XCTestCase {
    @available(macOS 13.0, *)
    func testExample() async throws {
        XCTAssertEqual(Length.convert(5, from: .meters, to: .centimeters), 500)
        XCTAssertEqual(Area.convert(1, from: .squareCentimeters, to: .squareMeters), 0.0001)
        XCTAssertEqual(Duration.seconds(3) + .seconds(2), .seconds(5))
        XCTAssertEqual(Vector(dx: 5, dy: 5).angle.radians, Angle(degrees: 45).radians, accuracy: 0.01)
        XCTAssertEqual(sin(.degrees(90)), 1, accuracy: 0.01)
        XCTAssertEqual(([1, 2, 3] as CountedSet).symmetricDifference([3, 4, 5]), [1, 2, 5, 4])
        /* Nov 8 */ XCTAssertEqual(([1: "Hello", 2: "Goodbye"] as Cache)[1], "Hello")
    }
}
