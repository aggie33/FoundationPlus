# FoundationPlus

Foundation, but better!

Here are some examples:

To find a phone number in a string:

```swift

// Foundation:
let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
let phoneNumber = detector.matches(in: "123-456-7890", range: NSRange(location: 0, length: 12)).first?.phoneNumber

// FoundationPlus:
let phoneNumber = "123-456-7890".phoneNumbers.first

```

