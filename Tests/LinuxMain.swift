import XCTest

import IncrementalTests

var tests = [XCTestCaseEntry]()
tests += IncrementalTests.allTests()
XCTMain(tests)
