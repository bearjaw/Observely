
import os.log
@testable import Observely
import XCTest

final class ObservelyTests: XCTestCase {

    @Observable<[String]> var sut: [String] = []

    private let expectedValueAdded = "Marty McFly"

    override func tearDown() {
        super.tearDown()
        _sut.removeObserver(self)
        sut = []
        XCTAssert(_sut.observers.count == 0, "Someone's still subscribed ⚠️")
    }

    // MARK: - Test Adds an observer

    func testObserve_adds_an_observer() {
        XCTAssert(_sut.observers.count == 0, "Someone's still subscribed ⚠️")
        _sut.observe(self) { _ in }
        XCTAssert(_sut.observers.count == 1, "Someone didn't subscribe ❌")
    }

    // MARK: - Test Removes an observer

    func testRemoveObserver_removes_an_observer() {
        _sut.observe(self) { _ in }
        _sut.removeObserver(self)
        XCTAssert(_sut.observers.count == 0, "Someone's still subscribed ⚠️")
    }

    func testRemoveAllObservers_removes_all_observers() {
        _sut.observe(self) { _ in }

        let mock = NSObject()
        _sut.observe(mock) { _ in }

        XCTAssert(_sut.observers.count == 2, "Where are all the subscribers at ⚠️")
        _sut.removeAllObservers()
        XCTAssert(_sut.observers.count == 0, "Someone's still subscribed ⚠️")
    }

    // MARK: - Test Observing values

    func testObserve_observe_initial_empty_value() {
        let expectation = XCTestExpectation(description: "Executes with empty value initially")
        _sut.observe(self) { values in
            if values?.isEmpty == true {
                expectation.fulfill()
            } else {
                XCTFail("Expected items to be empty. But was \(values?.count ?? -1)")
            }
        }
        wait(for: [expectation], timeout: 0.1)
    }

    func testObserve_observe_initial_value() {
        let expectation = XCTestExpectation(description: "Executes with values initially")

        // Given

        sut = [expectedValueAdded]

        // When
        _sut.observe(self) { values in
            self.verify(values, with: expectation)
        }

        // Then
        wait(for: [expectation], timeout: 0)
    }

    func testObserve_observe_only_new_value() {

        let expectation = XCTestExpectation(description: "Executes with values initially")

        // Given
        _sut.observe(self, .new) { values in
            self.verify(values, with: expectation)
        }

        // When
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.sut = [self.expectedValueAdded]
        }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    // MARK: Clean up

    func testIncrement_mutability() {
        // Given
        let model = CounterMock()

        // Whem
        model.increment()

        // Then
        XCTAssertTrue(model.counter == 1, "Failed. Counter should be one. but was \(model.counter)")
    }

    func testDecrement_mutability() {
        // Given
        let model = CounterMock()

        // Whem
        model.decrement()

        // Then
        XCTAssertTrue(model.counter == -1, "Failed. Counter should be one. but was \(model.counter)")
    }

    func testStart_observing() {
        // Given
        let model = CounterMock()

        let expectation = XCTestExpectation(description: "Executes with values initially")

        // Whem
        model.start { value in
            XCTAssertTrue(value == 0, "Failed. Counter should be zero. but was \(value)")
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation], timeout: 0)
    }

    static var allTests = [
        ("testObserve_adds_an_observer", testObserve_adds_an_observer,
         "testObserve_observe_initial_value", testObserve_observe_initial_value,
         "testObserve_observe_initial_empty_value", testObserve_observe_initial_empty_value,
         "testObserve_observe_only_new_value", testObserve_observe_only_new_value,
         "testRemoveObserver_removes_an_observer", testRemoveObserver_removes_an_observer,
         "testRemoveAllObservers_removes_all_observers", testRemoveAllObservers_removes_all_observers,
         "testIncrement_mutability", testIncrement_mutability,
         "testDecrement_mutability", testDecrement_mutability,
         "testStart_observing", testStart_observing
         )
    ]
}

private extension ObservelyTests {

    func verify(_ values: [String]?, with expectation: XCTestExpectation) {
        if values?.contains(expectedValueAdded) == true  {
            expectation.fulfill()
        } else {
            XCTFail("Values have not been updated")
        }
    }

}

// MARK: - Test Data -

class CounterMock {

    @Observable private(set) var counter: Int = 0

    func start(onChange: @escaping (Int) -> Void) {
        _counter.observe(self) { value in
            if let value = value {
                os_log(.debug, "Step: %@", "\(value)")
            } else {
                os_log(.debug, "I'm empty.")
            }
            onChange(value ?? 0)
        }
    }

    func increment() {
        counter += 1
    }

    func decrement() {
        counter -= 1
    }

    deinit {
        os_log(.debug, "Gone. Bye 👋")
    }
}
