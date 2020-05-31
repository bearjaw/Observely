
import os.log
@testable import Observely
import XCTest

final class ObservelyTests: XCTestCase {

    static var allTests = [
    ]
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
