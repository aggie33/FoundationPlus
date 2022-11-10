# FoundationPlus

Foundation, but better!

Here are some examples:

**To find a phone number in a string:**

```swift
// Foundation:
let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
let phoneNumber = detector.matches(in: "123-456-7890", range: NSRange(location: 0, length: 12)).first?.phoneNumber

// FoundationPlus:
let phoneNumber = "123-456-7890".phoneNumbers.first
```

**To find what day it is:**

```swift
// Foundation:
let currentDate = Date.now
let calendar = Calendar.current

let day = calendar.component(.day, from: currentDate)

// FoundationPlus:
let day = Date.now[.day]
```

**To find the number of times 3 appears in a set:**
```swift
// Foundation:
let set: NSCountedSet = NSCountedSet(array: [1, 2, 3, 3])
let count: Int = set.count(for: 3)

// FoundationPlus:
let set: CountedSet<Int> = [1, 2, 3, 3]
let count: Int = set.count(of: 3)
```

Not convinced? FoundationPlus will be updated to feature even more revamped Foundation types.
