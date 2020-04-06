import XCTest
@testable import Incremental


final class IncrementalTests: XCTestCase {
    func testWrite() {
        let x = Input(1)
        x.write(3)
        XCTAssert(x.i.value == 3)
    }

    func testPlus() {
        let x = Input(1)
        let added = x.i + x.i
        var values: [Int] = []
        var disposable: Disposable? = added.observe { value in
            values.append(value)
        }
        XCTAssertEqual(values, [2])
        x.write(2)
        XCTAssertEqual(values, [2, 4])
        disposable = nil
        x.write(3)
        XCTAssertEqual(values, [2, 4])
    }
}
