import XCTest
@testable import FoundationPlus

final class FoundationPlusTests: XCTestCase {
    @available(macOS 13.0, *)
    func testExample() async throws {

        let x = 5
        
        // How to ship an integer into class space.
        let speed = Measurement.miles(5) / .hours(3)
        print(speed)
        
        XCTAssertEqual(Length.convert(5, from: .meters, to: .centimeters), 500)
        XCTAssertEqual(Area.convert(1, from: .squareCentimeters, to: .squareMeters), 0.0001)
        XCTAssertEqual(Measurement.seconds(3) + .seconds(2), .seconds(5))
        XCTAssertEqual(Vector(dx: 5, dy: 5).angle.radians, Angle.convert(45, from: .degrees, to: .radians), accuracy: 0.01)
        XCTAssertEqual(sin(.degrees(90)), 1, accuracy: 0.01)
        XCTAssertEqual(([1, 2, 3] as CountedSet).symmetricDifference([3, 4, 5]), [1, 2, 5, 4])
        /* Nov 8 */ XCTAssertEqual(([1: "Hello", 2: "Goodbye"] as Cache)[1], "Hello")
        /* Nov 18 */ XCTAssertEqual(Measurement.meters(3) / .seconds(5), .metersPerSecond(3 / 5))
        /* Nov 18 */ XCTAssertEqual(Measurement.bytes(1).bits, 8.0)
        /* Nov 18 */ // XCTAssertEqual(5.formatted(.spellOut), "five")
    }
}



