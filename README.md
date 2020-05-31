# 📦 Observely

A simple property wrapper that offers observing a value over time.

## ⚠️ Disclaimer

This is just me playing around and this should probably not be used in production.

## Getting started

Consider the following counter class that can increment and decrement an `Int` by 1. 

```swift

class Counter {

    @Observable private(set) var counter: Int = 0
    
    // MARK: - Basic functionality
    
    func increment() {
         counter += 1
     }

     func decrement() {
         counter -= 1
     }
     
     // MARK: - Observe and react to changes

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

    deinit {
        os_log(.debug, "Gone. Bye 👋")
    }
}
```

Now we can observe our counter simply by accessing the wrapper and calling the `observe(observer:, option:, onChange:)`  function. The Counter wraps this call in it's own function `start(onChange:)`.

## 🚀 Further work 

- [] Thread safety
- [] Add possibilty to provide a queue to receive the updates from
- [] Further improvements along the road

